# LAZ-72 integration consumer

This consumer uses immutable Git commits, not new release tags:

- VRI #19: `8500248c843908076fc490f725342b959699259a`
- VRI-Framework #11: `b9db9278b8b8cdeb8edc5fd26ceff355f2cae705`
- vasset #4: `340e64a4c654a23cd6a15ee5798cb8fd2acc1c44`

Run from this directory:

```sh
xmake f -y -m release
xmake build -y shader-package-consumer
xmake run shader-package-consumer
xmake show -l packages
```

The test links the installed vasset importer and Framework, cooks a shader through
vasset, loads both desktop and web libraries through Framework, and requires an
invalid shader to fail compilation. Generated inputs live in `shader-consumer/`.
All shader package references must resolve to v1.2.1 with `vshaderc_lib=true`;
matching versions alone is insufficient if the compiler configuration differs.

Existing release tags retain their old shader dependencies. The development pins
must be updated together with their upstream acceptance evidence. This consumer
does not replace Engine tests, GPU rendering checks, or release-package acceptance.
