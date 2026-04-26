package("vuk")
    set_homepage("https://github.com/martty")
    set_license("MIT")

    add_urls("https://github.com/martty/vuk.git")

    add_versions("2025.09.14.2", "87bd224ea4110b7b909b12ace60ace960330e6e9")
    add_versions("2026.04.26", "c399bcd9d42e1b0282f007c8aa1bb3019c760f35")

    add_configs("debug_allocations", { description = "Debug VMA allocations", default = false, type = "boolean" })

    add_deps("spirv-cross 1.4.309+0")
    add_deps("function2")

    on_load(function (package)
        if package:config("debug_allocations") then
            package:add("defines", "VUK_DEBUG_ALLOCATIONS=1")
        end
    end)

    on_install("windows|x64", "macosx|x86_64", "macosx|arm64", "linux|x86_64", "linux|arm64", function (package)
        local configs = {}
        configs.debug_allocations = package:config("debug_allocations")
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")

        import("package.tools.xmake").install(package, configs)

        os.cp("include/vuk", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("function2/function2.hpp"))
    end)
package_end()

