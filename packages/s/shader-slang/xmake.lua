package("shader-slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    add_urls("https://github.com/shader-slang/slang.git", { submodules = false })

    add_versions("v2025.15.1", "74c39eaa3dbd6ca55a383afca51ec18962838f08")
    add_versions("v2025.24.2", "ca70f001276c8a0ea16629b9d53ba6077da462d6")

    add_deps("cmake")
    add_deps("miniz", {system = false})
    add_deps("lz4 v1.10.0", {system = false})
    add_deps("spirv-headers 1.4.309+0")
    add_deps("unordered_dense")
    add_deps("lua_static v5.4.7")

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
        io.replace("cmake/SlangTarget.cmake", [[set_property(TARGET ${target} PROPERTY SUFFIX ".dylib")]], "", {plain = true})
        -- GET THE SLOPWARE OUT OF MY FUCKING COMPILER
        -- io.replace("source/standard-modules/CMakeLists.txt", [[add_subdirectory(neural)]], "", {plain = true})
        io.replace("CMakeLists.txt", [[add_subdirectory(source/slang-glsl-module)]], "", {plain = true})
        -- io.replace("CMakeLists.txt", [[add_library(lz4_static ALIAS LZ4::lz4)]], "add_library(lz4 ALIAS lz4::lz4)", {plain = true})
        io.replace("CMakeLists.txt", [[add_subdirectory(external)]], "", {plain = true})

        local lua = package:dep("lua_static"):fetch()

        local configs = {
            "-DSLANG_ENABLE_TESTS=OFF",
            "-DSLANG_ENABLE_EXAMPLES=OFF",
            "-DSLANG_USE_SYSTEM_MINIZ=ON",
            "-DSLANG_USE_SYSTEM_LZ4=ON",
            "-DSLANG_USE_SYSTEM_SPIRV_HEADERS=ON",
            "-DSLANG_USE_SYSTEM_UNORDERED_DENSE=ON",
            "-DSLANG_USE_SYSTEM_VULKAN_HEADERS=OFF",
            "-DSLANG_USE_SYSTEM_SPIRV_TOOLS=OFF",
            "-DSLANG_USE_SYSTEM_GLSLANG=OFF",
            "-DSLANG_OVERRIDE_LUA_PATH=" .. table.concat(lua.includedirs or lua.sysincludedirs, ";"),

            "-DSLANG_ENABLE_DXIL=OFF",
            "-DSLANG_ENABLE_PREBUILT_BINARIES=OFF",
            "-DSLANG_ENABLE_GFX=OFF",
            "-DSLANG_ENABLE_SLANGD=OFF",
            "-DSLANG_ENABLE_SLANGC=OFF",
            "-DSLANG_ENABLE_SLANGI=OFF",
            "-DSLANG_ENABLE_SLANGRT=OFF",
            "-DSLANG_ENABLE_SLANG_GLSLANG=OFF",
            "-DSLANG_ENABLE_SLANG_RHI=OFF",
            "-DSLANG_ENABLE_REPLAYER=OFF",
            "-DSLANG_SLANG_LLVM_FLAVOR=DISABLE",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSLANG_LIB_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))

        import("package.tools.cmake").install(package, configs, {packagedeps = {"lz4"}})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            #include <slang-com-ptr.h>
            #include <slang.h>

            void test() {
                Slang::ComPtr<slang::IGlobalSession> global_session;
                slang::createGlobalSession(global_session.writeRef());
            }
        ]] }, {configs = {languages = "c++17"}}))
    end)
package_end()
