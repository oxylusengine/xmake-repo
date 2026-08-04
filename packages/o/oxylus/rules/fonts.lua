rule("install_fonts")
    after_build(function (target)
        local oxylus_pkg = target:pkg("oxylus")
        if oxylus_pkg then
            local output_dir = target:extraconf("rules", "@oxylus/install_fonts", "output_dir") or ""
            local font_src = path.join(oxylus_pkg:installdir(), "shared", "fonts")
            local font_dst = path.join(target:targetdir(), output_dir)

            os.mkdir(font_dst)
            os.cp(font_src .. "/*", font_dst)
        end
    end)

