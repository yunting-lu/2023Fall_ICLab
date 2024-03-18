module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

reg [31:0] seed_reg;
reg in_valid_d1;

//store input
//output when input is stored
//for JG check, ensure not receiving new data and not outputing different data when !out_idle

//seed_reg
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                      seed_reg <= 32'd0;
    else if(in_valid & out_idle)    seed_reg <= seed_in;
    else                            seed_reg <= seed_reg;
end
//in_valid_d1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  in_valid_d1 <= 1'b0;
    else        in_valid_d1 <= in_valid;
end
//output
always @(*) begin
    out_valid = in_valid_d1 & out_idle;
    seed_out = seed_reg;
end




endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output reg out_valid;
output reg [31:0] rand_num;
output busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

reg [31:0] seed_reg;
reg in_valid_d1;
reg [31:0] seed_now;
reg [31:0] seed_nxt_reg, seed_nxt_comb1, seed_nxt_comb2, seed_nxt_comb3, seed_nxt_comb4;
reg [7:0] cnt;
reg out_flag;

//calculate the result and store to FIFO if ~fifo_full
//stop calculating and remain last result if fifo_full

//seed_reg
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)          seed_reg <= 32'd0;
    else if(in_valid)   seed_reg <= seed;
    else                seed_reg <= seed_reg;
end
//in_valid_d1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  in_valid_d1 <= 1'b0;
    else        in_valid_d1 <= in_valid;
end
//seed_now
always @(*) begin
    if(in_valid_d1) seed_now = seed_reg;
    else            seed_now = seed_nxt_reg;
end
//seed_nxt
always @(*) begin
    seed_nxt_comb1 = seed_now;
    seed_nxt_comb2 = seed_nxt_comb1 ^ (seed_nxt_comb1 << 13);
    seed_nxt_comb3 = seed_nxt_comb2 ^ (seed_nxt_comb2 >> 17); //! pipeline?
    seed_nxt_comb4 = seed_nxt_comb3 ^ (seed_nxt_comb3 << 5);
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)          seed_nxt_reg <= 32'd0;
    else if(fifo_full)  seed_nxt_reg <= seed_nxt_reg;
    else                seed_nxt_reg <= seed_nxt_comb4;
end
//cnt
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              cnt <= 'd0;
    else if(in_valid_d1)    cnt <= 'd0;
    else if(fifo_full)      cnt <= cnt;
    else                    cnt <= cnt + 'd1;
end
//out_flag
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                          out_flag <= 1'b0;
    else if(in_valid_d1)                out_flag <= 1'b1;
    else if(cnt=='d255 && ~fifo_full)   out_flag <= 1'b0;
end
//busy
assign busy = out_flag;

//output
//reset to 0 after output 256 times
//cannot output when fifo_full
always @(*) begin
    if(out_flag && ~fifo_full) begin
        out_valid = 1'b1;
        rand_num = seed_nxt_reg;
    end
    else begin
        out_valid = 1'b0;
        rand_num = 32'd0;
    end
end


endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output reg fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

reg out_valid_comb;
reg [31:0] rand_num_comb;
reg fifo_empty_d1, fifo_empty_d2;

//output result if ~fifo_empty

//fifo_rinc
always @(*) begin
    if(~fifo_empty) begin
        fifo_rinc = 1'b1;
    end
    else begin
        fifo_rinc = 1'b0;
    end
end
//fifo_empty delay
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  fifo_empty_d1 <= 1'b1;
    else        fifo_empty_d1 <= fifo_empty;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  fifo_empty_d2 <= 1'b1;
    else        fifo_empty_d2 <= fifo_empty_d1;
end
//output
always @(*) begin
    if(~fifo_empty_d2) begin
        out_valid = 1'b1;
        rand_num = fifo_rdata;
    end
    else begin
        out_valid = 1'b0;
        rand_num = 'd0;
    end
end

/*
//out_valid
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 1'b0;
    else        out_valid <= out_valid_comb;
end
//rand_num
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  rand_num <= 32'd0;
    else        rand_num <= rand_num_comb;
end
*/



endmodule