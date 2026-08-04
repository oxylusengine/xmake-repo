rule("install_shaders")
    after_build(function (target)
        local oxylus_pkg = target:pkg("oxylus")
        if oxylus_pkg then
            local output_dir = target:extraconf("rules", "@oxylus/install_shaders", "output_dir") or ""
            local shader_src = path.join(oxylus_pkg:installdir(), "shared", "shaders")
            local shader_dst = path.join(target:targetdir(), output_dir)

            local packs = os.files(path.join(shader_src, "*.oxpack"))
            assert(#packs > 0, "@oxylus/install_shaders: no .oxpack in " .. shader_src ..
                ", reinstall the oxylus package (packs are not built when cross compiling)")

            os.mkdir(shader_dst)
            for _, pack in ipairs(packs) do
                os.cp(pack, shader_dst)
            end
        end
    end)

