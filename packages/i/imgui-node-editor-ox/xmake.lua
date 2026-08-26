package("imgui-node-editor-ox")
    set_homepage("https://github.com/thedmd/imgui-node-editor")
    set_description("Node Editor built using Dear ImGui")
    set_license("MIT")

    add_urls("https://github.com/thedmd/imgui-node-editor.git")
    add_versions("0.9.4+wip", "021aa0ea4da13fed864bafb2a92d4c5205076866")

    -- libc++ does not pull std::terminate in transitively, imgui 1.92.8 swapped
    -- 'thickness' and 'flags' on PathStroke(), and imgui >= 1.92 already defines
    -- operator*(float, ImVec2) under IMGUI_DEFINE_MATH_OPERATORS
    add_patches("0.9.4+wip", "patches/0.9.4+wip/libcxx-imgui-1.92.patch", "73af7d28d3cdb41c9322e6104c44219c1a9ce2eaf88917de25ad5e8c5b526f34")

    add_configs("wchar32", {description = "Use 32-bit ImWchar to match Dear ImGui", default = false, type = "boolean"})
    add_configs("imgui_version", {description = "Dear ImGui version to build against", type = "string"})

    on_load(function (package)
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

            target("imgui-node-editor")
                set_kind("$(kind)")
                add_defines("IMGUI_DEFINE_MATH_OPERATORS")
                add_files("crude_json.cpp", "imgui_canvas.cpp", "imgui_node_editor.cpp", "imgui_node_editor_api.cpp")
                add_headerfiles("(*.h)", "(*.inl)", {prefixdir = "imgui-node-editor"})
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
                ax::NodeEditor::Config config;
                ax::NodeEditor::EditorContext* ctx = ax::NodeEditor::CreateEditor(&config);
                ax::NodeEditor::DestroyEditor(ctx);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"imgui.h", "imgui-node-editor/imgui_node_editor.h"}}))
    end)
