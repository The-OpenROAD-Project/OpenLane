`default_nettype none
module inverter (
    input wire in,
    output out );

    assign out = !in;

endmodule
