-- Downstream counterpart of the engine's own `ox.cook_assets`: runs the rcli shipped inside the oxylus package over
-- the project's asset directory, so a game ships without the editor ever running. It cooks models and textures into
-- `<targetdir>/<output_dir>` and writes the assets.oxmanifest AssetManager registers everything from at startup.
--
--   add_rules("@oxylus/cook_assets", { root_dir = os.scriptdir() .. "/Assets" })
--
-- `output_dir` defaults to Assets/.cooked, which is where App mounts VFS::COOKED_DIR. A cook writes an .oxasset
-- sidecar for any asset that lacks one, commit those so their UUIDs stay put.
rule("cook_assets")
    after_build(function (target)
        import("core.project.depend")

        local oxylus_pkg = target:pkg("oxylus")
        if not oxylus_pkg then
            return
        end

        -- the package was built without rcli runs, see its compile_resources config
        if oxylus_pkg:requireconf("configs", "compile_resources") == false then
            return
        end

        local root_dir = target:extraconf("rules", "@oxylus/cook_assets", "root_dir")
        assert(root_dir, "@oxylus/cook_assets: set `root_dir` to the project's asset directory")
        root_dir = path.absolute(root_dir)

        local output_dir = target:extraconf("rules", "@oxylus/cook_assets", "output_dir") or "Assets/.cooked"
        local abs_output = path.absolute(path.join(target:targetdir(), output_dir))

        local rcli = path.join(oxylus_pkg:installdir(), "bin", "rcli")
        if is_plat("windows") then
            rcli = rcli .. ".exe"
        end
        assert(os.isfile(rcli), "@oxylus/cook_assets: rcli not found at " .. rcli ..
            ", reinstall the oxylus package (rcli is not built when cross compiling)")

        -- rcli skips a warm asset on its own, this only saves walking the tree when nothing moved. The file list goes
        -- in `values` too: mtimes alone never notice a file that was added or removed.
        local sources = os.files(path.join(root_dir, "**"))
        table.sort(sources)
        depend.on_changed(function ()
            cprint("${color.build.object}cooking assets %s -> %s", root_dir, abs_output)
            os.vrunv(rcli, {"--cook-assets", root_dir, "--output", abs_output})
        end, {
            dependfile = target:dependfile("oxylus_cook_assets"),
            files = table.join(sources, {rcli}),
            values = table.join({abs_output}, sources),
            changed = not os.isfile(path.join(abs_output, "assets.oxmanifest")),
        })
    end)
