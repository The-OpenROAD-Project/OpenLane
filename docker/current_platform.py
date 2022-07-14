import sys
import platform


def current_docker_platform() -> str:
    arch = platform.machine()

    if arch in ["x86_64", "amd64"]:
        return "amd64"
    elif arch in ["aarch64", "arm64"]:
        return "arm64v8"
    elif arch in ["ppc64le"]:
        return "ppc64le"
    else:
        print(
            f"Unsupported architecture '{platform.machine()}' Falling back to x86-64 for Docker.",
            file=sys.stderr,
        )
        return "amd64"


if __name__ == "__main__":
    print(current_docker_platform(), end="")
