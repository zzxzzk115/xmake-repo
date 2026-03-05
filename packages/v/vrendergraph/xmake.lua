package("vrendergraph")
    set_homepage("https://github.com/zzxzzk115/vrendergraph")
    set_description("vrendergraph is a tiny data-driven render pipeline layer that builds a runtime FrameGraph from JSON.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vrendergraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vrendergraph.git")

    add_versions("v0.2.0", "510b67c4bd6096c377d5561334bace54a0ac72b33a8d1352e19d6c2b82694229")

    add_deps("fg", "nlohmann_json", {system = false})

    on_install(function (package)
        local configs = {
            vrendergraph_build_examples = false,
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vrendergraph/vrendergraph.hpp>

            using namespace vrendergraph;

            int main()
            {
                FrameGraph           fg;
                FrameGraphBlackboard bb;

                vrendergraph::RenderGraphRegistry registry;

                // Build graph
                vrendergraph::RenderGraph rg(registry, [](FrameGraph& fg, std::string_view name) -> FrameGraphResource {
                    FrameGraphResource res;
                    return res;
                });

                RenderGraphDesc desc{};
                rg.build(fg, bb, desc);

                fg.compile();
                fg.execute();
                return 0;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
