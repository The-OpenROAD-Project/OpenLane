#!/bin/bash

# Handle generated spefs/defs
mkdir -p  $RUN_DIR/results/routing/eco_$ECO_ITER/def
mkdir -p  $RUN_DIR/results/routing/eco_$ECO_ITER/spef
mkdir -p  $RUN_DIR/results/routing/eco_$ECO_ITER/sdf

# Breakpoint to see if dirs are generated
# exit 111
# rsync -av $RUN_DIR/results/routing/*.def  \
#     $RUN_DIR/results/routing/eco_$ECO_ITER/def
# rsync -av $RUN_DIR/results/routing/*.spef \
#     $RUN_DIR/results/routing/eco_$ECO_ITER/spef
# rsync -av $RUN_DIR/results/routing/*.sdf  \
#     $RUN_DIR/results/routing/eco_$ECO_ITER/sdf

