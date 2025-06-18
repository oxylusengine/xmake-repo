package("oxylus")
    set_homepage("https://github.com/oxylusengine/Oxylus")
    set_description("Vulkan based game engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/oxylusengine/Oxylus.git")

    add_versions("v1.0.0", "1d460f68950df56ee81fb52e6c0bee8861f26d4f")

    set_policy("package.strict_compatibility", true)

    add_configs("lua_bindings", {description = "Enable lua bindings", default = true, type = "boolean"})
    add_configs("profile", {description = "Enable tracy profiling", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {}
        configs.lua_bindings = package:config("lua_bindings")
        configs.profile = package:config("profile")
        import("package.tools.xmake").install(package, configs)
        os.cp("Oxylus/include/", package:installdir("include"))
    end)
