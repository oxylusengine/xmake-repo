package("enet")
    set_homepage("https://github.com/zpl-c/enet")
    set_description("ENet reliable UDP networking library")
    set_license("MIT")

    add_urls("https://github.com/zpl-c/enet/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zpl-c/enet.git")

    add_versions("v2.6.5", "8647b6eaea881c86471ae29f732620d299fc20d7")

    if is_plat("windows", "mingw") then
        add_syslinks("winmm", "ws2_32")
    end

    on_load("windows", "mingw", function (package)
        if package:config("shared") then
            package:add("defines", "ENET_DLL")
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.examples = false
        import("package.tools.xmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                if (enet_initialize () != 0)
                    return;

                ENetAddress address;
                ENetHost* server;
                enet_address_build_any(&address, ENET_ADDRESS_TYPE_IPV6);
                address.port = 1234;
                server = enet_host_create (ENET_ADDRESS_TYPE_ANY, &address, 32, 2, 0, 0);
                if (server == NULL)
                    return;

                ENetEvent event;
                while (enet_host_service (server, &event, 1000) > 0);

                enet_host_destroy(server);
                enet_deinitialize();
            }
        ]]}, {includes = {"enet/include/enet.h"}}))
    end)