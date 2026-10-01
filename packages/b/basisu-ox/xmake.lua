package("basisu-ox")
    set_homepage("https://github.com/BinomialLLC/basis_universal")
    set_description("Basis Universal GPU texture codec: image loading, BC/ASTC encoding, and KTX2/DDS transcoding")
    set_license("Apache-2.0")

    -- upstream tags releases as v2_50, xmake versions need the dot
    add_urls("https://github.com/BinomialLLC/basis_universal/archive/refs/tags/v$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "_")
    end})
    add_urls("https://github.com/BinomialLLC/basis_universal.git")

    add_versions("2.50", "216e49e1f4213d4bfa4afaa07527e16bac28533dddd444197d3aa19230ac130c")

    add_configs("sse", {description = "Use the SSE4.1 kernels.", default = is_arch("x86_64", "x64", "x86", "i386"), type = "boolean"})
    add_configs("opencl", {description = "Enable the OpenCL ETC1S encoder.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build the basisu command line tool.", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("zstd")

    on_load(function (package)
        if package:config("opencl") then
            package:add("deps", "opencl")
        end
        -- basisu_enc.h reads this, so consumers have to see the value the library was built with
        package:add("defines", "BASISU_SUPPORT_SSE=" .. (package:config("sse") and "1" or "0"))
    end)

    on_install("windows|x64", "windows|arm64", "mingw|x86_64", "macosx", "linux", function (package)
        -- zstd comes from its own package rather than the bundled amalgamation, so a consumer that also links zstd
        -- doesn't end up with two copies of it
        for _, file in ipairs({"encoder/basisu_comp.cpp", "encoder/basisu_xbc7_encode.cpp",
                               "encoder/basisu_astc_ldr_encode.cpp", "transcoder/basisu_transcoder.cpp"}) do
            io.replace(file, "../zstd/zstd.h", "zstd.h", {plain = true})
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {
            sse = package:config("sse"),
            opencl = package:config("opencl"),
            tools = package:config("tools"),
        })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                basisu::basisu_encoder_init();
                basist::basisu_transcoder_init();
                basisu::image img(4, 4);
                basisu::image resized(2, 2);
                basisu::image_resample(img, resized);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"basisu/encoder/basisu_enc.h", "basisu/transcoder/basisu_transcoder.h"}}))
    end)
