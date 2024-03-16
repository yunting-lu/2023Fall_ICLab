//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : HT_TOP.v
//   	Module Name : HT_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Output signals
    out_valid, 
	out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================

reg [5:0] cnt_state;

parameter IDLE      = 'd0;
parameter INPUT     = 'd1;
parameter CALC      = 'd2;
parameter OUTPUT    = 'd3;
reg [1:0] curr_state, next_state;

integer i, j, k;

//store input
reg mode_reg;
reg [3:0] node[0:7];
reg [4:0] weight[0:7];
reg [6:0] temp_out[0:7];
reg [2:0] length[0:7];
reg [2:0] dummy_node_reg[0:7];

reg [3:0] node_comb[0:7];
reg [4:0] weight_comb[0:7];
reg [6:0] temp_out_comb[0:7];
reg [2:0] length_comb[0:7];
reg [2:0] dummy_node_comb[0:7];

//CALC
wire [31:0] IN_character;
wire [39:0] IN_weight;
wire [31:0] OUT_character;
reg [3:0] left_reg, right_reg;
reg [2:0] merge_node;
reg [4:0] left_weight, right_weight;

//output
wire [5:0] out_length;
reg out_valid_comb, out_code_comb;


// ===============================================================
// Design
// ===============================================================

/*
                A    |   B    |   C    |   E    |   I    |   L    |   O   |    V
            --------------------------------------------------------------------------
No. of reg      0    |   1    |   2    |   3    |   4    |   5    |   6   |    7
            --------------------------------------------------------------------------
parameter       15   |   14   |   13   |   12   |   11   |   10   |   9   |    8
*/
wire [3:0] reg_num[0:7];

assign reg_num[0] = 'd15;
assign reg_num[1] = 'd14;
assign reg_num[2] = 'd13;
assign reg_num[3] = 'd12;
assign reg_num[4] = 'd11;
assign reg_num[5] = 'd10;
assign reg_num[6] = 'd9;
assign reg_num[7] = 'd8;



//cnt_state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_state <= 'd0;
    else if(curr_state!=next_state) cnt_state <= 'd0;
    else        cnt_state <= cnt_state + 'd1;
end


//=================================
//		FSM
//=================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  curr_state <= IDLE;
    else        curr_state <= next_state;
end

always@(*) begin
    case(curr_state)
        IDLE: begin
            if(in_valid)    next_state = INPUT;
            else            next_state = IDLE;
        end
        INPUT: begin
            if(!in_valid)   next_state = CALC;
            else            next_state = INPUT;
        end
        CALC: begin
            if(cnt_state=='d5) next_state = OUTPUT;
            else                next_state = CALC;
        end
        OUTPUT: begin //TODO
            if(cnt_state==out_length-'d1)   next_state = IDLE;
            else                            next_state = OUTPUT;
        end
        default:    next_state = IDLE;
    endcase
end

//=================================
//		Store Input
//=================================

//*mode_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)                              mode_reg <= 'b0;
    else if(in_valid && curr_state==IDLE)   mode_reg <= out_mode;
    else                                    mode_reg <= mode_reg;
end
//*weight
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i+1) begin
            weight[i] <= 'd0;
        end
    end
    else begin
        for(j = 0; j < 8; j = j+1) begin
            weight[j] <= weight_comb[j];
        end
    end
end
always@(*) begin
    if(in_valid) begin
        for(i = 0; i < 7; i = i+1) begin
            weight_comb[i] = weight[i+1];
        end
        weight_comb[7] = in_weight;
    end
    else begin
        //if(!cnt_state[0]) begin
            for(j = 0; j < 8; j = j+1) begin
                if(node[j]==left_reg)       weight_comb[j] = 'd31;
                else if(node[j]==right_reg) weight_comb[j] = left_weight + right_weight;
                else                        weight_comb[j] = weight[j];
            end
        //end
        //else begin
        //    for(k = 0; k < 8; k = k+1) begin
        //        weight_comb[k] = weight[k];
        //    end
        //end
    end
end
//left_weight, right_weight
/*
always @(*) begin
    left_weight = 'd0;
    right_weight = 'd0;
    for(i = 0; i < 8; i = i+1) begin
        if(node[i]==left_reg)   left_weight = weight[i]; //!
        //else                    left_weight = 'd0;
    end
    for(j = 0; j < 8; j = j+1) begin
        if(node[j]==right_reg)  right_weight = weight[j]; //!
        //else                    right_weight = 'd0;
    end
end
*/
always @(*) begin
    if(left_reg==node[0])       left_weight = weight[0];
    else if(left_reg==node[1])  left_weight = weight[1];
    else if(left_reg==node[2])  left_weight = weight[2];
    else if(left_reg==node[3])  left_weight = weight[3];
    else if(left_reg==node[4])  left_weight = weight[4];
    else if(left_reg==node[5])  left_weight = weight[5];
    else if(left_reg==node[6])  left_weight = weight[6];
    else                        left_weight = weight[7];
end
always @(*) begin
    if(right_reg==node[0])       right_weight = weight[0];
    else if(right_reg==node[1])  right_weight = weight[1];
    else if(right_reg==node[2])  right_weight = weight[2];
    else if(right_reg==node[3])  right_weight = weight[3];
    else if(right_reg==node[4])  right_weight = weight[4];
    else if(right_reg==node[5])  right_weight = weight[5];
    else if(right_reg==node[6])  right_weight = weight[6];
    else                         right_weight = weight[7];
end

//=================================
//		CALC
//=================================

//*sort
SORT_IP #(8) MY_SORT_IP(.IN_character(IN_character), .IN_weight(IN_weight), .OUT_character(OUT_character));

assign IN_character = {node[0],node[1],node[2],node[3],node[4],node[5],node[6],node[7]};
assign IN_weight = {weight[0],weight[1],weight[2],weight[3],weight[4],weight[5],weight[6],weight[7]};

//*two smallest node: left_reg, right_reg
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        left_reg <= 'd0;
        right_reg <= 'd0;
    end
    else begin
        left_reg <= OUT_character[7:4];
        right_reg <= OUT_character[3:0];
    end
end
*/
always @(*) begin
    left_reg = OUT_character[7:4];
    right_reg = OUT_character[3:0];
end
//*merge_node
always@(*) begin
    case(cnt_state)
        'd7:    merge_node = 'd7;
        'd0:    merge_node = 'd6;
        'd1:    merge_node = 'd5;
        'd2:    merge_node = 'd4;
        'd3:    merge_node = 'd3;
        'd4:   merge_node = 'd2;
        'd5:   merge_node = 'd1;
        default:merge_node = 'd0;
    endcase
end

//*node //initial: A,B,C,E,I,L,O,V(15~8)
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i+1) begin
            node[i] <= 'd0;
        end
    end
    else begin
        for(j = 0; j < 8; j = j+1) begin
            node[j] <= node_comb[j];
        end
    end
end
always@(*) begin
    if(curr_state==INPUT && next_state==INPUT) begin
        node_comb[0] = 'd15; //A
        node_comb[1] = 'd14; //B
        node_comb[2] = 'd13; //C
        node_comb[3] = 'd12; //E
        node_comb[4] = 'd11; //I
        node_comb[5] = 'd10; //L
        node_comb[6] = 'd9;  //O
        node_comb[7] = 'd8;  //V
    end
    else begin
        for(i = 0; i < 8; i = i+1) begin
            if(node[i]==left_reg)       node_comb[i] = 'd0;
            else if(node[i]==right_reg) node_comb[i] = merge_node;
            else                        node_comb[i] = node[i];
        end
    end
end

//*temp_out
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i+1) begin
            temp_out[i] <= 'd0;
        end
    end
    else begin
        for(j = 0; j < 8; j = j+1) begin
            temp_out[j] <= temp_out_comb[j];
        end
    end
end
always@(*) begin
    if(curr_state==IDLE) begin //INPUT && next_state==INPUT
        for(i = 0; i < 8; i = i+1) begin
            temp_out_comb[i] = 'd0;
        end
    end
    else begin
        if(curr_state==CALC || next_state==CALC) begin //!cnt_state[0] && 
            for(j = 0; j < 8; j = j+1) begin
                if((left_reg==reg_num[j]) || (dummy_node_reg[j]==left_reg))         temp_out_comb[j] = {temp_out[j][5:0], 1'b0};
                else if((right_reg==reg_num[j]) || (dummy_node_reg[j]==right_reg))  temp_out_comb[j] = {temp_out[j][5:0], 1'b1};
                else                        temp_out_comb[j] = temp_out[j];
            end
        end
        else begin
            for(k = 0; k < 8; k = k+1) begin
                temp_out_comb[k] = temp_out[k];
            end
        end
    end
end

//*length
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i+1) begin
            length[i] <= 'd0;
        end
    end
    else begin
        for(j = 0; j < 8; j = j+1) begin
            length[j] <= length_comb[j];
        end
    end
end
always@(*) begin
    if(curr_state==IDLE) begin
        for(i = 0; i < 8; i = i+1) begin
            length_comb[i] = 'd0;
        end
    end
    else begin
        if(curr_state==CALC || next_state==CALC) begin //!cnt_state[0] && 
            for(j = 0; j < 8; j = j+1) begin
                if((left_reg==reg_num[j]) || (right_reg==reg_num[j]) || (dummy_node_reg[j]==left_reg) || (dummy_node_reg[j]==right_reg)) length_comb[j] = length[j] + 'd1;
                else                                            length_comb[j] = length[j];
            end
        end
        else begin
            for(k = 0; k < 8; k = k+1) begin
                length_comb[k] = length[k];
            end
        end
    end
end

//*dummy_node_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i+1) begin
            dummy_node_reg[i] <= 'd0;
        end
    end
    else begin
        for(j = 0; j < 8; j = j+1) begin
            dummy_node_reg[j] <= dummy_node_comb[j];
        end
    end
end
always@(*) begin
    if(curr_state==IDLE) begin //curr_state!=CALC
        for(i = 0; i < 8; i = i+1) begin
            dummy_node_comb[i] = 'd0;
        end
    end
    else begin
        if(curr_state==CALC || next_state==CALC) begin
            for(j = 0; j < 8; j = j+1) begin
                if((left_reg==reg_num[j]) || (right_reg==reg_num[j]) || (dummy_node_reg[j]==left_reg) || (dummy_node_reg[j]==right_reg))    dummy_node_comb[j] = merge_node;
                else                                                                                                                        dummy_node_comb[j] = dummy_node_reg[j];
            end 
        end
        else begin
            for(k = 0; k < 8; k = k+1) begin
                dummy_node_comb[k] = dummy_node_reg[k];
            end
        end
    end
end

//=================================
//		Output
//=================================

reg [2:0] cnt_index, cnt_reg;
reg [2:0] cnt_index_comb;

//cnt_index
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_index <= 'd0;
    else begin
        cnt_index <= cnt_index_comb;
    end
end
always @(*) begin
    if(curr_state==OUTPUT || next_state==OUTPUT)
        if(cnt_index==length_comb[cnt_reg]-1)   cnt_index_comb = 'd0;
        else                                    cnt_index_comb = cnt_index + 'd1;
    else                                        cnt_index_comb = 'd0;
end
//cnt_reg
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_reg <= 'd0;
    else begin
        if(curr_state==OUTPUT || next_state==OUTPUT) begin // || next_state==OUTPUT
            if(!mode_reg) begin
                if(cnt_index_comb=='d0) begin
                    if(cnt_reg=='d4)        cnt_reg <= 'd5;
                    else if(cnt_reg=='d5)   cnt_reg <= 'd6;
                    else if(cnt_reg=='d6)   cnt_reg <= 'd7;
                    else                    cnt_reg <= 'd3;
                end
                else                        cnt_reg <= cnt_reg;
            end
            else begin
                if(cnt_index_comb=='d0) begin
                    if(cnt_reg=='d4)        cnt_reg <= 'd2;
                    else if(cnt_reg=='d2)   cnt_reg <= 'd5;
                    else if(cnt_reg=='d5)   cnt_reg <= 'd0;
                    else                    cnt_reg <= 'd1;
                end
                else                        cnt_reg <= cnt_reg;
            end
        end
        else begin
            cnt_reg <= 'd4;
        end
    end
end


//out_length
assign out_length = (mode_reg) ? (length[0]+length[1]+length[2]+length[4]+length[5]) : (length[3]+length[4]+length[5]+length[6]+length[7]);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 'd0;
    else        out_valid <= out_valid_comb;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_code <= 'd0;
    else        out_code <= out_code_comb;
end

always@(*) begin
    
    if(curr_state==OUTPUT && next_state==OUTPUT) begin
        out_valid_comb = 1'b1;
        out_code_comb = temp_out[cnt_reg][cnt_index]; //TODO
    end
    else if(next_state==OUTPUT) begin
        out_valid_comb = 1'b1;
        out_code_comb = temp_out_comb[4][0]; //I, MSB
    end
    else begin
        out_valid_comb = 1'b0;
        out_code_comb = 1'b0;
    end
end


endmodule