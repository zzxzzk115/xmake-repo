package("vplot")
    set_homepage("https://github.com/zzxzzk115/vplot")
    set_description("Publication-quality plotting behind a pure C ABI: matplotlib's rendering stack ported to C++23, exportable to PNG/SVG/PDF or drawn live into an ImGui panel.")
    set_license("MIT")

    -- Upstream tags carry no "v" prefix, so $(version) is the tag verbatim.
    add_urls("https://github.com/zzxzzk115/vplot/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vplot.git", {alias = "git"})

    add_versions("source:0.1.0", "d6d33103ae1fbf4b381f5d5b3ed44042503d1d0eebb7d1e8880ef034a99ff61b")
    add_versions("git:0.1.0", "0.1.0")

    -- Agg is vendored (matplotlib's patched 2.4 snapshot, deliberately not the `agg` package --
    -- see vplot's external/xmake.lua) and builds as its own static target, so it installs as a
    -- second library that consumers have to link. vplot before agg: link order matters for
    -- static archives on ld.
    add_links("vplot", "agg")

    on_load(function (package)
        -- Both are linked INTO the static vplot archive's users, not into vplot itself, so they
        -- have to be public or the consumer's link fails on freetype/zlib symbols.
        local dep_configs = {}
        if package:is_plat("windows") and package:runtimes() then
            dep_configs.runtimes = package:runtimes()
        end
        package:add("deps", "freetype", {system = false, configs = dep_configs, public = true})
        package:add("deps", "zlib", {configs = dep_configs, public = true})
    end)

    on_install(function (package)
        local configs = {vplot_build_examples = false, vplot_build_tests = false}
        if package:is_plat("windows") and package:runtimes() then
            configs.runtimes = package:runtimes()
        end
        import("package.tools.xmake").install(package, configs)

        -- vplot declares no add_headerfiles, so `xmake install` ships the archives and nothing
        -- else. The public C ABI lives in include/vpl; copy it ourselves rather than patching
        -- upstream, so this package works against the 0.1.0 tag as released.
        os.cp("include/vpl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("vpl/vpl.h"))
        -- Links as well as compiles: the point of the check is that the vendored agg archive and
        -- the freetype/zlib deps all resolve, which a header-only probe would not catch.
        assert(package:check_cxxsnippets({test = [[
            #include <vpl/vpl.h>
            void test() {
                VplFigureDesc desc{};
                VplFigure* figure = nullptr;
                vplCreateFigure(&desc, &figure);
                vplDestroyFigure(figure);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
