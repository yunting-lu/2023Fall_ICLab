//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Siamese Neural Network 
//   Author     		: Jia-Yu Lee (maggie8905121@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SNN.v
//   Module Name : SNN
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SNN(
    //Input Port
    clk,
    rst_n,
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

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

//FSM
parameter IDLE  = 2'b00;
parameter IMG1  = 2'b01;
parameter IMG2  = 2'b11;
parameter WAIT  = 2'b10;
reg  [1:0] curr_state, next_state;

//counter
reg  [5:0] cnt;
wire [5:0] cnt_comb;

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
reg  [inst_sig_width+inst_exp_width:0] m0_a, m1_a, m2_a, m3_a, m4_a, m5_a, m6_a, m7_a, m8_a, m9_a, m10_a;
reg  [inst_sig_width+inst_exp_width:0] m0_b, m1_b, m2_b, m3_b, m4_b, m5_b, m6_b, m7_b, m8_b, m9_b, m10_b;
wire [inst_sig_width+inst_exp_width:0] m0_z, m1_z, m2_z, m3_z, m4_z, m5_z, m6_z, m7_z, m8_z, m9_z, m10_z;

reg  [inst_sig_width+inst_exp_width:0] a0_a, a1_a, a2_a, a3_a, a4_a, a5_a;
reg  [inst_sig_width+inst_exp_width:0] a0_b, a1_b, a2_b, a3_b, a4_b, a5_b;
reg  [inst_sig_width+inst_exp_width:0] a0_c, a1_c, a2_c, a3_c;
wire [inst_sig_width+inst_exp_width:0] a0_z, a1_z, a2_z, a3_z, a4_z, a5_z;

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
            if(cnt == 6'd47)    next_state = IMG2;
            else                next_state = IMG1;
        end
        IMG2: begin
            if(!in_valid)   next_state = WAIT;
            else            next_state = IMG2;
        end
        WAIT: begin
            if(cnt == 6'd27)    next_state = IDLE; //until calculation finish
            else                next_state = WAIT;
        end
    endcase
end

//=================================
//		Counter
//=================================

assign cnt_comb = cnt + 'd1;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt <= 'd0;
    else begin
        if(cnt == 6'd47)                                    cnt <= 'd0;
        else if((next_state!==IDLE) || (curr_state!==IDLE)) cnt <= cnt_comb;
        else                                                cnt <= 'd0;
    end
end

//=================================
//		Store Input
//=================================

//Opt
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  opt_reg <= 2'b0;
    else        opt_reg <= opt_comb;
end
always@(*) begin
    if(in_valid && (cnt == 6'd0) && (curr_state == IDLE))   opt_comb = Opt;
    else                                                    opt_comb = opt_reg;
end

//image
genvar i_index, j_index;
generate
    for(i_index=0; i_index<4; i_index = i_index+1) begin
        for(j_index=0; j_index<4; j_index = j_index+1) begin
            always@(posedge clk or negedge rst_n) begin
                if(!rst_n)  image_reg[i_index][j_index] <= 32'b0;
                else begin
                    if(in_valid) begin
                        if(i_index==cnt[3:2] && j_index==cnt[1:0])  image_reg[i_index][j_index] <= Img;
                        else                                        image_reg[i_index][j_index] <= image_reg[i_index][j_index];
                    end
                    else                                            image_reg[i_index][j_index] <= image_reg[i_index][j_index];
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
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        kern1_reg[0][0]<=32'b0; kern1_reg[0][1]<=32'b0; kern1_reg[0][2]<=32'b0;
        kern1_reg[1][0]<=32'b0; kern1_reg[1][1]<=32'b0; kern1_reg[1][2]<=32'b0;
        kern1_reg[2][0]<=32'b0; kern1_reg[2][1]<=32'b0; kern1_reg[2][2]<=32'b0;
    end
    else begin
        if((in_valid && curr_state!==IMG2) && (cnt < 6'd9)) begin
            kern1_reg[0][0]<=kern1_reg[0][1]; kern1_reg[0][1]<=kern1_reg[0][2]; kern1_reg[0][2]<=kern1_reg[1][0];
            kern1_reg[1][0]<=kern1_reg[1][1]; kern1_reg[1][1]<=kern1_reg[1][2]; kern1_reg[1][2]<=kern1_reg[2][0];
            kern1_reg[2][0]<=kern1_reg[2][1]; kern1_reg[2][1]<=kern1_reg[2][2]; kern1_reg[2][2]<=Kernel;
        end
        else begin
            kern1_reg[0][0]<=kern1_reg[0][0]; kern1_reg[0][1]<=kern1_reg[0][1]; kern1_reg[0][2]<=kern1_reg[0][2];
            kern1_reg[1][0]<=kern1_reg[1][0]; kern1_reg[1][1]<=kern1_reg[1][1]; kern1_reg[1][2]<=kern1_reg[1][2];
            kern1_reg[2][0]<=kern1_reg[2][0]; kern1_reg[2][1]<=kern1_reg[2][1]; kern1_reg[2][2]<=kern1_reg[2][2];
        end
    end
end
//2
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        kern2_reg[0][0]<=32'b0; kern2_reg[0][1]<=32'b0; kern2_reg[0][2]<=32'b0;
        kern2_reg[1][0]<=32'b0; kern2_reg[1][1]<=32'b0; kern2_reg[1][2]<=32'b0;
        kern2_reg[2][0]<=32'b0; kern2_reg[2][1]<=32'b0; kern2_reg[2][2]<=32'b0;
    end
    else begin
        if((in_valid && curr_state!==IMG2) && (cnt >= 6'd9 && cnt < 6'd18)) begin
            kern2_reg[0][0]<=kern2_reg[0][1]; kern2_reg[0][1]<=kern2_reg[0][2]; kern2_reg[0][2]<=kern2_reg[1][0];
            kern2_reg[1][0]<=kern2_reg[1][1]; kern2_reg[1][1]<=kern2_reg[1][2]; kern2_reg[1][2]<=kern2_reg[2][0];
            kern2_reg[2][0]<=kern2_reg[2][1]; kern2_reg[2][1]<=kern2_reg[2][2]; kern2_reg[2][2]<=Kernel;
        end
        else begin
            kern2_reg[0][0]<=kern2_reg[0][0]; kern2_reg[0][1]<=kern2_reg[0][1]; kern2_reg[0][2]<=kern2_reg[0][2];
            kern2_reg[1][0]<=kern2_reg[1][0]; kern2_reg[1][1]<=kern2_reg[1][1]; kern2_reg[1][2]<=kern2_reg[1][2];
            kern2_reg[2][0]<=kern2_reg[2][0]; kern2_reg[2][1]<=kern2_reg[2][1]; kern2_reg[2][2]<=kern2_reg[2][2];
        end
    end
end
//3
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        kern3_reg[0][0]<=32'b0; kern3_reg[0][1]<=32'b0; kern3_reg[0][2]<=32'b0;
        kern3_reg[1][0]<=32'b0; kern3_reg[1][1]<=32'b0; kern3_reg[1][2]<=32'b0;
        kern3_reg[2][0]<=32'b0; kern3_reg[2][1]<=32'b0; kern3_reg[2][2]<=32'b0;
    end
    else begin
        if((in_valid && curr_state!==IMG2) && (cnt >= 6'd18 && cnt < 6'd27)) begin
            kern3_reg[0][0]<=kern3_reg[0][1]; kern3_reg[0][1]<=kern3_reg[0][2]; kern3_reg[0][2]<=kern3_reg[1][0];
            kern3_reg[1][0]<=kern3_reg[1][1]; kern3_reg[1][1]<=kern3_reg[1][2]; kern3_reg[1][2]<=kern3_reg[2][0];
            kern3_reg[2][0]<=kern3_reg[2][1]; kern3_reg[2][1]<=kern3_reg[2][2]; kern3_reg[2][2]<=Kernel;
        end
        else begin
            kern3_reg[0][0]<=kern3_reg[0][0]; kern3_reg[0][1]<=kern3_reg[0][1]; kern3_reg[0][2]<=kern3_reg[0][2];
            kern3_reg[1][0]<=kern3_reg[1][0]; kern3_reg[1][1]<=kern3_reg[1][1]; kern3_reg[1][2]<=kern3_reg[1][2];
            kern3_reg[2][0]<=kern3_reg[2][0]; kern3_reg[2][1]<=kern3_reg[2][1]; kern3_reg[2][2]<=kern3_reg[2][2];
        end
    end
end

//weight
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        weight_reg[0][0] <= 32'b0;  weight_reg[0][1] <= 32'b0;
        weight_reg[1][0] <= 32'b0;  weight_reg[1][1] <= 32'b0;
    end
    else begin
        if((in_valid && curr_state!==IMG2) && (cnt < 6'd4)) begin
            weight_reg[0][0] <= weight_reg[0][1];   weight_reg[0][1] <= weight_reg[1][0];
            weight_reg[1][0] <= weight_reg[1][1];   weight_reg[1][1] <= Weight;
        end
        else begin
            weight_reg[0][0] <= weight_reg[0][0];   weight_reg[0][1] <= weight_reg[0][1];
            weight_reg[1][0] <= weight_reg[1][0];   weight_reg[1][1] <= weight_reg[1][1];
        end
    end
end

//=================================
//		Registers
//=================================

always@(posedge clk) begin // or negedge rst_n
    if(curr_state == IDLE) begin
        for(i=0;i<4;i=i+1) begin
            for(j=0;j<4;j=j+1) begin
                data_reg[i][j] <= 32'b0;
            end
        end
    end
    else begin
        for(m=0;m<4;m=m+1) begin
            for(n=0;n<4;n=n+1) begin
                data_reg[m][n] <= data_comb[m][n];
            end
        end
    end
end

always@(posedge clk) begin
    if(curr_state == IDLE) begin
        pooling_reg[0][0] <= 32'b0; pooling_reg[0][1] <= 32'b0;
        pooling_reg[1][0] <= 32'b0; pooling_reg[1][1] <= 32'b0;
    end
    else begin
        pooling_reg[0][0] <= pooling_comb[0][0]; pooling_reg[0][1] <= pooling_comb[0][1];
        pooling_reg[1][0] <= pooling_comb[1][0]; pooling_reg[1][1] <= pooling_comb[1][1];
    end
end

always@(posedge clk) begin
    if(curr_state == IDLE) begin
        feature_reg[0] <= 32'b0;
        feature_reg[1] <= 32'b0;
        feature_reg[2] <= 32'b0;
        feature_reg[3] <= 32'b0;
    end
    else begin
        feature_reg[0] <= feature_comb[0];
        feature_reg[1] <= feature_comb[1];
        feature_reg[2] <= feature_comb[2];
        feature_reg[3] <= feature_comb[3];
    end
end

always@(posedge clk) begin
    if(curr_state == IDLE) begin
        encoding1_reg[0] <= 32'b0;
        encoding1_reg[1] <= 32'b0;
        encoding1_reg[2] <= 32'b0;
        encoding1_reg[3] <= 32'b0;
    end
    else begin
        encoding1_reg[0] <= encoding1_comb[0];
        encoding1_reg[1] <= encoding1_comb[1];
        encoding1_reg[2] <= encoding1_comb[2];
        encoding1_reg[3] <= encoding1_comb[3];
    end
end

always@(posedge clk) begin
    if(curr_state == IDLE)  encoding2_reg <= 32'b0;
    else                    encoding2_reg <= d1_z;
end

//=================================
//		Counter Control
//=================================

//m0_a, m1_a, m2_a, m3_a, m4_a, m5_a, m6_a, m7_a, m8_a //image
//a4_b
//data_comb[0:3][0:3]
always@(*) begin
    case(cnt) //0~47, 6 bits
        6'd9, 6'd25, 6'd41: begin //00
            m0_a = pd_00;           m1_a = pd_00;           m2_a = pd_01;          
            m3_a = pd_00;           m4_a = image_reg[0][0]; m5_a = image_reg[0][1];
            m6_a = pd_10;           m7_a = image_reg[1][0]; m8_a = image_reg[1][1];
            //
            a4_b = (cnt == 6'd25)? 32'b0 : data_reg[3][1];
            data_comb[3][1] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];                                       data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd10, 6'd26, 6'd42: begin //01
            m0_a = pd_00;           m1_a = pd_01;           m2_a = pd_02;          
            m3_a = image_reg[0][0]; m4_a = image_reg[0][1]; m5_a = image_reg[0][2];
            m6_a = image_reg[1][0]; m7_a = image_reg[1][1]; m8_a = image_reg[1][2];
            //
            a4_b = (cnt == 6'd26)? 32'b0 : data_reg[3][2];
            data_comb[3][2] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];                                       data_comb[3][3] = data_reg[3][3];
        end
        6'd11, 6'd27, 6'd43: begin //02
            m0_a = pd_01;           m1_a = pd_02;           m2_a = pd_03;          
            m3_a = image_reg[0][1]; m4_a = image_reg[0][2]; m5_a = image_reg[0][3];
            m6_a = image_reg[1][1]; m7_a = image_reg[1][2]; m8_a = image_reg[1][3];
            //
            a4_b = (cnt == 6'd27)? 32'b0 : data_reg[3][3];
            data_comb[3][3] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];
        end
        6'd12, 6'd28, 6'd44: begin //03
            m0_a = pd_02;           m1_a = pd_03;           m2_a = pd_03;          
            m3_a = image_reg[0][2]; m4_a = image_reg[0][3]; m5_a = pd_03;
            m6_a = image_reg[1][2]; m7_a = image_reg[1][3]; m8_a = pd_13;
            //
            a4_b = (cnt == 6'd12)? 32'b0 : data_reg[0][0];
            data_comb[0][0] = a4_z;
                                                data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd13, 6'd29, 6'd45: begin //10
            m0_a = pd_00;           m1_a = image_reg[0][0]; m2_a = image_reg[0][1];
            m3_a = pd_10;           m4_a = image_reg[1][0]; m5_a = image_reg[1][1];
            m6_a = pd_20;           m7_a = image_reg[2][0]; m8_a = image_reg[2][1];
            //
            a4_b = (cnt == 6'd13)? 32'b0 : data_reg[0][1];
            data_comb[0][1] = a4_z;
            data_comb[0][0] = data_reg[0][0];                                       data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd14, 6'd30, 6'd46: begin //11
            m0_a = image_reg[0][0]; m1_a = image_reg[0][1]; m2_a = image_reg[0][2];
            m3_a = image_reg[1][0]; m4_a = image_reg[1][1]; m5_a = image_reg[1][2];
            m6_a = image_reg[2][0]; m7_a = image_reg[2][1]; m8_a = image_reg[2][2];
            //
            a4_b = (cnt == 6'd14)? 32'b0 : data_reg[0][2];
            data_comb[0][2] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];                                       data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd15, 6'd31, 6'd47: begin //12
            m0_a = image_reg[0][1]; m1_a = image_reg[0][2]; m2_a = image_reg[0][3];
            m3_a = image_reg[1][1]; m4_a = image_reg[1][2]; m5_a = image_reg[1][3];
            m6_a = image_reg[2][1]; m7_a = image_reg[2][2]; m8_a = image_reg[2][3];
            //
            a4_b = (cnt == 6'd15)? 32'b0 : data_reg[0][3];
            data_comb[0][3] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd16, 6'd32, 6'd0: begin //13
            m0_a = image_reg[0][2]; m1_a = image_reg[0][3]; m2_a = pd_03;
            m3_a = image_reg[1][2]; m4_a = image_reg[1][3]; m5_a = pd_13;
            m6_a = image_reg[2][2]; m7_a = image_reg[2][3]; m8_a = pd_23;
            //
            a4_b = (cnt == 6'd16)? 32'b0 : data_reg[1][0];
            data_comb[1][0] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
                                                data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd17, 6'd33, 6'd1: begin //20
            m0_a = pd_10;           m1_a = image_reg[1][0]; m2_a = image_reg[1][1];
            m3_a = pd_20;           m4_a = image_reg[2][0]; m5_a = image_reg[2][1];
            m6_a = pd_30;           m7_a = image_reg[3][0]; m8_a = image_reg[3][1];
            //
            a4_b = (cnt == 6'd17)? 32'b0 : data_reg[1][1];
            data_comb[1][1] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];                                       data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd18, 6'd34, 6'd2: begin //21
            m0_a = image_reg[1][0]; m1_a = image_reg[1][1]; m2_a = image_reg[1][2];
            m3_a = image_reg[2][0]; m4_a = image_reg[2][1]; m5_a = image_reg[2][2];
            m6_a = image_reg[3][0]; m7_a = image_reg[3][1]; m8_a = image_reg[3][2];
            //
            a4_b = (cnt == 6'd18)? 32'b0 : data_reg[1][2];
            data_comb[1][2] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];                                       data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd19, 6'd35, 6'd3: begin //22
            m0_a = image_reg[1][1]; m1_a = image_reg[1][2]; m2_a = image_reg[1][3];
            m3_a = image_reg[2][1]; m4_a = image_reg[2][2]; m5_a = image_reg[2][3];
            m6_a = image_reg[3][1]; m7_a = image_reg[3][2]; m8_a = image_reg[3][3];
            //
            a4_b = (cnt == 6'd19)? 32'b0 : data_reg[1][3];
            data_comb[1][3] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd20, 6'd36, 6'd4: begin //23
            m0_a = image_reg[1][2]; m1_a = image_reg[1][3]; m2_a = pd_13;
            m3_a = image_reg[2][2]; m4_a = image_reg[2][3]; m5_a = pd_23;
            m6_a = image_reg[3][2]; m7_a = image_reg[3][3]; m8_a = pd_33;
            //
            a4_b = (cnt == 6'd20)? 32'b0 : data_reg[2][0];
            data_comb[2][0] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
                                                data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd21, 6'd37, 6'd5: begin //30
            m0_a = pd_20;           m1_a = image_reg[2][0]; m2_a = image_reg[2][1];
            m3_a = pd_30;           m4_a = image_reg[3][0]; m5_a = image_reg[3][1];
            m6_a = pd_30;           m7_a = pd_30;           m8_a = pd_31;
            //
            a4_b = (cnt == 6'd21)? 32'b0 : data_reg[2][1];
            data_comb[2][1] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];                                       data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd22, 6'd38, 6'd6: begin //31
            m0_a = image_reg[2][0]; m1_a = image_reg[2][1]; m2_a = image_reg[2][2];
            m3_a = image_reg[3][0]; m4_a = image_reg[3][1]; m5_a = image_reg[3][2];
            m6_a = pd_30;           m7_a = pd_31;           m8_a = pd_32;
            //
            a4_b = (cnt == 6'd22)? 32'b0 : data_reg[2][2];
            data_comb[2][2] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];                                       data_comb[2][3] = data_reg[2][3];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd23, 6'd39, 6'd7: begin //32
            m0_a = image_reg[2][1]; m1_a = image_reg[2][2]; m2_a = image_reg[2][3];
            m3_a = image_reg[3][1]; m4_a = image_reg[3][2]; m5_a = image_reg[3][3];
            m6_a = pd_31;           m7_a = pd_32;           m8_a = pd_33;
            //
            a4_b = (cnt == 6'd23)? 32'b0 : data_reg[2][3];
            data_comb[2][3] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];
            data_comb[3][0] = data_reg[3][0];   data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        6'd24, 6'd40, 6'd8: begin //33
            m0_a = image_reg[2][2]; m1_a = image_reg[2][3]; m2_a = pd_23;
            m3_a = image_reg[3][2]; m4_a = image_reg[3][3]; m5_a = pd_33;
            m6_a = pd_32;           m7_a = pd_33;           m8_a = pd_33;
            //
            a4_b = (cnt == 6'd24)? 32'b0 : data_reg[3][0];
            data_comb[3][0] = a4_z;
            data_comb[0][0] = data_reg[0][0];   data_comb[0][1] = data_reg[0][1];   data_comb[0][2] = data_reg[0][2];   data_comb[0][3] = data_reg[0][3];
            data_comb[1][0] = data_reg[1][0];   data_comb[1][1] = data_reg[1][1];   data_comb[1][2] = data_reg[1][2];   data_comb[1][3] = data_reg[1][3];
            data_comb[2][0] = data_reg[2][0];   data_comb[2][1] = data_reg[2][1];   data_comb[2][2] = data_reg[2][2];   data_comb[2][3] = data_reg[2][3];
                                                data_comb[3][1] = data_reg[3][1];   data_comb[3][2] = data_reg[3][2];   data_comb[3][3] = data_reg[3][3];
        end
        default: begin
            m0_a = 'b0;             m1_a = 'b0;             m2_a = 'b0;
            m3_a = 'b0;             m4_a = 'b0;             m5_a = 'b0;
            m6_a = 'b0;             m7_a = 'b0;             m8_a = 'b0;
            //
            a4_b = 32'b0;
            for(i=0;i<4;i=i+1) begin
                for(j=0;j<4;j=j+1) begin
                    data_comb[i][j] = data_reg[i][j];
                end
            end
        end

    endcase
end

//m0_b, m1_b, m2_b, m3_b, m4_b, m5_b, m6_b, m7_b, m8_b //kernel
always@(*) begin
    if((cnt >= 6'd9) && (cnt <= 6'd24)) begin //kernel 1
        m0_b = kern1_reg[0][0]; m1_b = kern1_reg[0][1]; m2_b = kern1_reg[0][2];
        m3_b = kern1_reg[1][0]; m4_b = kern1_reg[1][1]; m5_b = kern1_reg[1][2];
        m6_b = kern1_reg[2][0]; m7_b = kern1_reg[2][1]; m8_b = kern1_reg[2][2];
    end
    else if((cnt >= 6'd25) && (cnt <= 6'd40)) begin //kernel 2
        m0_b = kern2_reg[0][0]; m1_b = kern2_reg[0][1]; m2_b = kern2_reg[0][2];
        m3_b = kern2_reg[1][0]; m4_b = kern2_reg[1][1]; m5_b = kern2_reg[1][2];
        m6_b = kern2_reg[2][0]; m7_b = kern2_reg[2][1]; m8_b = kern2_reg[2][2];
    end
    else begin //kernel 3
        m0_b = kern3_reg[0][0]; m1_b = kern3_reg[0][1]; m2_b = kern3_reg[0][2];
        m3_b = kern3_reg[1][0]; m4_b = kern3_reg[1][1]; m5_b = kern3_reg[1][2];
        m6_b = kern3_reg[2][0]; m7_b = kern3_reg[2][1]; m8_b = kern3_reg[2][2];
    end
end

//find max
//max pooling & min-max
//c0_a, c0_b, c1_a, c1_b
always@(*) begin
    case(cnt)
        6'd1: begin
            c0_a = data_reg[0][0];
            c0_b = data_reg[0][1];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd2: begin
            c0_a = c0_max_reg;
            c0_b = data_reg[1][0];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd3: begin
            c0_a = c0_max_reg;
            c0_b = data_reg[1][1]; //find left top max
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd4: begin
            c0_a = data_reg[0][2];
            c0_b = data_reg[0][3];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd5: begin
            c0_a = c0_max_reg;
            c0_b = data_reg[1][2];
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd6: begin
            c0_a = c0_max_reg;
            c0_b = data_reg[1][3]; //find right top max
            c1_a = 32'b0;
            c1_b = 32'b0;
        end
        6'd10: begin
            c0_a = data_reg[2][2];
            c0_b = data_reg[2][3];
            c1_a = data_reg[2][0];
            c1_b = data_reg[2][1];
        end
        6'd11: begin
            c0_a = c0_max_reg;
            c0_b = data_reg[3][2];
            c1_a = c1_max_reg;
            c1_b = data_reg[3][0];
        end
        6'd12: begin
            c0_a = c0_max_reg;
            c0_b = data_reg[3][3]; //find right bottom max
            c1_a = c1_max_reg;
            c1_b = data_reg[3][1]; //find left bottom max
        end
        6'd14, 6'd15, 6'd16: begin //min-max
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
        6'd12: begin
            max_comb = a5_z;
            min_comb = a5_z;
        end
        6'd13: begin
            max_comb = max_reg;
            min_comb = min_reg;
        end
        6'd14: begin
            max_comb = c0_max;
            min_comb = c1_min;
        end
        6'd15: begin
            max_comb = c0_max;
            min_comb = c1_min;
        end
        6'd16: begin
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
        6'd3: begin
            pooling_comb[0][0] = c0_max;            pooling_comb[0][1] = pooling_reg[0][1];
            pooling_comb[1][0] = pooling_reg[1][0]; pooling_comb[1][1] = pooling_reg[1][1];
        end
        6'd6: begin
            pooling_comb[0][0] = pooling_reg[0][0]; pooling_comb[0][1] = c0_max;
            pooling_comb[1][0] = pooling_reg[1][0]; pooling_comb[1][1] = pooling_reg[1][1];
        end
        6'd12: begin
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
//m9_a, m10_a, m9_b, m10_b
always@(*) begin
    case(cnt)
        6'd11: begin
            m9_a  = pooling_reg[0][0];  m9_b  = weight_reg[0][0];
            m10_a = pooling_reg[0][1];  m10_b = weight_reg[1][0];
        end
        6'd12: begin
            m9_a  = pooling_reg[0][0];  m9_b  = weight_reg[0][1];
            m10_a = pooling_reg[0][1];  m10_b = weight_reg[1][1];
        end
        6'd13: begin
            m9_a  = pooling_reg[1][0];  m9_b  = weight_reg[0][0];
            m10_a = pooling_reg[1][1];  m10_b = weight_reg[1][0];
        end
        6'd14: begin
            m9_a  = pooling_reg[1][0];  m9_b  = weight_reg[0][1];
            m10_a = pooling_reg[1][1];  m10_b = weight_reg[1][1];
        end
        default: begin
            m9_a  = 32'b0;              m9_b  = 32'b0;
            m10_a = 32'b0;              m10_b = 32'b0;
        end
    endcase
end
//feature_comb
always@(*) begin
    case(cnt)
        6'd12, 6'd13, 6'd14, 6'd15: begin
            feature_comb[0] = feature_reg[1];   feature_comb[1] = feature_reg[2];   feature_comb[2] = feature_reg[3];   feature_comb[3] = a5_z;
        end
        default: begin
            feature_comb[0] = feature_reg[0];   feature_comb[1] = feature_reg[1];   feature_comb[2] = feature_reg[2];   feature_comb[3] = feature_reg[3];
        end
    endcase
end

//normalization
always@(*) begin
    case(cnt)
        6'd17: begin
            s0_a = feature_reg[0];
        end
        6'd18: begin
            s0_a = feature_reg[1];
        end
        6'd19: begin
            s0_a = feature_reg[2];
        end
        6'd20: begin
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
            6'd21, 6'd22, 6'd23, 6'd24: begin
                encoding1_comb[0] = encoding1_reg[1];   encoding1_comb[1] = encoding1_reg[2];   encoding1_comb[2] = encoding1_reg[3];   encoding1_comb[3] = d1_z;
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
        6'd22: begin
            s3_a = encoding1_reg[0];    s3_b = encoding2_reg;
        end
        6'd23: begin
            s3_a = encoding1_reg[1];    s3_b = encoding2_reg;
        end
        6'd24: begin
            s3_a = encoding1_reg[2];    s3_b = encoding2_reg;
        end
        6'd25: begin
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
        6'd23: begin
            a7_b = 32'b0;
        end
        6'd24: begin
            a7_b = a7_z_reg;
        end
        6'd25: begin
            a7_b = a7_z_reg;
        end
        6'd26: begin
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
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M0(.a(m0_a), .b(m0_b), .rnd(3'b000), .z(m0_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M1(.a(m1_a), .b(m1_b), .rnd(3'b000), .z(m1_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M2(.a(m2_a), .b(m2_b), .rnd(3'b000), .z(m2_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M3(.a(m3_a), .b(m3_b), .rnd(3'b000), .z(m3_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M4(.a(m4_a), .b(m4_b), .rnd(3'b000), .z(m4_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M5(.a(m5_a), .b(m5_b), .rnd(3'b000), .z(m5_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M6(.a(m6_a), .b(m6_b), .rnd(3'b000), .z(m6_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M7(.a(m7_a), .b(m7_b), .rnd(3'b000), .z(m7_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M8(.a(m8_a), .b(m8_b), .rnd(3'b000), .z(m8_z));
//adder tree
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A0(.a(a0_a), .b(a0_b), .c(a0_c), .rnd(3'b000), .z(a0_z));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A1(.a(a1_a), .b(a1_b), .c(a1_c), .rnd(3'b000), .z(a1_z));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A2(.a(a2_a), .b(a2_b), .c(a2_c), .rnd(3'b000), .z(a2_z));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) A3(.a(a3_a), .b(a3_b), .c(a3_c), .rnd(3'b000), .z(a3_z)); //result of 1 channel conv
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A4(.a(a4_a), .b(a4_b), .rnd(3'b000), .z(a4_z)); //add 3 channels //a4_b <-- counter control
//mult & add pipeline
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a0_a <= 32'b0;
    else        a0_a <= m0_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a0_b <= 32'b0;
    else        a0_b <= m1_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a0_c <= 32'b0;
    else        a0_c <= m2_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a1_a <= 32'b0;
    else        a1_a <= m3_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a1_b <= 32'b0;
    else        a1_b <= m4_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a1_c <= 32'b0;
    else        a1_c <= m5_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a2_a <= 32'b0;
    else        a2_a <= m6_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a2_b <= 32'b0;
    else        a2_b <= m7_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a2_c <= 32'b0;
    else        a2_c <= m8_z;
end
//9-->3
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a3_a <= 32'b0;
    else        a3_a <= a0_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a3_b <= 32'b0;
    else        a3_b <= a1_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a3_c <= 32'b0;
    else        a3_c <= a2_z;
end
//2-->1
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a4_a <= 32'b0;
    else        a4_a <= a3_z;
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

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M9(.a(m9_a), .b(m9_b), .rnd(3'b000), .z(m9_z));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M10(.a(m10_a), .b(m10_b), .rnd(3'b000), .z(m10_z));
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A5(.a(a5_a), .b(a5_b), .rnd(3'b000), .z(a5_z)); //feature map

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a5_a <= 32'b0;
    else        a5_a <= m9_z;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  a5_b <= 32'b0;
    else        a5_b <= m10_z;
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

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 1'b0;
    else        out_valid <= out_valid_comb;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out <= 32'b0;
    else        out <= out_comb;
end

always@(*) begin
    if(curr_state == WAIT && cnt == 6'd26) begin
        out_valid_comb = 1'b1;
        out_comb = a7_z;
    end
    else begin
        out_valid_comb = 1'b0;
        out_comb = 32'b0;
    end
end



endmodule
