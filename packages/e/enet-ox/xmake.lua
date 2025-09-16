package("enet-ox")
    set_homepage("https://github.com/zpl-c/enet")
    set_description("ENet reliable UDP networking library")
    set_license("MIT")

    add_urls("https://github.com/zpl-c/enet/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zpl-c/enet.git")

    add_versions("v2.6.5", "8647b6eaea881c86471ae29f732620d299fc20d7")

    if is_plat("windows", "mingw") then
        add_syslinks("winmm", "ws2_32")
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENET_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENET_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DENET_TEST=" .. (package:config("test") and "ON" or "OFF"))
        table.insert(configs, "-DENET_USE_MORE_PEERS=" .. (package:config("use_more_peers") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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