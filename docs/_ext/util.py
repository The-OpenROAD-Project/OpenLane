import os


def debug(*args, **kwargs):
    if os.getenv("SPHINX_BUILD_SILENT") != "1":
        print(*args, **kwargs)
