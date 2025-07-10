package("imguizmo-lr")
    set_homepage("https://github.com/Hatrickek/ImGuizmo")
    set_description("Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui")

    add_urls("https://github.com/Hatrickek/ImGuizmo.git")

    add_versions("v1.91.8-docking", "a0bf889bcaebee8f110f2ebcf851a2d273d4bf89")

    on_load(function (package)
        local v = package:version()
        package:add("deps", "imgui " .. v)
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
                set_kind("static")
                add_files("*.cpp")
                add_headerfiles("*.h")
                add_packages("imgui")
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
package_end()
