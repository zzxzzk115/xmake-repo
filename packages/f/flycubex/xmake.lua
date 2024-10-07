package("flycubex")
    set_homepage("https://github.com/zzxzzk115/FlyCubeX")
    set_description("FlyCube with Xmake support.")

    add_urls("https://github.com/zzxzzk115/FlyCubeX.git")

	add_includedirs("include", "include/FlyCube")
    add_linkdirs("lib")

    add_deps("gli", "glm", "spirv-cross", "nowide_standalone")

    if is_plat("windows") then
        add_syslinks("d3d12", "dxgi", "dxguid")
        add_deps("directx-headers", "directxshadercompiler")
        add_defines("DIRECTX_SUPPORT", "NOMINMAX")
    elseif is_plat("linux") then
        add_syslinks("dl", "X11-xcb")
    elseif is_plat("macosx") then
        add_defines("METAL_SUPPORT")
    end

    add_links("FlyCubeX-lib")

    add_configs("build_apps", {description = "build example applications", default = false, type = "boolean"})
    add_configs("vulkan_support", {description = "enable vulkan support", default = true, type = "boolean"})
    
    on_load(function (package)
        if package:config("vulkan_support") then
            package:add_deps("vulkan-hpp", "vulkansdk")
            add_defines("VULKAN_SUPPORT")
        end
        local links = {"spirv-cross-c", "spirv-cross-cpp", "spirv-cross-reflect",
                       "spirv-cross-msl", "spirv-cross-util", "spirv-cross-hlsl",
                       "spirv-cross-glsl", "spirv-cross-core"}
        for _, link in ipairs(links) do
            if package:is_plat("windows") and package:is_debug() then
                link = link .. "d"
            end
            package:add("links", link)
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.build_apps = package:config("build_apps")
        configs.vulkan_support = package:config("vulkan_support")
        if package:config("shared") then
            configs.kind = "shared"
        end
        -- install
        import("package.tools.xmake").install(package, configs)
    end)