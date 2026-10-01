-- Replaces upstream's CMakeLists, which has no install rules and sets its flags globally.
option("sse", {default = false})
option("opencl", {default = false})
option("tools", {default = false})

add_rules("mode.debug", "mode.release")
set_languages("c++17")

add_requires("zstd")
if has_config("opencl") then
    add_requires("opencl")
end

target("basisu")
    set_kind("$(kind)")
    add_packages("zstd")

    -- the wasm bindings are the only encoder sources that aren't part of the library
    add_files("encoder/*.cpp|basisu_wasm_api.cpp|basisu_wasm_transcoder_api.cpp",
              "encoder/3rdparty/android_astc_decomp.cpp",
              "transcoder/basisu_transcoder.cpp")
    -- headers include each other as ../transcoder/..., so both directories keep their layout under basisu/
    add_headerfiles("(encoder/*.h)", "(encoder/*.inl)", "(transcoder/*.h)", "(transcoder/*.inc)", "(transcoder/*.inl)",
                    {prefixdir = "basisu"})

    add_defines("BASISD_SUPPORT_KTX2_ZSTD=1", "BASISU_SUPPORT_ASTCENC=0")

    if has_config("sse") then
        add_defines("BASISU_SUPPORT_SSE=1", {public = true})
        if not is_plat("windows") then
            add_cxflags("-msse4.1")
        end
    else
        add_defines("BASISU_SUPPORT_SSE=0", {public = true})
    end

    if has_config("opencl") then
        add_packages("opencl")
        add_defines("BASISU_SUPPORT_OPENCL=1")
    end

    if not is_plat("windows") then
        -- the codecs type-pun block data, upstream always builds with this
        add_cxflags("-fno-strict-aliasing")
        add_defines("_LARGEFILE64_SOURCE=1", "_FILE_OFFSET_BITS=64")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

if has_config("tools") then
    target("basisu_tool")
        set_kind("binary")
        set_basename("basisu")
        add_files("basisu_tool.cpp", "basisu_text_image.cpp")
        add_deps("basisu")
        add_packages("zstd")
        add_defines("BASISD_SUPPORT_KTX2_ZSTD=1")
end
