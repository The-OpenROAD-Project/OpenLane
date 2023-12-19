exec bash -c "set -e && \
    cd [file dirname [file normalize [info script]]]/reproducible && bash run.sh"
