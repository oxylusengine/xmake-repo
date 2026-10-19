package("vir")
    set_homepage("https://github.com/oxylusengine/vir")
    set_description("Vulkan Intermediate Representation, a render graph for modern Vulkan")
    set_license("MIT")

    add_urls("https://github.com/oxylusengine/vir.git")

    add_versions("2026.10.19", "cd4949b2fed17a0d2578ed8b1e2407438af9ca41")

    add_deps("vulkan-headers", "vulkan-memory-allocator", "fmt", "unordered_dense", "svector", "tracy")

    on_install("windows|x64", "macosx|x86_64", "macosx|arm64", "linux|x86_64", "linux|arm64", function (package)
        import("package.tools.xmake").install(package, {tests = false})
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("include"), "vir", "Module.hpp")))
    end)
package_end()
