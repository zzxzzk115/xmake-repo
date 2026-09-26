#include <vasset/vmesh.hpp>

int main()
{
    vasset::VMesh mesh;
    return vasset::loadMesh("nonexistent-package-consumer.vmesh", mesh) ? 1 : 0;
}
