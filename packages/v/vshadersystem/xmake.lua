package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vshadersystem.git")

    add_versions("v0.6.1", "04f61b49321e944b933ecce8f4c4b8b0eca07771d9a254d42340d5d31ec2395c")

    add_deps("spirv-cross vulkan-sdk-1.4.309", {configs = { shared = true, debug = false }, system = false})
    add_deps("glslang 1.4.309+0", {configs = { debug = false }, system = false})
    add_deps("xxhash")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        local configs = {
            vshadersystem_build_examples = false,
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vshadersystem/system.hpp>
            #include <iostream>

            using namespace vshadersystem;

            int main()
            {
                const char* source = R"(

            #version 460

            #pragma vultra material

            #pragma vultra param baseColor default(1,1,1,1)

            layout(location = 0) out vec4 outColor;

            void main()
            {
                outColor = vec4(1,0,0,1);
            }

            )";

                BuildRequest req;

                req.source.virtualPath = "test.frag.vshader";
                req.source.sourceText  = source;

                req.options.stage = ShaderStage::eFrag;

                auto r = build_single_shader(req);

                if (!r.isOk())
                    return 1;

                if (r.value().binary.spirv.empty())
                    return 1;

                return 0;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
