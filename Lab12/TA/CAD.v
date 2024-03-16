module CAD (
    input  wire clk,
    input  wire rst_n,
    input  wire in_valid,
    input  wire in_valid2,
    input  wire [1:0] matrix_size,
    input  wire [7:0] matrix,
    input  wire [3:0] matrix_idx,
    input  wire mode,

    output reg  out_valid,
    output reg  out_value
);

//          _                   __       __          __              
//    _____(_)___ _____  ____ _/ /  ____/ /__  _____/ /___ _________ 
//   / ___/ / __ `/ __ \/ __ `/ /  / __  / _ \/ ___/ / __ `/ ___/ _ \
//  (__  ) / /_/ / / / / /_/ / /  / /_/ /  __/ /__/ / /_/ / /  /  __/
// /____/_/\__, /_/ /_/\__,_/_/   \__,_/\___/\___/_/\__,_/_/   \___/ 
//        /____/                                                     

reg  [ 1:0] matrix_size_reg;
reg  [13:0] input_cnt;
wire [13:0] input_cnt_next;
reg  [31:0] input_temp_reg;
wire [39:0] input_temp_reg_next;

wire input_cnt_adder_cout;
reg  kernel_start_flag;

reg  [4:0]  input_kernel_cnt_sh;

reg  [3:0] image_idx;
reg  [3:0] kernel_idx;
reg        mode_reg;

reg        in_valid2_cnt;

reg  [13:0] reset_value_of_SRAM0_addr_after_cv;
reg  [13:0] reset_value_of_SRAM1_addr_after_cv;
reg  [13:0] reset_value_of_SRAM_addr_after_mp_a_row;
reg  [ 6:0] reset_value_of_SRAMK_addr_after_cv;

reg  [19:0] conv_sum;
reg  [19:0] mp_value;

reg  [19:0] out_value20;


//    _____ ____  ___    __  ___   ____ 
//   / ___// __ \/   |  /  |/  /  / __ \
//   \__ \/ /_/ / /| | / /|_/ /  / / / /
//  ___/ / _, _/ ___ |/ /  / /  / /_/ / 
// /____/_/ |_/_/  |_/_/  /_/   \____/  
//                                     

reg  signed [11:0] SRAM0_addr;
wire        [31:0] SRAM0_data_o;
reg         [31:0] SRAM0_data_o_reg;
wire        [31:0] SRAM0_data_i;
reg                SRAM0_WEB;
reg                SRAM0_OE;

SRAM_32x2048 SRAM0 (
    // address
    .A0  (SRAM0_addr[ 0]),
    .A1  (SRAM0_addr[ 1]),
    .A2  (SRAM0_addr[ 2]),
    .A3  (SRAM0_addr[ 3]),
    .A4  (SRAM0_addr[ 4]),
    .A5  (SRAM0_addr[ 5]),
    .A6  (SRAM0_addr[ 6]),
    .A7  (SRAM0_addr[ 7]),
    .A8  (SRAM0_addr[ 8]),
    .A9  (SRAM0_addr[ 9]),
    .A10 (SRAM0_addr[10]),
    // data out
    .DO0 (SRAM0_data_o[ 0]),
    .DO1 (SRAM0_data_o[ 1]),
    .DO2 (SRAM0_data_o[ 2]),
    .DO3 (SRAM0_data_o[ 3]),
    .DO4 (SRAM0_data_o[ 4]),
    .DO5 (SRAM0_data_o[ 5]),
    .DO6 (SRAM0_data_o[ 6]),
    .DO7 (SRAM0_data_o[ 7]),
    .DO8 (SRAM0_data_o[ 8]),
    .DO9 (SRAM0_data_o[ 9]),
    .DO10(SRAM0_data_o[10]),
    .DO11(SRAM0_data_o[11]),
    .DO12(SRAM0_data_o[12]),
    .DO13(SRAM0_data_o[13]),
    .DO14(SRAM0_data_o[14]),
    .DO15(SRAM0_data_o[15]),
    .DO16(SRAM0_data_o[16]),
    .DO17(SRAM0_data_o[17]),
    .DO18(SRAM0_data_o[18]),
    .DO19(SRAM0_data_o[19]),
    .DO20(SRAM0_data_o[20]),
    .DO21(SRAM0_data_o[21]),
    .DO22(SRAM0_data_o[22]),
    .DO23(SRAM0_data_o[23]),
    .DO24(SRAM0_data_o[24]),
    .DO25(SRAM0_data_o[25]),
    .DO26(SRAM0_data_o[26]),
    .DO27(SRAM0_data_o[27]),
    .DO28(SRAM0_data_o[28]),
    .DO29(SRAM0_data_o[29]),
    .DO30(SRAM0_data_o[30]),
    .DO31(SRAM0_data_o[31]),
    // data in
    .DI0 (SRAM0_data_i[ 0]),
    .DI1 (SRAM0_data_i[ 1]),
    .DI2 (SRAM0_data_i[ 2]),
    .DI3 (SRAM0_data_i[ 3]),
    .DI4 (SRAM0_data_i[ 4]),
    .DI5 (SRAM0_data_i[ 5]),
    .DI6 (SRAM0_data_i[ 6]),
    .DI7 (SRAM0_data_i[ 7]),
    .DI8 (SRAM0_data_i[ 8]),
    .DI9 (SRAM0_data_i[ 9]),
    .DI10(SRAM0_data_i[10]),
    .DI11(SRAM0_data_i[11]),
    .DI12(SRAM0_data_i[12]),
    .DI13(SRAM0_data_i[13]),
    .DI14(SRAM0_data_i[14]),
    .DI15(SRAM0_data_i[15]),
    .DI16(SRAM0_data_i[16]),
    .DI17(SRAM0_data_i[17]),
    .DI18(SRAM0_data_i[18]),
    .DI19(SRAM0_data_i[19]),
    .DI20(SRAM0_data_i[20]),
    .DI21(SRAM0_data_i[21]),
    .DI22(SRAM0_data_i[22]),
    .DI23(SRAM0_data_i[23]),
    .DI24(SRAM0_data_i[24]),
    .DI25(SRAM0_data_i[25]),
    .DI26(SRAM0_data_i[26]),
    .DI27(SRAM0_data_i[27]),
    .DI28(SRAM0_data_i[28]),
    .DI29(SRAM0_data_i[29]),
    .DI30(SRAM0_data_i[30]),
    .DI31(SRAM0_data_i[31]),
    // control
    .CK  (clk),
    .WEB (~SRAM0_WEB),
    .OE  (1'b1),
    .CS  (1'b1)
);

//    _____ ____  ___    __  ___   ___
//   / ___// __ \/   |  /  |/  /  <  /
//   \__ \/ /_/ / /| | / /|_/ /   / / 
//  ___/ / _, _/ ___ |/ /  / /   / /  
// /____/_/ |_/_/  |_/_/  /_/   /_/   
//                                   

reg  signed [11:0] SRAM1_addr;
wire        [31:0] SRAM1_data_o;
reg         [31:0] SRAM1_data_o_reg;
wire        [31:0] SRAM1_data_i;
reg                SRAM1_WEB;
reg                SRAM1_OE;

SRAM_32x2048 SRAM1 (
    // address
    .A0  (SRAM1_addr[ 0]),
    .A1  (SRAM1_addr[ 1]),
    .A2  (SRAM1_addr[ 2]),
    .A3  (SRAM1_addr[ 3]),
    .A4  (SRAM1_addr[ 4]),
    .A5  (SRAM1_addr[ 5]),
    .A6  (SRAM1_addr[ 6]),
    .A7  (SRAM1_addr[ 7]),
    .A8  (SRAM1_addr[ 8]),
    .A9  (SRAM1_addr[ 9]),
    .A10 (SRAM1_addr[10]),
    // data out
    .DO0 (SRAM1_data_o[ 0]),
    .DO1 (SRAM1_data_o[ 1]),
    .DO2 (SRAM1_data_o[ 2]),
    .DO3 (SRAM1_data_o[ 3]),
    .DO4 (SRAM1_data_o[ 4]),
    .DO5 (SRAM1_data_o[ 5]),
    .DO6 (SRAM1_data_o[ 6]),
    .DO7 (SRAM1_data_o[ 7]),
    .DO8 (SRAM1_data_o[ 8]),
    .DO9 (SRAM1_data_o[ 9]),
    .DO10(SRAM1_data_o[10]),
    .DO11(SRAM1_data_o[11]),
    .DO12(SRAM1_data_o[12]),
    .DO13(SRAM1_data_o[13]),
    .DO14(SRAM1_data_o[14]),
    .DO15(SRAM1_data_o[15]),
    .DO16(SRAM1_data_o[16]),
    .DO17(SRAM1_data_o[17]),
    .DO18(SRAM1_data_o[18]),
    .DO19(SRAM1_data_o[19]),
    .DO20(SRAM1_data_o[20]),
    .DO21(SRAM1_data_o[21]),
    .DO22(SRAM1_data_o[22]),
    .DO23(SRAM1_data_o[23]),
    .DO24(SRAM1_data_o[24]),
    .DO25(SRAM1_data_o[25]),
    .DO26(SRAM1_data_o[26]),
    .DO27(SRAM1_data_o[27]),
    .DO28(SRAM1_data_o[28]),
    .DO29(SRAM1_data_o[29]),
    .DO30(SRAM1_data_o[30]),
    .DO31(SRAM1_data_o[31]),
    // data in
    .DI0 (SRAM1_data_i[ 0]),
    .DI1 (SRAM1_data_i[ 1]),
    .DI2 (SRAM1_data_i[ 2]),
    .DI3 (SRAM1_data_i[ 3]),
    .DI4 (SRAM1_data_i[ 4]),
    .DI5 (SRAM1_data_i[ 5]),
    .DI6 (SRAM1_data_i[ 6]),
    .DI7 (SRAM1_data_i[ 7]),
    .DI8 (SRAM1_data_i[ 8]),
    .DI9 (SRAM1_data_i[ 9]),
    .DI10(SRAM1_data_i[10]),
    .DI11(SRAM1_data_i[11]),
    .DI12(SRAM1_data_i[12]),
    .DI13(SRAM1_data_i[13]),
    .DI14(SRAM1_data_i[14]),
    .DI15(SRAM1_data_i[15]),
    .DI16(SRAM1_data_i[16]),
    .DI17(SRAM1_data_i[17]),
    .DI18(SRAM1_data_i[18]),
    .DI19(SRAM1_data_i[19]),
    .DI20(SRAM1_data_i[20]),
    .DI21(SRAM1_data_i[21]),
    .DI22(SRAM1_data_i[22]),
    .DI23(SRAM1_data_i[23]),
    .DI24(SRAM1_data_i[24]),
    .DI25(SRAM1_data_i[25]),
    .DI26(SRAM1_data_i[26]),
    .DI27(SRAM1_data_i[27]),
    .DI28(SRAM1_data_i[28]),
    .DI29(SRAM1_data_i[29]),
    .DI30(SRAM1_data_i[30]),
    .DI31(SRAM1_data_i[31]),
    // control
    .CK  (clk),
    .WEB (~SRAM1_WEB),
    .OE  (1'b1),
    .CS  (1'b1)
);

//    _____ ____  ___    __  ___   __ __
//   / ___// __ \/   |  /  |/  /  / //_/
//   \__ \/ /_/ / /| | / /|_/ /  / ,<   
//  ___/ / _, _/ ___ |/ /  / /  / /| |  
// /____/_/ |_/_/  |_/_/  /_/  /_/ |_|  

reg  [ 6:0] SRAMK_addr;
wire [39:0] SRAMK_data_o;
reg  [39:0] SRAMK_data_o_reg;
wire [39:0] SRAMK_data_i;
reg         SRAMK_WEB;
reg         SRAMK_OE;

SRAM_40x80 SRAMK (
    // address
    .A0  (SRAMK_addr[ 0]),
    .A1  (SRAMK_addr[ 1]),
    .A2  (SRAMK_addr[ 2]),
    .A3  (SRAMK_addr[ 3]),
    .A4  (SRAMK_addr[ 4]),
    .A5  (SRAMK_addr[ 5]),
    .A6  (SRAMK_addr[ 6]),
    // data out
    .DO0 (SRAMK_data_o[ 0]),
    .DO1 (SRAMK_data_o[ 1]),
    .DO2 (SRAMK_data_o[ 2]),
    .DO3 (SRAMK_data_o[ 3]),
    .DO4 (SRAMK_data_o[ 4]),
    .DO5 (SRAMK_data_o[ 5]),
    .DO6 (SRAMK_data_o[ 6]),
    .DO7 (SRAMK_data_o[ 7]),
    .DO8 (SRAMK_data_o[ 8]),
    .DO9 (SRAMK_data_o[ 9]),
    .DO10(SRAMK_data_o[10]),
    .DO11(SRAMK_data_o[11]),
    .DO12(SRAMK_data_o[12]),
    .DO13(SRAMK_data_o[13]),
    .DO14(SRAMK_data_o[14]),
    .DO15(SRAMK_data_o[15]),
    .DO16(SRAMK_data_o[16]),
    .DO17(SRAMK_data_o[17]),
    .DO18(SRAMK_data_o[18]),
    .DO19(SRAMK_data_o[19]),
    .DO20(SRAMK_data_o[20]),
    .DO21(SRAMK_data_o[21]),
    .DO22(SRAMK_data_o[22]),
    .DO23(SRAMK_data_o[23]),
    .DO24(SRAMK_data_o[24]),
    .DO25(SRAMK_data_o[25]),
    .DO26(SRAMK_data_o[26]),
    .DO27(SRAMK_data_o[27]),
    .DO28(SRAMK_data_o[28]),
    .DO29(SRAMK_data_o[29]),
    .DO30(SRAMK_data_o[30]),
    .DO31(SRAMK_data_o[31]),
    .DO32(SRAMK_data_o[32]),
    .DO33(SRAMK_data_o[33]),
    .DO34(SRAMK_data_o[34]),
    .DO35(SRAMK_data_o[35]),
    .DO36(SRAMK_data_o[36]),
    .DO37(SRAMK_data_o[37]),
    .DO38(SRAMK_data_o[38]),
    .DO39(SRAMK_data_o[39]),
    // data in
    .DI0 (SRAMK_data_i[ 0]),
    .DI1 (SRAMK_data_i[ 1]),
    .DI2 (SRAMK_data_i[ 2]),
    .DI3 (SRAMK_data_i[ 3]),
    .DI4 (SRAMK_data_i[ 4]),
    .DI5 (SRAMK_data_i[ 5]),
    .DI6 (SRAMK_data_i[ 6]),
    .DI7 (SRAMK_data_i[ 7]),
    .DI8 (SRAMK_data_i[ 8]),
    .DI9 (SRAMK_data_i[ 9]),
    .DI10(SRAMK_data_i[10]),
    .DI11(SRAMK_data_i[11]),
    .DI12(SRAMK_data_i[12]),
    .DI13(SRAMK_data_i[13]),
    .DI14(SRAMK_data_i[14]),
    .DI15(SRAMK_data_i[15]),
    .DI16(SRAMK_data_i[16]),
    .DI17(SRAMK_data_i[17]),
    .DI18(SRAMK_data_i[18]),
    .DI19(SRAMK_data_i[19]),
    .DI20(SRAMK_data_i[20]),
    .DI21(SRAMK_data_i[21]),
    .DI22(SRAMK_data_i[22]),
    .DI23(SRAMK_data_i[23]),
    .DI24(SRAMK_data_i[24]),
    .DI25(SRAMK_data_i[25]),
    .DI26(SRAMK_data_i[26]),
    .DI27(SRAMK_data_i[27]),
    .DI28(SRAMK_data_i[28]),
    .DI29(SRAMK_data_i[29]),
    .DI30(SRAMK_data_i[30]),
    .DI31(SRAMK_data_i[31]),
    .DI32(SRAMK_data_i[32]),
    .DI33(SRAMK_data_i[33]),
    .DI34(SRAMK_data_i[34]),
    .DI35(SRAMK_data_i[35]),
    .DI36(SRAMK_data_i[36]),
    .DI37(SRAMK_data_i[37]),
    .DI38(SRAMK_data_i[38]),
    .DI39(SRAMK_data_i[39]),
    // control
    .CK  (clk),
    .WEB (~SRAMK_WEB),
    .OE  (1'b1),
    .CS  (1'b1)
);

//     __  ___      ____  _       ___               
//    /  |/  /_  __/ / /_(_)___  / (_)__  __________
//   / /|_/ / / / / / __/ / __ \/ / / _ \/ ___/ ___/
//  / /  / / /_/ / / /_/ / /_/ / / /  __/ /  (__  ) 
// /_/  /_/\__,_/_/\__/_/ .___/_/_/\___/_/  /____/  
//                     /_/                          

reg  [39:0] muln_a;
wire [ 7:0] mul0_b;
wire [ 7:0] mul1_b;
wire [ 7:0] mul2_b;
wire [ 7:0] mul3_b;
wire [ 7:0] mul4_b;
wire [15:0] mul0_o;
wire [15:0] mul1_o;
wire [15:0] mul2_o;
wire [15:0] mul3_o;
wire [15:0] mul4_o;

MULTIPLIER mul_inst0 (.clk(clk), .rst_n(rst_n), .a(muln_a[ 7: 0]), .b(mul0_b), .o(mul0_o));
MULTIPLIER mul_inst1 (.clk(clk), .rst_n(rst_n), .a(muln_a[15: 8]), .b(mul1_b), .o(mul1_o));
MULTIPLIER mul_inst2 (.clk(clk), .rst_n(rst_n), .a(muln_a[23:16]), .b(mul2_b), .o(mul2_o));
MULTIPLIER mul_inst3 (.clk(clk), .rst_n(rst_n), .a(muln_a[31:24]), .b(mul3_b), .o(mul3_o));
MULTIPLIER mul_inst4 (.clk(clk), .rst_n(rst_n), .a(muln_a[39:32]), .b(mul4_b), .o(mul4_o));

//    _____ __  ____  ________
//   / ___// / / /  |/  / ___/
//   \__ \/ / / / /|_/ / __ \ 
//  ___/ / /_/ / /  / / /_/ / 
// /____/\____/_/  /_/\____/  
                           
wire [19:0] sum60_a, sum60_b, sum60_c, sum60_d, sum60_e, sum60_f;
wire [19:0] sum60_o;

SUM6 sum6_inst0 (.clk(clk), .rst_n(rst_n), .a(sum60_a), .b(sum60_b), .c(sum60_c), .d(sum60_d), .e(sum60_e), .f(sum60_f), .o(sum60_o));

//     ___    ____  ____  _____ __  ______ 
//    /   |  / __ \/ __ \/ ___// / / / __ )
//   / /| | / / / / / / /\__ \/ / / / __  |
//  / ___ |/ /_/ / /_/ /___/ / /_/ / /_/ / 
// /_/  |_/_____/_____//____/\____/_____/  
                                        
wire [11:0] addsub0_a , addsub1_a;
reg  [11:0] addsub0_b , addsub1_b;
reg         addsub0_op, addsub1_op;
wire [11:0] addsub0_o , addsub1_o;

ADDR_ADDSUB addr_addsun_inst0 (.a(addsub0_a), .b(addsub0_b), .op(addsub0_op), .o(addsub0_o));
ADDR_ADDSUB addr_addsun_inst1 (.a(addsub1_a), .b(addsub1_b), .op(addsub1_op), .o(addsub1_o));
                                     

////////////////////////////////////////////////////////////////
//                                                            //
//                    input counter adder                     //
//                                                            //
////////////////////////////////////////////////////////////////

INPUT_CNT_ADDER input_cnt_adder_inst (
    .cnt(input_cnt),
    .matrix_size(matrix_size_reg),
    .flag(kernel_start_flag),
    .cnt_next(input_cnt_next),
    .cout(input_cnt_adder_cout)
);

////////////////////////////////////////////////////////////////
//                                                            //
//                      matrix size load                      //
//                                                            //
////////////////////////////////////////////////////////////////

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        matrix_size_reg <= 'b0;
    end
    else if (in_valid & (~(| input_cnt)) & ~kernel_start_flag) begin
        matrix_size_reg <= matrix_size;
    end
    else begin
        matrix_size_reg <= matrix_size_reg;
    end
end

////////////////////////////////////////////////////////////////
//                                                            //
//                 start kernel loading flag                  //
//                                                            //
////////////////////////////////////////////////////////////////

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        kernel_start_flag <= 'b0;
    end
    else if (in_valid2) begin
        kernel_start_flag <= 'b0;
    end
    else begin
        kernel_start_flag <= kernel_start_flag | input_cnt_adder_cout;
    end
end

////////////////////////////////////////////////////////////////
//                                                            //
//                  shift counter for kernel                  //
//                                                            //
////////////////////////////////////////////////////////////////

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        input_kernel_cnt_sh <= 'b1;
    end
    else if (input_cnt_adder_cout) begin
        input_kernel_cnt_sh <= 'b1;
    end
    else if (in_valid & kernel_start_flag) begin
        input_kernel_cnt_sh <= {input_kernel_cnt_sh[3:0], input_kernel_cnt_sh[4]};
    end
    else begin
        input_kernel_cnt_sh <= input_kernel_cnt_sh;
    end
end

////////////////////////////////////////////////////////////////
//                                                            //
//                    input counter update                    //
//                                                            //
////////////////////////////////////////////////////////////////

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        input_cnt <= 'b0;
    end
    else if (in_valid2) begin
        input_cnt <= 'b0;
    end
    else if (in_valid & ~kernel_start_flag) begin // for image, update every cycle
        input_cnt <= input_cnt_next;
    end
    else if (in_valid & input_kernel_cnt_sh[4]) begin // for kernel, update every 5 cycle
        input_cnt <= input_cnt_next;
    end
    else begin
        input_cnt <= input_cnt;
    end
end

////////////////////////////////////////////////////////////////
//                                                            //
//                  input matrix temp update                  //
//                                                            //
////////////////////////////////////////////////////////////////

assign input_temp_reg_next = {input_temp_reg, matrix};
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        input_temp_reg <= 'b0;
    end
    else if (in_valid) begin
        input_temp_reg <= input_temp_reg_next[31:0];
    end
    else begin
        input_temp_reg <= input_temp_reg;
    end
end

////////////////////////////////////////////////////////////////
//                                                            //
//                         in_valid2                          //
//                                                            //
////////////////////////////////////////////////////////////////

reg       cv_v [0:4];
reg [2:0] cv_r [0:4]; 
reg [1:0] cv_k [0:4]; 
reg [6:0] cv_j [0:4]; 
reg [6:0] cv_i [0:4]; 

reg cv_r_overflow [0:4]; 
reg cv_k_overflow [0:4]; 
reg cv_j_overflow [0:4]; 
reg cv_i_overflow [0:4]; 

wire cv_r_overflow_0; 
wire cv_k_overflow_0; 
wire cv_j_overflow_0; 
wire cv_i_overflow_0; 

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        in_valid2_cnt <= 'b0;
        mode_reg      <= 'b0;
        image_idx     <= 'b0;
        kernel_idx    <= 'b0;
        cv_v[0]       <= 'b0;
    end
    else if (in_valid2) begin
        in_valid2_cnt <= ~in_valid2_cnt;
        mode_reg      <= in_valid2_cnt ? mode_reg  : mode;
        image_idx     <= in_valid2_cnt ? image_idx : matrix_idx;
        kernel_idx    <= matrix_idx;
        cv_v[0]       <= in_valid2_cnt ? 'b1 : 'b0;
    end
    else begin
        in_valid2_cnt <= in_valid2_cnt;
        mode_reg      <= mode_reg;
        image_idx     <= image_idx;
        kernel_idx    <= kernel_idx;
        cv_v[0]       <= cv_v[0];
    end
end

assign cv_r_overflow_0 = cv_v[0] & ( cv_r[0] == 3'b100); 
assign cv_k_overflow_0 = cv_r_overflow_0 & (cv_k[0] == 'd3); 
assign cv_j_overflow_0 = (
    mode_reg ? 
        cv_k_overflow_0 & ((matrix_size_reg == 2'b00 && cv_j[0] == 'd11) || (matrix_size_reg == 2'b01 && cv_j[0] == 'd19) || (matrix_size_reg == 2'b10 && cv_j[0] == 'd35)) :
        cv_k_overflow_0 & ((matrix_size_reg == 2'b00 && cv_j[0] ==  'd1) || (matrix_size_reg == 2'b01 && cv_j[0] ==  'd5) || (matrix_size_reg == 2'b10 && cv_j[0] == 'd13))
); 
assign cv_i_overflow_0 = (
    mode_reg ? 
        cv_j_overflow_0 & ((matrix_size_reg == 2'b00 && cv_i[0] == 'd11) || (matrix_size_reg == 2'b01 && cv_i[0] == 'd19) || (matrix_size_reg == 2'b10 && cv_i[0] == 'd35)) :
        cv_j_overflow_0 & ((matrix_size_reg == 2'b00 && cv_i[0] ==  'd1) || (matrix_size_reg == 2'b01 && cv_i[0] ==  'd5) || (matrix_size_reg == 2'b10 && cv_i[0] == 'd13))
); 

integer idx;
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        cv_r[0] <= 'b0;
        cv_k[0] <= 'b0;
        cv_j[0] <= 'b0;
        cv_i[0] <= 'b0;
        for (idx = 1; idx < 5; idx = idx + 1) begin
            cv_v[idx] <= 'b0;
            cv_r[idx] <= 'b0;
            cv_k[idx] <= 'b0;
            cv_j[idx] <= 'b0;
            cv_i[idx] <= 'b0;
        end
        for (idx = 0; idx < 5; idx = idx + 1) begin
            cv_r_overflow[idx] <= 'b0;
            cv_k_overflow[idx] <= 'b0;
            cv_j_overflow[idx] <= 'b0;
            cv_i_overflow[idx] <= 'b0;
        end
    end
    else if (in_valid2 & ~in_valid2_cnt) begin
        cv_r[0] <= 'b0;
        cv_k[0] <= mode ? 'b11 : 'b0;
        cv_j[0] <= 'b0;
        cv_i[0] <= 'b0;
        for (idx = 1; idx < 5; idx = idx + 1) begin
            cv_v[idx] <= 'b0;
            cv_r[idx] <= 'b0;
            cv_k[idx] <= 'b0;
            cv_j[idx] <= 'b0;
            cv_i[idx] <= 'b0;
        end
        for (idx = 0; idx < 5; idx = idx + 1) begin
            cv_r_overflow[idx] <= 'b0;
            cv_k_overflow[idx] <= 'b0;
            cv_j_overflow[idx] <= 'b0;
            cv_i_overflow[idx] <= 'b0;
        end
    end
    else begin
        cv_r[0] <= cv_r_overflow_0 ? 'b0 : (cv_v[0]         ? cv_r[0] + 1 : cv_r[0]);
        cv_k[0] <= cv_k_overflow_0 ? 'b0 : (cv_r_overflow_0 ? cv_k[0] + 1 : cv_k[0]);
        cv_j[0] <= cv_j_overflow_0 ? 'b0 : (cv_k_overflow_0 ? cv_j[0] + 1 : cv_j[0]);
        cv_i[0] <= cv_i_overflow_0 ? 'b0 : (cv_j_overflow_0 ? cv_i[0] + 1 : cv_i[0]);
        for (idx = 1; idx < 5; idx = idx + 1) begin
            cv_v[idx] <= cv_v[idx - 1];
            cv_r[idx] <= cv_r[idx - 1];
            cv_k[idx] <= cv_k[idx - 1];
            cv_j[idx] <= cv_j[idx - 1];
            cv_i[idx] <= cv_i[idx - 1];
        end
        cv_r_overflow[1] <= cv_r_overflow_0;
        cv_k_overflow[1] <= cv_k_overflow_0;
        cv_j_overflow[1] <= cv_j_overflow_0;
        cv_i_overflow[1] <= cv_i_overflow_0;
        for (idx = 2; idx < 5; idx = idx + 1) begin
            cv_r_overflow[idx] <= cv_r_overflow[idx - 1];
            cv_k_overflow[idx] <= cv_k_overflow[idx - 1];
            cv_j_overflow[idx] <= cv_j_overflow[idx - 1];
            cv_i_overflow[idx] <= cv_i_overflow[idx - 1];
        end
    end
end

//     ___    ____  ____  _____ __  ______     ______            __             __
//    /   |  / __ \/ __ \/ ___// / / / __ )   / ____/___  ____  / /__________  / /
//   / /| | / / / / / / /\__ \/ / / / __  |  / /   / __ \/ __ \/ __/ ___/ __ \/ / 
//  / ___ |/ /_/ / /_/ /___/ / /_/ / /_/ /  / /___/ /_/ / / / / /_/ /  / /_/ / /  
// /_/  |_/_____/_____//____/\____/_____/   \____/\____/_/ /_/\__/_/   \____/_/   
                                                                               
assign addsub0_a = SRAM0_addr;
assign addsub1_a = SRAM1_addr;

always @(*) begin
    if (cv_v[0]) begin
        if (mode_reg) begin
            if (cv_r_overflow_0) begin
                if (cv_j_overflow_0) begin
                    if (matrix_size_reg == 2'b00) begin
                        // SRAM0_addr <= SRAM0_addr + 19;
                        // SRAM1_addr <= SRAM1_addr + 20;
                        addsub0_b  = 12'd19;
                        addsub1_b  = 12'd20;
                        addsub0_op =  1'b0;
                        addsub1_op =  1'b0;
                    end
                    else if (matrix_size_reg == 2'b01) begin
                        // SRAM0_addr <= SRAM0_addr + 18;
                        // SRAM1_addr <= SRAM1_addr + 19;
                        addsub0_b  = 12'd18;
                        addsub1_b  = 12'd19;
                        addsub0_op =  1'b0;
                        addsub1_op =  1'b0;
                    end
                    else begin
                        // SRAM0_addr <= SRAM0_addr + 16;
                        // SRAM1_addr <= SRAM1_addr + 17;
                        addsub0_b  = 12'd16;
                        addsub1_b  = 12'd17;
                        addsub0_op =  1'b0;
                        addsub1_op =  1'b0;
                    end
                end
                else begin
                    if (cv_k_overflow_0) begin
                        if (cv_j[0][2:0] == 3'b111) begin
                            // SRAM0_addr <= SRAM0_addr + 17;
                            // SRAM1_addr <= SRAM1_addr + 16;
                            addsub0_b  = 12'd17;
                            addsub1_b  = 12'd16;
                            addsub0_op =  1'b0;
                            addsub1_op =  1'b0;
                        end
                        else if (cv_j[0][2:0] == 3'b011 && cv_j[0] != 7'd3) begin
                            // SRAM0_addr <= SRAM0_addr + 16;
                            // SRAM1_addr <= SRAM1_addr + 17;
                            addsub0_b  = 12'd16;
                            addsub1_b  = 12'd17;
                            addsub0_op =  1'b0;
                            addsub1_op =  1'b0;
                        end
                        else begin
                            // SRAM0_addr <= SRAM0_addr + 16;
                            // SRAM1_addr <= SRAM1_addr + 16;
                            addsub0_b  = 12'd16;
                            addsub1_b  = 12'd16;
                            addsub0_op =  1'b0;
                            addsub1_op =  1'b0;
                        end
                    end
                    else begin
                        // SRAM0_addr <= SRAM0_addr + 16;
                        // SRAM1_addr <= SRAM1_addr + 16;
                        addsub0_b  = 12'd16;
                        addsub1_b  = 12'd16;
                        addsub0_op =  1'b0;
                        addsub1_op =  1'b0;
                    end
                end
            end
            else begin
                // SRAM0_addr <= SRAM0_addr - 4;
                // SRAM1_addr <= SRAM1_addr - 4;
                addsub0_b  = 12'd4;
                addsub1_b  = 12'd4;
                addsub0_op =  1'b1;
                addsub1_op =  1'b1;
            end
        end
        else begin
            if (cv_r_overflow_0) begin
                if (cv_j_overflow_0) begin
                    if (matrix_size_reg == 2'b00) begin
                        // SRAM0_addr <= SRAM0_addr - 12;
                        // SRAM1_addr <= SRAM1_addr - 12;
                        addsub0_b  = 12'd12;
                        addsub1_b  = 12'd12;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                    else if (matrix_size_reg == 2'b01) begin
                        // SRAM0_addr <= SRAM0_addr - 13;
                        // SRAM1_addr <= SRAM1_addr - 13;
                        addsub0_b  = 12'd13;
                        addsub1_b  = 12'd13;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                    else begin
                        // SRAM0_addr <= SRAM0_addr - 15;
                        // SRAM1_addr <= SRAM1_addr - 15;
                        addsub0_b  = 12'd15;
                        addsub1_b  = 12'd15;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                end
                else begin
                    if (~cv_k[0][0]) begin
                        // SRAM0_addr <= SRAM0_addr - 16;
                        // SRAM1_addr <= SRAM1_addr - 16;
                        addsub0_b  = 12'd16;
                        addsub1_b  = 12'd16;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                    else if (~cv_k[0][1]) begin
                        // SRAM0_addr <= SRAM0_addr - 12;
                        // SRAM1_addr <= SRAM1_addr - 12;
                        addsub0_b  = 12'd12;
                        addsub1_b  = 12'd12;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                    else if (~cv_j[0][0]) begin
                        // SRAM0_addr <= SRAM0_addr - 20;
                        // SRAM1_addr <= SRAM1_addr - 20;
                        addsub0_b  = 12'd20;
                        addsub1_b  = 12'd20;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                    else if (~cv_j[0][1]) begin
                        // SRAM0_addr <= SRAM0_addr - 19;
                        // SRAM1_addr <= SRAM1_addr - 20;
                        addsub0_b  = 12'd19;
                        addsub1_b  = 12'd20;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                    else begin
                        // SRAM0_addr <= SRAM0_addr - 20;
                        // SRAM1_addr <= SRAM1_addr - 19;
                        addsub0_b  = 12'd20;
                        addsub1_b  = 12'd19;
                        addsub0_op =  1'b1;
                        addsub1_op =  1'b1;
                    end
                end
            end
            else begin
                // SRAM0_addr <= SRAM0_addr + 4;
                // SRAM1_addr <= SRAM1_addr + 4;
                addsub0_b  = 12'd4;
                addsub1_b  = 12'd4;
                addsub0_op =  1'b0;
                addsub1_op =  1'b0;
            end
        end
    end
    else begin
        addsub0_b  = 12'd0;
        addsub1_b  = 12'd0;
        addsub0_op =  1'b0;
        addsub1_op =  1'b0;
    end
end

//    _____ ____  ___    __  ___   ______            __             __
//   / ___// __ \/   |  /  |/  /  / ____/___  ____  / /__________  / /
//   \__ \/ /_/ / /| | / /|_/ /  / /   / __ \/ __ \/ __/ ___/ __ \/ / 
//  ___/ / _, _/ ___ |/ /  / /  / /___/ /_/ / / / / /_/ /  / /_/ / /  
// /____/_/ |_/_/  |_/_/  /_/   \____/\____/_/ /_/\__/_/   \____/_/   
                                          

////////////////////////////////////////////////////////////////
//                                                            //
//                     catch sram output                      //
//                                                            //
////////////////////////////////////////////////////////////////

always @(posedge clk) begin
    SRAM0_data_o_reg <= SRAM0_data_o;
    SRAM1_data_o_reg <= SRAM1_data_o;
    SRAMK_data_o_reg <= SRAMK_data_o;
end

wire input_cnt_mod4_is2;
wire input_cnt_mod8_gt3;
assign input_cnt_mod4_is2 = input_cnt[1] & ~input_cnt[0];
assign input_cnt_mod8_gt3 = input_cnt[2];
assign SRAM0_data_i = in_valid ? input_temp_reg_next[31:0] : 'b0;
assign SRAM1_data_i = in_valid ? input_temp_reg_next[31:0] : 'b0;
assign SRAMK_data_i = in_valid ? input_temp_reg_next[39:0] : 'b0;

reg  done;

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        done <= 'b0;
    end
    else if (in_valid2) begin
        done <= 'b0;
    end
    else if (cv_i_overflow[3]) begin
        done <= 'b1;
    end
    else begin
        done <= done;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        SRAM0_addr <= 'b0;
        SRAM1_addr <= 'b0;
        SRAM0_WEB  <= 'b0;
        SRAM1_WEB  <= 'b0;

        SRAMK_addr <= 'b0;
        SRAMK_WEB  <= 'b0;
    end
////////////////////////////////////////////////////////////////
//                  image and kernel loading                  //
////////////////////////////////////////////////////////////////
    else if (in_valid) begin
        SRAM0_addr <= input_cnt_next[13:3];
        SRAM1_addr <= input_cnt_next[13:3];
        SRAM0_WEB  <= ~kernel_start_flag & ~input_cnt_mod8_gt3 & input_cnt_mod4_is2;
        SRAM1_WEB  <= ~kernel_start_flag &  input_cnt_mod8_gt3 & input_cnt_mod4_is2;

        SRAMK_addr <= kernel_start_flag ? input_cnt[6:0] : 'b0;
        SRAMK_WEB  <= kernel_start_flag & input_kernel_cnt_sh[3];
    end
////////////////////////////////////////////////////////////////
//                 output data for calculate                  //
////////////////////////////////////////////////////////////////
    else if (~in_valid2 & done) begin
        SRAM0_addr <= 'b0;
        SRAM1_addr <= 'b0;
        SRAM0_WEB  <= 'b0;
        SRAM1_WEB  <= 'b0;
        SRAMK_addr <= 'b0;
        SRAMK_WEB  <= 'b0;
    end
    else if (in_valid2) begin
        SRAM0_addr <= in_valid2_cnt ? SRAM0_addr : {matrix_idx, 7'b0};
        SRAM1_addr <= in_valid2_cnt ? SRAM1_addr : {matrix_idx, 7'b0};
        SRAM0_WEB  <= 'b0;
        SRAM1_WEB  <= 'b0;

        case (matrix_idx)
            4'h1   : SRAMK_addr <= 'd 5;
            4'h2   : SRAMK_addr <= 'd10;
            4'h3   : SRAMK_addr <= 'd15;
            4'h4   : SRAMK_addr <= 'd20;
            4'h5   : SRAMK_addr <= 'd25;
            4'h6   : SRAMK_addr <= 'd30;
            4'h7   : SRAMK_addr <= 'd35;
            4'h8   : SRAMK_addr <= 'd40;
            4'h9   : SRAMK_addr <= 'd45;
            4'hA   : SRAMK_addr <= 'd50;
            4'hB   : SRAMK_addr <= 'd55;
            4'hC   : SRAMK_addr <= 'd60;
            4'hD   : SRAMK_addr <= 'd65;
            4'hE   : SRAMK_addr <= 'd70;
            4'hF   : SRAMK_addr <= 'd75;
            default: SRAMK_addr <= 'd 0;
        endcase

        SRAMK_WEB  <= 'b0;
    end
    else if (cv_v[0]) begin
        if (mode_reg) begin
            if (cv_r_overflow_0) begin
                SRAMK_addr <= SRAMK_addr - 4;
                if (cv_i_overflow_0) begin
                    SRAM0_addr <= 'b0;
                    SRAM1_addr <= 'b0;
                end
                else begin
                    if (cv_j_overflow_0) begin
                        if (matrix_size_reg == 2'b00) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (matrix_size_reg == 2'b01) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (matrix_size_reg == 2'b10) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                    end
                    else begin
                        if (cv_k_overflow_0) begin
                            if (cv_j[0][2:0] == 3'b111) begin
                                SRAM0_addr <= addsub0_o;
                                SRAM1_addr <= addsub1_o;
                            end
                            else if (cv_j[0][2:0] == 3'b011 && cv_j[0] != 7'd3) begin
                                SRAM0_addr <= addsub0_o;
                                SRAM1_addr <= addsub1_o;
                            end
                            else begin
                                SRAM0_addr <= addsub0_o;
                                SRAM1_addr <= addsub1_o;
                            end
                        end
                        else begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                    end
                end
            end
            else begin
                SRAM0_addr <= addsub0_o;
                SRAM1_addr <= addsub1_o;
                SRAMK_addr <= SRAMK_addr + 1;
            end
        end
        else begin
            if (cv_r_overflow_0) begin
                SRAMK_addr <= SRAMK_addr - 4;
                if (cv_i_overflow_0) begin
                    SRAM0_addr <= 'b0;
                    SRAM1_addr <= 'b0;
                end
                else begin
                    if (cv_j_overflow_0) begin
                        if (matrix_size_reg == 2'b00) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (matrix_size_reg == 2'b01) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (matrix_size_reg == 2'b10) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                    end
                    else begin
                        if (~cv_k[0][0]) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (~cv_k[0][1]) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (~cv_j[0][0]) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else if (~cv_j[0][1]) begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                        else begin
                            SRAM0_addr <= addsub0_o;
                            SRAM1_addr <= addsub1_o;
                        end
                    end
                end
            end
            else begin
                SRAM0_addr <= addsub0_o;
                SRAM1_addr <= addsub1_o;
                SRAMK_addr <= SRAMK_addr + 1;
            end
        end
        SRAM0_WEB  <= 'b0;
        SRAM1_WEB  <= 'b0;
        SRAMK_WEB  <= 'b0;
    end
    else begin
        SRAM0_addr <= SRAM0_addr;
        SRAM1_addr <= SRAM1_addr;
        SRAM0_WEB  <= SRAM0_WEB;
        SRAM1_WEB  <= SRAM1_WEB;
        
        SRAMK_addr <= SRAMK_addr;
        SRAMK_WEB  <= SRAMK_WEB;
    end
end

//     __  ___      ____  _       ___                   ______            __             __
//    /  |/  /_  __/ / /_(_)___  / (_)__  __________   / ____/___  ____  / /__________  / /
//   / /|_/ / / / / / __/ / __ \/ / / _ \/ ___/ ___/  / /   / __ \/ __ \/ __/ ___/ __ \/ / 
//  / /  / / /_/ / / /_/ / /_/ / / /  __/ /  (__  )  / /___/ /_/ / / / / /_/ /  / /_/ / /  
// /_/  /_/\__,_/_/\__/_/ .___/_/_/\___/_/  /____/   \____/\____/_/ /_/\__/_/   \____/_/   
//                     /_/                                                                 


always @(*) begin
    if (mode_reg) begin
        // k[39:32], k[31:24], k2[23:16], k3[15: 8], k[ 7: 0]
        if (({4'b0, cv_r[2]} <= cv_i[2]) && ((matrix_size_reg == 2'b00 && ((cv_i[2] - cv_r[2]) < 7'd8)) || (matrix_size_reg == 2'b01 && ((cv_i[2] - cv_r[2]) < 7'd16)) || (matrix_size_reg == 2'b10 && ((cv_i[2] - cv_r[2]) < 7'd32)))) begin
            if (cv_j[2] == 7'd0) begin
                muln_a = {SRAM0_data_o_reg[31:24], 32'b0};
            end
            else if (cv_j[2] == 7'd1) begin
                muln_a = {SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24], 24'b0};
            end
            else if (cv_j[2] == 7'd2) begin
                muln_a = {SRAM0_data_o_reg[15: 8], SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24], 16'b0};
            end
            else if (cv_j[2] == 7'd3) begin
                muln_a = {SRAM0_data_o_reg[ 7: 0], SRAM0_data_o_reg[15: 8], SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24], 8'b0};
            end
            else if ((matrix_size_reg == 2'b00 && cv_j[2] ==  7'd8) || (matrix_size_reg == 2'b01 && cv_j[2] == 7'd16) || (matrix_size_reg == 2'b10 && cv_j[2] == 7'd32)) begin
                muln_a = { 8'b0, SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8], SRAM1_data_o_reg[23:16], SRAM1_data_o_reg[31:24]};
            end
            else if ((matrix_size_reg == 2'b00 && cv_j[2] ==  7'd9) || (matrix_size_reg == 2'b01 && cv_j[2] == 7'd17) || (matrix_size_reg == 2'b10 && cv_j[2] == 7'd33)) begin
                muln_a = {16'b0, SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8], SRAM1_data_o_reg[23:16]};
            end
            else if ((matrix_size_reg == 2'b00 && cv_j[2] == 7'd10) || (matrix_size_reg == 2'b01 && cv_j[2] == 7'd18) || (matrix_size_reg == 2'b10 && cv_j[2] == 7'd34)) begin
                muln_a = {24'b0, SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8]};
            end
            else if ((matrix_size_reg == 2'b00 && cv_j[2] == 7'd11) || (matrix_size_reg == 2'b01 && cv_j[2] == 7'd19) || (matrix_size_reg == 2'b10 && cv_j[2] == 7'd35)) begin
                muln_a = {32'b0, SRAM1_data_o_reg[ 7: 0]};
            end
            else begin
                case (cv_j[2][2:0])
                    3'b100 : muln_a = {SRAM1_data_o_reg[31:24], SRAM0_data_o_reg[ 7: 0], SRAM0_data_o_reg[15: 8], SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24]};
                    3'b101 : muln_a = {SRAM1_data_o_reg[23:16], SRAM1_data_o_reg[31:24], SRAM0_data_o_reg[ 7: 0], SRAM0_data_o_reg[15: 8], SRAM0_data_o_reg[23:16]};
                    3'b110 : muln_a = {SRAM1_data_o_reg[15: 8], SRAM1_data_o_reg[23:16], SRAM1_data_o_reg[31:24], SRAM0_data_o_reg[ 7: 0], SRAM0_data_o_reg[15: 8]};
                    3'b111 : muln_a = {SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8], SRAM1_data_o_reg[23:16], SRAM1_data_o_reg[31:24], SRAM0_data_o_reg[ 7: 0]};
                    3'b000 : muln_a = {SRAM0_data_o_reg[31:24], SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8], SRAM1_data_o_reg[23:16], SRAM1_data_o_reg[31:24]};
                    3'b001 : muln_a = {SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24], SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8], SRAM1_data_o_reg[23:16]};
                    3'b010 : muln_a = {SRAM0_data_o_reg[15: 8], SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24], SRAM1_data_o_reg[ 7: 0], SRAM1_data_o_reg[15: 8]};
                    3'b011 : muln_a = {SRAM0_data_o_reg[ 7: 0], SRAM0_data_o_reg[15: 8], SRAM0_data_o_reg[23:16], SRAM0_data_o_reg[31:24], SRAM1_data_o_reg[ 7: 0]};
                    default: muln_a = 'b0;
                endcase
            end
        end
        else begin
            muln_a = 'b0;
        end
    end
    else begin
        case ({cv_j[2][1:0], cv_k[2][0]})
            3'b000 : begin
                muln_a = {SRAM0_data_o_reg[31:0], SRAM1_data_o_reg[31:24]};
            end
            3'b001 : begin
                muln_a = {SRAM0_data_o_reg[23:0], SRAM1_data_o_reg[31:16]};
            end
            3'b010 : begin
                muln_a = {SRAM0_data_o_reg[15:0], SRAM1_data_o_reg[31: 8]};
            end
            3'b011 : begin
                muln_a = {SRAM0_data_o_reg[ 7:0], SRAM1_data_o_reg[31: 0]};
            end
            3'b100 : begin
                muln_a = {SRAM1_data_o_reg[31:0], SRAM0_data_o_reg[31:24]};
            end
            3'b101 : begin
                muln_a = {SRAM1_data_o_reg[23:0], SRAM0_data_o_reg[31:16]};
            end
            3'b110 : begin
                muln_a = {SRAM1_data_o_reg[15:0], SRAM0_data_o_reg[31: 8]};
            end
            3'b111 : begin
                muln_a = {SRAM1_data_o_reg[ 7:0], SRAM0_data_o_reg[31: 0]};
            end
            default: begin
                muln_a = 'b0;
            end
        endcase
    end
end

assign mul0_b = (~mode_reg | ({4'b0, cv_r[2]} <= cv_i[2])) ? SRAMK_data_o_reg[ 7: 0] : 'b0;
assign mul1_b = (~mode_reg | ({4'b0, cv_r[2]} <= cv_i[2])) ? SRAMK_data_o_reg[15: 8] : 'b0;
assign mul2_b = (~mode_reg | ({4'b0, cv_r[2]} <= cv_i[2])) ? SRAMK_data_o_reg[23:16] : 'b0;
assign mul3_b = (~mode_reg | ({4'b0, cv_r[2]} <= cv_i[2])) ? SRAMK_data_o_reg[31:24] : 'b0;
assign mul4_b = (~mode_reg | ({4'b0, cv_r[2]} <= cv_i[2])) ? SRAMK_data_o_reg[39:32] : 'b0;


//    _____                 _____    ______            __             __
//   / ___/__  ______ ___  / ___/   / ____/___  ____  / /__________  / /
//   \__ \/ / / / __ `__ \/ __ \   / /   / __ \/ __ \/ __/ ___/ __ \/ / 
//  ___/ / /_/ / / / / / / /_/ /  / /___/ /_/ / / / / /_/ /  / /_/ / /  
// /____/\__,_/_/ /_/ /_/\____/   \____/\____/_/ /_/\__/_/   \____/_/   

assign sum60_a = conv_sum;
assign sum60_b = {{4{mul0_o[15]}}, mul0_o};
assign sum60_c = {{4{mul1_o[15]}}, mul1_o};
assign sum60_d = {{4{mul2_o[15]}}, mul2_o};
assign sum60_e = {{4{mul3_o[15]}}, mul3_o};
assign sum60_f = {{4{mul4_o[15]}}, mul4_o};

always @(posedge clk, negedge rst_n) begin // todo : wrong cond maybe
    if (~rst_n) begin
        conv_sum <= 'b0;
    end
    else if (~cv_v[3] | cv_r_overflow[3]) begin
        conv_sum <= 'b0;
    end
    else if (cv_v[3]) begin
        conv_sum <= sum60_o;
    end
    else begin
        conv_sum <= conv_sum;
    end
end

//     __  ___              ____              ___                ______            __             __
//    /  |/  /___ __  __   / __ \____  ____  / (_)___  ____ _   / ____/___  ____  / /__________  / /
//   / /|_/ / __ `/ |/_/  / /_/ / __ \/ __ \/ / / __ \/ __ `/  / /   / __ \/ __ \/ __/ ___/ __ \/ / 
//  / /  / / /_/ />  <   / ____/ /_/ / /_/ / / / / / / /_/ /  / /___/ /_/ / / / / /_/ /  / /_/ / /  
// /_/  /_/\__,_/_/|_|  /_/    \____/\____/_/_/_/ /_/\__, /   \____/\____/_/ /_/\__/_/   \____/_/   
//                                                  /____/                                          

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        mp_value <= {1'b1, 19'b0};
    end
    else if (cv_k_overflow[3] | in_valid2) begin
        mp_value <= {1'b1, 19'b0};
    end
    else if (cv_r_overflow[3]) begin
        mp_value <= $signed(sum60_o) > $signed(mp_value) ? sum60_o : mp_value;
    end
    else begin
        mp_value <= mp_value;
    end
end

//    ____        __              __     __                _     
//   / __ \__  __/ /_____  __  __/ /_   / /   ____  ____ _(_)____
//  / / / / / / / __/ __ \/ / / / __/  / /   / __ \/ __ `/ / ___/
// / /_/ / /_/ / /_/ /_/ / /_/ / /_   / /___/ /_/ / /_/ / / /__  
// \____/\__,_/\__/ .___/\__,_/\__/  /_____/\____/\__, /_/\___/  
//               /_/                             /____/          


always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        out_value20 <= 'b0;
    end
    else if (cv_k_overflow[3]) begin
        out_value20 <= $signed(sum60_o) > $signed(mp_value) ? sum60_o : mp_value;
    end
    else begin
        out_value20 <= out_value20 >> 1;
    end
end

reg [4:0] out_valid_tail_cnt;

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        out_valid_tail_cnt <= 'b0;
    end
    else if (in_valid2 | cv_i_overflow[3]) begin
        out_valid_tail_cnt <= 'b0;
    end
    else if (out_valid_tail_cnt < 19 && done) begin
        out_valid_tail_cnt <= out_valid_tail_cnt + 1;
    end
    else begin
        out_valid_tail_cnt <= out_valid_tail_cnt;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 'b0;
    end
    else if (out_valid_tail_cnt == 19) begin
        out_valid <= 'b0;
    end
    else if (cv_k_overflow[3]) begin
        out_valid <= 'b1;
    end
    else begin
        out_valid <= out_valid;
    end
end

always @(*) begin
    if (~rst_n) begin
        out_value = 'b0;
    end
    else if (~out_valid) begin
        out_value = 'b0;
    end
    else if (cv_v[4]) begin
        out_value = out_value20[0];
    end
    else begin
        out_value = 'b0;
    end
end

endmodule

module ADDR_ADDSUB (
    input  wire [11:0] a,
    input  wire [11:0] b,
    input  wire        op,
    
    output wire [11:0] o
);
    wire cin01;
    wire cin02;
    wire cin03;
    wire cin04;
    wire cin05;
    wire cin06;
    wire cin07;
    wire cin08;
    wire cin09;
    wire cin10;
    wire cin11;
    FADDER fadder_inst00 (.sum(o[ 0]), .cout(cin01), .a(a[ 0]), .b(op ^ b[ 0]), .cin(   op));
    FADDER fadder_inst01 (.sum(o[ 1]), .cout(cin02), .a(a[ 1]), .b(op ^ b[ 1]), .cin(cin01));
    FADDER fadder_inst02 (.sum(o[ 2]), .cout(cin03), .a(a[ 2]), .b(op ^ b[ 2]), .cin(cin02));
    FADDER fadder_inst03 (.sum(o[ 3]), .cout(cin04), .a(a[ 3]), .b(op ^ b[ 3]), .cin(cin03));
    FADDER fadder_inst04 (.sum(o[ 4]), .cout(cin05), .a(a[ 4]), .b(op ^ b[ 4]), .cin(cin04));
    FADDER fadder_inst05 (.sum(o[ 5]), .cout(cin06), .a(a[ 5]), .b(op ^ b[ 5]), .cin(cin05));
    FADDER fadder_inst06 (.sum(o[ 6]), .cout(cin07), .a(a[ 6]), .b(op ^ b[ 6]), .cin(cin06));
    FADDER fadder_inst07 (.sum(o[ 7]), .cout(cin08), .a(a[ 7]), .b(op ^ b[ 7]), .cin(cin07));
    FADDER fadder_inst08 (.sum(o[ 8]), .cout(cin09), .a(a[ 8]), .b(op ^ b[ 8]), .cin(cin08));
    FADDER fadder_inst09 (.sum(o[ 9]), .cout(cin10), .a(a[ 9]), .b(op ^ b[ 9]), .cin(cin09));
    FADDER fadder_inst10 (.sum(o[10]), .cout(cin11), .a(a[10]), .b(op ^ b[10]), .cin(cin10));
    FADDER fadder_inst11 (.sum(o[11]), .cout(     ), .a(a[11]), .b(op ^ b[11]), .cin(cin11));
endmodule

module INPUT_CNT_ADDER (
    input  wire [13:0] cnt,
    input  wire [ 1:0] matrix_size,
    input  wire flag,
    output wire [13:0] cnt_next,
    output wire cout
);
    wire is8;
    wire is16;
    assign is8  = matrix_size == 2'b00;
    assign is16 = matrix_size == 2'b01;
    wire cin01;
    wire cin02;
    wire cin03;
    wire cin04;
    wire cin05;
    wire cin06;
    wire cin07;
    wire cin08;
    wire cin09;
    wire cin10;
    wire cin11;
    wire cin12;
    wire cin13;
    FADDER fadder_inst00 (.sum(cnt_next[ 0]), .cout(cin01), .a(cnt[ 0]), .b(1'b1), .cin( 1'b0));
    FADDER fadder_inst01 (.sum(cnt_next[ 1]), .cout(cin02), .a(cnt[ 1]), .b(1'b0), .cin(cin01));
    FADDER fadder_inst02 (.sum(cnt_next[ 2]), .cout(cin03), .a(cnt[ 2]), .b(1'b0), .cin(cin02));
    FADDER fadder_inst03 (.sum(cnt_next[ 3]), .cout(cin04), .a(cnt[ 3]), .b(1'b0), .cin(cin03 & (flag | ~is8 )));
    FADDER fadder_inst04 (.sum(cnt_next[ 4]), .cout(cin05), .a(cnt[ 4]), .b(1'b0), .cin(cin04 & (flag | ~is16)));
    FADDER fadder_inst05 (.sum(cnt_next[ 5]), .cout(cin06), .a(cnt[ 5]), .b(1'b0), .cin(cin05 | (~flag & is8 & cin03) | (~flag & is16 & cin04)));
    FADDER fadder_inst06 (.sum(cnt_next[ 6]), .cout(cin07), .a(cnt[ 6]), .b(1'b0), .cin(cin06));
    FADDER fadder_inst07 (.sum(cnt_next[ 7]), .cout(cin08), .a(cnt[ 7]), .b(1'b0), .cin(cin07));
    FADDER fadder_inst08 (.sum(cnt_next[ 8]), .cout(cin09), .a(cnt[ 8]), .b(1'b0), .cin(cin08 & (flag | ~is8 )));
    FADDER fadder_inst09 (.sum(cnt_next[ 9]), .cout(cin10), .a(cnt[ 9]), .b(1'b0), .cin(cin09 & (flag | ~is16)));
    FADDER fadder_inst10 (.sum(cnt_next[10]), .cout(cin11), .a(cnt[10]), .b(1'b0), .cin(cin10 | (~flag & is8 & cin08) | (~flag & is16 & cin09)));
    FADDER fadder_inst11 (.sum(cnt_next[11]), .cout(cin12), .a(cnt[11]), .b(1'b0), .cin(cin11));
    FADDER fadder_inst12 (.sum(cnt_next[12]), .cout(cin13), .a(cnt[12]), .b(1'b0), .cin(cin12));
    FADDER fadder_inst13 (.sum(cnt_next[13]), .cout(cout ), .a(cnt[13]), .b(1'b0), .cin(cin13));
endmodule

module FADDER(sum, cout, a, b, cin);
    output sum, cout;
    input  a, b, cin;
    xor u0(sum , a   , b   , cin);
    and u1(net1, a   , b);
    and u2(net2, b   , cin);
    and u3(net3, cin , a);
    or  u4(cout, net1, net2, net3);
endmodule

module MULTIPLIER (
    input  wire clk,
    input  wire rst_n,
    input  wire signed [ 7:0] a,
    input  wire signed [ 7:0] b,
    output reg  signed [15:0] o
);

    always @(posedge clk) begin
        o <= $signed(a) * $signed(b);
    end
endmodule

module SUM6 (
    input  wire clk,
    input  wire rst_n,
    input  wire signed [19:0] a,
    input  wire signed [19:0] b,
    input  wire signed [19:0] c,
    input  wire signed [19:0] d,
    input  wire signed [19:0] e,
    input  wire signed [19:0] f,
    output wire signed [19:0] o
);
    assign o = $signed(a) + $signed(b) + $signed(c) + $signed(d) + $signed(e) + $signed(f);
endmodule