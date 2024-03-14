//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

// Input Signals
input clk, rst_n;
input in_valid;
input direction;
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output reg [7:0] out_data;

// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;

//==============================================//
//       parameter & integer declaration        //
//==============================================//

parameter IDLE          = 'd0;
parameter COMM          = 'd1;
parameter SD_RESP       = 'd2;
//SD write
parameter WAIT_UNIT     = 'd3;
parameter TO_SD         = 'd4;
parameter SD_BUSY       = 'd5;
//SD read
parameter FROM_SD       = 'd6;
parameter W_DRAM        = 'd7;
//output
parameter OUTPUT        = 'd8;

//==============================================//
//           reg & wire declaration             //
//==============================================//

//ungroup
reg SD_DATA_DONE;
reg [63:0] SD_DATA_reg;

reg [3:0] curr_state, next_state;
//store input
reg        direction_comb, direction_reg;
reg [12:0] addr_dram_comb, addr_dram_reg;
reg [15:0] addr_sd_comb, addr_sd_reg;
wire [31:0] addr_dram_reg_full, addr_sd_reg_full;
reg [63:0] data_dram_reg, data_sd_reg;
//read/write
wire [5:0] command;
wire [47:0] command_format;
wire [87:0] data_to_sd;
reg [87:0] store_comb, store_reg;
//control
reg in_valid_delay;
reg [6:0] cnt_state;
reg [2:0] cnt_out;
reg [7:0] out_dram [0:7];
reg [7:0] out_sd [0:7];
reg dram_write_done, sd_resp_finish, can_output;
//crc
wire [6:0] addr_sd_crc7;
wire [15:0] data_dram_crc16;
//dram output
//output block
reg out_valid_comb;
reg [7:0] out_data_comb;
reg MOSI_comb;

//==============================================//
//                  Design                      //
//==============================================//

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  curr_state <= IDLE;
    else        curr_state <= next_state;
end

always@(*) begin
    case(curr_state)
        IDLE: begin
            if((R_VALID && !direction_reg) || (in_valid_delay && direction_reg))    next_state = COMM;
            else                                                                    next_state = IDLE;
        end
        COMM: begin //after command_format, output 1 (MOSI) //maybe a flag when cycle=48
            if(MISO == 1'b0)    next_state = SD_RESP;
            else                next_state = COMM;
        end
        SD_RESP: begin
            if((MISO == 1'b0) && (!direction_reg))                          next_state = WAIT_UNIT; //MISO low for 8 cycles //write //cnt_state == 'd7 
            else if((MISO == 1'b0) && (sd_resp_finish) && (direction_reg))  next_state = FROM_SD; //wait until SD ready //read
            else                                                            next_state = SD_RESP;
        end
        //SD write
        WAIT_UNIT: begin
            if(cnt_state == 'd12)   next_state = TO_SD; //'d5 //MISO low for 8 cycles + wait at least 1 unit
            else                    next_state = WAIT_UNIT; //wait 8 cycles (output MOSI 1) 
        end
        TO_SD: begin //output 88 cycles
            if(cnt_state == 'd87)   next_state = SD_BUSY;
            else                    next_state = TO_SD;
        end
        SD_BUSY: begin //data response + busy
            if(can_output && MISO == 1'b1)  next_state = OUTPUT;
            else                            next_state = SD_BUSY;
        end
        //SD read
        FROM_SD: begin //SD input data for 64 cycles
            if(cnt_state == 'd64)   next_state = W_DRAM;
            else                    next_state = FROM_SD;
        end
        W_DRAM: begin //wait until DRAM write finish
            if(B_VALID) next_state = OUTPUT;
            else        next_state = W_DRAM;
        end
        OUTPUT: begin //output 8 cycles
            if(cnt_state == 'd7)    next_state = IDLE;
            else                    next_state = OUTPUT;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

//==============================================//
//                Store Input                   //
//==============================================//

//direction
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  direction_reg <= 1'b0;
    else        direction_reg <= direction_comb;
end
always@(*) begin
    if(in_valid)    direction_comb = direction;
    else            direction_comb = direction_reg;
end

//addr_dram
assign addr_dram_reg_full = {19'b0, addr_dram_reg};
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  addr_dram_reg <= 13'b0;
    else        addr_dram_reg <= addr_dram_comb;
end
always@(*) begin
    if(in_valid)    addr_dram_comb = addr_dram;
    else            addr_dram_comb = addr_dram_reg;
end

//addr_sd
assign addr_sd_reg_full = {16'b0, addr_sd_reg};
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  addr_sd_reg <= 16'b0;
    else        addr_sd_reg <= addr_sd_comb;
end
always@(*) begin
    if(in_valid)    addr_sd_comb = addr_sd;
    else            addr_sd_comb = addr_sd_reg;
end

//data from DRAM
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  data_dram_reg <= 64'b0;
    else begin
        if(R_VALID) data_dram_reg <= R_DATA;
        else        data_dram_reg <= data_dram_reg;
    end
end
//data from SD
integer k;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  data_sd_reg <= 64'b0;
    else begin
        if(next_state == FROM_SD) begin
            data_sd_reg[0] <= MISO;
            for(k=0;k<63;k=k+1) begin
                data_sd_reg[k+1] <= data_sd_reg[k];
            end
        end
        else begin
            data_sd_reg <= data_sd_reg;
        end
    end
end

/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                      data_sd_reg[0] <= 1'b0;
    else if(next_state == FROM_SD)  data_sd_reg[0] <= MISO;
    else                            data_sd_reg[0] <= data_sd_reg[0];
end

genvar j;
generate
    for(j=0;j<63;j=j+1) begin
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n)                      data_sd_reg[j+1] <= 1'b0;
            else if(next_state == FROM_SD)  data_sd_reg[j+1] <= data_sd_reg[j];
            else                            data_sd_reg[j+1] <= data_sd_reg[j+1];
        end
    end
endgenerate
*/

//==============================================//
//                  READ/WRITE                  //
//==============================================//
//* direction 0: DRAM read --> SD write, 1: SD read --> DRAM write 

assign command = (direction_reg)? 6'd17 : 6'd24;
assign command_format = {2'b01, command, addr_sd_reg_full, addr_sd_crc7, 1'b1}; //total 48 
assign data_to_sd = {8'hfe, data_dram_reg, data_dram_crc16}; //total 88 

//COMM
always@(*) begin
    if((curr_state == COMM) || (curr_state == TO_SD))  MOSI_comb = store_reg[87];

    else MOSI_comb = 1;
end

//shift reg storing data for SD 
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  store_reg <= 88'b0;
    else        store_reg <= store_comb;
end
always@(*) begin
    if(curr_state == IDLE)                                  store_comb = {command_format, 40'hff_ffff_ffff};
    else if((curr_state == COMM) || (curr_state == TO_SD))  store_comb = {store_reg[86:0], 1'b1};
    else if(curr_state == WAIT_UNIT)                        store_comb = data_to_sd;
    else                                                    store_comb = store_reg;
end

//==============================================//
//                    Control                   //
//==============================================//

//delay
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  in_valid_delay <= 1'b0;
    else        in_valid_delay <= in_valid;
end

//counter
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_state <= 'd0;
    else begin
       if(curr_state != next_state) cnt_state <= 'd0; //for FSM state transfer
       else                         cnt_state <= cnt_state + 'd1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_out <= 'd0;
    else begin
        if(next_state == OUTPUT)    cnt_out <= cnt_out + 'd1; //for output exactly 8 cycles
        else                        cnt_out <= 'd0;
    end
end

//data split into byte for output //data_dram_reg[63:0]
genvar i;
generate
    for(i=0;i<8;i=i+1) begin
        assign out_dram[i] = data_dram_reg[63-i*8 : 56-i*8];
        assign out_sd[i] = data_sd_reg[63-i*8 : 56-i*8];
    end
endgenerate

//SD_DATA_DONE
always@(*) begin
    if((curr_state == W_DRAM) && (cnt_state == 'd15)) begin
        //SD_DATA_DONE = 1;
        if(!dram_write_done)    SD_DATA_DONE = 1;
        else                    SD_DATA_DONE = 0;
    end   
    else                        SD_DATA_DONE = 0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                      dram_write_done <= 1'b0;
    else begin
        if(SD_DATA_DONE)            dram_write_done <= 1'b1;
        else if(curr_state == IDLE) dram_write_done <= 1'b0;
        else                        dram_write_done <= dram_write_done;
    end
end

//prevent DRAM spends too many cycles and cnt_state oveflows
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                          sd_resp_finish <= 1'b0;
    else begin
        if(curr_state != next_state)    sd_resp_finish <= 1'b0;
        else if(cnt_state >= 'd7)       sd_resp_finish <= 1'b1;
        else                            sd_resp_finish <= sd_resp_finish;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                          can_output <= 1'b0;
    else begin
        if(curr_state != next_state)    can_output <= 1'b0;
        else if(cnt_state >= 'd8)       can_output <= 1'b1; //data response needs 8 cycles
        else                            can_output <= can_output;
    end
end

//==============================================//
//                     CRC                      //
//==============================================//

CRC7 C07(.crcIn(7'b0), .data({2'b01, command, addr_sd_reg_full}), .crcOut(addr_sd_crc7)); //7 40 7 
CRC16_CCITT C16(.crcIn(16'b0), .data(data_dram_reg), .crcOut(data_dram_crc16)); //16 64 16 

//==============================================//
//                DRAM Output                   //
//==============================================//
//*READ
//AR_VALID
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                      AR_VALID <= 1'b0;
    else if(in_valid & !direction)  AR_VALID <= 1'b1;
    else if(AR_READY)               AR_VALID <= 1'b0;
    else                            AR_VALID <= AR_VALID;
end
//AR_ADDR
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                      AR_ADDR <= 32'b0;
    else if(in_valid & !direction)  AR_ADDR <= {19'b0, addr_dram};
    else if(AR_READY)               AR_ADDR <= 32'b0;
    else                            AR_ADDR <= AR_ADDR;
end
//R_READY
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)          R_READY <= 1'b0;
    else if(AR_READY)   R_READY <= 1'b1;
    else if(R_VALID)    R_READY <= 1'b0;
    else                R_READY <= R_READY;
end
//*WRITE
//AW_VALID
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)              AW_VALID <= 1'b0;
    else if(SD_DATA_DONE)   AW_VALID <= 1'b1; //TODO
    else if(AW_READY)       AW_VALID <= 1'b0;
    else                    AW_VALID <= AW_VALID;
end
//AW_ADDR
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)              AW_ADDR <= 32'b0;
    else if(SD_DATA_DONE)   AW_ADDR <= addr_dram_reg_full;
    else if(AW_READY)       AW_ADDR <= 32'b0;
    else                    AW_ADDR <= AW_ADDR;
end
//W_VALID
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)          W_VALID <= 1'b0;
    else if(AW_READY)   W_VALID <= 1'b1;
    else if(W_READY)    W_VALID <= 1'b0;
    else                W_VALID <= W_VALID;
end
//W_DATA
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)          W_DATA <= 64'b0;
    else if(AW_READY)   W_DATA <= data_sd_reg; //TODO
    else if(W_READY)    W_DATA <= 64'b0;
    else                W_DATA <= W_DATA;
end
//B_READY
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)          B_READY <= 1'b0;
    else if(AW_READY)   B_READY <= 1'b1;
    else if(B_VALID)    B_READY <= 1'b0; //B_VALID && (B_RESP==2'b0) 
    else                B_READY <= B_READY;
end

//==============================================//
//                Output Block                  //
//==============================================//

//out_valid
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 1'b0;
    else        out_valid <= out_valid_comb;
end
//out_data
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_data <= 8'b0;
    else        out_data <= out_data_comb;
end
//MOSI
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  MOSI <= 1'b1;
    else        MOSI <= MOSI_comb;
end

always@(*) begin
    if(next_state == OUTPUT) begin
        out_valid_comb = 1'b1;
        if(!direction_reg) begin //DRAM-->SD 
            out_data_comb = out_dram[cnt_out]; //TODO
        end
        else begin //SD-->DRAM 
            out_data_comb = out_sd[cnt_out]; //TODO
        end
    end
    else begin
        out_valid_comb = 1'b0;
        out_data_comb = 8'b0;
    end
end

endmodule

module CRC7 (
    input [6:0] crcIn,
    input [39:0] data,
    output [6:0] crcOut
);
// CRC polynomial coefficients: x^7 + x^3 + 1
//                              0x9 (hex)
// CRC width:                   7 bits
// CRC shift direction:         left (big endian)
// Input word width:            40 bits

    assign crcOut[0] = crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[6] ^ data[0] ^ data[4] ^ data[7] ^ data[8] ^ data[12] ^ data[14] ^ data[15] ^ data[16] ^ data[18] ^ data[20] ^ data[21] ^ data[23] ^ data[24] ^ data[30] ^ data[31] ^ data[34] ^ data[35] ^ data[37] ^ data[39];
    assign crcOut[1] = crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ data[1] ^ data[5] ^ data[8] ^ data[9] ^ data[13] ^ data[15] ^ data[16] ^ data[17] ^ data[19] ^ data[21] ^ data[22] ^ data[24] ^ data[25] ^ data[31] ^ data[32] ^ data[35] ^ data[36] ^ data[38];
    assign crcOut[2] = crcIn[0] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ data[2] ^ data[6] ^ data[9] ^ data[10] ^ data[14] ^ data[16] ^ data[17] ^ data[18] ^ data[20] ^ data[22] ^ data[23] ^ data[25] ^ data[26] ^ data[32] ^ data[33] ^ data[36] ^ data[37] ^ data[39];
    assign crcOut[3] = crcIn[0] ^ crcIn[2] ^ crcIn[5] ^ crcIn[6] ^ data[0] ^ data[3] ^ data[4] ^ data[8] ^ data[10] ^ data[11] ^ data[12] ^ data[14] ^ data[16] ^ data[17] ^ data[19] ^ data[20] ^ data[26] ^ data[27] ^ data[30] ^ data[31] ^ data[33] ^ data[35] ^ data[38] ^ data[39];
    assign crcOut[4] = crcIn[1] ^ crcIn[3] ^ crcIn[6] ^ data[1] ^ data[4] ^ data[5] ^ data[9] ^ data[11] ^ data[12] ^ data[13] ^ data[15] ^ data[17] ^ data[18] ^ data[20] ^ data[21] ^ data[27] ^ data[28] ^ data[31] ^ data[32] ^ data[34] ^ data[36] ^ data[39];
    assign crcOut[5] = crcIn[0] ^ crcIn[2] ^ crcIn[4] ^ data[2] ^ data[5] ^ data[6] ^ data[10] ^ data[12] ^ data[13] ^ data[14] ^ data[16] ^ data[18] ^ data[19] ^ data[21] ^ data[22] ^ data[28] ^ data[29] ^ data[32] ^ data[33] ^ data[35] ^ data[37];
    assign crcOut[6] = crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[5] ^ data[3] ^ data[6] ^ data[7] ^ data[11] ^ data[13] ^ data[14] ^ data[15] ^ data[17] ^ data[19] ^ data[20] ^ data[22] ^ data[23] ^ data[29] ^ data[30] ^ data[33] ^ data[34] ^ data[36] ^ data[38];
endmodule

module CRC16_CCITT (
    input [15:0] crcIn,
    input [63:0] data,
    output [15:0] crcOut
);
// CRC polynomial coefficients: x^16 + x^12 + x^5 + 1
//                              0x1021 (hex)
// CRC width:                   16 bits
// CRC shift direction:         left (big endian)
// Input word width:            64 bits

    assign crcOut[0] = crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[15] ^ data[0] ^ data[4] ^ data[8] ^ data[11] ^ data[12] ^ data[19] ^ data[20] ^ data[22] ^ data[26] ^ data[27] ^ data[28] ^ data[32] ^ data[33] ^ data[35] ^ data[42] ^ data[48] ^ data[49] ^ data[51] ^ data[52] ^ data[55] ^ data[56] ^ data[58] ^ data[63];
    assign crcOut[1] = crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ data[1] ^ data[5] ^ data[9] ^ data[12] ^ data[13] ^ data[20] ^ data[21] ^ data[23] ^ data[27] ^ data[28] ^ data[29] ^ data[33] ^ data[34] ^ data[36] ^ data[43] ^ data[49] ^ data[50] ^ data[52] ^ data[53] ^ data[56] ^ data[57] ^ data[59];
    assign crcOut[2] = crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ data[2] ^ data[6] ^ data[10] ^ data[13] ^ data[14] ^ data[21] ^ data[22] ^ data[24] ^ data[28] ^ data[29] ^ data[30] ^ data[34] ^ data[35] ^ data[37] ^ data[44] ^ data[50] ^ data[51] ^ data[53] ^ data[54] ^ data[57] ^ data[58] ^ data[60];
    assign crcOut[3] = crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ data[3] ^ data[7] ^ data[11] ^ data[14] ^ data[15] ^ data[22] ^ data[23] ^ data[25] ^ data[29] ^ data[30] ^ data[31] ^ data[35] ^ data[36] ^ data[38] ^ data[45] ^ data[51] ^ data[52] ^ data[54] ^ data[55] ^ data[58] ^ data[59] ^ data[61];
    assign crcOut[4] = crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ data[4] ^ data[8] ^ data[12] ^ data[15] ^ data[16] ^ data[23] ^ data[24] ^ data[26] ^ data[30] ^ data[31] ^ data[32] ^ data[36] ^ data[37] ^ data[39] ^ data[46] ^ data[52] ^ data[53] ^ data[55] ^ data[56] ^ data[59] ^ data[60] ^ data[62];
    assign crcOut[5] = crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[13] ^ data[0] ^ data[4] ^ data[5] ^ data[8] ^ data[9] ^ data[11] ^ data[12] ^ data[13] ^ data[16] ^ data[17] ^ data[19] ^ data[20] ^ data[22] ^ data[24] ^ data[25] ^ data[26] ^ data[28] ^ data[31] ^ data[35] ^ data[37] ^ data[38] ^ data[40] ^ data[42] ^ data[47] ^ data[48] ^ data[49] ^ data[51] ^ data[52] ^ data[53] ^ data[54] ^ data[55] ^ data[57] ^ data[58] ^ data[60] ^ data[61];
    assign crcOut[6] = crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ crcIn[14] ^ data[1] ^ data[5] ^ data[6] ^ data[9] ^ data[10] ^ data[12] ^ data[13] ^ data[14] ^ data[17] ^ data[18] ^ data[20] ^ data[21] ^ data[23] ^ data[25] ^ data[26] ^ data[27] ^ data[29] ^ data[32] ^ data[36] ^ data[38] ^ data[39] ^ data[41] ^ data[43] ^ data[48] ^ data[49] ^ data[50] ^ data[52] ^ data[53] ^ data[54] ^ data[55] ^ data[56] ^ data[58] ^ data[59] ^ data[61] ^ data[62];
    assign crcOut[7] = crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[15] ^ data[2] ^ data[6] ^ data[7] ^ data[10] ^ data[11] ^ data[13] ^ data[14] ^ data[15] ^ data[18] ^ data[19] ^ data[21] ^ data[22] ^ data[24] ^ data[26] ^ data[27] ^ data[28] ^ data[30] ^ data[33] ^ data[37] ^ data[39] ^ data[40] ^ data[42] ^ data[44] ^ data[49] ^ data[50] ^ data[51] ^ data[53] ^ data[54] ^ data[55] ^ data[56] ^ data[57] ^ data[59] ^ data[60] ^ data[62] ^ data[63];
    assign crcOut[8] = crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ data[3] ^ data[7] ^ data[8] ^ data[11] ^ data[12] ^ data[14] ^ data[15] ^ data[16] ^ data[19] ^ data[20] ^ data[22] ^ data[23] ^ data[25] ^ data[27] ^ data[28] ^ data[29] ^ data[31] ^ data[34] ^ data[38] ^ data[40] ^ data[41] ^ data[43] ^ data[45] ^ data[50] ^ data[51] ^ data[52] ^ data[54] ^ data[55] ^ data[56] ^ data[57] ^ data[58] ^ data[60] ^ data[61] ^ data[63];
    assign crcOut[9] = crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ crcIn[14] ^ data[4] ^ data[8] ^ data[9] ^ data[12] ^ data[13] ^ data[15] ^ data[16] ^ data[17] ^ data[20] ^ data[21] ^ data[23] ^ data[24] ^ data[26] ^ data[28] ^ data[29] ^ data[30] ^ data[32] ^ data[35] ^ data[39] ^ data[41] ^ data[42] ^ data[44] ^ data[46] ^ data[51] ^ data[52] ^ data[53] ^ data[55] ^ data[56] ^ data[57] ^ data[58] ^ data[59] ^ data[61] ^ data[62];
    assign crcOut[10] = crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[15] ^ data[5] ^ data[9] ^ data[10] ^ data[13] ^ data[14] ^ data[16] ^ data[17] ^ data[18] ^ data[21] ^ data[22] ^ data[24] ^ data[25] ^ data[27] ^ data[29] ^ data[30] ^ data[31] ^ data[33] ^ data[36] ^ data[40] ^ data[42] ^ data[43] ^ data[45] ^ data[47] ^ data[52] ^ data[53] ^ data[54] ^ data[56] ^ data[57] ^ data[58] ^ data[59] ^ data[60] ^ data[62] ^ data[63];
    assign crcOut[11] = crcIn[0] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ data[6] ^ data[10] ^ data[11] ^ data[14] ^ data[15] ^ data[17] ^ data[18] ^ data[19] ^ data[22] ^ data[23] ^ data[25] ^ data[26] ^ data[28] ^ data[30] ^ data[31] ^ data[32] ^ data[34] ^ data[37] ^ data[41] ^ data[43] ^ data[44] ^ data[46] ^ data[48] ^ data[53] ^ data[54] ^ data[55] ^ data[57] ^ data[58] ^ data[59] ^ data[60] ^ data[61] ^ data[63];
    assign crcOut[12] = crcIn[0] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ data[0] ^ data[4] ^ data[7] ^ data[8] ^ data[15] ^ data[16] ^ data[18] ^ data[22] ^ data[23] ^ data[24] ^ data[28] ^ data[29] ^ data[31] ^ data[38] ^ data[44] ^ data[45] ^ data[47] ^ data[48] ^ data[51] ^ data[52] ^ data[54] ^ data[59] ^ data[60] ^ data[61] ^ data[62] ^ data[63];
    assign crcOut[13] = crcIn[0] ^ crcIn[1] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[12] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ data[1] ^ data[5] ^ data[8] ^ data[9] ^ data[16] ^ data[17] ^ data[19] ^ data[23] ^ data[24] ^ data[25] ^ data[29] ^ data[30] ^ data[32] ^ data[39] ^ data[45] ^ data[46] ^ data[48] ^ data[49] ^ data[52] ^ data[53] ^ data[55] ^ data[60] ^ data[61] ^ data[62] ^ data[63];
    assign crcOut[14] = crcIn[1] ^ crcIn[2] ^ crcIn[5] ^ crcIn[6] ^ crcIn[8] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ data[2] ^ data[6] ^ data[9] ^ data[10] ^ data[17] ^ data[18] ^ data[20] ^ data[24] ^ data[25] ^ data[26] ^ data[30] ^ data[31] ^ data[33] ^ data[40] ^ data[46] ^ data[47] ^ data[49] ^ data[50] ^ data[53] ^ data[54] ^ data[56] ^ data[61] ^ data[62] ^ data[63];
    assign crcOut[15] = crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[14] ^ crcIn[15] ^ data[3] ^ data[7] ^ data[10] ^ data[11] ^ data[18] ^ data[19] ^ data[21] ^ data[25] ^ data[26] ^ data[27] ^ data[31] ^ data[32] ^ data[34] ^ data[41] ^ data[47] ^ data[48] ^ data[50] ^ data[51] ^ data[54] ^ data[55] ^ data[57] ^ data[62] ^ data[63];
endmodule

