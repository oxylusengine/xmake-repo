package("imguizmo-ox")
    set_homepage("https://github.com/CedricGuillemet/ImGuizmo")
    set_description("Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui")
    set_license("MIT")

    add_urls("https://github.com/CedricGuillemet/ImGuizmo.git")
    add_versions("1.84+wip", "df1c30142e7c3fb13c171aaeb328bb338fa7aaa6")

    -- imgui 1.92.8 swapped 'thickness' and 'flags' on AddPolyline() and moved
    -- ImDrawFlags_Closed to 1 << 9, so upstream's `true` argument now lands in
    -- 'flags' as an invalid bit and the polyline is dropped with a user error
    add_patches("1.84+wip", "patches/1.84+wip/imgui-1.92.8-drawflags.patch", "548d5f09857656f9b73ab99528cba3db44c193bc5ff8e1514436fc2395d0e025")

    add_configs("wchar32", {description = "Use 32-bit ImWchar to match Dear ImGui", default = false, type = "boolean"})
    add_configs("imgui_version", {description = "Dear ImGui version to build against", type = "string"})

    on_load(function (package)
        -- the patch above targets the post-1.92.8 signature
        package:add("deps", "imgui", {
            version = package:config("imgui_version") or ">=1.92.8",
            configs = {wchar32 = package:config("wchar32")}
        })
    end)

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        local imgui = package:dep("imgui")
        local configs = imgui:requireinfo().configs
        if configs then
            configs = string.serialize(configs, {strip = true, indent = false})
        end
        local xmake_lua = ([[
            add_rules("mode.debug", "mode.release")
            set_languages("c++14")

            add_requires("imgui %s", {configs = %s})

            target("imguizmo")
                set_kind("$(kind)")
                add_defines("IMGUI_DEFINE_MATH_OPERATORS")
                add_files("*.cpp")
                add_headerfiles("*.h")
                add_packages("imgui")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]]):format(imgui:version_str(), configs)
        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ImGuiIO& io = ImGui::GetIO();
                ImGuizmo::SetRect(0, 0, io.DisplaySize.x, io.DisplaySize.y);
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"imgui.h", "ImGuizmo.h"}}))
    end)
