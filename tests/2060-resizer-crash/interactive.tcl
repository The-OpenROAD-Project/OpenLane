exec bash -c "set -e && \
    cd [file dirname [file normalize [info script]]]/reproducible && \
    cd \$(dirname \$(realpath run.sh)) && bash run.sh"
