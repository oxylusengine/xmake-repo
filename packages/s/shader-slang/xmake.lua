package("shader-slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    if is_host("windows") then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-windows-x86_64.tar.gz",
            {version = function (version) return version:gsub("v", "") end})

        add_versions("v2025.10.4", "f4199d9cb32f93410444713adfe880da2b665a9e13f2f8e23fdbff06068a9ff3")
        add_versions("v2025.12.1", "02018cc923a46c434e23b166ef13c14165b0a0c4b863279731c4f6c4898fbf8e")
        add_versions("v2025.15.1", "cabaaecf1727040e4b24dfe015c303a709f5dd2d68d5a3dd2b73a50828f29fc5")
    elseif is_host("linux") then
        if is_arch("x86_64") then

            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-x86_64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.10.4", "c2edcfdada38feb345725613c516a842700437f6fa55910b567b9058c415ce8f")
            add_versions("v2025.12.1", "8f34b98391562ce6f97d899e934645e2c4466a02e66b69f69651ff1468553b27")
            add_versions("v2025.15.1", "df3834d350beee7d6f14b8f38ee164038e8b11e70b17e2544fbf49a4d532ddb3")
        end

        if is_arch("arm64") then
            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-aarch64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.10.4", "c2edcfdada38feb345725613c516a842700437f6fa55910b567b9058c415ce8f")
            add_versions("v2025.12.1", "d42edf9e778a63f532a25ae8b9f37e02ee7daa68e3e6e5d884b7ad0956ef253d")
            add_versions("v2025.15.1", "c9ecffb085dfe0027135b73032fc04d74a31206b766779d61547c7e30e747af4")
        end
    elseif is_host("macosx") then
        if is_arch("arm64") then
            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-aarch64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.12.1", "205c6f61f6357ba3472551fa48d922f8220836c757d9b9059133938bdade02ae")
            add_versions("v2025.15.1", "459e197bf0f379c37b83d7d13885858ab9d17614ae56fc22f5a1af76614ecd06")
        end

        if is_arch("x86_64") then
            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-x86_64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.12.1", "6c36eeb4dea30c614da90b970a998da8460c04688aa1ef60b673c23da424bb2a")
            add_versions("v2025.15.1", "8ca046224defe4574efcca2ad863b14a3a703bf57da490e095e97f5d5907489c")
        end
    end

    on_install("windows|x64", "macosx|x86_64", "macosx|arm64", "linux|x86_64", "linux|arm64", function (package)
        os.cp("include/*.h", package:installdir("include"))

        if package:is_plat("windows") then
            os.trycp("lib/slang.*", package:installdir("lib"))
            os.trycp("bin/slang.*", package:installdir("lib"))
        else
            os.trycp("lib/libslang.*", package:installdir("lib"))
            os.trycp("bin/libslang.*", package:installdir("lib"))
        end

        os.trycp("lib/libslang-glslang.*", package:installdir("modules"))
        os.trycp("bin/libslang-glslang.*", package:installdir("modules"))

        os.trycp("lib/*slang-glslang.*", package:installdir("modules"))
        os.trycp("bin/*slang-glslang.*", package:installdir("modules"))

        os.trycp("lib/*slang-glsl-module.*", package:installdir("modules"))
        os.trycp("bin/*slang-glsl-module.*", package:installdir("modules"))

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

