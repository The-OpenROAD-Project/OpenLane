/Black-box entry subcircuit/ {  # remove black-box defintions
    while ( $1 != ".ends" ) {
        getline;
    }
    getline;
}
/^\*/ {  # remove comments
    next;
}
/^.ENDS .*/ {  # remove name from ends lines
    print $1;
    next;
}
 {
    print $0;
}