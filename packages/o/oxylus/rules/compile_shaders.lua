-- Downstream counterpart of the engine's own `ox.compile_shaders`: feeds a TOML shader manifest
-- to the rcli shipped inside the oxylus package and drops an .oxpack next to the binary, which
-- the project loads with AssetFile::unpack + RenderContext::create_pipeline.
rule("compile_shaders")
    -- .slang is claimed so a blanket add_files("./Assets/**") does not trip xmake's "unknown
    -- source file"; the sources are compiled through the manifest, not one file at a time.
    set_extensions(".toml", ".slang")
    on_buildcmd_file(function (target, batchcmds, sourcefile, opt)
        if path.extension(sourcefile) ~= ".toml" then
            return
        end

        local oxylus_pkg = target:pkg("oxylus")
        if not oxylus_pkg then
            return
        end

        local config_path = path.absolute(sourcefile)
        local config_dir = path.directory(config_path)

        local output_dir = target:extraconf("rules", "@oxylus/compile_shaders", "output_dir") or ""
        local output_name = target:extraconf("rules", "@oxylus/compile_shaders", "output_name")
            or (path.basename(sourcefile) .. ".oxpack")

        local rcli = path.join(oxylus_pkg:installdir(), "bin", "rcli")
        if is_plat("windows") then
            rcli = rcli .. ".exe"
        end
        assert(os.isfile(rcli), "@oxylus/compile_shaders: rcli not found at " .. rcli ..
            ", reinstall the oxylus package (rcli is not built when cross compiling)")

        -- So project shaders can `import common` / `#include <fullscreen.slang>`.
        local engine_shaders = path.join(oxylus_pkg:installdir(), "shared", "shader_sources")
        local abs_output = path.absolute(path.join(target:targetdir(), output_dir, output_name))

        local args = {
            "--config", config_path,
            "--output", abs_output,
            "--include-dir", engine_shaders,
        }

        batchcmds:show_progress(opt.progress,
            "${color.build.object}compiling shaders from %s -> %s",
            path.filename(config_path), output_name)
        batchcmds:mkdir(path.directory(abs_output))
        batchcmds:vrunv(rcli, args)

        batchcmds:add_depfiles(sourcefile)
        batchcmds:add_depfiles(rcli)

        -- Register each program's .slang as a dependency so editing one retriggers a compile.
        -- Engine modules pulled in by import/#include are not tracked; they only change when
        -- the oxylus package itself is updated, which reinstalls rcli and invalidates anyway.
        local root_dir = nil
        local config_text = io.readfile(config_path)
        for line in config_text:gmatch("[^\r\n]+") do
            local rd = line:match('^%s*root_directory%s*=%s*"([^"]+)"')
            if rd then
                root_dir = path.absolute(path.join(config_dir, rd))
            end
            local p = line:match('^%s*path%s*=%s*"([^"]+)"')
            if p and root_dir then
                local slang_file = path.absolute(path.join(root_dir, p))
                if os.isfile(slang_file) then
                    batchcmds:add_depfiles(slang_file)
                end
            end
        end

        batchcmds:set_depmtime(os.mtime(abs_output))
        batchcmds:set_depcache(target:dependfile(abs_output))
    end)
