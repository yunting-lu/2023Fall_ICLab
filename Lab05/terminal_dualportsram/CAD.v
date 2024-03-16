module CAD(
    //Input Port
    clk,
    rst_n,
    in_valid,
    in_valid2,
    matrix_size,
    matrix,
    matrix_idx,
    mode,
    //Output Port
    out_valid,
    out_value
);

input clk, rst_n, in_valid, in_valid2, mode;
input [1:0] matrix_size;
input [7:0] matrix;
input [3:0] matrix_idx;
output reg out_valid;
output reg out_value;

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

reg [2:0] curr_state, next_state;

parameter IDLE  =   3'd0;
parameter INPUT =   3'd1;
parameter IDLE2 =   3'd2;
parameter INPUT2=   3'd3;
parameter CONV  =   3'd4;
parameter DECONV=   3'd5;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

integer i, j, m, n;
integer a, b, c;

//store input
reg [1:0] matrix_size_reg;
reg [3:0] i_matrix_idx;
reg [3:0] k_matrix_idx;
reg mode_reg;
reg [63:0] image_row;

//input counter
reg [2:0] cnt_in_kernel;
reg [2:0] cnti_in_img8;
reg [4:0] cntj_in_img8;
reg [1:0] cnt_sram_num;
reg [3:0] image_page;   
reg img_finish;

//SRAM
reg web_sram_img_1, web_sram_img_2, web_sram_img_3, web_sram_img_4;
reg web_sram_kernel;
wire [63:0] DO_SRAM_IMG1, DO_SRAM_IMG2, DO_SRAM_IMG3, DO_SRAM_IMG4;
wire [7:0] DO_sram_img [0:31];
wire [39:0] DO_SRAM_Kern;

//SRAM Address
wire [8:0] ptr_matrix;
wire [6:0] ptr_kernel;
reg [6:0] ker_addr, ker_addr_comb;
reg [8:0] img_addr, img_addr_comb;

//FSM
reg [14:0] cnt_state, cnt_state_d1;
reg [4:0] cnt_invalid2;
reg deconv_out_finish;

//store sram do
reg signed [7:0] DO_Kernel_reg[0:4];
reg signed [7:0] DO_Kernel_comb[0:4];
reg signed [7:0] DO_Image_reg[0:4];
reg signed [7:0] DO_Image_comb[0:4];

reg [4:0] deconv_col_ptr, deconv_col_ptr_comb, deconv_col_ptr_d1, deconv_col_ptr_d2, deconv_col_ptr_d3, deconv_col_ptr_d4;

//==============================================//


//input counter continued.
reg [4:0] cnt_kernel, cnt_kernel_d1, cnt_kernel_d2, cnt_kernel_d3, cnt_kernel_d4;
reg signed [7:0] kernel_reg[0:4][0:4];
reg [4:0] cnt_change_addr, cnt_change_addr_d1, cnt_change_addr_d2, cnt_change_addr_d3;

//convolution
reg signed [7:0]  m1_a, m2_a, m3_a, m4_a, m5_a, m6_a, m7_a, m8_a, m9_a, m10_a, m11_a, m12_a, m13_a, m14_a, m15_a, m16_a, m17_a, m18_a, m19_a, m20_a, m21_a, m22_a, m23_a, m24_a, m25_a;
reg signed [7:0]  m1_b, m2_b, m3_b, m4_b, m5_b, m6_b, m7_b, m8_b, m9_b, m10_b, m11_b, m12_b, m13_b, m14_b, m15_b, m16_b, m17_b, m18_b, m19_b, m20_b, m21_b, m22_b, m23_b, m24_b, m25_b;
reg signed [15:0] m1_z, m2_z, m3_z, m4_z, m5_z, m6_z, m7_z, m8_z, m9_z, m10_z, m11_z, m12_z, m13_z, m14_z, m15_z, m16_z, m17_z, m18_z, m19_z, m20_z, m21_z, m22_z, m23_z, m24_z, m25_z;
reg signed [19:0] sum_comb, sum;
reg signed [19:0] largest, largest_comb;
reg [19:0] conv_result_comb, conv_result_reg;
reg signed [19:0] pre_sum;
reg [1:0] cnt_img_1, cnt_img_1_comb;
reg [4:0] img_addr_offset, img_addr_offset_comb;
wire check_16, check_32;
reg [7:0] cnt_square, cnt_square_comb;
reg col_offset, col_offset_comb;
reg col_offset_d1, col_offset_d2, col_offset_d3;
reg [4:0] col_ptr_8;
reg [4:0] col_ptr_8_d1, col_ptr_8_d2, col_ptr_8_d3;
reg [4:0] cnt_conv_out;

//deconv
reg signed [19:0] deconv_temp1[0:35];
reg signed [19:0] deconv_temp2[0:35];
reg signed [19:0] deconv_temp3[0:35];
reg signed [19:0] deconv_temp4[0:35];
reg signed [19:0] deconv_temp5[0:3];
wire signed [19:0] result;
reg [5:0] cnt_line;
reg stop_mac;
reg stop_flag;
reg [5:0] cnt_line_row;
reg [4:0] img_size;
reg web_sram_temp;
reg [10:0] temp_addr, temp_addr_comb, temp_addr_read, temp_addr_read_comb;
wire signed [19:0] DI_SRAM_temp, DO_SRAM_temp;
reg [10:0] temp_addr_p1;
reg start_read, start_read_d1, start_read_comb;
reg [4:0] cnt20, cnt20_comb;
reg [18:0] deconv_out_buf; //[0]-->out_value


//output
reg out_valid_comb, out_value_comb;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

//=================================
//		Store Input
//=================================

//matrix_size_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  matrix_size_reg <= 2'd0;
    else begin
        if(in_valid && curr_state==IDLE)    matrix_size_reg <= matrix_size;
        else                                matrix_size_reg <= matrix_size_reg;
    end
end
//matrix_idx
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  i_matrix_idx <= 4'd0;
    else begin
        if(in_valid2 && curr_state==IDLE2)  i_matrix_idx <= matrix_idx;
        else                                i_matrix_idx <= i_matrix_idx;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  k_matrix_idx <= 4'd0;
    else begin
        if(in_valid2 && curr_state==INPUT2) k_matrix_idx <= matrix_idx;
        else                                k_matrix_idx <= k_matrix_idx;
    end
end
//mode
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  mode_reg <= 1'd0;
    else begin
        if(in_valid2 && curr_state==IDLE2)  mode_reg <= mode;
        else                                mode_reg <= mode_reg;
    end
end
//image_row / kernel_row
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        image_row <= 64'b0;
    end
    else begin
        if(in_valid)    image_row <= {image_row[55:0],matrix};
        else            image_row <= 64'b0;
    end
end

//=================================
//		Input Counter
//=================================

//kernel 5*5, store one row a time
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_in_kernel <= 3'd0;
    else begin
        if(!img_finish)             cnt_in_kernel <= 3'd0;
        else if(cnt_in_kernel=='d4) cnt_in_kernel <= 3'd0;
        else if(curr_state==INPUT)  cnt_in_kernel <= cnt_in_kernel + 'd1;
        else                        cnt_in_kernel <= 3'd0;
    end
end
//image 8*8
//cnti_in_img8
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnti_in_img8 <= 3'd0;
    else begin
        if(cnti_in_img8==3'd7)  cnti_in_img8 <= 3'd0;
        else if(in_valid)       cnti_in_img8 <= cnti_in_img8 + 'd1;
        else                    cnti_in_img8 <= 3'd0;
    end
end
//cnt_sram_num
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_sram_num <= 2'd0;
    else begin
        if(matrix_size_reg==2'd0 || curr_state==IDLE)                               cnt_sram_num <= 2'd0;
        else if(matrix_size_reg==2'd1 && cnti_in_img8==3'd7 && cnt_sram_num==2'd1)  cnt_sram_num <= 2'd0;
        else if(matrix_size_reg==2'd2 && cnti_in_img8==3'd7 && cnt_sram_num==2'd3)  cnt_sram_num <= 2'd0;
        else if(cnti_in_img8==3'd7)                                                 cnt_sram_num <= cnt_sram_num + 'd1;
        else                                                                        cnt_sram_num <= cnt_sram_num;
    end
end
//cntj_in_img8
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cntj_in_img8 <= 5'd0;
    else begin
        if(cnti_in_img8==3'd7) begin
            if(matrix_size_reg=='d0)                                cntj_in_img8 <= cntj_in_img8 + 'd1;
            else if(matrix_size_reg==2'd1 && cnt_sram_num==2'd1)    cntj_in_img8 <= cntj_in_img8 + 'd1;
            else if(matrix_size_reg==2'd2 && cnt_sram_num==2'd3)    cntj_in_img8 <= cntj_in_img8 + 'd1;
            else                                                    cntj_in_img8 <= cntj_in_img8; //?
        end
        else if(curr_state==INPUT)                                  cntj_in_img8 <= cntj_in_img8;
        else                                                        cntj_in_img8 <= 5'd0;
    end
end
//image_page
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  image_page <= 4'd0;
    else begin
        if(!in_valid)                                                                                           image_page <= 4'd0;
        else if(matrix_size_reg==2'd0 && cnti_in_img8==3'd7 && cntj_in_img8[2:0]==3'd7)                         image_page <= image_page + 'd1;
        else if(matrix_size_reg==2'd1 && cnti_in_img8==3'd7 && cntj_in_img8[3:0]==4'd15 && cnt_sram_num==2'd1)  image_page <= image_page + 'd1;
        else if(matrix_size_reg==2'd2 && cnti_in_img8==3'd7 && cntj_in_img8==5'd31 && cnt_sram_num==2'd3)       image_page <= image_page + 'd1;
        else                                                                                                    image_page <= image_page;
    end
end
//img_finish, image --> kernel
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  img_finish <= 1'b0;
    else begin
        if(!in_valid)                                                                                               img_finish <= 1'b0;
        else if(image_page=='d15) begin
            if(matrix_size_reg==2'd0 && cnti_in_img8==3'd7 && cntj_in_img8[2:0]==3'd7)                              img_finish <= 1'b1;
            else if(matrix_size_reg==2'd1 && cnti_in_img8==3'd7 && cntj_in_img8[3:0]==4'd15 && cnt_sram_num==2'd1)  img_finish <= 1'b1;
            else if(matrix_size_reg==2'd2 && cnti_in_img8==3'd7 && cntj_in_img8==5'd31 && cnt_sram_num==2'd3)       img_finish <= 1'b1;
            else                                                                                                    img_finish <= img_finish;
        end
        else                                                                                                        img_finish <= img_finish;
    end
end

//=================================
//		SRAM
//=================================

//image first 8*8
SUMA180_512X64X1BM1 SRAM_IMG_1(.A0(img_addr[0]), .A1(img_addr[1]),.A2(img_addr[2]), .A3(img_addr[3]), .A4(img_addr[4]), .A5(img_addr[5]), .A6(img_addr[6]), .A7(img_addr[7]), .A8(img_addr[8]), 
                            .DO0(DO_SRAM_IMG1[0]), .DO1(DO_SRAM_IMG1[1]), .DO2(DO_SRAM_IMG1[2]), .DO3(DO_SRAM_IMG1[3]), .DO4(DO_SRAM_IMG1[4]),
                            .DO5(DO_SRAM_IMG1[5]), .DO6(DO_SRAM_IMG1[6]), .DO7(DO_SRAM_IMG1[7]), .DO8(DO_SRAM_IMG1[8]), .DO9(DO_SRAM_IMG1[9]), .DO10(DO_SRAM_IMG1[10]), .DO11(DO_SRAM_IMG1[11]), .DO12(DO_SRAM_IMG1[12]), .DO13(DO_SRAM_IMG1[13]), .DO14(DO_SRAM_IMG1[14]),
                            .DO15(DO_SRAM_IMG1[15]), .DO16(DO_SRAM_IMG1[16]), .DO17(DO_SRAM_IMG1[17]), .DO18(DO_SRAM_IMG1[18]), .DO19(DO_SRAM_IMG1[19]), .DO20(DO_SRAM_IMG1[20]), .DO21(DO_SRAM_IMG1[21]), .DO22(DO_SRAM_IMG1[22]),
                            .DO23(DO_SRAM_IMG1[23]), .DO24(DO_SRAM_IMG1[24]), .DO25(DO_SRAM_IMG1[25]), .DO26(DO_SRAM_IMG1[26]), .DO27(DO_SRAM_IMG1[27]), .DO28(DO_SRAM_IMG1[28]), .DO29(DO_SRAM_IMG1[29]), .DO30(DO_SRAM_IMG1[30]),
                            .DO31(DO_SRAM_IMG1[31]), .DO32(DO_SRAM_IMG1[32]), .DO33(DO_SRAM_IMG1[33]), .DO34(DO_SRAM_IMG1[34]), .DO35(DO_SRAM_IMG1[35]), .DO36(DO_SRAM_IMG1[36]), .DO37(DO_SRAM_IMG1[37]), .DO38(DO_SRAM_IMG1[38]),
                            .DO39(DO_SRAM_IMG1[39]), .DO40(DO_SRAM_IMG1[40]), .DO41(DO_SRAM_IMG1[41]), .DO42(DO_SRAM_IMG1[42]), .DO43(DO_SRAM_IMG1[43]), .DO44(DO_SRAM_IMG1[44]), .DO45(DO_SRAM_IMG1[45]), .DO46(DO_SRAM_IMG1[46]),
                            .DO47(DO_SRAM_IMG1[47]), .DO48(DO_SRAM_IMG1[48]), .DO49(DO_SRAM_IMG1[49]), .DO50(DO_SRAM_IMG1[50]), .DO51(DO_SRAM_IMG1[51]), .DO52(DO_SRAM_IMG1[52]), .DO53(DO_SRAM_IMG1[53]), .DO54(DO_SRAM_IMG1[54]),
                            .DO55(DO_SRAM_IMG1[55]), .DO56(DO_SRAM_IMG1[56]), .DO57(DO_SRAM_IMG1[57]), .DO58(DO_SRAM_IMG1[58]), .DO59(DO_SRAM_IMG1[59]), .DO60(DO_SRAM_IMG1[60]), .DO61(DO_SRAM_IMG1[61]), .DO62(DO_SRAM_IMG1[62]),
                            .DO63(DO_SRAM_IMG1[63]), .DI0(image_row[0]), .DI1(image_row[1]), .DI2(image_row[2]), .DI3(image_row[3]), .DI4(image_row[4]), .DI5(image_row[5]), .DI6(image_row[6]), .DI7(image_row[7]), .DI8(image_row[8]),
                            .DI9(image_row[9]), .DI10(image_row[10]), .DI11(image_row[11]), .DI12(image_row[12]), .DI13(image_row[13]), .DI14(image_row[14]), .DI15(image_row[15]), .DI16(image_row[16]), .DI17(image_row[17]),
                            .DI18(image_row[18]), .DI19(image_row[19]), .DI20(image_row[20]), .DI21(image_row[21]), .DI22(image_row[22]), .DI23(image_row[23]), .DI24(image_row[24]), .DI25(image_row[25]),
                            .DI26(image_row[26]), .DI27(image_row[27]), .DI28(image_row[28]), .DI29(image_row[29]), .DI30(image_row[30]), .DI31(image_row[31]), .DI32(image_row[32]), .DI33(image_row[33]),
                            .DI34(image_row[34]), .DI35(image_row[35]), .DI36(image_row[36]), .DI37(image_row[37]), .DI38(image_row[38]), .DI39(image_row[39]), .DI40(image_row[40]), .DI41(image_row[41]),
                            .DI42(image_row[42]), .DI43(image_row[43]), .DI44(image_row[44]), .DI45(image_row[45]), .DI46(image_row[46]), .DI47(image_row[47]), .DI48(image_row[48]), .DI49(image_row[49]),
                            .DI50(image_row[50]), .DI51(image_row[51]), .DI52(image_row[52]), .DI53(image_row[53]), .DI54(image_row[54]), .DI55(image_row[55]), .DI56(image_row[56]), .DI57(image_row[57]),
                            .DI58(image_row[58]), .DI59(image_row[59]), .DI60(image_row[60]), .DI61(image_row[61]), .DI62(image_row[62]), .DI63(image_row[63]), .CK(clk), .WEB(web_sram_img_1), .OE(1'b1), .CS(1'b1));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  web_sram_img_1 <= 1'b1;
    else begin
        if(cnti_in_img8==3'd7 && !img_finish && cnt_sram_num==2'd0)     web_sram_img_1 <= 1'b0;
        else                                                            web_sram_img_1 <= 1'b1;
    end
end
//image second 8*8
SUMA180_512X64X1BM1 SRAM_IMG_2(.A0(img_addr[0]), .A1(img_addr[1]),.A2(img_addr[2]), .A3(img_addr[3]), .A4(img_addr[4]), .A5(img_addr[5]), .A6(img_addr[6]), .A7(img_addr[7]), .A8(img_addr[8]), 
                            .DO0(DO_SRAM_IMG2[0]), .DO1(DO_SRAM_IMG2[1]), .DO2(DO_SRAM_IMG2[2]), .DO3(DO_SRAM_IMG2[3]), .DO4(DO_SRAM_IMG2[4]),
                            .DO5(DO_SRAM_IMG2[5]), .DO6(DO_SRAM_IMG2[6]), .DO7(DO_SRAM_IMG2[7]), .DO8(DO_SRAM_IMG2[8]), .DO9(DO_SRAM_IMG2[9]), .DO10(DO_SRAM_IMG2[10]), .DO11(DO_SRAM_IMG2[11]), .DO12(DO_SRAM_IMG2[12]), .DO13(DO_SRAM_IMG2[13]), .DO14(DO_SRAM_IMG2[14]),
                            .DO15(DO_SRAM_IMG2[15]), .DO16(DO_SRAM_IMG2[16]), .DO17(DO_SRAM_IMG2[17]), .DO18(DO_SRAM_IMG2[18]), .DO19(DO_SRAM_IMG2[19]), .DO20(DO_SRAM_IMG2[20]), .DO21(DO_SRAM_IMG2[21]), .DO22(DO_SRAM_IMG2[22]),
                            .DO23(DO_SRAM_IMG2[23]), .DO24(DO_SRAM_IMG2[24]), .DO25(DO_SRAM_IMG2[25]), .DO26(DO_SRAM_IMG2[26]), .DO27(DO_SRAM_IMG2[27]), .DO28(DO_SRAM_IMG2[28]), .DO29(DO_SRAM_IMG2[29]), .DO30(DO_SRAM_IMG2[30]),
                            .DO31(DO_SRAM_IMG2[31]), .DO32(DO_SRAM_IMG2[32]), .DO33(DO_SRAM_IMG2[33]), .DO34(DO_SRAM_IMG2[34]), .DO35(DO_SRAM_IMG2[35]), .DO36(DO_SRAM_IMG2[36]), .DO37(DO_SRAM_IMG2[37]), .DO38(DO_SRAM_IMG2[38]),
                            .DO39(DO_SRAM_IMG2[39]), .DO40(DO_SRAM_IMG2[40]), .DO41(DO_SRAM_IMG2[41]), .DO42(DO_SRAM_IMG2[42]), .DO43(DO_SRAM_IMG2[43]), .DO44(DO_SRAM_IMG2[44]), .DO45(DO_SRAM_IMG2[45]), .DO46(DO_SRAM_IMG2[46]),
                            .DO47(DO_SRAM_IMG2[47]), .DO48(DO_SRAM_IMG2[48]), .DO49(DO_SRAM_IMG2[49]), .DO50(DO_SRAM_IMG2[50]), .DO51(DO_SRAM_IMG2[51]), .DO52(DO_SRAM_IMG2[52]), .DO53(DO_SRAM_IMG2[53]), .DO54(DO_SRAM_IMG2[54]),
                            .DO55(DO_SRAM_IMG2[55]), .DO56(DO_SRAM_IMG2[56]), .DO57(DO_SRAM_IMG2[57]), .DO58(DO_SRAM_IMG2[58]), .DO59(DO_SRAM_IMG2[59]), .DO60(DO_SRAM_IMG2[60]), .DO61(DO_SRAM_IMG2[61]), .DO62(DO_SRAM_IMG2[62]),
                            .DO63(DO_SRAM_IMG2[63]), .DI0(image_row[0]), .DI1(image_row[1]), .DI2(image_row[2]), .DI3(image_row[3]), .DI4(image_row[4]), .DI5(image_row[5]), .DI6(image_row[6]), .DI7(image_row[7]), .DI8(image_row[8]),
                            .DI9(image_row[9]), .DI10(image_row[10]), .DI11(image_row[11]), .DI12(image_row[12]), .DI13(image_row[13]), .DI14(image_row[14]), .DI15(image_row[15]), .DI16(image_row[16]), .DI17(image_row[17]),
                            .DI18(image_row[18]), .DI19(image_row[19]), .DI20(image_row[20]), .DI21(image_row[21]), .DI22(image_row[22]), .DI23(image_row[23]), .DI24(image_row[24]), .DI25(image_row[25]),
                            .DI26(image_row[26]), .DI27(image_row[27]), .DI28(image_row[28]), .DI29(image_row[29]), .DI30(image_row[30]), .DI31(image_row[31]), .DI32(image_row[32]), .DI33(image_row[33]),
                            .DI34(image_row[34]), .DI35(image_row[35]), .DI36(image_row[36]), .DI37(image_row[37]), .DI38(image_row[38]), .DI39(image_row[39]), .DI40(image_row[40]), .DI41(image_row[41]),
                            .DI42(image_row[42]), .DI43(image_row[43]), .DI44(image_row[44]), .DI45(image_row[45]), .DI46(image_row[46]), .DI47(image_row[47]), .DI48(image_row[48]), .DI49(image_row[49]),
                            .DI50(image_row[50]), .DI51(image_row[51]), .DI52(image_row[52]), .DI53(image_row[53]), .DI54(image_row[54]), .DI55(image_row[55]), .DI56(image_row[56]), .DI57(image_row[57]),
                            .DI58(image_row[58]), .DI59(image_row[59]), .DI60(image_row[60]), .DI61(image_row[61]), .DI62(image_row[62]), .DI63(image_row[63]), .CK(clk), .WEB(web_sram_img_2), .OE(1'b1), .CS(1'b1));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  web_sram_img_2 <= 1'b1;
    else begin
        if(cnti_in_img8==3'd7 && !img_finish && cnt_sram_num==2'd1)     web_sram_img_2 <= 1'b0;
        else                                                            web_sram_img_2 <= 1'b1;
    end
end
//image third 8*8
SUMA180_512X64X1BM1 SRAM_IMG_3(.A0(img_addr[0]), .A1(img_addr[1]),.A2(img_addr[2]), .A3(img_addr[3]), .A4(img_addr[4]), .A5(img_addr[5]), .A6(img_addr[6]), .A7(img_addr[7]), .A8(img_addr[8]), 
                            .DO0(DO_SRAM_IMG3[0]), .DO1(DO_SRAM_IMG3[1]), .DO2(DO_SRAM_IMG3[2]), .DO3(DO_SRAM_IMG3[3]), .DO4(DO_SRAM_IMG3[4]),
                            .DO5(DO_SRAM_IMG3[5]), .DO6(DO_SRAM_IMG3[6]), .DO7(DO_SRAM_IMG3[7]), .DO8(DO_SRAM_IMG3[8]), .DO9(DO_SRAM_IMG3[9]), .DO10(DO_SRAM_IMG3[10]), .DO11(DO_SRAM_IMG3[11]), .DO12(DO_SRAM_IMG3[12]), .DO13(DO_SRAM_IMG3[13]), .DO14(DO_SRAM_IMG3[14]),
                            .DO15(DO_SRAM_IMG3[15]), .DO16(DO_SRAM_IMG3[16]), .DO17(DO_SRAM_IMG3[17]), .DO18(DO_SRAM_IMG3[18]), .DO19(DO_SRAM_IMG3[19]), .DO20(DO_SRAM_IMG3[20]), .DO21(DO_SRAM_IMG3[21]), .DO22(DO_SRAM_IMG3[22]),
                            .DO23(DO_SRAM_IMG3[23]), .DO24(DO_SRAM_IMG3[24]), .DO25(DO_SRAM_IMG3[25]), .DO26(DO_SRAM_IMG3[26]), .DO27(DO_SRAM_IMG3[27]), .DO28(DO_SRAM_IMG3[28]), .DO29(DO_SRAM_IMG3[29]), .DO30(DO_SRAM_IMG3[30]),
                            .DO31(DO_SRAM_IMG3[31]), .DO32(DO_SRAM_IMG3[32]), .DO33(DO_SRAM_IMG3[33]), .DO34(DO_SRAM_IMG3[34]), .DO35(DO_SRAM_IMG3[35]), .DO36(DO_SRAM_IMG3[36]), .DO37(DO_SRAM_IMG3[37]), .DO38(DO_SRAM_IMG3[38]),
                            .DO39(DO_SRAM_IMG3[39]), .DO40(DO_SRAM_IMG3[40]), .DO41(DO_SRAM_IMG3[41]), .DO42(DO_SRAM_IMG3[42]), .DO43(DO_SRAM_IMG3[43]), .DO44(DO_SRAM_IMG3[44]), .DO45(DO_SRAM_IMG3[45]), .DO46(DO_SRAM_IMG3[46]),
                            .DO47(DO_SRAM_IMG3[47]), .DO48(DO_SRAM_IMG3[48]), .DO49(DO_SRAM_IMG3[49]), .DO50(DO_SRAM_IMG3[50]), .DO51(DO_SRAM_IMG3[51]), .DO52(DO_SRAM_IMG3[52]), .DO53(DO_SRAM_IMG3[53]), .DO54(DO_SRAM_IMG3[54]),
                            .DO55(DO_SRAM_IMG3[55]), .DO56(DO_SRAM_IMG3[56]), .DO57(DO_SRAM_IMG3[57]), .DO58(DO_SRAM_IMG3[58]), .DO59(DO_SRAM_IMG3[59]), .DO60(DO_SRAM_IMG3[60]), .DO61(DO_SRAM_IMG3[61]), .DO62(DO_SRAM_IMG3[62]),
                            .DO63(DO_SRAM_IMG3[63]), .DI0(image_row[0]), .DI1(image_row[1]), .DI2(image_row[2]), .DI3(image_row[3]), .DI4(image_row[4]), .DI5(image_row[5]), .DI6(image_row[6]), .DI7(image_row[7]), .DI8(image_row[8]),
                            .DI9(image_row[9]), .DI10(image_row[10]), .DI11(image_row[11]), .DI12(image_row[12]), .DI13(image_row[13]), .DI14(image_row[14]), .DI15(image_row[15]), .DI16(image_row[16]), .DI17(image_row[17]),
                            .DI18(image_row[18]), .DI19(image_row[19]), .DI20(image_row[20]), .DI21(image_row[21]), .DI22(image_row[22]), .DI23(image_row[23]), .DI24(image_row[24]), .DI25(image_row[25]),
                            .DI26(image_row[26]), .DI27(image_row[27]), .DI28(image_row[28]), .DI29(image_row[29]), .DI30(image_row[30]), .DI31(image_row[31]), .DI32(image_row[32]), .DI33(image_row[33]),
                            .DI34(image_row[34]), .DI35(image_row[35]), .DI36(image_row[36]), .DI37(image_row[37]), .DI38(image_row[38]), .DI39(image_row[39]), .DI40(image_row[40]), .DI41(image_row[41]),
                            .DI42(image_row[42]), .DI43(image_row[43]), .DI44(image_row[44]), .DI45(image_row[45]), .DI46(image_row[46]), .DI47(image_row[47]), .DI48(image_row[48]), .DI49(image_row[49]),
                            .DI50(image_row[50]), .DI51(image_row[51]), .DI52(image_row[52]), .DI53(image_row[53]), .DI54(image_row[54]), .DI55(image_row[55]), .DI56(image_row[56]), .DI57(image_row[57]),
                            .DI58(image_row[58]), .DI59(image_row[59]), .DI60(image_row[60]), .DI61(image_row[61]), .DI62(image_row[62]), .DI63(image_row[63]), .CK(clk), .WEB(web_sram_img_3), .OE(1'b1), .CS(1'b1));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  web_sram_img_3 <= 1'b1;
    else begin
        if(cnti_in_img8==3'd7 && !img_finish && cnt_sram_num==2'd2)     web_sram_img_3 <= 1'b0;
        else                                                            web_sram_img_3 <= 1'b1;
    end
end
//image fourth 8*8
SUMA180_512X64X1BM1 SRAM_IMG_4(.A0(img_addr[0]), .A1(img_addr[1]),.A2(img_addr[2]), .A3(img_addr[3]), .A4(img_addr[4]), .A5(img_addr[5]), .A6(img_addr[6]), .A7(img_addr[7]), .A8(img_addr[8]), 
                            .DO0(DO_SRAM_IMG4[0]), .DO1(DO_SRAM_IMG4[1]), .DO2(DO_SRAM_IMG4[2]), .DO3(DO_SRAM_IMG4[3]), .DO4(DO_SRAM_IMG4[4]),
                            .DO5(DO_SRAM_IMG4[5]), .DO6(DO_SRAM_IMG4[6]), .DO7(DO_SRAM_IMG4[7]), .DO8(DO_SRAM_IMG4[8]), .DO9(DO_SRAM_IMG4[9]), .DO10(DO_SRAM_IMG4[10]), .DO11(DO_SRAM_IMG4[11]), .DO12(DO_SRAM_IMG4[12]), .DO13(DO_SRAM_IMG4[13]), .DO14(DO_SRAM_IMG4[14]),
                            .DO15(DO_SRAM_IMG4[15]), .DO16(DO_SRAM_IMG4[16]), .DO17(DO_SRAM_IMG4[17]), .DO18(DO_SRAM_IMG4[18]), .DO19(DO_SRAM_IMG4[19]), .DO20(DO_SRAM_IMG4[20]), .DO21(DO_SRAM_IMG4[21]), .DO22(DO_SRAM_IMG4[22]),
                            .DO23(DO_SRAM_IMG4[23]), .DO24(DO_SRAM_IMG4[24]), .DO25(DO_SRAM_IMG4[25]), .DO26(DO_SRAM_IMG4[26]), .DO27(DO_SRAM_IMG4[27]), .DO28(DO_SRAM_IMG4[28]), .DO29(DO_SRAM_IMG4[29]), .DO30(DO_SRAM_IMG4[30]),
                            .DO31(DO_SRAM_IMG4[31]), .DO32(DO_SRAM_IMG4[32]), .DO33(DO_SRAM_IMG4[33]), .DO34(DO_SRAM_IMG4[34]), .DO35(DO_SRAM_IMG4[35]), .DO36(DO_SRAM_IMG4[36]), .DO37(DO_SRAM_IMG4[37]), .DO38(DO_SRAM_IMG4[38]),
                            .DO39(DO_SRAM_IMG4[39]), .DO40(DO_SRAM_IMG4[40]), .DO41(DO_SRAM_IMG4[41]), .DO42(DO_SRAM_IMG4[42]), .DO43(DO_SRAM_IMG4[43]), .DO44(DO_SRAM_IMG4[44]), .DO45(DO_SRAM_IMG4[45]), .DO46(DO_SRAM_IMG4[46]),
                            .DO47(DO_SRAM_IMG4[47]), .DO48(DO_SRAM_IMG4[48]), .DO49(DO_SRAM_IMG4[49]), .DO50(DO_SRAM_IMG4[50]), .DO51(DO_SRAM_IMG4[51]), .DO52(DO_SRAM_IMG4[52]), .DO53(DO_SRAM_IMG4[53]), .DO54(DO_SRAM_IMG4[54]),
                            .DO55(DO_SRAM_IMG4[55]), .DO56(DO_SRAM_IMG4[56]), .DO57(DO_SRAM_IMG4[57]), .DO58(DO_SRAM_IMG4[58]), .DO59(DO_SRAM_IMG4[59]), .DO60(DO_SRAM_IMG4[60]), .DO61(DO_SRAM_IMG4[61]), .DO62(DO_SRAM_IMG4[62]),
                            .DO63(DO_SRAM_IMG4[63]), .DI0(image_row[0]), .DI1(image_row[1]), .DI2(image_row[2]), .DI3(image_row[3]), .DI4(image_row[4]), .DI5(image_row[5]), .DI6(image_row[6]), .DI7(image_row[7]), .DI8(image_row[8]),
                            .DI9(image_row[9]), .DI10(image_row[10]), .DI11(image_row[11]), .DI12(image_row[12]), .DI13(image_row[13]), .DI14(image_row[14]), .DI15(image_row[15]), .DI16(image_row[16]), .DI17(image_row[17]),
                            .DI18(image_row[18]), .DI19(image_row[19]), .DI20(image_row[20]), .DI21(image_row[21]), .DI22(image_row[22]), .DI23(image_row[23]), .DI24(image_row[24]), .DI25(image_row[25]),
                            .DI26(image_row[26]), .DI27(image_row[27]), .DI28(image_row[28]), .DI29(image_row[29]), .DI30(image_row[30]), .DI31(image_row[31]), .DI32(image_row[32]), .DI33(image_row[33]),
                            .DI34(image_row[34]), .DI35(image_row[35]), .DI36(image_row[36]), .DI37(image_row[37]), .DI38(image_row[38]), .DI39(image_row[39]), .DI40(image_row[40]), .DI41(image_row[41]),
                            .DI42(image_row[42]), .DI43(image_row[43]), .DI44(image_row[44]), .DI45(image_row[45]), .DI46(image_row[46]), .DI47(image_row[47]), .DI48(image_row[48]), .DI49(image_row[49]),
                            .DI50(image_row[50]), .DI51(image_row[51]), .DI52(image_row[52]), .DI53(image_row[53]), .DI54(image_row[54]), .DI55(image_row[55]), .DI56(image_row[56]), .DI57(image_row[57]),
                            .DI58(image_row[58]), .DI59(image_row[59]), .DI60(image_row[60]), .DI61(image_row[61]), .DI62(image_row[62]), .DI63(image_row[63]), .CK(clk), .WEB(web_sram_img_4), .OE(1'b1), .CS(1'b1));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  web_sram_img_4 <= 1'b1;
    else begin
        if(cnti_in_img8==3'd7 && !img_finish && cnt_sram_num==2'd3)     web_sram_img_4 <= 1'b0;
        else                                                            web_sram_img_4 <= 1'b1;
    end
end

assign DO_sram_img[0] = DO_SRAM_IMG1[63:56];
assign DO_sram_img[1] = DO_SRAM_IMG1[55:48];
assign DO_sram_img[2] = DO_SRAM_IMG1[47:40];
assign DO_sram_img[3] = DO_SRAM_IMG1[39:32];
assign DO_sram_img[4] = DO_SRAM_IMG1[31:24];
assign DO_sram_img[5] = DO_SRAM_IMG1[23:16];
assign DO_sram_img[6] = DO_SRAM_IMG1[15:8];
assign DO_sram_img[7] = DO_SRAM_IMG1[7:0];
assign DO_sram_img[8] = DO_SRAM_IMG2[63:56];
assign DO_sram_img[9] = DO_SRAM_IMG2[55:48];
assign DO_sram_img[10] = DO_SRAM_IMG2[47:40];
assign DO_sram_img[11] = DO_SRAM_IMG2[39:32];
assign DO_sram_img[12] = DO_SRAM_IMG2[31:24];
assign DO_sram_img[13] = DO_SRAM_IMG2[23:16];
assign DO_sram_img[14] = DO_SRAM_IMG2[15:8];
assign DO_sram_img[15] = DO_SRAM_IMG2[7:0];
assign DO_sram_img[16] = DO_SRAM_IMG3[63:56];
assign DO_sram_img[17] = DO_SRAM_IMG3[55:48];
assign DO_sram_img[18] = DO_SRAM_IMG3[47:40];
assign DO_sram_img[19] = DO_SRAM_IMG3[39:32];
assign DO_sram_img[20] = DO_SRAM_IMG3[31:24];
assign DO_sram_img[21] = DO_SRAM_IMG3[23:16];
assign DO_sram_img[22] = DO_SRAM_IMG3[15:8];
assign DO_sram_img[23] = DO_SRAM_IMG3[7:0];
assign DO_sram_img[24] = DO_SRAM_IMG4[63:56];
assign DO_sram_img[25] = DO_SRAM_IMG4[55:48];
assign DO_sram_img[26] = DO_SRAM_IMG4[47:40];
assign DO_sram_img[27] = DO_SRAM_IMG4[39:32];
assign DO_sram_img[28] = DO_SRAM_IMG4[31:24];
assign DO_sram_img[29] = DO_SRAM_IMG4[23:16];
assign DO_sram_img[30] = DO_SRAM_IMG4[15:8];
assign DO_sram_img[31] = DO_SRAM_IMG4[7:0];



//kernel 5*5
SUMA180_80X40X1BM1 SRAM_Kernel(.A0(ker_addr[0]), .A1(ker_addr[1]), .A2(ker_addr[2]), .A3(ker_addr[3]), .A4(ker_addr[4]), .A5(ker_addr[5]), .A6(ker_addr[6]),
                            .DO0(DO_SRAM_Kern[0]), .DO1(DO_SRAM_Kern[1]), .DO2(DO_SRAM_Kern[2]), .DO3(DO_SRAM_Kern[3]), .DO4(DO_SRAM_Kern[4]), .DO5(DO_SRAM_Kern[5]), .DO6(DO_SRAM_Kern[6]),
                            .DO7(DO_SRAM_Kern[7]), .DO8(DO_SRAM_Kern[8]), .DO9(DO_SRAM_Kern[9]), .DO10(DO_SRAM_Kern[10]), .DO11(DO_SRAM_Kern[11]), .DO12(DO_SRAM_Kern[12]), .DO13(DO_SRAM_Kern[13]), .DO14(DO_SRAM_Kern[14]), .DO15(DO_SRAM_Kern[15]),
                            .DO16(DO_SRAM_Kern[16]), .DO17(DO_SRAM_Kern[17]), .DO18(DO_SRAM_Kern[18]), .DO19(DO_SRAM_Kern[19]), .DO20(DO_SRAM_Kern[20]), .DO21(DO_SRAM_Kern[21]), .DO22(DO_SRAM_Kern[22]), .DO23(DO_SRAM_Kern[23]),
                            .DO24(DO_SRAM_Kern[24]), .DO25(DO_SRAM_Kern[25]), .DO26(DO_SRAM_Kern[26]), .DO27(DO_SRAM_Kern[27]), .DO28(DO_SRAM_Kern[28]), .DO29(DO_SRAM_Kern[29]), .DO30(DO_SRAM_Kern[30]), .DO31(DO_SRAM_Kern[31]),
                            .DO32(DO_SRAM_Kern[32]), .DO33(DO_SRAM_Kern[33]), .DO34(DO_SRAM_Kern[34]), .DO35(DO_SRAM_Kern[35]), .DO36(DO_SRAM_Kern[36]), .DO37(DO_SRAM_Kern[37]), .DO38(DO_SRAM_Kern[38]), .DO39(DO_SRAM_Kern[39]),
                            .DI0(image_row[0]), .DI1(image_row[1]), .DI2(image_row[2]), .DI3(image_row[3]), .DI4(image_row[4]), .DI5(image_row[5]), .DI6(image_row[6]), .DI7(image_row[7]), .DI8(image_row[8]), .DI9(image_row[9]),
                            .DI10(image_row[10]), .DI11(image_row[11]), .DI12(image_row[12]), .DI13(image_row[13]), .DI14(image_row[14]), .DI15(image_row[15]), .DI16(image_row[16]), .DI17(image_row[17]),
                            .DI18(image_row[18]), .DI19(image_row[19]), .DI20(image_row[20]), .DI21(image_row[21]), .DI22(image_row[22]), .DI23(image_row[23]), .DI24(image_row[24]), .DI25(image_row[25]),
                            .DI26(image_row[26]), .DI27(image_row[27]), .DI28(image_row[28]), .DI29(image_row[29]), .DI30(image_row[30]), .DI31(image_row[31]), .DI32(image_row[32]), .DI33(image_row[33]),
                            .DI34(image_row[34]), .DI35(image_row[35]), .DI36(image_row[36]), .DI37(image_row[37]), .DI38(image_row[38]), .DI39(image_row[39]), .CK(clk), .WEB(web_sram_kernel), .OE(1'b1), .CS(1'b1));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  web_sram_kernel <= 1'b1;
    else begin
        if(cnt_in_kernel==3'd4 && img_finish)   web_sram_kernel <= 1'b0;
        else                                    web_sram_kernel <= 1'b1;
    end
end

//=================================
//		SRAM Address
//=================================

//find matrix's first row
assign ptr_matrix = i_matrix_idx << (matrix_size_reg+'d3);
assign ptr_kernel = k_matrix_idx * 5;

//ker_addr
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  ker_addr <= 7'b0;
    else        ker_addr <= ker_addr_comb;
end
always@(*) begin
    case(curr_state)
        IDLE:                                       ker_addr_comb = 7'b0;
        INPUT: begin
            if(!web_sram_kernel && ker_addr==7'd79) ker_addr_comb = 7'b0;
            else if(!web_sram_kernel)               ker_addr_comb = ker_addr + 'd1;
            else                                    ker_addr_comb = ker_addr;
        end
        INPUT2,CONV,DECONV:                         ker_addr_comb = ptr_kernel + cnt_kernel;
        default:                                    ker_addr_comb = 7'b0;
    endcase
end
//img_addr
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  img_addr <= 9'b0;
    else        img_addr <= img_addr_comb;
end
always@(*) begin
    case(curr_state)
        IDLE:   img_addr_comb = 9'b0;
        INPUT: begin
            if(matrix_size_reg==2'd0 && !web_sram_img_1)        img_addr_comb = img_addr + 'd1;
            else if(matrix_size_reg==2'd1 && !web_sram_img_2)   img_addr_comb = img_addr + 'd1;
            else if(matrix_size_reg==2'd2 && !web_sram_img_4)   img_addr_comb = img_addr + 'd1;
            else                                                img_addr_comb = img_addr;
        end
        INPUT2,CONV,DECONV: begin
            img_addr_comb = ptr_matrix + cnt_kernel + img_addr_offset; //
        end
        default:    img_addr_comb = 9'b0;
    endcase
end

//=================================
//		FSM
//=================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_invalid2 <= 5'b0;
    else begin
        if(curr_state==IDLE)                    cnt_invalid2 <= 5'b0;
        else if(curr_state==IDLE2 && in_valid2) cnt_invalid2 <= cnt_invalid2 + 'd1;
        else                                    cnt_invalid2 <= cnt_invalid2;
    end
end

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
            if(!in_valid)   next_state = IDLE2;
            else            next_state = INPUT;
        end
        IDLE2: begin
            if(in_valid2)   next_state = INPUT2;
            else            next_state = IDLE2;
        end
        INPUT2: begin
            if(!in_valid2 && !mode_reg)     next_state = CONV;
            else if(!in_valid2 && mode_reg) next_state = DECONV;
            else                            next_state = INPUT2;
        end
        CONV: begin //TODO: when to go to IDLE
            if(matrix_size_reg==2'd0 && cnt_state==15'd102) begin
                if(cnt_invalid2==5'd16) next_state = IDLE;
                else                    next_state = IDLE2;
            end
            else if(matrix_size_reg==2'd1 && cnt_state==15'd742) begin //TODO: check length
                if(cnt_invalid2==5'd16) next_state = IDLE;
                else                    next_state = IDLE2;
            end
            else if(matrix_size_reg==2'd2 && cnt_state==15'd3942) begin //TODO: check length
                if(cnt_invalid2==5'd16) next_state = IDLE;
                else                    next_state = IDLE2;
            end
            else                        next_state = CONV;
        end
        DECONV: begin
            if(deconv_out_finish) begin
                if(cnt_invalid2==5'd16) next_state = IDLE;
                else                    next_state = IDLE2;
            end
            else    next_state = DECONV;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
//cnt_state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_state <= 15'b0;
    else begin
        if(curr_state!=next_state)  cnt_state <= 15'b0;
        else                        cnt_state <= cnt_state + 'd1;
    end
end


//=================================
//		Store SRAM DO
//=================================

//Kernel from SRAM
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        DO_Kernel_reg[0] <= 8'b0;
        DO_Kernel_reg[1] <= 8'b0;
        DO_Kernel_reg[2] <= 8'b0;
        DO_Kernel_reg[3] <= 8'b0;
        DO_Kernel_reg[4] <= 8'b0;
    end
    else begin
        DO_Kernel_reg[0] <= DO_Kernel_comb[0];
        DO_Kernel_reg[1] <= DO_Kernel_comb[1];
        DO_Kernel_reg[2] <= DO_Kernel_comb[2];
        DO_Kernel_reg[3] <= DO_Kernel_comb[3];
        DO_Kernel_reg[4] <= DO_Kernel_comb[4];
    end
end
always@(*) begin
    if(curr_state==CONV || curr_state==DECONV) begin
        DO_Kernel_comb[0] = DO_SRAM_Kern[39:32];
        DO_Kernel_comb[1] = DO_SRAM_Kern[31:24];
        DO_Kernel_comb[2] = DO_SRAM_Kern[23:16];
        DO_Kernel_comb[3] = DO_SRAM_Kern[15:8];
        DO_Kernel_comb[4] = DO_SRAM_Kern[7:0];
    end
    else begin
        DO_Kernel_comb[0] = 8'b0;
        DO_Kernel_comb[1] = 8'b0;
        DO_Kernel_comb[2] = 8'b0;
        DO_Kernel_comb[3] = 8'b0;
        DO_Kernel_comb[4] = 8'b0;
    end
end
//Image from SRAM
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        DO_Image_reg[0] <= 8'b0;
        DO_Image_reg[1] <= 8'b0;
        DO_Image_reg[2] <= 8'b0;
        DO_Image_reg[3] <= 8'b0;
        DO_Image_reg[4] <= 8'b0;
    end
    else begin
        DO_Image_reg[0] <= DO_Image_comb[0];
        DO_Image_reg[1] <= DO_Image_comb[1];
        DO_Image_reg[2] <= DO_Image_comb[2];
        DO_Image_reg[3] <= DO_Image_comb[3];
        DO_Image_reg[4] <= DO_Image_comb[4];
    end
end
always@(*) begin
    if(curr_state==CONV) begin
        DO_Image_comb[0] = DO_sram_img[col_ptr_8_d2+col_offset_d2];
        DO_Image_comb[1] = DO_sram_img[col_ptr_8_d2+col_offset_d2+'d1];
        DO_Image_comb[2] = DO_sram_img[col_ptr_8_d2+col_offset_d2+'d2];
        DO_Image_comb[3] = DO_sram_img[col_ptr_8_d2+col_offset_d2+'d3];
        DO_Image_comb[4] = DO_sram_img[col_ptr_8_d2+col_offset_d2+'d4];
    end
    else if(curr_state==DECONV) begin
        DO_Image_comb[0] = DO_sram_img[deconv_col_ptr_d4];
        DO_Image_comb[1] = 8'b0;
        DO_Image_comb[2] = 8'b0;
        DO_Image_comb[3] = 8'b0;
        DO_Image_comb[4] = 8'b0;
    end
    else begin
        DO_Image_comb[0] = 8'b0;
        DO_Image_comb[1] = 8'b0;
        DO_Image_comb[2] = 8'b0;
        DO_Image_comb[3] = 8'b0;
        DO_Image_comb[4] = 8'b0;
    end
end

//===============================================STOP=============================================================//



//kernel counter for kernel address
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_kernel <= 3'b0;
    else begin
        if(curr_state==CONV || next_state==CONV) begin
            if(cnt_kernel=='d4) cnt_kernel <= 'd0;
            else                cnt_kernel <= cnt_kernel + 'd1;
        end
        else if(curr_state==DECONV || next_state==DECONV) begin
            if(cnt_state>='d3)  cnt_kernel <= 'd0;
            else if(cnt_kernel=='d4) cnt_kernel <= 'd0;
            else                cnt_kernel <= cnt_kernel + 'd1;
            
        end
        else cnt_kernel <= 3'b0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_kernel_d1 <= 3'b0;
    else        cnt_kernel_d1 <= cnt_kernel;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_kernel_d2 <= 3'b0;
    else        cnt_kernel_d2 <= cnt_kernel_d1;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_kernel_d3 <= 3'b0;
    else        cnt_kernel_d3 <= cnt_kernel_d2;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_kernel_d4 <= 3'b0;
    else        cnt_kernel_d4 <= cnt_kernel_d3;
end

//store Kernel
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<5;i=i+1) begin
            for(j=0;j<5;j=j+1) begin
                kernel_reg[i][j] <= 'b0;
            end
        end
    end
    else begin
        if(curr_state==DECONV && cnt_state>='d1 && cnt_state<='d5) begin
            kernel_reg[0][0]<=kernel_reg[1][0]; kernel_reg[0][1]<=kernel_reg[1][1]; kernel_reg[0][2]<=kernel_reg[1][2]; kernel_reg[0][3]<=kernel_reg[1][3]; kernel_reg[0][4]<=kernel_reg[1][4];
            kernel_reg[1][0]<=kernel_reg[2][0]; kernel_reg[1][1]<=kernel_reg[2][1]; kernel_reg[1][2]<=kernel_reg[2][2]; kernel_reg[1][3]<=kernel_reg[2][3]; kernel_reg[1][4]<=kernel_reg[2][4];
            kernel_reg[2][0]<=kernel_reg[3][0]; kernel_reg[2][1]<=kernel_reg[3][1]; kernel_reg[2][2]<=kernel_reg[3][2]; kernel_reg[2][3]<=kernel_reg[3][3]; kernel_reg[2][4]<=kernel_reg[3][4];
            kernel_reg[3][0]<=kernel_reg[4][0]; kernel_reg[3][1]<=kernel_reg[4][1]; kernel_reg[3][2]<=kernel_reg[4][2]; kernel_reg[3][3]<=kernel_reg[4][3]; kernel_reg[3][4]<=kernel_reg[4][4];
            kernel_reg[4][0]<=DO_SRAM_Kern[39:32];
            kernel_reg[4][1]<=DO_SRAM_Kern[31:24];
            kernel_reg[4][2]<=DO_SRAM_Kern[23:16];
            kernel_reg[4][3]<=DO_SRAM_Kern[15:8];
            kernel_reg[4][4]<=DO_SRAM_Kern[7:0];
        end
        else begin
            for(m=0;m<5;m=m+1) begin
                for(n=0;n<5;n=n+1) begin
                    kernel_reg[m][n] <= kernel_reg[m][n];
                end
            end
        end
    end
end

//------------------------------------------------------------------------//
//cnt_change_addr //for deconv, when to change address
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_change_addr <= 5'b0;
    else begin
        if(curr_state==DECONV || next_state==DECONV) begin
            if(matrix_size_reg=='d0) begin
                if(cnt_change_addr=='d7)    cnt_change_addr <= 5'b0;
                else                        cnt_change_addr <= cnt_change_addr + 'd1;
            end
            else if(matrix_size_reg=='d1) begin
                if(cnt_change_addr=='d15)   cnt_change_addr <= 5'b0;
                else                        cnt_change_addr <= cnt_change_addr + 'd1;
            end
            else begin
                if(cnt_change_addr=='d31)   cnt_change_addr <= 5'b0;
                else                        cnt_change_addr <= cnt_change_addr + 'd1;
            end
        end
        else                                cnt_change_addr <= 5'b0;
    end
end

//deconv_col_ptr
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_col_ptr <= 5'b0;
    else        deconv_col_ptr <= deconv_col_ptr_comb;
end
always@(*) begin
    if(curr_state==DECONV && cnt_state>'d1) begin
        if(matrix_size_reg=='d0) begin
            if(cnt_line=='d5)           deconv_col_ptr_comb = 5'b0;
            else if(deconv_col_ptr=='d7)     deconv_col_ptr_comb = 5'b0;
            else                        deconv_col_ptr_comb = deconv_col_ptr + 'd1;
        end
        else if(matrix_size_reg=='d1) begin
            if(cnt_line=='d13)          deconv_col_ptr_comb = 5'b0;
            else if(deconv_col_ptr=='d15)    deconv_col_ptr_comb = 5'b0;
            else                        deconv_col_ptr_comb = deconv_col_ptr + 'd1;
        end
        else begin
            if(cnt_line=='d29)          deconv_col_ptr_comb = 5'b0;
            else if(deconv_col_ptr=='d31)    deconv_col_ptr_comb = 5'b0;
            else                        deconv_col_ptr_comb = deconv_col_ptr + 'd1;
        end
    end
    else deconv_col_ptr_comb = 5'b0;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_col_ptr_d1 <= 5'b0;
    else        deconv_col_ptr_d1 <= deconv_col_ptr;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_col_ptr_d2 <= 5'b0;
    else        deconv_col_ptr_d2 <= deconv_col_ptr_d1; //for output
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_col_ptr_d3 <= 5'b0;
    else        deconv_col_ptr_d3 <= deconv_col_ptr_d2;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_col_ptr_d4 <= 5'b0;
    else        deconv_col_ptr_d4 <= deconv_col_ptr_d3;
end

//------------------------------------------------------------------------//


//multiplier
always@(*) begin
    if(curr_state==DECONV) begin
        m1_a = kernel_reg[0][0]; m1_b = DO_Image_reg[0];
        m2_a = kernel_reg[0][1]; m2_b = DO_Image_reg[0];
        m3_a = kernel_reg[0][2]; m3_b = DO_Image_reg[0];
        m4_a = kernel_reg[0][3]; m4_b = DO_Image_reg[0];
        m5_a = kernel_reg[0][4]; m5_b = DO_Image_reg[0];
    end
    else if(curr_state==CONV) begin
        m1_a = DO_Kernel_reg[0]; m1_b = DO_Image_reg[0];
        m2_a = DO_Kernel_reg[1]; m2_b = DO_Image_reg[1];
        m3_a = DO_Kernel_reg[2]; m3_b = DO_Image_reg[2];
        m4_a = DO_Kernel_reg[3]; m4_b = DO_Image_reg[3];
        m5_a = DO_Kernel_reg[4]; m5_b = DO_Image_reg[4];
    end
    else begin
        m1_a = 'd0; m1_b = 'd0;
        m2_a = 'd0; m2_b = 'd0;
        m3_a = 'd0; m3_b = 'd0;
        m4_a = 'd0; m4_b = 'd0;
        m5_a = 'd0; m5_b = 'd0;
    end
end
always@(*) begin
    m6_a = kernel_reg[1][0]; m6_b = DO_Image_reg[0];
    m7_a = kernel_reg[1][1]; m7_b = DO_Image_reg[0];
    m8_a = kernel_reg[1][2]; m8_b = DO_Image_reg[0];
    m9_a = kernel_reg[1][3]; m9_b = DO_Image_reg[0];
    m10_a = kernel_reg[1][4]; m10_b = DO_Image_reg[0];

    m11_a = kernel_reg[2][0]; m11_b = DO_Image_reg[0];
    m12_a = kernel_reg[2][1]; m12_b = DO_Image_reg[0];
    m13_a = kernel_reg[2][2]; m13_b = DO_Image_reg[0];
    m14_a = kernel_reg[2][3]; m14_b = DO_Image_reg[0];
    m15_a = kernel_reg[2][4]; m15_b = DO_Image_reg[0];

    m16_a = kernel_reg[3][0]; m16_b = DO_Image_reg[0];
    m17_a = kernel_reg[3][1]; m17_b = DO_Image_reg[0];
    m18_a = kernel_reg[3][2]; m18_b = DO_Image_reg[0];
    m19_a = kernel_reg[3][3]; m19_b = DO_Image_reg[0];
    m20_a = kernel_reg[3][4]; m20_b = DO_Image_reg[0];

    m21_a = kernel_reg[4][0]; m21_b = DO_Image_reg[0];
    m22_a = kernel_reg[4][1]; m22_b = DO_Image_reg[0];
    m23_a = kernel_reg[4][2]; m23_b = DO_Image_reg[0];
    m24_a = kernel_reg[4][3]; m24_b = DO_Image_reg[0];
    m25_a = kernel_reg[4][4]; m25_b = DO_Image_reg[0];
end

always@(*) begin
    if(stop_mac || stop_flag) begin
        m1_z = 'd0; m6_z = 'd0; m11_z = 'd0; m16_z = 'd0; m21_z = 'd0;
        m2_z = 'd0; m7_z = 'd0; m12_z = 'd0; m17_z = 'd0; m22_z = 'd0;
        m3_z = 'd0; m8_z = 'd0; m13_z = 'd0; m18_z = 'd0; m23_z = 'd0;
        m4_z = 'd0; m9_z = 'd0; m14_z = 'd0; m19_z = 'd0; m24_z = 'd0;
        m5_z = 'd0; m10_z ='d0; m15_z = 'd0; m20_z = 'd0; m25_z = 'd0;
    end

    else begin
        m1_z = m1_a * m1_b; m6_z = m6_a * m6_b;    m11_z = m11_a * m11_b; m16_z = m16_a * m16_b; m21_z = m21_a * m21_b;
        m2_z = m2_a * m2_b; m7_z = m7_a * m7_b;    m12_z = m12_a * m12_b; m17_z = m17_a * m17_b; m22_z = m22_a * m22_b;
        m3_z = m3_a * m3_b; m8_z = m8_a * m8_b;    m13_z = m13_a * m13_b; m18_z = m18_a * m18_b; m23_z = m23_a * m23_b;
        m4_z = m4_a * m4_b; m9_z = m9_a * m9_b;    m14_z = m14_a * m14_b; m19_z = m19_a * m19_b; m24_z = m24_a * m24_b;
        m5_z = m5_a * m5_b; m10_z = m10_a * m10_b; m15_z = m15_a * m15_b; m20_z = m20_a * m20_b; m25_z = m25_a * m25_b;
    end
end

assign result = deconv_temp1[0]+{{4{m1_z[15]}}, m1_z};

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<36;i=i+1) begin
            deconv_temp1[i] <= 20'b0;
            deconv_temp2[i] <= 20'b0;
            deconv_temp3[i] <= 20'b0;
            deconv_temp4[i] <= 20'b0;
        end
        for(j=0;j<4;j=j+1) deconv_temp5[j] <= 20'b0;
    end
    else begin
        if(curr_state==DECONV && cnt_state>'d6) begin
            deconv_temp1[0]<=deconv_temp1[1]+{{4{m2_z[15]}},m2_z};   deconv_temp1[1]<=deconv_temp1[2]+{{4{m3_z[15]}},m3_z};   deconv_temp1[2]<=deconv_temp1[3]+{{4{m4_z[15]}},m4_z}; deconv_temp1[3]<=deconv_temp1[4]+{{4{m5_z[15]}},m5_z};
            deconv_temp2[0]<=deconv_temp2[1]+{{4{m7_z[15]}},m7_z};   deconv_temp2[1]<=deconv_temp2[2]+{{4{m8_z[15]}},m8_z};   deconv_temp2[2]<=deconv_temp2[3]+{{4{m9_z[15]}},m9_z}; deconv_temp2[3]<=deconv_temp2[4]+{{4{m10_z[15]}},m10_z};
            deconv_temp3[0]<=deconv_temp3[1]+{{4{m12_z[15]}},m12_z}; deconv_temp3[1]<=deconv_temp3[2]+{{4{m13_z[15]}},m13_z}; deconv_temp3[2]<=deconv_temp3[3]+{{4{m14_z[15]}},m14_z}; deconv_temp3[3]<=deconv_temp3[4]+{{4{m15_z[15]}},m15_z};
            deconv_temp4[0]<=deconv_temp4[1]+{{4{m17_z[15]}},m17_z}; deconv_temp4[1]<=deconv_temp4[2]+{{4{m18_z[15]}},m18_z}; deconv_temp4[2]<=deconv_temp4[3]+{{4{m19_z[15]}},m19_z}; deconv_temp4[3]<=deconv_temp4[4]+{{4{m20_z[15]}},m20_z};
            deconv_temp5[0]<=deconv_temp5[1]+{{4{m22_z[15]}},m22_z}; deconv_temp5[1]<=deconv_temp5[2]+{{4{m23_z[15]}},m23_z}; deconv_temp5[2]<=deconv_temp5[3]+{{4{m24_z[15]}},m24_z}; deconv_temp5[3]<={{4{m25_z[15]}},m25_z};
            //
            deconv_temp1[11]<=(matrix_size_reg=='d0)?(deconv_temp2[0]+{{4{m6_z[15]}},m6_z}):deconv_temp1[12];  deconv_temp1[19]<=(matrix_size_reg=='d1)?(deconv_temp2[0]+{{4{m6_z[15]}},m6_z}):deconv_temp1[20];  deconv_temp1[35]<=(matrix_size_reg=='d2)?(deconv_temp2[0]+{{4{m6_z[15]}},m6_z}):'d0;
            deconv_temp2[11]<=(matrix_size_reg=='d0)?(deconv_temp3[0]+{{4{m11_z[15]}},m11_z}):deconv_temp2[12]; deconv_temp2[19]<=(matrix_size_reg=='d1)?(deconv_temp3[0]+{{4{m11_z[15]}},m11_z}):deconv_temp2[20]; deconv_temp2[35]<=(matrix_size_reg=='d2)?(deconv_temp3[0]+{{4{m11_z[15]}},m11_z}):'d0;
            deconv_temp3[11]<=(matrix_size_reg=='d0)?(deconv_temp4[0]+{{4{m16_z[15]}},m16_z}):deconv_temp3[12]; deconv_temp3[19]<=(matrix_size_reg=='d1)?(deconv_temp4[0]+{{4{m16_z[15]}},m16_z}):deconv_temp3[20]; deconv_temp3[35]<=(matrix_size_reg=='d2)?(deconv_temp4[0]+{{4{m16_z[15]}},m16_z}):'d0;
            deconv_temp4[11]<=(matrix_size_reg=='d0)?(deconv_temp5[0]+{{4{m21_z[15]}},m21_z}):deconv_temp4[12]; deconv_temp4[19]<=(matrix_size_reg=='d1)?(deconv_temp5[0]+{{4{m21_z[15]}},m21_z}):deconv_temp4[20]; deconv_temp4[35]<=(matrix_size_reg=='d2)?(deconv_temp5[0]+{{4{m21_z[15]}},m21_z}):'d0;
            //4~10
            for(a=4;a<11;a=a+1) begin
                deconv_temp1[a]<=deconv_temp1[a+1];
                deconv_temp2[a]<=deconv_temp2[a+1];
                deconv_temp3[a]<=deconv_temp3[a+1];
                deconv_temp4[a]<=deconv_temp4[a+1];
            end
            //12~18
            for(b=12;b<19;b=b+1) begin
                deconv_temp1[b]<=deconv_temp1[b+1];
                deconv_temp2[b]<=deconv_temp2[b+1];
                deconv_temp3[b]<=deconv_temp3[b+1];
                deconv_temp4[b]<=deconv_temp4[b+1];
            end
            //20~34
            for(c=20;c<35;c=c+1) begin
                deconv_temp1[c]<=deconv_temp1[c+1];
                deconv_temp2[c]<=deconv_temp2[c+1];
                deconv_temp3[c]<=deconv_temp3[c+1];
                deconv_temp4[c]<=deconv_temp4[c+1];
            end
        end
        else begin
            for(m=0;m<36;m=m+1) begin
                deconv_temp1[m] <= 20'b0;
                deconv_temp2[m] <= 20'b0;
                deconv_temp3[m] <= 20'b0;
                deconv_temp4[m] <= 20'b0;
            end
            for(n=0;n<4;n=n+1) deconv_temp5[n] <= 20'b0;
        end
    end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_line <= 5'b0;
    else begin
        if(curr_state==DECONV && cnt_state>'d7) begin
            if(matrix_size_reg=='d0) begin
                if(cnt_line=='d11)  cnt_line <= 'd0;
                else                cnt_line <= cnt_line + 'd1;
            end
            else if(matrix_size_reg=='d1) begin
                if(cnt_line=='d19)  cnt_line <= 'd0;
                else                cnt_line <= cnt_line + 'd1;
            end
            else begin
                if(cnt_line=='d35)  cnt_line <= 'd0;
                else                cnt_line <= cnt_line + 'd1;
            end
        end
        else    cnt_line <= 5'b0;
    end
end
//stop_mac
always@(*) begin
    if(matrix_size_reg=='d0 && cnt_line>'d6 && cnt_line<'d11)        stop_mac = 1'b1;
    else if(matrix_size_reg=='d1 && cnt_line>'d14 && cnt_line<'d19)  stop_mac = 1'b1;
    else if(matrix_size_reg=='d2 && cnt_line>'d30 && cnt_line<'d35)  stop_mac = 1'b1;
    else                                                             stop_mac = 1'b0;
end
//which row in mac
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_line_row <= 'd0;
    else begin
        if(curr_state==DECONV) begin
            if(matrix_size_reg=='d0 && cnt_line=='d10)  cnt_line_row <= cnt_line_row + 'd1;
            else if(matrix_size_reg=='d1 && cnt_line=='d18) cnt_line_row <= cnt_line_row + 'd1;
            else if(matrix_size_reg=='d2 && cnt_line=='d34) cnt_line_row <= cnt_line_row + 'd1;
            else cnt_line_row <= cnt_line_row;
        end
        else cnt_line_row <= 'd0;
    end
end



always@(*) begin
    if(matrix_size_reg=='d0)    img_size = 'd7;
    else if(matrix_size_reg=='d1) img_size = 'd15;
    else                        img_size = 'd31;
end

//stop_flag
always@(*) begin
    if(cnt_line_row > img_size) stop_flag = 1'b1;
    else                        stop_flag = 1'b0;
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_out_finish <= 1'b0;
    else begin
        if(out_valid) begin
            if(matrix_size_reg=='d0 && temp_addr_read_comb=='d144)         deconv_out_finish <= 1'b1; //TODO
            else if(matrix_size_reg=='d1 && temp_addr_read_comb=='d400)    deconv_out_finish <= 1'b1;
            else if(matrix_size_reg=='d2 && temp_addr_read_comb=='d1296)   deconv_out_finish <= 1'b1;
            else                                                    deconv_out_finish <= 1'b0;
        end
        else    deconv_out_finish <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  start_read <= 1'b0;
    else begin
        start_read <= start_read_comb;
    end
end
always@(*) begin
    if(curr_state!=DECONV)    start_read_comb = 1'b0;
    else if(temp_addr=='d0 && cnt_state>'d7)    start_read_comb = 1'b1;
    else                                        start_read_comb = start_read;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  start_read_d1 <= 1'b0;
    else        start_read_d1 <= start_read;
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) cnt20 <= 'd0;
    else begin
        cnt20 <= cnt20_comb;
        //if(cnt20=='d19 || cnt_state<'d9)  cnt20 <= 'd0; // ~start_read
        //else                               cnt20 <= cnt20 + 'd1;
    end
end
always@(*) begin
    if(cnt20=='d19 || cnt_state<'d9)    cnt20_comb = 'd0;
    else                                cnt20_comb = cnt20 + 'd1;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  deconv_out_buf <= 'd0;
    else begin
        if(cnt20=='d1)  deconv_out_buf <= DO_SRAM_temp[19:1];
        else            deconv_out_buf <= {1'b0,deconv_out_buf[18:1]};
    end
end

assign DI_SRAM_temp = result;

/*
SUMA180_1296X20X1BM1 SRAM_Temp(.A0(temp_addr[0]), .A1(temp_addr[1]), .A2(temp_addr[2]), .A3(temp_addr[3]), .A4(temp_addr[4]), .A5(temp_addr[5]), .A6(temp_addr[6]), .A7(temp_addr[7]), .A8(temp_addr[8]), .A9(temp_addr[9]), .A10(temp_addr[10]), 
                               .DO0(DO_SRAM_temp[0]), .DO1(DO_SRAM_temp[1]), .DO2(DO_SRAM_temp[2]), .DO3(DO_SRAM_temp[3]),
                               .DO4(DO_SRAM_temp[4]), .DO5(DO_SRAM_temp[5]), .DO6(DO_SRAM_temp[6]), .DO7(DO_SRAM_temp[7]), 
                               .DO8(DO_SRAM_temp[8]), .DO9(DO_SRAM_temp[9]), .DO10(DO_SRAM_temp[10]), .DO11(DO_SRAM_temp[11]), 
                               .DO12(DO_SRAM_temp[12]), .DO13(DO_SRAM_temp[13]), .DO14(DO_SRAM_temp[14]), .DO15(DO_SRAM_temp[15]), 
                               .DO16(DO_SRAM_temp[16]), .DO17(DO_SRAM_temp[17]), .DO18(DO_SRAM_temp[18]), .DO19(DO_SRAM_temp[19]), 
                               .DI0(DI_SRAM_temp[0]), .DI1(DI_SRAM_temp[1]), .DI2(DI_SRAM_temp[2]), .DI3(DI_SRAM_temp[3]), .DI4(DI_SRAM_temp[4]), 
                               .DI5(DI_SRAM_temp[5]), .DI6(DI_SRAM_temp[6]), .DI7(DI_SRAM_temp[7]), .DI8(DI_SRAM_temp[8]), .DI9(DI_SRAM_temp[9]), 
                               .DI10(DI_SRAM_temp[10]), .DI11(DI_SRAM_temp[11]), .DI12(DI_SRAM_temp[12]), .DI13(DI_SRAM_temp[13]), 
                               .DI14(DI_SRAM_temp[14]), .DI15(DI_SRAM_temp[15]), .DI16(DI_SRAM_temp[16]), .DI17(DI_SRAM_temp[17]), 
                               .DI18(DI_SRAM_temp[18]), .DI19(DI_SRAM_temp[19]),
                               .CK(clk), .WEB(web_sram_temp), .OE(1'b1), .CS(1'b1));
*/
//A for write and B for read
SJMA180_1296X20X1BM1 SRAM_Temp(.A0(temp_addr[0]), .A1(temp_addr[1]), .A2(temp_addr[2]), .A3(temp_addr[3]), .A4(temp_addr[4]), .A5(temp_addr[5]), 
                            .A6(temp_addr[6]), .A7(temp_addr[7]), .A8(temp_addr[8]), .A9(temp_addr[9]), .A10(temp_addr[10]),
                            .B0(temp_addr_read[0]), .B1(temp_addr_read[1]), .B2(temp_addr_read[2]), .B3(temp_addr_read[3]), .B4(temp_addr_read[4]), .B5(temp_addr_read[5]),  //TODO
                            .B6(temp_addr_read[6]), .B7(temp_addr_read[7]), .B8(temp_addr_read[8]), .B9(temp_addr_read[9]), .B10(temp_addr_read[10]), //TODO
                            .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), 
                            .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), .DOA11(), 
                            .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), 
                            .DOA17(), .DOA18(), .DOA19(),
                            .DOB0(DO_SRAM_temp[0]), .DOB1(DO_SRAM_temp[1]), .DOB2(DO_SRAM_temp[2]), .DOB3(DO_SRAM_temp[3]), .DOB4(DO_SRAM_temp[4]), //read data
                            .DOB5(DO_SRAM_temp[5]), .DOB6(DO_SRAM_temp[6]), .DOB7(DO_SRAM_temp[7]), .DOB8(DO_SRAM_temp[8]), .DOB9(DO_SRAM_temp[9]), 
                            .DOB10(DO_SRAM_temp[10]), .DOB11(DO_SRAM_temp[11]), .DOB12(DO_SRAM_temp[12]), .DOB13(DO_SRAM_temp[13]), .DOB14(DO_SRAM_temp[14]),
                            .DOB15(DO_SRAM_temp[15]), .DOB16(DO_SRAM_temp[16]), .DOB17(DO_SRAM_temp[17]), .DOB18(DO_SRAM_temp[18]), .DOB19(DO_SRAM_temp[19]), 
                            .DIA0(DI_SRAM_temp[0]), .DIA1(DI_SRAM_temp[1]), .DIA2(DI_SRAM_temp[2]), .DIA3(DI_SRAM_temp[3]), .DIA4(DI_SRAM_temp[4]), //write data
                            .DIA5(DI_SRAM_temp[5]), .DIA6(DI_SRAM_temp[6]), .DIA7(DI_SRAM_temp[7]), .DIA8(DI_SRAM_temp[8]), .DIA9(DI_SRAM_temp[9]),
                            .DIA10(DI_SRAM_temp[10]), .DIA11(DI_SRAM_temp[11]), .DIA12(DI_SRAM_temp[12]), .DIA13(DI_SRAM_temp[13]), .DIA14(DI_SRAM_temp[14]), 
                            .DIA15(DI_SRAM_temp[15]), .DIA16(DI_SRAM_temp[16]), .DIA17(DI_SRAM_temp[17]), .DIA18(DI_SRAM_temp[18]), .DIA19(DI_SRAM_temp[19]), 
                            .DIB0(), .DIB1(), .DIB2(), .DIB3(), .DIB4(), 
                            .DIB5(), .DIB6(), .DIB7(), .DIB8(), .DIB9(), 
                            .DIB10(), .DIB11(), .DIB12(), .DIB13(), .DIB14(), 
                            .DIB15(), .DIB16(), .DIB17(), .DIB18(), .DIB19(), 
                            .WEAN(web_sram_temp), .WEBN(1'b1), .CKA(clk), .CKB(clk), .CSA(1'b1), .CSB(1'b1), .OEA(1'b1), .OEB(1'b1));


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  temp_addr <= 'd0;
    else begin
        temp_addr <= temp_addr_comb;
        //if(curr_state==DECONV && cnt_state>'d6) begin
        //    //temp_addr <= temp_addr_p1;
        //    if(matrix_size_reg=='d0 && temp_addr=='d143) temp_addr <= 'd0;
        //    else if(matrix_size_reg=='d1 && temp_addr=='d399) temp_addr <= 'd0;
        //    else if(matrix_size_reg=='d2 && temp_addr=='d1295) temp_addr <= 'd0;
        //    else temp_addr <= temp_addr + 'd1;
        //end
        //else    temp_addr <= 'd0;
    end
end
always@(*) begin
    if(curr_state==DECONV && cnt_state>'d6) begin
        if(matrix_size_reg=='d0 && temp_addr=='d143) temp_addr_comb = 'd0;
        else if(matrix_size_reg=='d1 && temp_addr=='d399) temp_addr_comb = 'd0;
        else if(matrix_size_reg=='d2 && temp_addr=='d1295) temp_addr_comb = 'd0;
        else temp_addr_comb = temp_addr + 'd1;
    end
    else    temp_addr_comb = 'd0;
end
//always@(*)begin
//    if(!start_read)begin
//        if(matrix_size_reg=='d0 && temp_addr=='d143) temp_addr_p1 = 'd0;
//        else if(matrix_size_reg=='d1 && temp_addr=='d399) temp_addr_p1 = 'd0;
//        else if(matrix_size_reg=='d2 && temp_addr=='d1295) temp_addr_p1 = 'd0;
//        else if(start_read_comb) temp_addr_p1 = 'd0;
//        else temp_addr_p1 = temp_addr + 'b1;
//    end
//    else begin
//        if(cnt20=='d19) temp_addr_p1 = temp_addr + 'd1;
//        else            temp_addr_p1 = temp_addr;
//    end
//end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  web_sram_temp <= 'b1;
    else begin
        if (curr_state==DECONV && cnt_state<'d7) web_sram_temp <='b0;
        else begin
            if(temp_addr_comb=='b0) web_sram_temp <= 'b1;
            else                    web_sram_temp <= web_sram_temp;
        end
    end
end

//temp_addr_read
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  temp_addr_read <= 'd0;
    else begin
        temp_addr_read <= temp_addr_read_comb;
        //if(curr_state!=DECONV)  temp_addr_read <= 'd1; //avoid conflict with write
        //else if(cnt_state=='d7) temp_addr_read <= 'd0;
        //else if(cnt20=='d19)    temp_addr_read <= temp_addr_read + 'd1;
        //else                    temp_addr_read <= temp_addr_read;
    end
end
always@(*) begin
    if(curr_state!=DECONV)  temp_addr_read_comb = 'd1; //avoid conflict with write
    else if(cnt_state=='d7) temp_addr_read_comb = 'd0;
    else if(cnt20=='d19)    temp_addr_read_comb = temp_addr_read + 'd1;
    else                    temp_addr_read_comb = temp_addr_read;
end


//=======================CONV - 8*8 FINISHED=================================//

//cnt_img_1
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_img_1 <= 2'b0;
    else        cnt_img_1 <= cnt_img_1_comb;
end
always@(*) begin
    if(curr_state==CONV) begin
        if(cnt_kernel=='d4 && cnt_img_1=='d3)   cnt_img_1_comb = 'd0;
        else if(cnt_kernel=='d4)                cnt_img_1_comb = cnt_img_1 + 'd1;
        else                                    cnt_img_1_comb = cnt_img_1;
    end
    else                                        cnt_img_1_comb = 2'b0;
end
//cnt_square
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_square <= 8'b0;
    else        cnt_square <= cnt_square_comb;
end
always@(*) begin
    if(curr_state==CONV) begin
        if(cnt_kernel=='d4 && cnt_img_1=='d3)   cnt_square_comb = cnt_square + 'd1;
        else                                    cnt_square_comb = cnt_square;
    end
    else                                        cnt_square_comb = 8'b0;
end
//img_addr_offset
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  img_addr_offset <= 5'b0;
    else        img_addr_offset <= img_addr_offset_comb;
end
always@(*) begin
    if(curr_state==CONV) begin
        if(matrix_size_reg=='d0) begin
            if(cnt_kernel=='d4 && cnt_img_1=='d3 && cnt_square=='d1)    img_addr_offset_comb = img_addr_offset + 'd1;
            else if(cnt_kernel=='d4 && cnt_img_1=='d3)                  img_addr_offset_comb = img_addr_offset - 'd1;
            else if(cnt_kernel=='d4 && cnt_img_1=='d1)                  img_addr_offset_comb = img_addr_offset + 'd1;
            else                                                        img_addr_offset_comb = img_addr_offset;
        end
        else if(matrix_size_reg=='d1) begin
            if(cnt_kernel=='d4 && cnt_img_1=='d3 && check_16)           img_addr_offset_comb = img_addr_offset + 'd1;
            else if(cnt_kernel=='d4 && cnt_img_1=='d3)                  img_addr_offset_comb = img_addr_offset - 'd1;
            else if(cnt_kernel=='d4 && cnt_img_1=='d1)                  img_addr_offset_comb = img_addr_offset + 'd1;
            else                                                        img_addr_offset_comb = img_addr_offset;
        end
        else begin
            if(cnt_kernel=='d4 && cnt_img_1=='d3 && check_32)           img_addr_offset_comb = img_addr_offset + 'd1;
            else if(cnt_kernel=='d4 && cnt_img_1=='d3)                  img_addr_offset_comb = img_addr_offset - 'd1;
            else if(cnt_kernel=='d4 && cnt_img_1=='d1)                  img_addr_offset_comb = img_addr_offset + 'd1;
            else                                                        img_addr_offset_comb = img_addr_offset;
        end
    end
    else if(curr_state==DECONV) begin
        if(matrix_size_reg=='d0) begin
            if(cnt_line=='d7)  img_addr_offset_comb = img_addr_offset + 'd1;
            else                        img_addr_offset_comb = img_addr_offset;
        end
        else if(matrix_size_reg=='d1) begin
            if(cnt_line=='d15) img_addr_offset_comb = img_addr_offset + 'd1;
            else                        img_addr_offset_comb = img_addr_offset;
        end
        else begin
            if(cnt_line=='d31) img_addr_offset_comb = img_addr_offset + 'd1;
            else                        img_addr_offset_comb = img_addr_offset;
        end
    end
    else begin
        img_addr_offset_comb = 5'b0;
    end
end

assign check_16 = (cnt_square=='d5) || (cnt_square=='d11) || (cnt_square=='d17) || (cnt_square=='d23) || (cnt_square=='d29);
assign check_32 = (cnt_square=='d13) || (cnt_square=='d27) || (cnt_square=='d41) || (cnt_square=='d55) || (cnt_square=='d69) ||
                    (cnt_square=='d83) || (cnt_square=='d97) || (cnt_square=='d111) || (cnt_square=='d125) || (cnt_square=='d139) ||
                    (cnt_square=='d153) || (cnt_square=='d167) || (cnt_square=='d181);

//col_offset 5bits
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  col_offset <= 1'b0;
    else        col_offset <= col_offset_comb;
end
always@(*) begin
    if(curr_state==CONV) begin
        if(cnt_kernel=='d4) col_offset_comb = ~col_offset;
        else                col_offset_comb = col_offset;
    end
    else begin
        col_offset_comb = 1'b0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  col_offset_d1 <= 1'b0;
    else        col_offset_d1 <= col_offset;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  col_offset_d2 <= 1'b0;
    else        col_offset_d2 <= col_offset_d1;
end
//col_ptr_8
always@(*) begin
    if(curr_state==CONV) begin
        if(matrix_size_reg=='d0) begin
            col_ptr_8 = (cnt_square[0])? 'd2 : 'd0;
        end
        else if(matrix_size_reg=='d1) begin
            col_ptr_8 = (cnt_square % 'd6) << 'd1;
        end
        else begin
            col_ptr_8 = (cnt_square % 'd14) << 'd1;
        end
    end
    else begin
        col_ptr_8 = 'd0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  col_ptr_8_d1 <= 2'b0;
    else        col_ptr_8_d1 <= col_ptr_8;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  col_ptr_8_d2 <= 2'b0;
    else        col_ptr_8_d2 <= col_ptr_8_d1;
end
//go to multiplier
always@(*) begin
    sum_comb = m1_z + m2_z + m3_z + m4_z + m5_z + pre_sum;
end
//sum
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  sum <= 20'b0;
    else        sum <= sum_comb;
end
//pre_sum
always@(*) begin
    if(curr_state==CONV) begin
        if(cnt_kernel_d3=='d0)  pre_sum = 'd0;
        else                    pre_sum = sum;
    end
    else                        pre_sum = 'd0;
end
//largest
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  largest <= 20'b0;
    else        largest <= largest_comb;
end
always@(*) begin
    if(cnt_kernel_d4=='d4) begin
        if(cnt_img_1=='d1)  largest_comb = sum;
        else                largest_comb = (sum>largest)? sum : largest;
    end
    else                    largest_comb = largest;
end
//conv_result_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  conv_result_reg <= 20'b0;
    else        conv_result_reg <= conv_result_comb;
end
always@(*) begin
    if(curr_state==CONV && cnt_state > 'd20) begin
        if(cnt_kernel_d4=='d4 && cnt_img_1=='d0)    conv_result_comb = largest_comb; //only store when max-pooling finished
        else                                        conv_result_comb = conv_result_reg;
    end
    else begin
        conv_result_comb = conv_result_reg;
    end
end
//cnt_conv_out
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_conv_out <= 5'b0;
    else begin
        if(cnt_conv_out=='d19)  cnt_conv_out <= 5'b0;
        else if(out_valid_comb) cnt_conv_out <= cnt_conv_out + 'd1;
        else                    cnt_conv_out <= 5'b0;
    end
end


//==========================CONV - 8*8 FINISHED===================================//


//=================================
//		Output
//=================================

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 1'b0;
    else        out_valid <= out_valid_comb;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_value <= 1'b0;
    else        out_value <= out_value_comb;
end

always@(*) begin
    if(curr_state==CONV) begin
        if(cnt_state>'d22) begin
            out_valid_comb = 1'b1;
            out_value_comb = conv_result_reg[cnt_conv_out];
        end
        else begin
            out_valid_comb = 1'b0;
            out_value_comb = 1'b0;
        end
    end
    else if(curr_state==DECONV) begin
        if(cnt_state >= 'd10) begin
            out_valid_comb = 1'b1;
            out_value_comb = (cnt20=='d1)?(DO_SRAM_temp[0]):(deconv_out_buf[0]);
        end
        else begin
            out_valid_comb = 1'b0;
            out_value_comb = 1'b0;
        end
    end
    else begin
        out_valid_comb = 1'b0;
        out_value_comb = 1'b0;
    end
end



endmodule