-- Downstream counterpart of the engine's own `ox.publish_csharp`: publishes a game's C# project with NativeAOT into
-- `<targetdir>/<output_dir>` and installs the library next to the game, so it runs with no .NET installed. The project
-- builds against the Oxylus.Scripting the package installed rather than whatever SDK its Oxylus.props names.
--
--   add_rules("@oxylus/publish_csharp", {
--       project = os.scriptdir() .. "/Scripts/Pong.csproj",
--       asset_dir = os.scriptdir() .. "/Assets",
--   })
--
-- `asset_dir` is where the project's .cs files live, `output_dir` defaults to "scripts". NativeAOT can't cross compile
-- between operating systems, so each platform publishes its own.
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
            target:extraconf("rules", "@oxylus/publish_csharp", "output_dir") or "scripts"))
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
            dotnet.publish_aot(target, project, output_dir, {
                "-p:OxylusSdkDir=" .. path.unix(sdk_dir) .. "/",
                "-p:OxylusAssetDir=" .. path.unix(asset_dir) .. "/",
                -- a game needs no culture data or exception message resources, and trades size for speed
                "-p:InvariantGlobalization=true",
                "-p:UseSystemResourceKeys=true",
                "-p:OptimizationPreference=Speed",
            })
        end, {
            dependfile = target:dependfile("oxylus_publish_csharp"),
            files = sources,
            values = table.join({ output_dir }, sources),
            changed = not os.isdir(output_dir),
        })
    end)

    after_install(function (target)
        local output_dir = target:extraconf("rules", "@oxylus/publish_csharp", "output_dir") or "scripts"
        local published = path.join(target:targetdir(), output_dir)
        local destination = path.join(target:installdir(), output_dir)
        os.mkdir(destination)
        -- the library alone, the debug symbols and import library the publish leaves next to it don't ship
        local libraries = table.join(os.files(path.join(published, "*.dll")), os.files(path.join(published, "*.so")),
            os.files(path.join(published, "*.dylib")))
        for _, library in ipairs(libraries) do
            os.vcp(library, destination)
        end
    end)
