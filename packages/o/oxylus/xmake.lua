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

    add_deps("stb 2024.06.01", {system = false})
    add_deps("miniaudio 0.11.25", {system = false})
    add_deps("fastgltf-ox v0.8.0", {system = false})
    add_deps("meshoptimizer v1.2", {system = false})
    add_deps("libsdl3 3.4.12", {})
    add_deps("ktx-ox v4.4.0", {system=false})
    add_deps("shader-slang v2026.12.2", {system=false})
    add_deps("enet-ox v2.6.5", {configs={test=false,use_more_peers=false}})
    add_deps("flecs v4.1.5")
    add_deps("imgui 42e91c315534a15133fb08fb8108cfdd515e0912", {configs={wchar32=true}})
    add_deps("vk-bootstrap v1.4.354", {debug=false,system=false})
    add_deps("vuk 2026.07.2", {configs={debug_allocations=false}})
    add_deps("unordered_dense v4.8.1")
    add_deps("tracy v0.13.1", {configs={code_transfer=true,tracy_enable=false,callstack_inlines=false,on_demand=true,system_tracing=true,exit=true,callstack=true}})
    add_deps("fmt 12.1.0", {configs={shared=false,header_only=false},system=false})
    add_deps("plf_colony v7.41")
    add_deps("simdutf v8.2.0")
    add_deps("joltphysics-ox v5.5.0", {configs={avx2=true,debug_renderer=true,tzcnt=true,sse4_1=true,sse4_2=true,avx=true,rtti=true,lzcnt=true}})
    add_deps("glm 1.0.3", {configs={header_only=true,cxx_standard="20"},system=false})
    add_deps("sol2 c1f95a773c6f8f4fde8ca3efe872e7286afe4444", {configs = { includes_lua = false }})
    add_deps("lua v5.4.7")
    add_deps("toml++ v3.4.0")
    add_deps("loguru v2.1.0", {configs={fmt=true},system=false})
    add_deps("simdjson v4.2.4")
    add_deps("svector v1.0.3")
    add_deps("zpp_bits v4.7.1")
    add_deps("rmlui f7b297e2c8fc44c5e85df498dbae91762c0769a5", {configs={shared=false,lua=true},system=false})

    add_defines(
        "GLM_ENABLE_EXPERIMENTAL",
        "GLM_FORCE_DEPTH_ZERO_TO_ONE",
        { public = true })

    if is_plat("windows") then
        add_defines("_UNICODE", { force = true, public = true  })
        add_defines("UNICODE", { force = true, public = true  })
        add_defines("WIN32_LEAN_AND_MEAN", { force = true, public = true  })
        add_defines("VC_EXTRALEAN", { force = true, public = true  })
        add_defines("NOMINMAX", { force = true, public = true  })
        add_defines("_WIN32", { force = true, public = true  })
        add_defines("_CRT_SECURE_NO_WARNINGS", { force = true, public = true  })
        add_defines("OX_PLATFORM_WINDOWS", { public = true })
    elseif is_plat("linux") then
        add_defines("OX_PLATFORM_LINUX", { public = true })
    elseif is_plat("macosx") then
        add_defines("OX_PLATFORM_MACOSX", { public = true })
    end

    if is_mode("debug")  then
        add_defines("OX_DEBUG", { public = true })
        add_defines("_DEBUG", { public = true })
    elseif is_mode("release") or is_mode("releasedbg") then
        add_defines("OX_RELEASE", { public = true })
        add_defines("NDEBUG", { public = true })
    elseif is_mode("dist") then
        add_defines("OX_DISTRIBUTION", { public = true })
        add_defines("NDEBUG", { public = true })
    end

    if is_plat("windows") then
        add_cxxflags(
            "/permissive-",
            "/EHsc",
            "/bigobj",
            "-wd4100",
            "/Zc:preprocessor",
            { public = true })
    end

    on_install(function (package)
        local configs = {}
        configs.lua_bindings = package:config("lua_bindings")
        configs.profile = package:config("profile")
        configs.tests = package:config("tests")
        configs.editor = false
        import("package.tools.xmake").install(package, configs)
        os.cp("Oxylus/include", package:installdir())

        local shader_dst = package:installdir("shared", "shaders")
        os.mkdir(shader_dst)

        -- RmlUI loads no font by default, so consumers have nothing to render text with
        -- unless they ship their own. These live under the editor tree but are not
        -- editor-only, so hand them to consumers through @oxylus/install_fonts.
        local font_src = "OxylusEditor/Assets/Fonts"
        local font_dst = package:installdir("shared", "fonts")
        os.cp(font_src .. "/*", font_dst)

        -- rcli is linked with $ORIGIN as its runpath, but libResourceCompiler lands in
        -- lib/, so keep a copy next to the executable to make it runnable from installdir.
        local bindir = package:installdir("bin")
        if not package:is_plat("windows") then
            os.trycp(path.join(package:installdir("lib"), "libResourceCompiler.*"), bindir)
        end

        -- Renderer::init loads a compiled engine.oxpack, so build it here. It is the only
        -- shader artifact consumers get; the raw slang sources are not shipped.
        if not package:is_cross() then
            os.vrunv(path.join(bindir, "rcli"), {
                "--config", path.absolute("OxylusEditor/Assets/engine.toml"),
                "--output", path.join(shader_dst, "engine.oxpack"),
            })
        end
    end)
