package("vgfw")
    set_homepage("https://github.com/zzxzzk115/vgfw")
    set_description("VGFW (V Graphics FrameWork) is a header-only library designed for rapidly creating graphics prototypes.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vgfw/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vgfw.git")
	
    add_versions("v1.2.1", "044c69d785a315d6f3c39d8a74359d2d6ae6b98bbe616ea3ec398bf5efb7457d")
    add_versions("v1.2.0", "53eb5460d1d234dad7daf0c83e9c74638563babeecf8bf1cd817d57a10d8b0ad")
	add_versions("v1.1.1", "51dfda6e280523ea50c59a2f7ff5a325f196b157d598709a6f145071c91b6160")
	
	add_configs("examples", {description = "Build examples", default = false, type = "boolean"})

    add_deps("fg", "glfw", "glm", "spdlog", "stb", "tinyobjloader", "tinygltf")
	add_deps("imgui v1.90.8-docking", {configs = {glfw = true, opengl3 = true, wchar32 = true}})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_load(function (package)
        if not package:version() or package:version():ge("1.2.0") then
            package:add("deps", "glad v0.1.36", {configs = {api = "gl=4.6", profile = "core"}})
        else
            package:add("deps", "glad")
        end
    end)

    on_install("windows", "linux", function (package)
		local configs = {
			examples = package:config("examples")
		}
        import("package.tools.xmake").install(package, configs)
    end)
