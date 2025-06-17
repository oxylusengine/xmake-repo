package("oxylus")
    set_homepage("https://github.com/oxylusengine/Oxylus")
    set_description("Vulkan based game engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/oxylusengine/Oxylus.git")

    add_versions("v1.0.0", "6e602ab13afb8028bb6c58a2cfb6414687b90a2a")

    set_policy("package.strict_compatibility", true)

    add_configs("lua_bindings", {description = "Enable lua bindings", default = false, type = "boolean"})
    add_configs("profile", {description = "Enable tracy profiling", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {}
        configs.lua_bindings = package:config("lua_bindings")
        configs.profile = package:config("profile")
        import("package.tools.xmake").install(package, configs)
    end)
