module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output reg sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

/* wire reg declaration*/
reg dreq_d1;


/* design */
//sreq
always @(posedge sclk or negedge rst_n) begin
    if(!rst_n)      sreq <= 1'b0;
    else if(sack)   sreq <= 1'b0;
    else if(sready) sreq <= 1'b1;
    else            sreq <= sreq;
end
//dreq
NDFF_syn U_NDFF_req(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
//dack
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)              dack <= 1'b0;
    else if(dreq && !dbusy) dack <= 1'b1;
    else if(!dreq)          dack <= 1'b0;
    else                    dack <= dack;
end
//sack
NDFF_syn U_NDFF_ack(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

//dreq_d1
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)  dreq_d1 <= 1'b0;
    else        dreq_d1 <= dreq;
end

//dvalid
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)                          dvalid <= 1'b0;
    else if(dreq && !dreq_d1 && !dbusy) dvalid <= 1'b1;
    else                                dvalid <= 1'b0;
end
//dout
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)                          dout <= 32'd0;
    else if(dreq && !dreq_d1 && !dbusy) dout <= din;
    else                                dout <= dout;
end
//sidle
always @(posedge sclk or negedge rst_n) begin
    if(!rst_n)                      sidle <= 1'b1;
    else if(sready | sreq | sack)   sidle <= 1'b0;
    else                            sidle <= 1'b1;
end


endmodule