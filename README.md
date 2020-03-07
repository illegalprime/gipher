# gipher

make GIFs from scanning subtitle tracks on videos

```bash
# build it
nix-build -E '(import <nixpkgs> {}).callPackage ./. {}'

# run it
result/bin/gipher  PATH_TO_VIDEO  OUTPUT_FILE

# play it
open OUTPUT_FILE.gif
```

