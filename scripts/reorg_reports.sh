#!/bin/bash

# Handle generated timing reports
mkdir -p  $RUN_DIR/reports/routing/eco_$ECO_ITER
rsync -vt $RUN_DIR/reports/routing/* \
          $RUN_DIR/reports/routing/eco_$ECO_ITER
find $RUN_DIR/reports/routing -maxdepth 1 -type f -delete
