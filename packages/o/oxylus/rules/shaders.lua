rule("install_shaders")
    after_build(function (target)
        local oxylus_pkg = target:pkg("oxylus")
        if oxylus_pkg then
            local output_dir = target:extraconf("rules", "@oxylus/install_shaders", "output_dir") or ""
            local shader_src = path.join(oxylus_pkg:installdir(), "shared", "shaders")
            local shader_dst = path.join(target:targetdir(), output_dir)

            ox.mkdir(shader_dst)
            os.cp(shader_src .. "/*", shader_dst)
        end
    end)

