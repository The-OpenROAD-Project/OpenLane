import sys


def current_nix_system(arch: str) -> str:
    return {"amd64": "x86_64-linux", "arm64v8": "aarch64-linux"}[arch]


if __name__ == "__main__":
    print(current_nix_system(*sys.argv[1:]), end="")
