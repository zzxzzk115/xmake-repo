#include <vasset/vasset_importers.hpp>
#include <vasset/vasset_registry.hpp>
#include <vrf/gpu/shader_library.hpp>

#include <filesystem>
#include <fstream>
#include <iostream>

int main()
{
    std::filesystem::create_directories("shader-consumer/source");
    std::filesystem::create_directories("shader-consumer/imported");
    {
        std::ofstream manifest("shader-consumer/smoke.vshaderlib.lua");
        manifest << "return { name = \"smoke\", root = \"source\", shaders = {\"*.vshader\"} }\n";
        std::ofstream shader("shader-consumer/source/smoke.vshader");
        shader << "[shader(\"fragment\")]\n"
                  "float4 fragmentMain() : SV_Target0 { return float4(1, 0, 0, 1); }\n";
    }
    vasset::VAssetRegistry registry {};
    registry.setAssetRootPath("shader-consumer");
    registry.setImportedFolderName("imported");
    vasset::VAssetImporter importer {registry};
    if (!importer.importOrReimportAsset("shader-consumer/smoke.vshaderlib.lua", true)
        || registry.getRegistry().size() != 1)
        return 1;
    auto output = std::filesystem::path("shader-consumer") / registry.getRegistry().begin()->second.importedPath;
    for (const char* extension : {".vshlib", ".vshweblib"})
    {
        output.replace_extension(extension);
        if (!vrf::ShaderLibrary::LoadFromFile(output.string()))
            return 2;
    }
    {
        std::ofstream shader("shader-consumer/source/smoke.vshader");
        shader << "this is not valid Slang;\n";
    }
    if (importer.importOrReimportAsset("shader-consumer/smoke.vshaderlib.lua", true))
        return 3;
    std::cout << "vasset cook -> vrf load (desktop/web) and invalid-source rejection PASS\n";
}
