// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: J. Callenes
// // 
// // Create Date: 06/07/2018 04:21:54 PM
// // Design Name: 
// // Module Name: ProgCount
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////

// parameter LINE_LENGTH = 31; 

// typedef input [LINE_LENGTH : 0] line_i;
// typedef output logic [LINE_LENGTH : 0] line_o;
// typedef logic [LINE_LENGTH : 0] line;

// module prefetcher (
//     parameter queue_len = 15;    
// )
// (
//     input clk_i, // clk signal

//     line_i addr_i, // incoming addr from l2 cache
//     line_o addr_o, // outgoing addr from prefetch to processor
// );
    
//     // queue data structure
//     line address_queue [$:queue_len];

//     /* cases to be aware of: 
//     *      - inserting into a full queue  
//     *      - popping from an empty queue
//     *      - flushing the queue on branch misprediction (another module)?
//     */
//     always_ff @(posedge clk_i) begin
//         address_queue.insert(addr_i);
//         addr_o = address_queue.front();
//     end


//     /*

//     something about bootloader code here

//     */
    
// endmodule
