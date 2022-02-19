BEGIN {  # Print power and standard_input definitions
    printf "%s power 1.8\n", vdd;
    printf "%s power 0.0\n", gnd;
    printf "#define std_input min@%s max@%s\n", gnd, vdd;
}
$1 == "input" {  # Print input nets
    gsub(/;/, "");
    if ( $2 == vdd || $2 == gnd ) {  # ignore power nets
        next;
    }
    if ( NF == 3 ) {  # print buses as net[range]
        $2 = $3 $2;
    }
    print $2, "input std_input";
}