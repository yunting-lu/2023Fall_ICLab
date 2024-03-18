//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Siamese Neural Network
//   Author     		: Hsien-Chi Peng (jhpeng2012@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SNN.v
//   Module Name : SNN
//   Release version : V1.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on


module SNN(
    //Input Port
    clk,
    rst_n,
    cg_en,
    in_valid,
    Img,
    Kernel,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;


//---------------------------------------------------------------------
//   INPUTS & OUTPUTS
//---------------------------------------------------------------------
input rst_n, clk, in_valid;
input cg_en;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATIONS
//---------------------------------------------------------------------

//FSM
parameter IDLE  = 2'b00;
parameter IMG1  = 2'b01;
parameter IMG2  = 2'b11;
parameter WAIT  = 2'b10;
reg  [1:0] curr_state, next_state;

//counter
reg  [5:0] cnt;
reg  [5:0] cnt_comb;

//store input
reg  [1:0] opt_reg, opt_comb;
reg  [inst_sig_width+inst_exp_width:0] image_reg [0:3][0:3];
wire [inst_sig_width+inst_exp_width:0] pd_00, pd_01, pd_02, pd_03, pd_10, pd_13, pd_20, pd_23, pd_30, pd_31, pd_32, pd_33;
reg  [inst_sig_width+inst_exp_width:0] kern1_reg [0:2][0:2];
reg  [inst_sig_width+inst_exp_width:0] kern2_reg [0:2][0:2];
reg  [inst_sig_width+inst_exp_width:0] kern3_reg [0:2][0:2];
reg  [inst_sig_width+inst_exp_width:0] weight_reg [0:1][0:1];

//registers
integer i, j, m, n;
reg  [inst_sig_width+inst_exp_width:0] data_reg  [0:3][0:3];
reg  [inst_sig_width+inst_exp_width:0] data_comb [0:3][0:3];
reg  [inst_sig_width+inst_exp_width:0] pooling_reg [0:1][0:1];
reg  [inst_sig_width+inst_exp_width:0] pooling_comb [0:1][0:1];
reg  [inst_sig_width+inst_exp_width:0] feature_reg [0:3];
reg  [inst_sig_width+inst_exp_width:0] feature_comb [0:3];
reg  [inst_sig_width+inst_exp_width:0] encoding1_reg [0:3];
reg  [inst_sig_width+inst_exp_width:0] encoding1_comb [0:3];
reg  [inst_sig_width+inst_exp_width:0] encoding2_reg; //[0:3]
reg  [inst_sig_width+inst_exp_width:0] encoding2_comb [0:3];

//convolution & fully connected
reg  [inst_sig_width+inst_exp_width:0] mult_a[0:10];
reg  [inst_sig_width+inst_exp_width:0] mult_b[0:10];
wire [inst_sig_width+inst_exp_width:0] mult_z[0:10];

reg  [inst_sig_width+inst_exp_width:0] add_a[0:5];
reg  [inst_sig_width+inst_exp_width:0] add_b[0:5];
reg  [inst_sig_width+inst_exp_width:0] add_c[0:3];
wire [inst_sig_width+inst_exp_width:0] add_z[0:5];

//equalization
wire [inst_sig_width+inst_exp_width:0] data_pd_00, data_pd_01, data_pd_02, data_pd_03, 
                                       data_pd_10, data_pd_13, data_pd_20, data_pd_23, 
                                       data_pd_30, data_pd_31, data_pd_32, data_pd_33;
reg  [inst_sig_width+inst_exp_width:0] sum_a[0:3];
reg  [inst_sig_width+inst_exp_width:0] sum_b[0:3];
reg  [inst_sig_width+inst_exp_width:0] sum_c[0:3];
wire [inst_sig_width+inst_exp_width:0] sum_z[0:3];
reg  [inst_sig_width+inst_exp_width:0] d9_a;
wire [inst_sig_width+inst_exp_width:0] d9_z;
reg  [inst_sig_width+inst_exp_width:0] eqdata_reg  [0:3][0:3];
reg  [inst_sig_width+inst_exp_width:0] eqdata_comb [0:3][0:3];


//max pooling
reg  [inst_sig_width+inst_exp_width:0] c0_a, c1_a, c2_a; //, c3_a
reg  [inst_sig_width+inst_exp_width:0] c0_b, c1_b, c2_b; //, c3_b
wire [inst_sig_width+inst_exp_width:0] c0_min, c1_min, c2_min; //, c3_min
wire [inst_sig_width+inst_exp_width:0] c0_max, c1_max, c2_max; //, c3_max
reg  [inst_sig_width+inst_exp_width:0] max_reg, min_reg, max_comb, min_comb;
reg  [inst_sig_width+inst_exp_width:0] c0_max_reg, c1_max_reg;

//min-max normalization
reg  [inst_sig_width+inst_exp_width:0] s0_a, s1_a, d0_a;
reg  [inst_sig_width+inst_exp_width:0] s0_b, s1_b, d0_b;
wire [inst_sig_width+inst_exp_width:0] s0_z, s1_z, d0_z;
reg  [inst_sig_width+inst_exp_width:0] scaled_reg;

//activation function
reg  [inst_sig_width+inst_exp_width:0] e0_a, e1_a;
wire [inst_sig_width+inst_exp_width:0] e0_z, e1_z;
reg  [inst_sig_width+inst_exp_width:0] d1_a, d1_b;
wire [inst_sig_width+inst_exp_width:0] d1_z;
reg  [inst_sig_width+inst_exp_width:0] s2_a, s2_b, a6_a, a6_b;
wire [inst_sig_width+inst_exp_width:0] s2_z, a6_z;
wire [inst_sig_width+inst_exp_width:0] a6_a_comb, d1_a_comb;

//L1 distance s3 a7
reg  [inst_sig_width+inst_exp_width:0] s3_a, s3_b, a7_a, a7_b;
wire [inst_sig_width+inst_exp_width:0] s3_z, a7_z;
reg  [inst_sig_width+inst_exp_width:0] a7_z_reg;

//output
reg  out_valid_comb;
reg [inst_sig_width+inst_exp_width:0] out_comb;

//---------------------------------------------------------------------
//   GATED_OR
//---------------------------------------------------------------------

//GATED_OR GATED_X(.CLOCK(clk), .SLEEP_CTRL(), .RST_N(rst_n), .CLOCK_GATED());

//opt_reg
wire G_clk_first_input;
GATED_OR GATED_opt(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~((cnt == 6'd0) && (curr_state == IDLE)))), .RST_N(rst_n), .CLOCK_GATED(G_clk_first_input));

//image_reg
wire G_clk_img0;
GATED_OR GATED_img0(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~((curr_state==IDLE | next_state==IMG1 | next_state==IMG2) && cnt[3:0]=='d0))), .RST_N(rst_n), .CLOCK_GATED(G_clk_img0)); //curr_state!=2'b10

genvar img_idx;
wire G_clk_img[0:14];
generate
    for(img_idx=0;img_idx<15;img_idx=img_idx+1) begin: gated_img_array
        GATED_OR GATED_imgarray(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~((next_state==IMG1 | next_state==IMG2)&(cnt[3:0]==(img_idx+1))))), .RST_N(rst_n), .CLOCK_GATED(G_clk_img[img_idx]));
    end
endgenerate

//weight_reg & kernel_reg
genvar in_idx;
wire G_clk_input[0:25];
generate
    for(in_idx=0;in_idx<26;in_idx=in_idx+1) begin: gated_kernelweight_array
        GATED_OR GATED_kernelweight(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(next_state==IMG1 && cnt==in_idx+1))), .RST_N(rst_n), .CLOCK_GATED(G_clk_input[in_idx]));
    end
endgenerate

//cnt - general
genvar cnt_idx;
wire G_clk_cnt[0:47];
generate
    for(cnt_idx=0;cnt_idx<48;cnt_idx=cnt_idx+1) begin: gated_cnt_array
        GATED_OR GATED_cnt(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt==cnt_idx))), .RST_N(rst_n), .CLOCK_GATED(G_clk_cnt[cnt_idx]));
    end
endgenerate

//data_reg
wire G_clk_data[0:3][0:3];
GATED_OR GATED_data00(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d12 | cnt=='d28 | cnt=='d44))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[0][0]));
GATED_OR GATED_data01(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d13 | cnt=='d29 | cnt=='d45))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[0][1]));
GATED_OR GATED_data02(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d14 | cnt=='d30 | cnt=='d46))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[0][2]));
GATED_OR GATED_data03(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d15 | cnt=='d31 | cnt=='d47))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[0][3]));
GATED_OR GATED_data10(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d16 | cnt=='d32 | cnt=='d0 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[1][0]));
GATED_OR GATED_data11(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d17 | cnt=='d33 | cnt=='d1 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[1][1]));
GATED_OR GATED_data12(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d18 | cnt=='d34 | cnt=='d2 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[1][2]));
GATED_OR GATED_data13(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d19 | cnt=='d35 | cnt=='d3 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[1][3]));
GATED_OR GATED_data20(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d20 | cnt=='d36 | cnt=='d4 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[2][0]));
GATED_OR GATED_data21(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d21 | cnt=='d37 | cnt=='d5 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[2][1]));
GATED_OR GATED_data22(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d22 | cnt=='d38 | cnt=='d6 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[2][2]));
GATED_OR GATED_data23(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d23 | cnt=='d39 | cnt=='d7 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[2][3]));
GATED_OR GATED_data30(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d24 | cnt=='d40 | cnt=='d8 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[3][0]));
GATED_OR GATED_data31(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d25 | cnt=='d41 | cnt=='d9 ))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[3][1]));
GATED_OR GATED_data32(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d26 | cnt=='d42 | cnt=='d10))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[3][2]));
GATED_OR GATED_data33(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(cnt=='d27 | cnt=='d43 | cnt=='d11))), .RST_N(rst_n), .CLOCK_GATED(G_clk_data[3][3]));

//assign G_clk_data[0][0] = G_clk_cnt[12] & G_clk_cnt[28] & G_clk_cnt[44];
//assign G_clk_data[0][1] = G_clk_cnt[13] & G_clk_cnt[29] & G_clk_cnt[45];
//assign G_clk_data[0][2] = G_clk_cnt[14] & G_clk_cnt[30] & G_clk_cnt[46];
//assign G_clk_data[0][3] = G_clk_cnt[15] & G_clk_cnt[31] & G_clk_cnt[47];
//assign G_clk_data[1][0] = G_clk_cnt[16] & G_clk_cnt[32] & G_clk_cnt[0];
//assign G_clk_data[1][1] = G_clk_cnt[17] & G_clk_cnt[33] & G_clk_cnt[1];
//assign G_clk_data[1][2] = G_clk_cnt[18] & G_clk_cnt[34] & G_clk_cnt[2];
//assign G_clk_data[1][3] = G_clk_cnt[19] & G_clk_cnt[35] & G_clk_cnt[3];
//assign G_clk_data[2][0] = G_clk_cnt[20] & G_clk_cnt[36] & G_clk_cnt[4];
//assign G_clk_data[2][1] = G_clk_cnt[21] & G_clk_cnt[37] & G_clk_cnt[5];
//assign G_clk_data[2][2] = G_clk_cnt[22] & G_clk_cnt[38] & G_clk_cnt[6];
//assign G_clk_data[2][3] = G_clk_cnt[23] & G_clk_cnt[39] & G_clk_cnt[7];
//assign G_clk_data[3][0] = G_clk_cnt[24] & G_clk_cnt[40] & G_clk_cnt[8];
//assign G_clk_data[3][1] = G_clk_cnt[25] & G_clk_cnt[41] & G_clk_cnt[9];
//assign G_clk_data[3][2] = G_clk_cnt[26] & G_clk_cnt[42] & G_clk_cnt[10];
//assign G_clk_data[3][3] = G_clk_cnt[27] & G_clk_cnt[43] & G_clk_cnt[11];

//mult0~8
wire G_clk_mult0to8;
GATED_OR GATED_mult0to8(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~((curr_state==IMG1&&(cnt>'d8 || cnt=='d0))||(curr_state==IMG2)||(curr_state==WAIT&&cnt<'d9)))), .RST_N(rst_n), .CLOCK_GATED(G_clk_mult0to8));



//encoding2_reg
wire G_clk_en2;
GATED_OR GATED_encoding2(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~(curr_state==WAIT && (cnt>='d29 && cnt<='d32)))), .RST_N(rst_n), .CLOCK_GATED(G_clk_en2));

//output
wire G_clk_out;
GATED_OR GATED_out(.CLOCK(clk), .SLEEP_CTRL(cg_en&(~((curr_state==WAIT && cnt==6'd34) || curr_state==IDLE))), .RST_N(rst_n), .CLOCK_GATED(G_clk_out));

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

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
            if(in_valid)    next_state = IMG1;
            else            next_state = IDLE;
        end
        IMG1: begin
            if(cnt == 6'd0)    next_state = IMG2;
            else                next_state = IMG1;
        end
        IMG2: begin
            if(cnt == 6'd0)   next_state = WAIT;
            else            next_state = IMG2;
        end
        WAIT: begin
            if(cnt == 6'd34)    next_state = IDLE; //until calculation finish
            else                next_state = WAIT;
        end
    endcase
end

//=================================
//		Counter
//=================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt <= 'd0;
    else        cnt <= cnt_comb;
end

always@(*)begin
	case(next_state)
		IDLE:	    cnt_comb = 'b0;
		IMG1:	    cnt_comb = (cnt=='d47)?'b0: cnt + 'b1;
		IMG2:	    cnt_comb = (cnt=='d47)?'b0: cnt + 'b1;
		WAIT:	    cnt_comb = (cnt=='d47)?'b0: cnt + 'b1;
	    default:	cnt_comb = 'b0;
	endcase
end

//=================================
//		Store Input
//=================================

//Opt
always@(posedge G_clk_first_input or negedge rst_n) begin
    if(!rst_n)  opt_reg <= 2'b0;
    else        opt_reg <= opt_comb;
end
always@(*) begin
    if((next_state==IMG1) && (cnt == 6'd0) && (curr_state == IDLE)) opt_comb = Opt;
    else                                                            opt_comb = opt_reg;
end

//image
genvar i_index, j_index;
generate
    for(i_index=0; i_index<4; i_index = i_index+1) begin
        for(j_index=0; j_index<4; j_index = j_index+1) begin
            if(i_index==0 && j_index==0) begin
                always @(posedge G_clk_img0 or negedge rst_n) begin
                    if(!rst_n)                                                      image_reg[0][0] <= 32'b0;
                    else if((next_state==IMG1 | next_state==IMG2) && cnt[3:0]=='d0) image_reg[0][0] <= Img;
                    else                                                            image_reg[0][0] <= image_reg[0][0];
                end
            end
            else begin
                always@(posedge G_clk_img[i_index*4+j_index-1] or negedge rst_n) begin
                    if(!rst_n)                                                                              image_reg[i_index][j_index] <= 32'b0;
                    else if((next_state==IMG1 | next_state==IMG2)&(i_index==cnt[3:2] && j_index==cnt[1:0])) image_reg[i_index][j_index] <= Img;
                    else                                                                                    image_reg[i_index][j_index] <= image_reg[i_index][j_index];
                end
            end
        end
    end
endgenerate

//padding
assign pd_00 = opt_reg[0] ? 'b0 : image_reg[0][0];
assign pd_01 = opt_reg[0] ? 'b0 : image_reg[0][1];
assign pd_02 = opt_reg[0] ? 'b0 : image_reg[0][2];
assign pd_03 = opt_reg[0] ? 'b0 : image_reg[0][3];
assign pd_10 = opt_reg[0] ? 'b0 : image_reg[1][0];
assign pd_13 = opt_reg[0] ? 'b0 : image_reg[1][3];
assign pd_20 = opt_reg[0] ? 'b0 : image_reg[2][0];
assign pd_23 = opt_reg[0] ? 'b0 : image_reg[2][3];
assign pd_30 = opt_reg[0] ? 'b0 : image_reg[3][0];
assign pd_31 = opt_reg[0] ? 'b0 : image_reg[3][1];
assign pd_32 = opt_reg[0] ? 'b0 : image_reg[3][2];
assign pd_33 = opt_reg[0] ? 'b0 : image_reg[3][3];

//kernel
//add FSM control to prevent receiving unknown
//1
genvar ker1_i, ker1_j;
generate
    for(ker1_i=0;ker1_i<3;ker1_i=ker1_i+1) begin
        for(ker1_j=0;ker1_j<3;ker1_j=ker1_j+1) begin
            if(ker1_i==0 && ker1_j==0) begin
                always @(posedge G_clk_first_input or negedge rst_n) begin
                    if(!rst_n)                                  kern1_reg[0][0] <= 32'b0;
                    else if((next_state==IMG1) && (cnt=='d0))   kern1_reg[0][0] <= Kernel;
                    else                                        kern1_reg[0][0] <= kern1_reg[0][0];
                end
            end
            else begin
                always @(posedge G_clk_input[ker1_i*3+ker1_j-1] or negedge rst_n) begin
                    if(!rst_n)                                              kern1_reg[ker1_i][ker1_j] <= 32'b0;
                    else if((next_state==IMG1) && (cnt==ker1_i*3+ker1_j))   kern1_reg[ker1_i][ker1_j] <= Kernel;
                    else                                                    kern1_reg[ker1_i][ker1_j] <= kern1_reg[ker1_i][ker1_j];
                end
            end
        end
    end
endgenerate
//2
genvar ker2_i, ker2_j;
generate
    for(ker2_i=0;ker2_i<3;ker2_i=ker2_i+1) begin
        for(ker2_j=0;ker2_j<3;ker2_j=ker2_j+1) begin
            always @(posedge G_clk_input[ker2_i*3+ker2_j+8] or negedge rst_n) begin
                if(!rst_n)                                              kern2_reg[ker2_i][ker2_j] <= 32'b0;
                else if((next_state==IMG1) && (cnt==ker2_i*3+ker2_j+9)) kern2_reg[ker2_i][ker2_j] <= Kernel;
                else                                                    kern2_reg[ker2_i][ker2_j] <= kern2_reg[ker2_i][ker2_j];
            end
        end
    end
endgenerate
//3
genvar ker3_i, ker3_j;
generate
    for(ker3_i=0;ker3_i<3;ker3_i=ker3_i+1) begin
        for(ker3_j=0;ker3_j<3;ker3_j=ker3_j+1) begin
            always @(posedge G_clk_input[ker3_i*3+ker3_j+17] or negedge rst_n) begin
                if(!rst_n)                                                  kern3_reg[ker3_i][ker3_j] <= 32'b0;
                else if((next_state==IMG1) && (cnt==ker3_i*3+ker3_j+18))    kern3_reg[ker3_i][ker3_j] <= Kernel;
                else                                                        kern3_reg[ker3_i][ker3_j] <= kern3_reg[ker3_i][ker3_j];
            end
        end
    end
endgenerate

//weight
genvar widx_i, widx_j;
generate
    for(widx_i=0;widx_i<2;widx_i=widx_i+1) begin
        for(widx_j=0;widx_j<2;widx_j=widx_j+1) begin
            if(widx_i==0 && widx_j==0) begin
                always @(posedge G_clk_first_input or negedge rst_n) begin
                    if(!rst_n)                                  weight_reg[0][0] <= 32'b0;
                    else if((next_state==IMG1) && (cnt=='d0))   weight_reg[0][0] <= Weight;
                    else                                        weight_reg[0][0] <= weight_reg[0][0];
                end
            end
            else begin
                always @(posedge G_clk_input[widx_i*2+widx_j-1] or negedge rst_n) begin
                    if(!rst_n)                                              weight_reg[widx_i][widx_j] <= 32'b0;
                    else if((next_state==IMG1) && (cnt==(widx_i*2+widx_j))) weight_reg[widx_i][widx_j] <= Weight;
                    else                                                    weight_reg[widx_i][widx_j] <= weight_reg[widx_i][widx_j];
                end
            end
        end
    end
endgenerate

//=================================
//		Registers
//=================================

//data_reg
genvar data_idx_i, data_idx_j;
generate
    for(data_idx_i=0;data_idx_i<4;data_idx_i=data_idx_i+1) begin
        for(data_idx_j=0;data_idx_j<4;data_idx_j=data_idx_j+1) begin
            always @(posedge G_clk_data[data_idx_i][data_idx_j] or negedge rst_n) begin
                if(!rst_n)  data_reg[data_idx_i][data_idx_j] <= 32'b0;
                else        data_reg[data_idx_i][data_idx_j] <= data_comb[data_idx_i][data_idx_j];
            end
        end
    end
endgenerate
//eqdata_reg
genvar eq_idx_i, eq_idx_j;
generate
    for(eq_idx_i=0;eq_idx_i<4;eq_idx_i=eq_idx_i+1) begin
        for(eq_idx_j=0;eq_idx_j<4;eq_idx_j=eq_idx_j+1) begin
            always @(posedge G_clk_cnt[eq_idx_i*4+eq_idx_j+4] or negedge rst_n) begin
                if(!rst_n)  eqdata_reg[eq_idx_i][eq_idx_j] <= 32'b0;
                else if(cnt==(eq_idx_i*4+eq_idx_j+4))        eqdata_reg[eq_idx_i][eq_idx_j] <= eqdata_comb[eq_idx_i][eq_idx_j];
            end
        end
    end
endgenerate
//pooling_reg
always @(posedge G_clk_cnt[11] or negedge rst_n) begin
    if(!rst_n)  pooling_reg[0][0] <= 32'b0;
    else        pooling_reg[0][0] <= pooling_comb[0][0]; // if(cnt=='d11)
end
always @(posedge G_clk_cnt[14] or negedge rst_n) begin
    if(!rst_n)  pooling_reg[0][1] <= 32'b0;
    else        pooling_reg[0][1] <= pooling_comb[0][1]; // if(cnt=='d14)
end
always @(posedge G_clk_cnt[20] or negedge rst_n) begin
    if(!rst_n)  pooling_reg[1][0] <= 32'b0;
    else        pooling_reg[1][0] <= pooling_comb[1][0]; // if(cnt=='d20)
end
always @(posedge G_clk_cnt[20] or negedge rst_n) begin
    if(!rst_n)  pooling_reg[1][1] <= 32'b0;
    else        pooling_reg[1][1] <= pooling_comb[1][1]; // if(cnt=='d20)
end
//feature_reg
always @(posedge G_clk_cnt[20] or negedge rst_n) begin
    if(!rst_n)  feature_reg[0] <= 32'b0;
    else        feature_reg[0] <= feature_comb[0]; // if(cnt=='d20)
end
always @(posedge G_clk_cnt[21] or negedge rst_n) begin
    if(!rst_n)  feature_reg[1] <= 32'b0;
    else        feature_reg[1] <= feature_comb[01]; // if(cnt=='d21)
end
always @(posedge G_clk_cnt[22] or negedge rst_n) begin
    if(!rst_n)  feature_reg[2] <= 32'b0;
    else        feature_reg[2] <= feature_comb[2]; // if(cnt=='d22)
end
always @(posedge G_clk_cnt[23] or negedge rst_n) begin
    if(!rst_n)  feature_reg[3] <= 32'b0;
    else        feature_reg[3] <= feature_comb[3]; // if(cnt=='d23)
end
//encoding1_reg
always @(posedge G_clk_cnt[29] or negedge rst_n) begin
    if(!rst_n)  encoding1_reg[0] <= 32'b0;
    else        encoding1_reg[0] <= encoding1_comb[0]; // if(cnt=='d29)
end
always @(posedge G_clk_cnt[30] or negedge rst_n) begin
    if(!rst_n)  encoding1_reg[1] <= 32'b0;
    else        encoding1_reg[1] <= encoding1_comb[1]; // if(cnt=='d30)
end
always @(posedge G_clk_cnt[31] or negedge rst_n) begin
    if(!rst_n)  encoding1_reg[2] <= 32'b0;
    else        encoding1_reg[2] <= encoding1_comb[2]; // if(cnt=='d31)
end
always @(posedge G_clk_cnt[32] or negedge rst_n) begin
    if(!rst_n)  encoding1_reg[3] <= 32'b0;
    else        encoding1_reg[3] <= encoding1_comb[3]; // if(cnt=='d32)
end
//encoding2_reg
always@(posedge G_clk_en2 or negedge rst_n) begin
    if(!rst_n)                                              encoding2_reg <= 32'b0;
    else if(curr_state==WAIT && (cnt>='d29 && cnt<='d32))   encoding2_reg <= d1_z;
    else                                                    encoding2_reg <= encoding2_reg;
end

//=================================
//		Counter Control
//=================================

//mult_a[0], mult_a[1], mult_a[2], mult_a[3], mult_a[4], mult_a[5], mult_a[6], mult_a[7], mult_a[8] //image
//add_b[4]
//data_comb[0:3][0:3]
always@(*) begin
    if(cg_en&~((curr_state==IMG1&&(cnt>'d8 || cnt=='d0))||(curr_state==IMG2)||(curr_state==WAIT&&cnt<'d9))) begin
        mult_a[0] = 'd0;           mult_a[1] = 'd0;                 mult_a[2] = 'd0;
        mult_a[3] = 'd0;           mult_a[4] = 'd0;                 mult_a[5] = 'd0;
        mult_a[6] = 'd0;           mult_a[7] = 'd0;                 mult_a[8] = 'd0;
    end
    else begin
    case(cnt) //0~47, 6 bits
        6'd9, 6'd25, 6'd41: begin //00
            mult_a[0] = pd_00;           mult_a[1] = pd_00;           mult_a[2] = pd_01;          
            mult_a[3] = pd_00;           mult_a[4] = image_reg[0][0]; mult_a[5] = image_reg[0][1];
            mult_a[6] = pd_10;           mult_a[7] = image_reg[1][0]; mult_a[8] = image_reg[1][1];
            
        end
        6'd10, 6'd26, 6'd42: begin //01
            mult_a[0] = pd_00;           mult_a[1] = pd_01;           mult_a[2] = pd_02;          
            mult_a[3] = image_reg[0][0]; mult_a[4] = image_reg[0][1]; mult_a[5] = image_reg[0][2];
            mult_a[6] = image_reg[1][0]; mult_a[7] = image_reg[1][1]; mult_a[8] = image_reg[1][2];
            
        end
        6'd11, 6'd27, 6'd43: begin //02
            mult_a[0] = pd_01;           mult_a[1] = pd_02;           mult_a[2] = pd_03;          
            mult_a[3] = image_reg[0][1]; mult_a[4] = image_reg[0][2]; mult_a[5] = image_reg[0][3];
            mult_a[6] = image_reg[1][1]; mult_a[7] = image_reg[1][2]; mult_a[8] = image_reg[1][3];
            
        end
        6'd12, 6'd28, 6'd44: begin //03
            mult_a[0] = pd_02;           mult_a[1] = pd_03;           mult_a[2] = pd_03;          
            mult_a[3] = image_reg[0][2]; mult_a[4] = image_reg[0][3]; mult_a[5] = pd_03;
            mult_a[6] = image_reg[1][2]; mult_a[7] = image_reg[1][3]; mult_a[8] = pd_13;
            
        end
        6'd13, 6'd29, 6'd45: begin //10
            mult_a[0] = pd_00;           mult_a[1] = image_reg[0][0]; mult_a[2] = image_reg[0][1];
            mult_a[3] = pd_10;           mult_a[4] = image_reg[1][0]; mult_a[5] = image_reg[1][1];
            mult_a[6] = pd_20;           mult_a[7] = image_reg[2][0]; mult_a[8] = image_reg[2][1];
            
        end
        6'd14, 6'd30, 6'd46: begin //11
            mult_a[0] = image_reg[0][0]; mult_a[1] = image_reg[0][1]; mult_a[2] = image_reg[0][2];
            mult_a[3] = image_reg[1][0]; mult_a[4] = image_reg[1][1]; mult_a[5] = image_reg[1][2];
            mult_a[6] = image_reg[2][0]; mult_a[7] = image_reg[2][1]; mult_a[8] = image_reg[2][2];
            
        end
        6'd15, 6'd31, 6'd47: begin //12
            mult_a[0] = image_reg[0][1]; mult_a[1] = image_reg[0][2]; mult_a[2] = image_reg[0][3];
            mult_a[3] = image_reg[1][1]; mult_a[4] = image_reg[1][2]; mult_a[5] = image_reg[1][3];
            mult_a[6] = image_reg[2][1]; mult_a[7] = image_reg[2][2]; mult_a[8] = image_reg[2][3];
            
        end
        6'd16, 6'd32, 6'd0: begin //13
            mult_a[0] = image_reg[0][2]; mult_a[1] = image_reg[0][3]; mult_a[2] = pd_03;
            mult_a[3] = image_reg[1][2]; mult_a[4] = image_reg[1][3]; mult_a[5] = pd_13;
            mult_a[6] = image_reg[2][2]; mult_a[7] = image_reg[2][3]; mult_a[8] = pd_23;
            
        end
        6'd17, 6'd33, 6'd1: begin //20
            mult_a[0] = pd_10;           mult_a[1] = image_reg[1][0]; mult_a[2] = image_reg[1][1];
            mult_a[3] = pd_20;           mult_a[4] = image_reg[2][0]; mult_a[5] = image_reg[2][1];
            mult_a[6] = pd_30;           mult_a[7] = image_reg[3][0]; mult_a[8] = image_reg[3][1];
            
        end
        6'd18, 6'd34, 6'd2: begin //21
            mult_a[0] = image_reg[1][0]; mult_a[1] = image_reg[1][1]; mult_a[2] = image_reg[1][2];
            mult_a[3] = image_reg[2][0]; mult_a[4] = image_reg[2][1]; mult_a[5] = image_reg[2][2];
            mult_a[6] = image_reg[3][0]; mult_a[7] = image_reg[3][1]; mult_a[8] = image_reg[3][2];
            
        end
        6'd19, 6'd35, 6'd3: begin //22
            mult_a[0] = image_reg[1][1]; mult_a[1] = image_reg[1][2]; mult_a[2] = image_reg[1][3];
            mult_a[3] = image_reg[2][1]; mult_a[4] = image_reg[2][2]; mult_a[5] = image_reg[2][3];
            mult_a[6] = image_reg[3][1]; mult_a[7] = image_reg[3][2]; mult_a[8] = image_reg[3][3];
            
        end
        6'd20, 6'd36, 6'd4: begin //23
            mult_a[0] = image_reg[1][2]; mult_a[1] = image_reg[1][3]; mult_a[2] = pd_13;
            mult_a[3] = image_reg[2][2]; mult_a[4] = image_reg[2][3]; mult_a[5] = pd_23;
            mult_a[6] = image_reg[3][2]; mult_a[7] = image_reg[3][3]; mult_a[8] = pd_33;
            
        end
        6'd21, 6'd37, 6'd5: begin //30
            mult_a[0] = pd_20;           mult_a[1] = image_reg[2][0]; mult_a[2] = image_reg[2][1];
            mult_a[3] = pd_30;           mult_a[4] = image_reg[3][0]; mult_a[5] = image_reg[3][1];
            mult_a[6] = pd_30;           mult_a[7] = pd_30;           mult_a[8] = pd_31;
            
        end
        6'd22, 6'd38, 6'd6: begin //31
            mult_a[0] = image_reg[2][0]; mult_a[1] = image_reg[2][1]; mult_a[2] = image_reg[2][2];
            mult_a[3] = image_reg[3][0]; mult_a[4] = image_reg[3][1]; mult_a[5] = image_reg[3][2];
            mult_a[6] = pd_30;           mult_a[7] = pd_31;           mult_a[8] = pd_32;
            
        end
        6'd23, 6'd39, 6'd7: begin //32
            mult_a[0] = image_reg[2][1]; mult_a[1] = image_reg[2][2]; mult_a[2] = image_reg[2][3];
            mult_a[3] = image_reg[3][1]; mult_a[4] = image_reg[3][2]; mult_a[5] = image_reg[3][3];
            mult_a[6] = pd_31;           mult_a[7] = pd_32;           mult_a[8] = pd_33;
            
        end
        6'd24, 6'd40, 6'd8: begin //33
            mult_a[0] = image_reg[2][2]; mult_a[1] = image_reg[2][3]; mult_a[2] = pd_23;
            mult_a[3] = image_reg[3][2]; mult_a[4] = image_reg[3][3]; mult_a[5] = pd_33;
            mult_a[6] = pd_32;           mult_a[7] = pd_33;           mult_a[8] = pd_33;
            
        end
        default: begin
            mult_a[0] = 'b0;             mult_a[1] = 'b0;             mult_a[2] = 'b0;
            mult_a[3] = 'b0;             mult_a[4] = 'b0;             mult_a[5] = 'b0;
            mult_a[6] = 'b0;             mult_a[7] = 'b0;             mult_a[8] = 'b0;
            
        end

    endcase
    end
end

always@(*) begin
    case(cnt) //0~47, 6 bits
        6'd9, 6'd25, 6'd41: begin //00
            
            add_b[4] = (cnt == 6'd25)? 32'b0 : data_reg[3][1];
            data_comb[3][1] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];                                       data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd10, 6'd26, 6'd42: begin //01
            
            add_b[4] = (cnt == 6'd26)? 32'b0 : data_reg[3][2];
            data_comb[3][2] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];                                       data_comb[3][3] = data_reg[3][3];
        end
        6'd11, 6'd27, 6'd43: begin //02
            
            add_b[4] = (cnt == 6'd27)? 32'b0 : data_reg[3][3];
            data_comb[3][3] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];
        end
        6'd12, 6'd28, 6'd44: begin //03
            
            add_b[4] = (cnt == 6'd12)? 32'b0 : data_reg[0][0];
            data_comb[0][0] = add_z[4];
                                                data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd13, 6'd29, 6'd45: begin //10
            
            add_b[4] = (cnt == 6'd13)? 32'b0 : data_reg[0][1];
            data_comb[0][1] = add_z[4];
            data_comb[0][0] = data_reg[0][0];                                       data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd14, 6'd30, 6'd46: begin //11
            
            add_b[4] = (cnt == 6'd14)? 32'b0 : data_reg[0][2];
            data_comb[0][2] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];                                       data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd15, 6'd31, 6'd47: begin //12
            
            add_b[4] = (cnt == 6'd15)? 32'b0 : data_reg[0][3];
            data_comb[0][3] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd16, 6'd32, 6'd0: begin //13
            
            add_b[4] = (cnt == 6'd16)? 32'b0 : data_reg[1][0];
            data_comb[1][0] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
                                                data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd17, 6'd33, 6'd1: begin //20
            
            add_b[4] = (cnt == 6'd17)? 32'b0 : data_reg[1][1];
            data_comb[1][1] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];                                       data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd18, 6'd34, 6'd2: begin //21
            
            add_b[4] = (cnt == 6'd18)? 32'b0 : data_reg[1][2];
            data_comb[1][2] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];                                       data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd19, 6'd35, 6'd3: begin //22
            
            add_b[4] = (cnt == 6'd19)? 32'b0 : data_reg[1][3];
            data_comb[1][3] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd20, 6'd36, 6'd4: begin //23
            
            add_b[4] = (cnt == 6'd20)? 32'b0 : data_reg[2][0];
            data_comb[2][0] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
                                                data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd21, 6'd37, 6'd5: begin //30
           
            add_b[4] = (cnt == 6'd21)? 32'b0 : data_reg[2][1];
            data_comb[2][1] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];                                       data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd22, 6'd38, 6'd6: begin //31
            
            add_b[4] = (cnt == 6'd22)? 32'b0 : data_reg[2][2];
            data_comb[2][2] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];                                       data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd23, 6'd39, 6'd7: begin //32
            
            add_b[4] = (cnt == 6'd23)? 32'b0 : data_reg[2][3];
            data_comb[2][3] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd24, 6'd40, 6'd8: begin //33
            
            add_b[4] = (cnt == 6'd24)? 32'b0 : data_reg[3][0];
            data_comb[3][0] = add_z[4];
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
                                                data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        default: begin
            
            add_b[4] = 32'b0;
            for(i=0;i<4;i=i+1) begin
                for(j=0;j<4;j=j+1) begin
                    data_comb[i][j] = data_reg[i][j];
                end
            end
        end

    endcase
end

//mult_b[0], mult_b[1], mult_b[2], mult_b[3], mult_b[4], mult_b[5], mult_b[6], mult_b[7], mult_b[8] //kernel
always@(*) begin
    if(cg_en&~((curr_state==IMG1&&(cnt>'d8 || cnt=='d0))||(curr_state==IMG2)||(curr_state==WAIT&&cnt<'d9))) begin
        mult_b[0] = 'd0; mult_b[1] = 'd0; mult_b[2] = 'd0;
        mult_b[3] = 'd0; mult_b[4] = 'd0; mult_b[5] = 'd0;
        mult_b[6] = 'd0; mult_b[7] = 'd0; mult_b[8] = 'd0;
        
    end
    else begin
        if((cnt >= 6'd9) && (cnt <= 6'd24)) begin //kernel 1
            mult_b[0] = kern1_reg[0][0]; mult_b[1] = kern1_reg[0][1]; mult_b[2] = kern1_reg[0][2];
            mult_b[3] = kern1_reg[1][0]; mult_b[4] = kern1_reg[1][1]; mult_b[5] = kern1_reg[1][2];
            mult_b[6] = kern1_reg[2][0]; mult_b[7] = kern1_reg[2][1]; mult_b[8] = kern1_reg[2][2];
        end
        else if((cnt >= 6'd25) && (cnt <= 6'd40)) begin //kernel 2
            mult_b[0] = kern2_reg[0][0]; mult_b[1] = kern2_reg[0][1]; mult_b[2] = kern2_reg[0][2];
            mult_b[3] = kern2_reg[1][0]; mult_b[4] = kern2_reg[1][1]; mult_b[5] = kern2_reg[1][2];
            mult_b[6] = kern2_reg[2][0]; mult_b[7] = kern2_reg[2][1]; mult_b[8] = kern2_reg[2][2];
        end
        else begin //kernel 3
            mult_b[0] = kern3_reg[0][0]; mult_b[1] = kern3_reg[0][1]; mult_b[2] = kern3_reg[0][2];
            mult_b[3] = kern3_reg[1][0]; mult_b[4] = kern3_reg[1][1]; mult_b[5] = kern3_reg[1][2];
            mult_b[6] = kern3_reg[2][0]; mult_b[7] = kern3_reg[2][1]; mult_b[8] = kern3_reg[2][2];
        end
    end
end


//* equalization

//data padding
assign data_pd_00 = opt_reg[0] ? 'b0 : data_reg[0][0];
assign data_pd_01 = opt_reg[0] ? 'b0 : data_reg[0][1];
assign data_pd_02 = opt_reg[0] ? 'b0 : data_reg[0][2];
assign data_pd_03 = opt_reg[0] ? 'b0 : data_reg[0][3];
assign data_pd_10 = opt_reg[0] ? 'b0 : data_reg[1][0];
assign data_pd_13 = opt_reg[0] ? 'b0 : data_reg[1][3];
assign data_pd_20 = opt_reg[0] ? 'b0 : data_reg[2][0];
assign data_pd_23 = opt_reg[0] ? 'b0 : data_reg[2][3];
assign data_pd_30 = opt_reg[0] ? 'b0 : data_reg[3][0];
assign data_pd_31 = opt_reg[0] ? 'b0 : data_reg[3][1];
assign data_pd_32 = opt_reg[0] ? 'b0 : data_reg[3][2];
assign data_pd_33 = opt_reg[0] ? 'b0 : data_reg[3][3];

//sum_a, sum_b, sum_c [0:2]
always @(*) begin
    case(cnt)
        'd2: begin
            sum_a[0] = data_pd_00;      sum_b[0] = data_pd_00;      sum_c[0] = data_pd_01;
            sum_a[1] = data_pd_00;      sum_b[1] = data_reg[0][0];  sum_c[1] = data_reg[0][1];
            sum_a[2] = data_pd_10;      sum_b[2] = data_reg[1][0];  sum_c[2] = data_reg[1][1];
        end
        'd3: begin
            sum_a[0] = data_pd_00;      sum_b[0] = data_pd_01;      sum_c[0] = data_pd_02;
            sum_a[1] = data_reg[0][0];  sum_b[1] = data_reg[0][1];  sum_c[1] = data_reg[0][2];
            sum_a[2] = data_reg[1][0];  sum_b[2] = data_reg[1][1];  sum_c[2] = data_reg[1][2];
        end
        'd4: begin
            sum_a[0] = data_pd_01;      sum_b[0] = data_pd_02;      sum_c[0] = data_pd_03;
            sum_a[1] = data_reg[0][1];  sum_b[1] = data_reg[0][2];  sum_c[1] = data_reg[0][3];
            sum_a[2] = data_reg[1][1];  sum_b[2] = data_reg[1][2];  sum_c[2] = data_reg[1][3];
        end
        'd5: begin
            sum_a[0] = data_pd_02;      sum_b[0] = data_pd_03;      sum_c[0] = data_pd_03;
            sum_a[1] = data_reg[0][2];  sum_b[1] = data_reg[0][3];  sum_c[1] = data_pd_03;
            sum_a[2] = data_reg[1][2];  sum_b[2] = data_reg[1][3];  sum_c[2] = data_pd_13;
        end
        'd6: begin
            sum_a[0] = data_pd_00;      sum_b[0] = data_reg[0][0];  sum_c[0] = data_reg[0][1];
            sum_a[1] = data_pd_10;      sum_b[1] = data_reg[1][0];  sum_c[1] = data_reg[1][1];
            sum_a[2] = data_pd_20;      sum_b[2] = data_reg[2][0];  sum_c[2] = data_reg[2][1];
        end
        'd7: begin
            sum_a[0] = data_reg[0][0];  sum_b[0] = data_reg[0][1];  sum_c[0] = data_reg[0][2];
            sum_a[1] = data_reg[1][0];  sum_b[1] = data_reg[1][1];  sum_c[1] = data_reg[1][2];
            sum_a[2] = data_reg[2][0];  sum_b[2] = data_reg[2][1];  sum_c[2] = data_reg[2][2];
        end
        'd8: begin
            sum_a[0] = data_reg[0][1];  sum_b[0] = data_reg[0][2];  sum_c[0] = data_reg[0][3];
            sum_a[1] = data_reg[1][1];  sum_b[1] = data_reg[1][2];  sum_c[1] = data_reg[1][3];
            sum_a[2] = data_reg[2][1];  sum_b[2] = data_reg[2][2];  sum_c[2] = data_reg[2][3];
        end
        'd9: begin
            sum_a[0] = data_reg[0][2];  sum_b[0] = data_reg[0][3];  sum_c[0] = data_pd_03;
            sum_a[1] = data_reg[1][2];  sum_b[1] = data_reg[1][3];  sum_c[1] = data_pd_13;
            sum_a[2] = data_reg[2][2];  sum_b[2] = data_reg[2][3];  sum_c[2] = data_pd_23;
        end
        'd10: begin
            sum_a[0] = data_pd_10;      sum_b[0] = data_reg[1][0];  sum_c[0] = data_reg[1][1];
            sum_a[1] = data_pd_20;      sum_b[1] = data_reg[2][0];  sum_c[1] = data_reg[2][1];
            sum_a[2] = data_pd_30;      sum_b[2] = data_reg[3][0];  sum_c[2] = data_reg[3][1];
        end
        'd11: begin
            sum_a[0] = data_reg[1][0];  sum_b[0] = data_reg[1][1];  sum_c[0] = data_reg[1][2];
            sum_a[1] = data_reg[2][0];  sum_b[1] = data_reg[2][1];  sum_c[1] = data_reg[2][2];
            sum_a[2] = data_reg[3][0];  sum_b[2] = data_reg[3][1];  sum_c[2] = data_reg[3][2];
        end
        'd12: begin
            sum_a[0] = data_reg[1][1];  sum_b[0] = data_reg[1][2];  sum_c[0] = data_reg[1][3];
            sum_a[1] = data_reg[2][1];  sum_b[1] = data_reg[2][2];  sum_c[1] = data_reg[2][3];
            sum_a[2] = data_reg[3][1];  sum_b[2] = data_reg[3][2];  sum_c[2] = data_reg[3][3];
        end
        'd13: begin
            sum_a[0] = data_reg[1][2];  sum_b[0] = data_reg[1][3];  sum_c[0] = data_pd_13;
            sum_a[1] = data_reg[2][2];  sum_b[1] = data_reg[2][3];  sum_c[1] = data_pd_23;
            sum_a[2] = data_reg[3][2];  sum_b[2] = data_reg[3][3];  sum_c[2] = data_pd_33;
        end
        'd14: begin
            sum_a[0] = data_pd_20;      sum_b[0] = data_reg[2][0];  sum_c[0] = data_reg[2][1];
            sum_a[1] = data_pd_30;      sum_b[1] = data_reg[3][0];  sum_c[1] = data_reg[3][1];
            sum_a[2] = data_pd_30;      sum_b[2] = data_pd_30;      sum_c[2] = data_pd_31;
        end
        'd15: begin
            sum_a[0] = data_reg[2][0];  sum_b[0] = data_reg[2][1];  sum_c[0] = data_reg[2][2];
            sum_a[1] = data_reg[3][0];  sum_b[1] = data_reg[3][1];  sum_c[1] = data_reg[3][2];
            sum_a[2] = data_pd_30;      sum_b[2] = data_pd_31;      sum_c[2] = data_pd_32;
        end
        'd16: begin
            sum_a[0] = data_reg[2][1];  sum_b[0] = data_reg[2][2];  sum_c[0] = data_reg[2][3];
            sum_a[1] = data_reg[3][1];  sum_b[1] = data_reg[3][2];  sum_c[1] = data_reg[3][3];
            sum_a[2] = data_pd_31;      sum_b[2] = data_pd_32;      sum_c[2] = data_pd_33;
        end
        'd17: begin
            sum_a[0] = data_reg[2][2];  sum_b[0] = data_reg[2][3];  sum_c[0] = data_pd_23;
            sum_a[1] = data_reg[3][2];  sum_b[1] = data_reg[3][3];  sum_c[1] = data_pd_33;
            sum_a[2] = data_pd_32;      sum_b[2] = data_pd_33;      sum_c[2] = data_pd_33;
        end
        default: begin
            sum_a[0] = 'd0;             sum_b[0] = 'd0;             sum_c[0] = 'd0;
            sum_a[1] = 'd0;             sum_b[1] = 'd0;             sum_c[1] = 'd0;
            sum_a[2] = 'd0;             sum_b[2] = 'd0;             sum_c[2] = 'd0;
        end
    endcase
end

//eqdata_comb
always @(*) begin
    for(i=0;i<4;i=i+1) begin
        for(j=0;j<4;j=j+1) begin
            eqdata_comb[i][j] = eqdata_reg[i][j];
        end
    end
    case(cnt)
        'd4:    eqdata_comb[0][0] = d9_z;
        'd5:    eqdata_comb[0][1] = d9_z;
        'd6:    eqdata_comb[0][2] = d9_z;
        'd7:    eqdata_comb[0][3] = d9_z;
        'd8:    eqdata_comb[1][0] = d9_z;
        'd9:    eqdata_comb[1][1] = d9_z;
        'd10:   eqdata_comb[1][2] = d9_z;
        'd11:   eqdata_comb[1][3] = d9_z;
        'd12:   eqdata_comb[2][0] = d9_z;
        'd13:   eqdata_comb[2][1] = d9_z;
        'd14:   eqdata_comb[2][2] = d9_z;
        'd15:   eqdata_comb[2][3] = d9_z;
        'd16:   eqdata_comb[3][0] = d9_z;
        'd17:   eqdata_comb[3][1] = d9_z;
        'd18:   eqdata_comb[3][2] = d9_z;
        'd19:   eqdata_comb[3][3] = d9_z;
    endcase
end


//find max
//max pooling & min-max
//c0_a, c0_b, c1_a, c1_b
always@(*) begin
    case(cnt)
        6'd9: begin
            c0_a = eqdata_reg[0][0];
            c0_b = eqdata_reg[0][1];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd10: begin
            c0_a = c0_max_reg;
            c0_b = eqdata_reg[1][0];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd11: begin
            c0_a = c0_max_reg;
            c0_b = eqdata_reg[1][1]; //find left top max
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd12: begin
            c0_a = eqdata_reg[0][2];
            c0_b = eqdata_reg[0][3];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd13: begin
            c0_a = c0_max_reg;
            c0_b = eqdata_reg[1][2];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd14: begin
            c0_a = c0_max_reg;
            c0_b = eqdata_reg[1][3]; //find right top max
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd18: begin
            c0_a = eqdata_reg[2][2];
            c0_b = eqdata_reg[2][3];
            c1_a = eqdata_reg[2][0];
            c1_b = eqdata_reg[2][1];
        end
        6'd19: begin
            c0_a = c0_max_reg;
            c0_b = eqdata_reg[3][2];
            c1_a = c1_max_reg;
            c1_b = eqdata_reg[3][0];
        end
        6'd20: begin
            c0_a = c0_max_reg;
            c0_b = eqdata_reg[3][3]; //find right bottom max
            c1_a = c1_max_reg;
            c1_b = eqdata_reg[3][1]; //find left bottom max
        end
        //6'd22, 6'd23, 6'd24: begin //min-max
        //    c0_a = max_reg;
        //    c0_b = feature_reg[3];
        //    c1_a = min_reg;
        //    c1_b = feature_reg[3];
        //end
        6'd22: begin
            c0_a = max_reg;
            c0_b = feature_reg[1];
            c1_a = min_reg;
            c1_b = feature_reg[1];
        end
        6'd23: begin
            c0_a = max_reg;
            c0_b = feature_reg[2];
            c1_a = min_reg;
            c1_b = feature_reg[2];
        end
        6'd24: begin
            c0_a = max_reg;
            c0_b = feature_reg[3];
            c1_a = min_reg;
            c1_b = feature_reg[3];
        end
        default: begin
            c0_a = 32'b0;
            c0_b = 32'b0;
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
    endcase
end
//min-max
always@(*) begin
    case(cnt)
        6'd20: begin
            max_comb = add_z[5];
            min_comb = add_z[5];
        end
        6'd21: begin
            max_comb = max_reg;
            min_comb = min_reg;
        end
        6'd22: begin
            max_comb = c0_max;
            min_comb = c1_min;
        end
        6'd23: begin
            max_comb = c0_max;
            min_comb = c1_min;
        end
        6'd24: begin
            max_comb = c0_max;
            min_comb = c1_min;
        end
        default: begin
            max_comb = max_reg;
            min_comb = min_reg;
        end
    endcase
end

//pooling_comb
always@(*) begin
    case(cnt)
        6'd11: begin
            pooling_comb[0][0] = c0_max;            pooling_comb[0][1] = pooling_reg[0][1];
            pooling_comb[1][0] = pooling_reg[1][0]; pooling_comb[1][1] = pooling_reg[1][1];
        end
        6'd14: begin
            pooling_comb[0][0] = pooling_reg[0][0]; pooling_comb[0][1] = c0_max;
            pooling_comb[1][0] = pooling_reg[1][0]; pooling_comb[1][1] = pooling_reg[1][1];
        end
        6'd20: begin
            pooling_comb[0][0] = pooling_reg[0][0]; pooling_comb[0][1] = pooling_reg[0][1];
            pooling_comb[1][0] = c1_max;            pooling_comb[1][1] = c0_max;
        end
        default: begin
            pooling_comb[0][0] = pooling_reg[0][0]; pooling_comb[0][1] = pooling_reg[0][1];
            pooling_comb[1][0] = pooling_reg[1][0]; pooling_comb[1][1] = pooling_reg[1][1];
        end
    endcase
end

//fully connected
//mult_a[9], mult_a[10], mult_b[9], mult_b[10]
always@(*) begin
    case(cnt)
        6'd19: begin
            mult_a[9]  = pooling_reg[0][0];  mult_b[9]  = weight_reg[0][0];
            mult_a[10] = pooling_reg[0][1];  mult_b[10] = weight_reg[1][0];
        end
        6'd20: begin
            mult_a[9]  = pooling_reg[0][0];  mult_b[9]  = weight_reg[0][1];
            mult_a[10] = pooling_reg[0][1];  mult_b[10] = weight_reg[1][1];
        end
        6'd21: begin
            mult_a[9]  = pooling_reg[1][0];  mult_b[9]  = weight_reg[0][0];
            mult_a[10] = pooling_reg[1][1];  mult_b[10] = weight_reg[1][0];
        end
        6'd22: begin
            mult_a[9]  = pooling_reg[1][0];  mult_b[9]  = weight_reg[0][1];
            mult_a[10] = pooling_reg[1][1];  mult_b[10] = weight_reg[1][1];
        end
        default: begin
            mult_a[9]  = 32'b0;              mult_b[9]  = 32'b0;
            mult_a[10] = 32'b0;              mult_b[10] = 32'b0;
        end
    endcase
end
//feature_comb
always@(*) begin
    case(cnt)
        //6'd20, 6'd21, 6'd22, 6'd23: begin
        //    feature_comb[0] = feature_reg[1];   feature_comb[1] = feature_reg[2];   feature_comb[2] = feature_reg[3];   feature_comb[3] = add_z[5];
        //end
        6'd20: begin
            feature_comb[0] = add_z[5];         feature_comb[1] = feature_reg[1];   feature_comb[2] = feature_reg[2];   feature_comb[3] = feature_reg[3];
        end
        6'd21: begin
            feature_comb[0] = feature_reg[0];   feature_comb[1] = add_z[5];         feature_comb[2] = feature_reg[2];   feature_comb[3] = feature_reg[3];
        end
        6'd22: begin
            feature_comb[0] = feature_reg[0];   feature_comb[1] = feature_reg[1];   feature_comb[2] = add_z[5];         feature_comb[3] = feature_reg[3];
        end
        6'd23: begin
            feature_comb[0] = feature_reg[0];   feature_comb[1] = feature_reg[1];   feature_comb[2] = feature_reg[2];   feature_comb[3] = add_z[5];
        end
        default: begin
            feature_comb[0] = feature_reg[0];   feature_comb[1] = feature_reg[1];   feature_comb[2] = feature_reg[2];   feature_comb[3] = feature_reg[3];
        end
    endcase
end

//normalization
always@(*) begin
    case(cnt)
        6'd25: begin
            s0_a = feature_reg[0];
        end
        6'd26: begin
            s0_a = feature_reg[1];
        end
        6'd27: begin
            s0_a = feature_reg[2];
        end
        6'd28: begin
            s0_a = feature_reg[3];
        end
        default: begin
            s0_a = 32'b0;
        end
    endcase
end
always@(*) begin
    s0_b = min_reg;
    s1_a = max_reg;
    s1_b = min_reg;
end

//encoding1_comb <-- IMG2, encoding2_comb <--WAIT
always@(*) begin
    if(curr_state == IMG2) begin
        case(cnt)
            //6'd29, 6'd30, 6'd31, 6'd32: begin
            //    encoding1_comb[0] = encoding1_reg[1];   encoding1_comb[1] = encoding1_reg[2];   encoding1_comb[2] = encoding1_reg[3];   encoding1_comb[3] = d1_z;
            //end
            6'd29: begin
                encoding1_comb[0] = d1_z;               encoding1_comb[1] = encoding1_reg[1];   encoding1_comb[2] = encoding1_reg[2];   encoding1_comb[3] = encoding1_reg[3];
            end
            6'd30: begin
                encoding1_comb[0] = encoding1_reg[0];   encoding1_comb[1] = d1_z;               encoding1_comb[2] = encoding1_reg[2];   encoding1_comb[3] = encoding1_reg[3];
            end
            6'd31: begin
                encoding1_comb[0] = encoding1_reg[0];   encoding1_comb[1] = encoding1_reg[1];   encoding1_comb[2] = d1_z;               encoding1_comb[3] = encoding1_reg[3];
            end
            6'd32: begin
                encoding1_comb[0] = encoding1_reg[0];   encoding1_comb[1] = encoding1_reg[1];   encoding1_comb[2] = encoding1_reg[2];   encoding1_comb[3] = d1_z; 
            end
            default: begin
                encoding1_comb[0] = encoding1_reg[0];   encoding1_comb[1] = encoding1_reg[1];   encoding1_comb[2] = encoding1_reg[2];   encoding1_comb[3] = encoding1_reg[3];
            end
        endcase
    end
    else begin
        encoding1_comb[0] = encoding1_reg[0]; encoding1_comb[1] = encoding1_reg[1]; encoding1_comb[2] = encoding1_reg[2];   encoding1_comb[3] = encoding1_reg[3];
    end
end

//L1 distance
//s3_a, s3_b
always@(*) begin
    case(cnt)
        6'd30: begin
            s3_a = encoding1_reg[0];    s3_b = encoding2_reg;
        end
        6'd31: begin
            s3_a = encoding1_reg[1];    s3_b = encoding2_reg;
        end
        6'd32: begin
            s3_a = encoding1_reg[2];    s3_b = encoding2_reg;
        end
        6'd33: begin
            s3_a = encoding1_reg[3];    s3_b = encoding2_reg;
        end
        default: begin
            s3_a = 32'b0;               s3_b = 32'b0;
        end
    endcase
end
//a7_b
always@(*) begin
    case(cnt)
        6'd31: begin
            a7_b = 32'b0;
        end
        6'd32: begin
            a7_b = a7_z_reg;
        end
        6'd33: begin
            a7_b = a7_z_reg;
        end
        6'd34: begin
            a7_b = a7_z_reg;
        end
        default: begin
            a7_b = 32'b0;
        end
    endcase
end

//=================================
//		Convolution
//=================================

//9 mults
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M0(.a(mult_a[0]), .b(mult_b[0]), .rnd(3'b000), .z(mult_z[0]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M1(.a(mult_a[1]), .b(mult_b[1]), .rnd(3'b000), .z(mult_z[1]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M2(.a(mult_a[2]), .b(mult_b[2]), .rnd(3'b000), .z(mult_z[2]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M3(.a(mult_a[3]), .b(mult_b[3]), .rnd(3'b000), .z(mult_z[3]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M4(.a(mult_a[4]), .b(mult_b[4]), .rnd(3'b000), .z(mult_z[4]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M5(.a(mult_a[5]), .b(mult_b[5]), .rnd(3'b000), .z(mult_z[5]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M6(.a(mult_a[6]), .b(mult_b[6]), .rnd(3'b000), .z(mult_z[6]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M7(.a(mult_a[7]), .b(mult_b[7]), .rnd(3'b000), .z(mult_z[7]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M8(.a(mult_a[8]), .b(mult_b[8]), .rnd(3'b000), .z(mult_z[8]));
//adder tree
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A0(.a(add_a[0]), .b(add_b[0]), .c(add_c[0]), .rnd(3'b000), .z(add_z[0]), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A1(.a(add_a[1]), .b(add_b[1]), .c(add_c[1]), .rnd(3'b000), .z(add_z[1]), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A2(.a(add_a[2]), .b(add_b[2]), .c(add_c[2]), .rnd(3'b000), .z(add_z[2]), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A3(.a(add_a[3]), .b(add_b[3]), .c(add_c[3]), .rnd(3'b000), .z(add_z[3]), .status()); //result of 1 channel conv
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A4(.a(add_a[4]), .b(add_b[4]), .rnd(3'b000), .z(add_z[4])); //add 3 channels //add_b[4] <-- counter control
//mult & add pipeline
always@(posedge clk or negedge rst_n) begin //G_clk_mult0to8
    if(!rst_n)  add_a[0] <= 32'b0;
    else        add_a[0] <= mult_z[0];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_b[0] <= 32'b0;
    else        add_b[0] <= mult_z[1];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_c[0] <= 32'b0;
    else        add_c[0] <= mult_z[2];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_a[1] <= 32'b0;
    else        add_a[1] <= mult_z[3];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_b[1] <= 32'b0;
    else        add_b[1] <= mult_z[4];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_c[1] <= 32'b0;
    else        add_c[1] <= mult_z[5];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_a[2] <= 32'b0;
    else        add_a[2] <= mult_z[6];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_b[2] <= 32'b0;
    else        add_b[2] <= mult_z[7];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_c[2] <= 32'b0;
    else        add_c[2] <= mult_z[8];
end
//9-->3
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_a[3] <= 32'b0;
    else        add_a[3] <= add_z[0];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_b[3] <= 32'b0;
    else        add_b[3] <= add_z[1];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_c[3] <= 32'b0;
    else        add_c[3] <= add_z[2];
end
//2-->1
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_a[4] <= 32'b0;
    else        add_a[4] <= add_z[3];
end

//=================================
//		Equalization
//=================================

//equalization
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A10(.a(sum_a[0]), .b(sum_b[0]), .c(sum_c[0]), .rnd(3'b000), .z(sum_z[0]), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A11(.a(sum_a[1]), .b(sum_b[1]), .c(sum_c[1]), .rnd(3'b000), .z(sum_z[1]), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A12(.a(sum_a[2]), .b(sum_b[2]), .c(sum_c[2]), .rnd(3'b000), .z(sum_z[2]), .status());
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A13(.a(sum_a[3]), .b(sum_b[3]), .c(sum_c[3]), .rnd(3'b000), .z(sum_z[3]), .status());
DW_fp_div  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) DIV9(.a(d9_a), .b(32'b01000001000100000000000000000000), .rnd(3'b000), .z(d9_z));

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_a[3] <= 32'd0;
        sum_b[3] <= 32'd0;
        sum_c[3] <= 32'd0;
    end
    else begin
        sum_a[3] <= sum_z[0];
        sum_b[3] <= sum_z[1];
        sum_c[3] <= sum_z[2];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  d9_a <= 32'd0;
    else        d9_a <= sum_z[3];
end


//=================================
//		Max-Pooling
//=================================

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) C0(.a(c0_a), .b(c0_b), .zctr(1'b0), .z0(c0_min), .z1(c0_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) C1(.a(c1_a), .b(c1_b), .zctr(1'b0), .z0(c1_min), .z1(c1_max));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  c0_max_reg <= 32'b0;
    else        c0_max_reg <= c0_max;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  c1_max_reg <= 32'b0;
    else        c1_max_reg <= c1_max;
end
//for min-max
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  max_reg <= 32'b0;
    else        max_reg <= max_comb;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  min_reg <= 32'b0;
    else        min_reg <= min_comb;
end

//=================================
//		Fully Connected
//=================================

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M9(.a(mult_a[9]), .b(mult_b[9]), .rnd(3'b000), .z(mult_z[9]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M10(.a(mult_a[10]), .b(mult_b[10]), .rnd(3'b000), .z(mult_z[10]));
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A5(.a(add_a[5]), .b(add_b[5]), .rnd(3'b000), .z(add_z[5])); //feature map

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_a[5] <= 32'b0;
    else        add_a[5] <= mult_z[9];
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  add_b[5] <= 32'b0;
    else        add_b[5] <= mult_z[10];
end

//=================================
//		Min-Max Normalization
//=================================

DW_fp_sub  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S0(.a(s0_a), .b(s0_b), .rnd(3'b000), .z(s0_z)); //x - min
DW_fp_sub  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S1(.a(s1_a), .b(s1_b), .rnd(3'b000), .z(s1_z)); //max - min
DW_fp_div  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) D0(.a(d0_a), .b(d0_b), .rnd(3'b000), .z(d0_z)); //scaled

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  d0_a <= 32'b0;
    else        d0_a <= s0_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  d0_b <= 32'b0;
    else        d0_b <= s1_z;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  scaled_reg <= 32'b0;
    else        scaled_reg <= d0_z;
end

//=================================
//		Activation Function
//=================================

//TODO: reuse sub and add
DW_fp_exp  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) E0(.a(e0_a), .z(e0_z)); //e^x
DW_fp_exp  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) E1(.a(e1_a), .z(e1_z)); //e^(-x)
DW_fp_sub  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S2(.a(s2_a), .b(s2_b), .rnd(3'b000), .z(s2_z)); //e^x - e^(-x)
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A6(.a(a6_a), .b(a6_b), .rnd(3'b000), .z(a6_z)); // xxx + e^(-x)
DW_fp_div  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) D1(.a(d1_a), .b(d1_b), .rnd(3'b000), .z(d1_z)); //acti. result

always@(*) begin
    e0_a = scaled_reg;
    e1_a = {~scaled_reg[31], scaled_reg[30:0]};
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  s2_a <= 32'b0;
    else        s2_a <= e0_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  s2_b <= 32'b0;
    else        s2_b <= e1_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a6_a <= 32'b0;
    else        a6_a <= a6_a_comb;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a6_b <= 32'b0;
    else        a6_b <= e1_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  d1_a <= 32'b0;
    else        d1_a <= d1_a_comb;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  d1_b <= 32'b0;
    else        d1_b <= a6_z;
end

assign a6_a_comb = opt_reg[1] ? e0_z : 32'b00111111100000000000000000000000;
assign d1_a_comb = opt_reg[1] ? s2_z : 32'b00111111100000000000000000000000;

//=================================
//		L1 Distance
//=================================

//TODO: reuse sub and add
DW_fp_sub  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S3(.a(s3_a), .b(s3_b), .rnd(3'b000), .z(s3_z));
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A7(.a(a7_a), .b(a7_b), .rnd(3'b000), .z(a7_z));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a7_a <= 32'b0;
    else        a7_a <= {1'b0, s3_z[30:0]}; //s3_z absolute
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a7_z_reg <= 32'b0;
    else        a7_z_reg <= a7_z;
end

//=================================
//		Output
//=================================

always@(posedge G_clk_out or negedge rst_n) begin
    if(!rst_n)  out_valid <= 1'b0;
    else        out_valid <= out_valid_comb;
end
always@(posedge G_clk_out or negedge rst_n) begin
    if(!rst_n)  out <= 32'b0;
    else        out <= out_comb;
end

always@(*) begin
    if(curr_state == WAIT && cnt == 6'd34) begin
        out_valid_comb = 1'b1;
        out_comb = a7_z;
    end
    else begin
        out_valid_comb = 1'b0;
        out_comb = 32'b0;
    end
end



endmodule