package("shader-slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    if is_host("windows") then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-windows-x86_64.tar.gz",
            {version = function (version) return version:gsub("v", "") end})

        add_versions("v2025.10.4", "f4199d9cb32f93410444713adfe880da2b665a9e13f2f8e23fdbff06068a9ff3")
        add_versions("v2025.12.1", "02018cc923a46c434e23b166ef13c14165b0a0c4b863279731c4f6c4898fbf8e")
        add_versions("v2025.15.1", "c1c94c182480df4d2914731b280d5e6ae9ea3677fdf8871a4e46abc4ef81d976")
        add_versions("v2026.12.2", "a234a47e8c499080b28cd55e5490cbcc396754d44f823952607ba25d95d25b94")
    elseif is_host("linux") then
        if is_arch("x86_64") then

            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-x86_64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.10.4", "c2edcfdada38feb345725613c516a842700437f6fa55910b567b9058c415ce8f")
            add_versions("v2025.12.1", "8f34b98391562ce6f97d899e934645e2c4466a02e66b69f69651ff1468553b27")
            add_versions("v2025.15.1", "df3834d350beee7d6f14b8f38ee164038e8b11e70b17e2544fbf49a4d532ddb3")
            add_versions("v2026.12.2", "5533415953112ddeb0a935755bdd2da5de530e6528a560a32ad809c9d9faf29c")
        end

        if is_arch("arm64") then
            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-aarch64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.10.4", "c2edcfdada38feb345725613c516a842700437f6fa55910b567b9058c415ce8f")
            add_versions("v2025.12.1", "d42edf9e778a63f532a25ae8b9f37e02ee7daa68e3e6e5d884b7ad0956ef253d")
            add_versions("v2025.15.1", "c9ecffb085dfe0027135b73032fc04d74a31206b766779d61547c7e30e747af4")
            add_versions("v2026.12.2", "42e2c649e5b7d1e05e466210ee3314232538604053323d1e3e2f32af81faef08")
        end
    elseif is_host("macosx") then
        if is_arch("arm64") then
            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-aarch64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.12.1", "205c6f61f6357ba3472551fa48d922f8220836c757d9b9059133938bdade02ae")
            add_versions("v2025.15.1", "459e197bf0f379c37b83d7d13885858ab9d17614ae56fc22f5a1af76614ecd06")
            add_versions("v2026.12.2", "de919ef0d616a8dba86fa8443bb25975492936872cb261094c1a152522b3b495")
        end

        if is_arch("x86_64") then
            add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-x86_64.tar.gz",
                {version = function (version) return version:gsub("v", "") end})

            add_versions("v2025.12.1", "6c36eeb4dea30c614da90b970a998da8460c04688aa1ef60b673c23da424bb2a")
            add_versions("v2025.15.1", "8ca046224defe4574efcca2ad863b14a3a703bf57da490e095e97f5d5907489c")
            add_versions("v2026.12.2", "e0bdbd8cc39c8d0b9f7a0308d93f4f5d004af27d71aa131d7b173768fe3f70eb")
        end
    end

    on_install("windows|x64", "macosx|x86_64", "macosx|arm64", "linux|x86_64", "linux|arm64", function (package)
        os.cp("include/*.h", package:installdir("include"))

        os.trycp("lib/*slang-compiler.*", package:installdir("lib"))
        os.trycp("bin/*slang-compiler.*", package:installdir("lib"))

        os.trycp("lib/*slang-glslang*", package:installdir("modules"))
        os.trycp("bin/*slang-glslang*", package:installdir("modules"))

        os.trycp("lib/*slang-glsl-module*", package:installdir("modules"))
        os.trycp("bin/*slang-glsl-module*", package:installdir("modules"))

        -- slang ships libslang-compiler.so, not libshader-slang.so, so the
        -- link name does not match the package name and xmake's auto-rpath
        -- detection does not kick in. Declare everything explicitly. The
        -- rpath must be absolute because a bare "lib" would be resolved
        -- relative to the process cwd, not the package installdir.
        package:add("links", "slang-compiler")
        package:add("linkdirs", "lib")
        if package:is_plat("linux", "macosx") then
            package:add("rpathdirs", package:installdir("lib"))
        end

        -- slang looks up its backend modules (glslang, glsl-module) via PATH.
        package:addenv("PATH", "bin")
        package:addenv("PATH", "modules")
    end)

package_end()
