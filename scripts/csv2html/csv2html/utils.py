"""
utils file include helper function
"""
import pathlib


def get_static_folder(file_name):
    p = pathlib.Path('.')
    return pathlib.PosixPath(str(p) +'/scripts/csv2html/csv2html/static/'+str(file_name))
