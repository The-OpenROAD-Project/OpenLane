#!/usr/bin/python3

import os
import sys


def get_design_path(design):
    path = os.path.abspath(design) + '/'
    if not os.path.exists(path):
        path = os.path.join(
            os.getcwd(),
            './designs/{design}/'.format(
                design=design
            )
        )
    if os.path.exists(path):
        return path
    else:
        return None

def get_run_path(design, tag):
    DEFAULT_PATH = os.path.join(
        get_design_path(design),
        'runs/{tag}/'.format(
            tag=tag
        )
    )

    return DEFAULT_PATH
