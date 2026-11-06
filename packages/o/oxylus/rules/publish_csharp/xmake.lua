-- Downstream counterpart of the engine's own `ox.publish_csharp`: publishes a game's C# project with NativeAOT and
-- copies the library into `<targetdir>/<output_dir>`, by default next to the executable with the game's other shared
-- libraries, and installs it the same way, so it runs with no .NET installed. The library is named after the project.
-- The project builds against the Oxylus.Scripting the package installed rather than whatever SDK its Oxylus.props
-- names.
--
--   add_rules("@oxylus/publish_csharp", {
--       project = os.scriptdir() .. "/Scripts/Pong.csproj",
--       asset_dir = os.scriptdir() .. "/Assets",
--   })
--
-- `asset_dir` is where the project's .cs files live. NativeAOT can't cross compile between operating systems, so each
-- platform publishes its own.
rule("publish_csharp")
    after_build(function (target)
        import("core.project.depend")

        local oxylus_pkg = target:pkg("oxylus")
        if not oxylus_pkg then
            return
        end

        assert(oxylus_pkg:requireconf("configs", "csharp") ~= false,
            "@oxylus/publish_csharp: the oxylus package was built with csharp = false")

        local project = target:extraconf("rules", "@oxylus/publish_csharp", "project")
        local asset_dir = target:extraconf("rules", "@oxylus/publish_csharp", "asset_dir")
        assert(project and asset_dir, "@oxylus/publish_csharp: set `project` to the .csproj and `asset_dir` to the assets")
        project = path.absolute(project)
        asset_dir = path.absolute(asset_dir)

        local output_dir = path.absolute(path.join(target:targetdir(),
            target:extraconf("rules", "@oxylus/publish_csharp", "output_dir") or "."))
        local library = path.basename(project)
            .. (target:is_plat("windows") and ".dll" or target:is_plat("macosx") and ".dylib" or ".so")
        -- on the side, the pdb and import library a publish leaves would overwrite the executable's own next to it
        local publish_dir = path.absolute(path.join(target:autogendir(), "publish_csharp"))
        local sdk_dir = path.join(oxylus_pkg:installdir(), "managed")
        local dotnet = import("dotnet", { rootdir = path.join(oxylus_pkg:installdir(), "xmake"), anonymous = true })

        -- the editor writes Oxylus.props when it opens the project, a checkout that never was has none yet. Both
        -- properties are passed to the publish anyway, so either one's paths do
        local props = path.join(path.directory(project), "Oxylus.props")
        if not os.isfile(props) then
            io.writefile(props, format([[<Project>
  <!-- written by the Oxylus editor every time the project opens, edit the csproj instead. A game's build sets both
       properties itself and imports the Oxylus.Sdk.props its engine package installed -->
  <PropertyGroup>
    <OxylusSdkDir>%s/</OxylusSdkDir>
    <OxylusAssetDir>%s/</OxylusAssetDir>
  </PropertyGroup>

  <Import Project="$(OxylusSdkDir)Oxylus.Sdk.props" />
</Project>
]], path.unix(sdk_dir), path.unix(asset_dir)))
        end

        local sources = table.join(
            os.files(path.join(path.directory(project), "**.cs|bin/**|obj/**")),
            os.files(path.join(path.directory(project), "*.csproj")),
            os.files(path.join(asset_dir, "**.cs")),
            os.files(path.join(sdk_dir, "*")))
        table.sort(sources)

        depend.on_changed(function ()
            cprint("${color.build.object}publishing C# %s with NativeAOT", path.filename(project))
            dotnet.publish_aot(target, project, publish_dir, {
                "-p:OxylusSdkDir=" .. path.unix(sdk_dir) .. "/",
                "-p:OxylusAssetDir=" .. path.unix(asset_dir) .. "/",
                -- a game needs no culture data or exception message resources, and trades size for speed
                "-p:InvariantGlobalization=true",
                "-p:UseSystemResourceKeys=true",
                "-p:OptimizationPreference=Speed",
            })
            os.vcp(path.join(publish_dir, library), path.join(output_dir, library))
        end, {
            dependfile = target:dependfile("oxylus_publish_csharp"),
            files = sources,
            values = table.join({ output_dir }, sources),
            changed = not os.isfile(path.join(output_dir, library)),
        })
    end)

    after_install(function (target)
        local output_dir = target:extraconf("rules", "@oxylus/publish_csharp", "output_dir") or "."
        local library = path.basename(target:extraconf("rules", "@oxylus/publish_csharp", "project"))
            .. (target:is_plat("windows") and ".dll" or target:is_plat("macosx") and ".dylib" or ".so")
        -- bindir, App::with_scripts is relative to the executable wherever an install puts that
        os.vcp(path.join(target:targetdir(), output_dir, library), path.join(target:bindir(), output_dir, library))
    end)
