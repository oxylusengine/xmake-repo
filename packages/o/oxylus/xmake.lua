package("oxylus")
    set_homepage("https://github.com/oxylusengine/Oxylus")
    set_description("Vulkan based game engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/oxylusengine/Oxylus.git")

    add_versions("v1.0.0", "b0065989683130888eeb036fab8524b854d1ff78")

    set_policy("package.strict_compatibility", true)

    add_configs("lua_bindings", {description = "Enable lua bindings", default = true, type = "boolean"})
    add_configs("profile", {description = "Enable tracy profiling", default = false, type = "boolean"})
    add_configs("tests", {description = "Enable tests", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {}
        configs.lua_bindings = package:config("lua_bindings")
        configs.profile = package:config("profile")
        configs.tests = package:config("tests")
        import("package.tools.xmake").install(package, configs)
        os.cp("Oxylus/include", package:installdir())

        local shader_src = "Oxylus/src/Render/Shaders"
        local shader_dst = package:installdir("shared", "shaders")
        os.cp(shader_src .. "/*", shader_dst)
    end)
