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

    add_deps("stb 2024.06.01", { system = false })
    add_deps("miniaudio 0.11.22", { system = false })
    add_deps("fastgltf-ox v0.8.0", { system = false })
    add_deps("meshoptimizer v0.22", { system = false })
    add_deps("libsdl3")
    add_deps("ktx-ox v4.4.0", { system = false })
    add_deps("shader-slang v2025.15.1", { system = false })
    add_deps("enet-ox v2.6.5", { configs = { test = false, use_more_peers = false } })
    add_deps("flecs-ox v4.1.0")
    add_deps("imgui v1.92.0-docking", {configs={wchar32=true}})
    add_deps("vk-bootstrap v1.4.307", {debug=false,system=false})
    add_deps("vuk 2025.09.14.2", {configs={debug_allocations=false},debug=true,private=false})
    add_deps("unordered_dense v4.5.0")
    add_deps("tracy v0.12.2", {configs={code_transfer=true,tracy_enable=false,callstack_inlines=false,on_demand=true,system_tracing=true,exit=true,callstack=true}})
    add_deps("fmt 12.0.0", {configs={shared=false,header_only=false},system=false})
    add_deps("plf_colony v7.41")
    add_deps("simdutf v6.2.0")
    add_deps("joltphysics-ox v5.4.0+fix", {configs={avx2=true,debug_renderer=true,tzcnt=true,sse4_1=true,sse4_2=true,avx=true,rtti=true,lzcnt=true,enable_floating_point_exceptions=false}})
    add_deps("glm 1.0.1", {configs={header_only=true,cxx_standard="20"},system=false})
    add_deps("sol2 c1f95a773c6f8f4fde8ca3efe872e7286afe4444")
    add_deps("toml++ v3.4.0")
    add_deps("loguru v2.1.0", {configs={fmt=true},system=false})
    add_deps("simdjson-ox v3.12.2")

    add_defines(
        "GLM_ENABLE_EXPERIMENTAL",
        "GLM_FORCE_DEPTH_ZERO_TO_ONE",
        { public = true })

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
