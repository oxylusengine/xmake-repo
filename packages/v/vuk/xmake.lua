package("vuk")
    set_homepage("https://github.com/martty")
    set_license("MIT")

    add_urls("https://github.com/oxylusengine/vuk.git")

    add_versions("2025.09.14.2", "87bd224ea4110b7b909b12ace60ace960330e6e9")
    add_versions("2026.05.03", "61abde9ddff60a38b792f193ba60c39e068c1eae")
    add_versions("2026.05.10", "2d67e3d9cd3951419082c163e6f570a040684df1")
    add_versions("2026.07.2", "d68e263806aad7660e05d56339a9540d553e4eba")
    add_versions("2026.08.16", "ab16226ce3ff31288b6a5c0c87907da41b1a6372")
    add_versions("2026.08.16.1", "0515ad1daff9092ec66eb0a1672b040bb6473b23")
    add_versions("2026.08.17", "e5d01dd49557da070f84dcfeecee7a5fbceef373")
    add_versions("2026.8.17.1", "dfd22ccbd1071665f31600f322eb64201ced1873")
    add_versions("2026.08.17.2", "8eafd64ed90eb1ea468ebd2fdc83043a899adf93")

    add_patches("2026.07.2", "patches/2026.07.2/make-ret-index-sequence.patch",
        "54ffce12a5261f3e304b2766273b53322260c953461d947f09f3e50dad2ebc16")

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

