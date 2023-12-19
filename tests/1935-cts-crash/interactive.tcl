exec bash -c "set -e && \
    cd [file dirname [file normalize [info script]]]/reproducible && \ 
    tar xvf issue.tar.gz && cd issue_reproducible && bash run.sh"
