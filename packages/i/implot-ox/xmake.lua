package("implot-ox")
    set_homepage("https://github.com/epezent/implot")
    set_description("Immediate Mode Plotting")
    set_license("MIT")

    add_urls("https://github.com/epezent/implot/archive/refs/tags/$(version).tar.gz",
             "https://github.com/epezent/implot.git")

    add_versions("v1.0", "e4a9db64eef7bcc604e2a5ea380af124eb97aa3e8a6a96330079c88add0f7e93")
    add_versions("v0.17", "0aa3ff4fb97e553608e6758e77980eedf01745628fe6c025e647f941ae674127")
    add_versions("v0.16", "961df327d8a756304d1b0a67316eebdb1111d13d559f0d3415114ec0eb30abd1")
    add_versions("v0.15", "3df87e67a1e28db86828059363d78972a298cd403ba1f5780c1040e03dfa2672")

    add_configs("wchar32", {description = "Use 32-bit ImWchar to match Dear ImGui", default = false, type = "boolean"})
    add_configs("imgui_version", {description = "Dear ImGui version to build against", type = "string"})

    on_load(function (package)
        local imgui_version = package:config("imgui_version")
        local version = package:version()
        if not imgui_version and version and version:lt("0.17") then
            imgui_version = "<=1.91"
        end
        package:add("deps", "imgui", {
            version = imgui_version,
            configs = {wchar32 = package:config("wchar32")}
        })
    end)

    on_install(function (package)
        local imgui = package:dep("imgui")
        local configs = imgui:requireinfo().configs or {}
        local xmake_lua = ([[
            add_rules("mode.release", "mode.debug")
            add_requires("imgui %s", {configs = %s})
            target("implot")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("*.cpp|implot_demo.cpp")
                add_headerfiles("*.h")
                add_packages("imgui")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]]):format(imgui:version_str(), string.serialize(configs, {strip = true, indent = false}))
        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <implot.h>
            void test() {
                ImPlot::CreateContext();
                ImPlot::DestroyContext();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
