package("flecs-ox")
    set_homepage("https://github.com/SanderMertens/flecs")
    set_description("A fast entity component system (ECS) for C & C++")
    set_license("MIT")

    add_urls("https://github.com/SanderMertens/flecs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SanderMertens/flecs.git")

    add_versions("v4.1.0", "9e06477db0fdf9317bf583ff4b1318622283165f")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("bsd") then
        add_syslinks("execinfo", "pthread")
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "flecs_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFLECS_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DFLECS_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFLECS_PIC=" .. (package:config("pic") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        local pdb = path.join(package:buildir(), "flecs.pdb")
        os.trycp(pdb, package:installdir(package:config("shared") and "bin" or "lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                flecs::world ecs;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "flecs.h"}))
    end)