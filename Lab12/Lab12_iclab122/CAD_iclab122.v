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

//FSM
reg [2:0] curr_state, next_state;

parameter IDLE      =   3'd0;
parameter INPUT     =   3'd1;
parameter INPUT2    =   3'd3;
parameter CONV      =   3'd4;
parameter DECONV    =   3'd5;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

integer i, j, k;

//store input
reg [1:0] matrix_size_reg;
reg [3:0] i_matrix_idx;
reg [3:0] k_matrix_idx;
reg mode_reg;
reg [63:0] matrix_row;

//Counter
reg [2:0] cnt_one_row;
reg [4:0] img_row_bound;
reg [2:0] cnt_one_krow;

//SRAM Address
reg write_flag;
reg write_k_flag;
reg image_finish, image_finish_comb;
reg [1:0] sram_num;
reg web_sram_img_1, web_sram_img_2, web_sram_img_3, web_sram_img_4;
reg [8:0] img_addr, img_addr_comb;
reg web_sram_kernel;
reg [6:0] ker_addr, ker_addr_comb;
wire [8:0] ptr_matrix;
wire [6:0] ptr_kernel;
reg [2:0] row_offset;

//CONV
reg [1:0] cnt_maxpool_offset;
reg maxpool_offset;
reg [4:0] ptr_col, ptr_col_comb;
reg [4:0] ptr_row, ptr_row_comb;

//DECONV
reg [7:0] img_pad [0:39];
reg [4:0] cnt_de_20;
reg stop_flag;
reg [5:0] cnt_de_col, cnt_de_col_comb;
reg [5:0] cnt_de_row, cnt_de_row_comb;

//DELAY_ELEMENT
reg [4:0] ptr_col_d1, ptr_col_d2;
reg maxpool_offset_d1, maxpool_offset_d2;
reg [5:0] cnt_de_col_d1, cnt_de_col_d2, cnt_de_col_d3;
reg [5:0] cnt_de_row_d1, cnt_de_row_d2, cnt_de_row_d3;
reg [2:0] row_offset_d1, row_offset_d2, row_offset_d3;

//MULT
reg signed [7:0] mult_a [0:4];
reg signed [7:0] mult_b [0:4];
reg signed [15:0] mult_z [0:4];
reg signed [19:0] sum, sum_comb, pre_sum;
reg signed [19:0] largest, largest_comb;
reg signed [19:0] conv_result_reg, conv_result_comb;
reg [4:0] cnt_state;

//SRAM_DO
reg signed [7:0] DO_Kernel_reg [0:4];
reg signed [7:0] DO_Kernel_comb [0:4];
reg signed [7:0] DO_Image_reg [0:31];
reg signed [7:0] DO_Image_comb [0:31];

//SRAM
wire [63:0] DO_SRAM_IMG1, DO_SRAM_IMG2, DO_SRAM_IMG3, DO_SRAM_IMG4;
wire [7:0] DO_sram_img [0:31];
wire [39:0] DO_SRAM_Kern;

//Output
reg [4:0] cnt20;
reg [10:0] cnt_out;
reg out_valid_comb, out_value_comb;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

//=================================
//		Store Input
//=================================

//matrix_size_reg
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                              matrix_size_reg <= 2'b0;
    else if(in_valid && curr_state==IDLE)   matrix_size_reg <= matrix_size;
    else                                    matrix_size_reg <= matrix_size_reg;
end
//i_matrix_idx, k_matrix_idx
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_matrix_idx <= 4'd0;
        k_matrix_idx <= 4'd0;
    end
    else begin
        if(in_valid2) begin
            i_matrix_idx <= k_matrix_idx;
            k_matrix_idx <= matrix_idx;
        end
    end
end
//mode_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  mode_reg <= 1'd0;
    else begin
        if(in_valid2 && curr_state==IDLE)   mode_reg <= mode;
        else                                mode_reg <= mode_reg;
    end
end
//matrix_row
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        matrix_row <= 64'b0;
    end
    else begin
        if(in_valid)    matrix_row <= {matrix_row[55:0],matrix};
        else            matrix_row <= 64'b0;
    end
end

//=================================
//		Counter
//=================================

//*****IMAGE*****
//cnt_one_row
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_one_row <= 3'd0;
    else begin
        if(in_valid)    cnt_one_row <= cnt_one_row + 3'd1;
        else            cnt_one_row <= 3'd0;
    end
end

//*****KERNEL*****
//cnt_one_krow
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_one_krow <= 3'd0;
    else begin
        if(cnt_one_krow==3'd4)      cnt_one_krow <= 3'd0;
        else if(image_finish_comb)  cnt_one_krow <= cnt_one_krow + 3'd1;
        else                        cnt_one_krow <= 3'd0;
    end
end

//=================================
//		SRAM Address
//=================================

//write_flag
always @(*) begin
    if(curr_state==INPUT && cnt_one_row==3'd7)  write_flag = 1'b1;
    else                                        write_flag = 1'b0;
end

//write_k_flag
always @(*) begin
    if(curr_state==INPUT && cnt_one_krow==3'd4) write_k_flag = 1'b1;
    else                                        write_k_flag = 1'b0;
end

//image_finish
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  image_finish <= 1'b0;
    else        image_finish <= image_finish_comb;
end
always @(*) begin
    if(curr_state==IDLE)    image_finish_comb = 1'b0;
    else begin
        case(matrix_size_reg)
            2'd0:   if(img_addr==9'd127 && ~web_sram_img_1)     image_finish_comb = 1'b1; //8*16page
                    else                                        image_finish_comb = image_finish;
            2'd1:   if(img_addr==9'd255 && ~web_sram_img_2)     image_finish_comb = 1'b1;
                    else                                        image_finish_comb = image_finish; //16*16page
            2'd2:   if(img_addr==9'd511 && ~web_sram_img_4)     image_finish_comb = 1'b1;
                    else                                        image_finish_comb = image_finish; //32*16page
            default:                                            image_finish_comb = 1'b0;
        endcase
    end
end

//*****IMAGE*****
//sram_num
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  sram_num <= 2'd0;
    else begin
        if(curr_state==IDLE)                            sram_num <= 2'd0;
        else if(write_flag && matrix_size_reg==2'd1)    sram_num <= {1'b0, ~sram_num[0]};
        else if(write_flag && matrix_size_reg==2'd2)    sram_num <= sram_num + 2'd1;
        else                                            sram_num <= sram_num;
    end
end
//web_sram_img_1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                                              web_sram_img_1 <= 1'b1;
    else if(write_flag && sram_num==2'd0 && ~image_finish)  web_sram_img_1 <= 1'b0;
    else                                                    web_sram_img_1 <= 1'b1;
end
//web_sram_img_2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                                              web_sram_img_2 <= 1'b1;
    else if(write_flag && sram_num==2'd1 && ~image_finish)  web_sram_img_2 <= 1'b0;
    else                                                    web_sram_img_2 <= 1'b1;
end
//web_sram_img_3
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                                              web_sram_img_3 <= 1'b1;
    else if(write_flag && sram_num==2'd2 && ~image_finish)  web_sram_img_3 <= 1'b0;
    else                                                    web_sram_img_3 <= 1'b1;
end
//web_sram_img_4
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                                              web_sram_img_4 <= 1'b1;
    else if(write_flag && sram_num==2'd3 && ~image_finish)  web_sram_img_4 <= 1'b0;
    else                                                    web_sram_img_4 <= 1'b1;
end

//img_addr
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  img_addr <= 9'd0;
    else        img_addr <= img_addr_comb;
end
always @(*) begin
    case(curr_state)
        IDLE:   img_addr_comb = 9'd0;
        INPUT: begin
            if(matrix_size_reg==2'd0 && !web_sram_img_1)        img_addr_comb = img_addr + 'd1;
            else if(matrix_size_reg==2'd1 && !web_sram_img_2)   img_addr_comb = img_addr + 'd1;
            else if(matrix_size_reg==2'd2 && !web_sram_img_4)   img_addr_comb = img_addr + 'd1;
            else                                                img_addr_comb = img_addr;
        end
        INPUT2: begin
            img_addr_comb = ptr_matrix;
        end
        CONV: begin
            img_addr_comb = ptr_matrix + row_offset + ptr_row + cnt_maxpool_offset[1];
        end
        DECONV: begin
            img_addr_comb = ptr_matrix + cnt_de_row - row_offset;
        end
        default:    img_addr_comb = 9'b0;
    endcase
end


//*****KERNEL*****
//web_sram_kernel
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                              web_sram_kernel <= 1'b1;
    else if(write_k_flag && image_finish)   web_sram_kernel <= 1'b0;
    else                                    web_sram_kernel <= 1'b1;
end
//ker_addr
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  ker_addr <= 7'd0;
    else        ker_addr <= ker_addr_comb;
end
always @(*) begin
    case (curr_state)
        IDLE:   ker_addr_comb = 7'd0;
        INPUT: begin
            if(!web_sram_kernel && ker_addr==7'd79) ker_addr_comb = 7'b0;
            else if(!web_sram_kernel)               ker_addr_comb = ker_addr + 'd1;
            else                                    ker_addr_comb = ker_addr;
        end
        INPUT2: begin
            ker_addr_comb = ptr_kernel;
        end
        CONV, DECONV: begin
            ker_addr_comb = ptr_kernel + row_offset;
        end
        default: ker_addr_comb = 7'd0;
    endcase
end


//find matrix's first row
assign ptr_matrix = i_matrix_idx << (matrix_size_reg+'d3);
assign ptr_kernel = k_matrix_idx * 5;

//row_offset
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  row_offset <= 3'd0;
    else begin
        if(next_state==INPUT2)                          row_offset <= 3'd0;
        else if(curr_state==DECONV && (cnt_state=='d4)) row_offset <= 3'd0;
        else if(row_offset==3'd4)                       row_offset <= 3'd0;
        else                                            row_offset <= row_offset + 3'd1;
    end
end

//=================================
//		CONV
//=================================

//cnt_maxpool_offset
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_maxpool_offset <= 2'd0;
    else begin

        if(curr_state==CONV && row_offset==3'd4)    cnt_maxpool_offset <= cnt_maxpool_offset + 2'd1;
        else if(curr_state==CONV)                   cnt_maxpool_offset <= cnt_maxpool_offset;
        else                                        cnt_maxpool_offset <= 2'd0;
    end
end
//maxpool_offset
always @(*) begin
    case(cnt_maxpool_offset)
        2'd0:       maxpool_offset = 1'd0;
        2'd1:       maxpool_offset = 1'd1;
        2'd2:       maxpool_offset = 1'd0;
        2'd3:       maxpool_offset = 1'd1;
        default:    maxpool_offset = 1'd0;
    endcase
end

//ptr_col
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  ptr_col <= 5'd0;
    else if(curr_state==IDLE)   ptr_col <= 5'd0;
    else                        ptr_col <= ptr_col_comb;
end
always @(*) begin
    if(cnt_maxpool_offset==2'd3 && row_offset==3'd4) begin
        case(matrix_size_reg)
            2'd0: begin
                if(ptr_col==5'd2)   ptr_col_comb = 5'd0;
                else                ptr_col_comb = ptr_col + 5'd2;
            end
            2'd1: begin
                if(ptr_col==5'd10)  ptr_col_comb = 5'd0;
                else                ptr_col_comb = ptr_col + 5'd2;
            end
            2'd2: begin
                if(ptr_col==5'd26)  ptr_col_comb = 5'd0;
                else                ptr_col_comb = ptr_col + 5'd2;
            end
            default: begin
                ptr_col_comb = 5'd0;
            end
        endcase
    end
    else begin
        ptr_col_comb = ptr_col;
    end
end

//ptr_row
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  ptr_row <= 5'd0;
    else if(curr_state==IDLE)   ptr_row <= 5'd0;
    else                        ptr_row <= ptr_row_comb;
end
always @(*) begin
    if(cnt_maxpool_offset==2'd3 && row_offset==3'd4) begin
        case(matrix_size_reg)
            2'd0: begin
                if(ptr_col==5'd2)   ptr_row_comb = ptr_row + 5'd2;
                else                ptr_row_comb = ptr_row;
            end
            2'd1: begin
                if(ptr_col==5'd10)  ptr_row_comb = ptr_row + 5'd2;
                else                ptr_row_comb = ptr_row;
            end
            2'd2: begin
                if(ptr_col==5'd26)  ptr_row_comb = ptr_row + 5'd2;
                else                ptr_row_comb = ptr_row;
            end
            default: begin
                ptr_row_comb = 5'd0;
            end
        endcase
    end
    else begin
        ptr_row_comb = ptr_row;
    end
end

//=================================
//		DECONV
//=================================

//img_pad
always @(*) begin
    for(i=0;i<4;i=i+1) begin
        img_pad[i] = 8'd0;
        img_pad[i+36] = 8'd0;
    end
    for(j=0;j<32;j=j+1) begin
        img_pad[j+4] = DO_Image_reg[j];
    end
end

//cnt_de_20
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                                      cnt_de_20 <= 5'd0;
    else if(cnt_de_20==5'd19)                       cnt_de_20 <= 5'd0;
    else if(next_state==DECONV || next_state==CONV) cnt_de_20 <= cnt_de_20 + 5'd1;
    else                                            cnt_de_20 <= 5'd0;
end

//stop_flag
always @(*) begin
    if(cnt_state<'d4)                               stop_flag = 1'b0;
    else if(cnt_state!='d31)                        stop_flag = 1'b1;
    else if(cnt_de_20<5'd14 || cnt_de_20==5'd19)    stop_flag = 1'b1;
    else                                            stop_flag = 1'b0;
end

//cnt_de_col
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_de_col <= 6'd0;
    else        cnt_de_col <= cnt_de_col_comb;
end
always @(*) begin
    if(curr_state==DECONV) begin
        if(row_offset==3'd4 && ~stop_flag) begin
            case(matrix_size_reg)
                2'd0: begin
                    if(cnt_de_col==6'd11)   cnt_de_col_comb = 6'd0;
                    else                    cnt_de_col_comb = cnt_de_col + 6'd1;
                end
                2'd1: begin
                    if(cnt_de_col==6'd19)   cnt_de_col_comb = 6'd0;
                    else                    cnt_de_col_comb = cnt_de_col + 6'd1;
                end
                2'd2: begin
                    if(cnt_de_col==6'd35)   cnt_de_col_comb = 6'd0;
                    else                    cnt_de_col_comb = cnt_de_col + 6'd1;
                end
                default: begin
                    cnt_de_col_comb = 6'd0;
                end
            endcase
        end
        else begin
            cnt_de_col_comb = cnt_de_col;
        end
    end
    else begin
        cnt_de_col_comb = 6'd0;
    end
end
//cnt_de_row
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  cnt_de_row <= 6'd0;
    else if(curr_state==IDLE)   cnt_de_row <= 6'd0;
    else                        cnt_de_row <= cnt_de_row_comb;
end
always @(*) begin
    if(curr_state==DECONV && row_offset==3'd4 && ~stop_flag) begin
        case(matrix_size_reg)
            2'd0: begin
                if(cnt_de_col==6'd11)   cnt_de_row_comb = cnt_de_row + 6'd1;
                else                    cnt_de_row_comb = cnt_de_row;
            end
            2'd1: begin
                if(cnt_de_col==6'd19)   cnt_de_row_comb = cnt_de_row + 6'd1;
                else                    cnt_de_row_comb = cnt_de_row;
            end
            2'd2: begin
                if(cnt_de_col==6'd35)   cnt_de_row_comb = cnt_de_row + 6'd1;
                else                    cnt_de_row_comb = cnt_de_row;
            end
            default: begin
                cnt_de_row_comb = 6'd0;
            end
        endcase
    end
    else begin
        cnt_de_row_comb = cnt_de_row;
    end
end

//=================================
//		DELAY_ELEMENT
//=================================

//ptr_col_d2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ptr_col_d1 <= 5'd0;
        ptr_col_d2 <= 5'd0;
    end
    else begin
        ptr_col_d1 <= ptr_col;
        ptr_col_d2 <= ptr_col_d1;
    end
end
//maxpool_offset_d2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        maxpool_offset_d1 <= 1'd0;
        maxpool_offset_d2 <= 1'd0;
    end
    else begin
        maxpool_offset_d1 <= maxpool_offset;
        maxpool_offset_d2 <= maxpool_offset_d1;
    end
end
//cnt_de_col_d2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_de_col_d1 <= 6'd0;
        cnt_de_col_d2 <= 6'd0;
        cnt_de_col_d3 <= 6'd0;
    end
    else begin
        cnt_de_col_d1 <= cnt_de_col;
        cnt_de_col_d2 <= cnt_de_col_d1;
        cnt_de_col_d3 <= cnt_de_col_d2;
    end
end
//cnt_de_row_d2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_de_row_d1 <= 6'd0;
        cnt_de_row_d2 <= 6'd0;
        cnt_de_row_d3 <= 6'd0;
    end
    else begin
        cnt_de_row_d1 <= cnt_de_row;
        cnt_de_row_d2 <= cnt_de_row_d1;
        cnt_de_row_d3 <= cnt_de_row_d2;
    end
end
//row_offset_d2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        row_offset_d1 <= 3'd0;
        row_offset_d2 <= 3'd0;
        row_offset_d3 <= 3'd0;
    end
    else begin
        row_offset_d1 <= row_offset;
        row_offset_d2 <= row_offset_d1;
        row_offset_d3 <= row_offset_d2;
    end
end

//=================================
//		MULT
//=================================

//mult_a, mult_b
always @(*) begin
    if(curr_state==CONV) begin
        for(i=0;i<5;i=i+1) begin
            mult_a[i] = DO_Image_reg[i];
            mult_b[i] = DO_Kernel_reg[i];
        end
    end
    else if(curr_state==DECONV) begin
        for(i=0;i<5;i=i+1) begin
            mult_a[4-i] = img_pad[cnt_de_col_d3+i];
            mult_b[i] = DO_Kernel_reg[i];
        end
        //mask the image (upper and lower bound)
        if(cnt_de_row_d3==6'd0 && row_offset_d3>3'd0) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if(cnt_de_row_d3==6'd1 && row_offset_d3>3'd1) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if(cnt_de_row_d3==6'd2 && row_offset_d3>3'd2) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if(cnt_de_row_d3==6'd3 && row_offset_d3>3'd3) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if((matrix_size_reg==2'd0 && cnt_de_row_d3==6'd8 && row_offset_d3<3'd1)
                || (matrix_size_reg==2'd1 && cnt_de_row_d3==6'd16 && row_offset_d3<3'd1)
                || (matrix_size_reg==2'd2 && cnt_de_row_d3==6'd32 && row_offset_d3<3'd1)) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if((matrix_size_reg==2'd0 && cnt_de_row_d3==6'd9 && row_offset_d3<3'd2)
                || (matrix_size_reg==2'd1 && cnt_de_row_d3==6'd17 && row_offset_d3<3'd2)
                || (matrix_size_reg==2'd2 && cnt_de_row_d3==6'd33 && row_offset_d3<3'd2)) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if((matrix_size_reg==2'd0 && cnt_de_row_d3==6'd10 && row_offset_d3<3'd3)
                || (matrix_size_reg==2'd1 && cnt_de_row_d3==6'd18 && row_offset_d3<3'd3)
                || (matrix_size_reg==2'd2 && cnt_de_row_d3==6'd34 && row_offset_d3<3'd3)) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
        else if((matrix_size_reg==2'd0 && cnt_de_row_d3==6'd11 && row_offset_d3<3'd4)
                || (matrix_size_reg==2'd1 && cnt_de_row_d3==6'd19 && row_offset_d3<3'd4)
                || (matrix_size_reg==2'd2 && cnt_de_row_d3==6'd35 && row_offset_d3<3'd4)) begin
            for(i=0;i<5;i=i+1) begin
                mult_a[i] = 8'd0;
            end
        end
    end
    else begin
        for(j=0;j<5;j=j+1) begin
            mult_a[j] = 8'd0;
            mult_b[j] = 8'd0;
        end
    end
end

genvar mulz_idx;
generate
    for(mulz_idx=0; mulz_idx<5; mulz_idx=mulz_idx+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)  mult_z[mulz_idx] <= 16'd0;
            else        mult_z[mulz_idx] <= mult_a[mulz_idx] * mult_b[mulz_idx];
        end
    end
endgenerate

//sum
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  sum <= 20'd0;
    else        sum <= sum_comb;
end
always @(*) begin
    sum_comb = mult_z[0] + mult_z[1] + mult_z[2] + mult_z[3] + mult_z[4] + pre_sum;
end
//pre_sum
always @(*) begin
    if(row_offset==3'd4)    pre_sum = 20'd0;
    else                    pre_sum = sum;
end
//largest
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  largest <= 20'd0;
    else        largest <= largest_comb;
end
always @(*) begin
    if(curr_state==CONV) begin
        if(row_offset==3'd3 && cnt_maxpool_offset==2'd1)    largest_comb = sum_comb;
        else if(row_offset==3'd3 && sum_comb>largest)       largest_comb = sum_comb;
        else                                                largest_comb = largest;
    end
    else begin //DECONV
        largest_comb = sum_comb;
        if(cnt_de_20=='d4)  largest_comb = sum_comb;
        else                largest_comb = largest;
    end
end
//conv_result_reg
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  conv_result_reg <= 20'd0;
    else        conv_result_reg <= conv_result_comb;
end
always @(*) begin
    if(!cnt20)  conv_result_comb = largest_comb;
    else        conv_result_comb = conv_result_reg;
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
            if(in_valid)        next_state = INPUT;
            else if(in_valid2)  next_state = INPUT2;
            else                next_state = IDLE;
        end
        INPUT: begin
            if(!in_valid)   next_state = IDLE;
            else            next_state = INPUT;
        end
        INPUT2: begin
            if(!in_valid2 && !mode_reg)     next_state = CONV;
            else if(!in_valid2 && mode_reg) next_state = DECONV;
            else                            next_state = INPUT2;
        end
        CONV: begin
            if(cnt20==5'd19) begin
                case(matrix_size_reg)
                    2'd0:   if(cnt_out==11'd3)      next_state = IDLE;
                            else                    next_state = CONV;
                    2'd1:   if(cnt_out==11'd35)     next_state = IDLE;
                            else                    next_state = CONV;
                    2'd2:   if(cnt_out==11'd195)    next_state = IDLE;
                            else                    next_state = CONV;
                    default:                        next_state = CONV;
                endcase
            end
            else                                    next_state = CONV;
        end
        DECONV: begin
            if(cnt20==5'd19) begin
                case(matrix_size_reg)
                    2'd0:   if(cnt_out==11'd143)    next_state = IDLE;
                            else                    next_state = DECONV;
                    2'd1:   if(cnt_out==11'd399)    next_state = IDLE;
                            else                    next_state = DECONV;
                    2'd2:   if(cnt_out==11'd1295)   next_state = IDLE;
                            else                    next_state = DECONV;
                    default:                        next_state = DECONV;
                endcase
            end
            else                                    next_state = DECONV;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_state <= 5'd0;
    else if(next_state!=curr_state) cnt_state <= 5'd0;
    else if(cnt_state==5'd31)       cnt_state <= cnt_state;
    else                            cnt_state <= cnt_state + 5'd1;
end

//=================================
//		Store SRAM_DO
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
    if(next_state==CONV || next_state==DECONV) begin
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
        for(i=0;i<32;i=i+1) begin
            DO_Image_reg[i] <= 8'b0;
        end
    end
    else begin
        for(j=0;j<32;j=j+1) begin
            DO_Image_reg[j] <= DO_Image_comb[j];
        end
    end
end
always@(*) begin
    if(curr_state==CONV) begin
        DO_Image_comb[0] = DO_sram_img[ptr_col_d2+maxpool_offset_d2];
        DO_Image_comb[1] = DO_sram_img[ptr_col_d2+maxpool_offset_d2+'d1];
        DO_Image_comb[2] = DO_sram_img[ptr_col_d2+maxpool_offset_d2+'d2];
        DO_Image_comb[3] = DO_sram_img[ptr_col_d2+maxpool_offset_d2+'d3];
        DO_Image_comb[4] = DO_sram_img[ptr_col_d2+maxpool_offset_d2+'d4];
        for(i=5;i<32;i=i+1) begin
            DO_Image_comb[i] = 'd0;
        end
    end
    else if(curr_state==DECONV) begin
        case(matrix_size_reg)
            2'd0: begin
                for(k=0;k<8;k=k+1) begin
                    DO_Image_comb[k] = DO_sram_img[k];
                end
                for(k=8;k<32;k=k+1) begin
                    DO_Image_comb[k] = 'd0;
                end
            end
            2'd1: begin
                for(k=0;k<16;k=k+1) begin
                    DO_Image_comb[k] = DO_sram_img[k];
                end
                for(k=16;k<32;k=k+1) begin
                    DO_Image_comb[k] = 'd0;
                end
            end
            2'd2: begin
                for(k=0;k<32;k=k+1) begin
                    DO_Image_comb[k] = DO_sram_img[k];
                end
            end
            default: begin
                for(k=0;k<32;k=k+1) begin
                    DO_Image_comb[k] = 'd0;
                end
            end
        endcase
    end
    else begin
        for(j=0;j<32;j=j+1) begin
            DO_Image_comb[j] = 8'b0;
        end
    end
end

//=================================
//		Output
//=================================

//cnt20
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  cnt20 <= 5'd0;
    else if(cnt20==5'd19)       cnt20 <= 5'd0;
    else if(out_valid_comb)     cnt20 <= cnt20 + 5'd1;
    else                        cnt20 <= 5'd0;
end
//cnt_out
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  cnt_out <= 11'd0;
    else if(curr_state==IDLE)   cnt_out <= 11'd0;
    else if(cnt20==5'd19)       cnt_out <= cnt_out + 11'd1;
    else                        cnt_out <= cnt_out;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 1'b0;
    else        out_valid <= out_valid_comb;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_value <= 1'b0;
    else        out_value <= out_value_comb;
end

always@(*) begin
    out_valid_comb = 1'b0;
    out_value_comb = 1'b0;
    if(curr_state==CONV) begin
        if(cnt_state>=5'd22) begin
            out_valid_comb = 1'b1;
            out_value_comb = (!cnt20) ? conv_result_comb[0] : conv_result_reg[cnt20];
        end
    end
    else if(curr_state==DECONV) begin
        if(cnt_state>=5'd3) begin
            out_valid_comb = 1'b1;
            if(cnt_state<'d4)   out_value_comb = sum_comb[cnt20];
            else                out_value_comb = (!cnt20) ? sum_comb[0] : largest[cnt20];
        end
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
                            .DO63(DO_SRAM_IMG1[63]), .DI0(matrix_row[0]), .DI1(matrix_row[1]), .DI2(matrix_row[2]), .DI3(matrix_row[3]), .DI4(matrix_row[4]), .DI5(matrix_row[5]), .DI6(matrix_row[6]), .DI7(matrix_row[7]), .DI8(matrix_row[8]),
                            .DI9(matrix_row[9]), .DI10(matrix_row[10]), .DI11(matrix_row[11]), .DI12(matrix_row[12]), .DI13(matrix_row[13]), .DI14(matrix_row[14]), .DI15(matrix_row[15]), .DI16(matrix_row[16]), .DI17(matrix_row[17]),
                            .DI18(matrix_row[18]), .DI19(matrix_row[19]), .DI20(matrix_row[20]), .DI21(matrix_row[21]), .DI22(matrix_row[22]), .DI23(matrix_row[23]), .DI24(matrix_row[24]), .DI25(matrix_row[25]),
                            .DI26(matrix_row[26]), .DI27(matrix_row[27]), .DI28(matrix_row[28]), .DI29(matrix_row[29]), .DI30(matrix_row[30]), .DI31(matrix_row[31]), .DI32(matrix_row[32]), .DI33(matrix_row[33]),
                            .DI34(matrix_row[34]), .DI35(matrix_row[35]), .DI36(matrix_row[36]), .DI37(matrix_row[37]), .DI38(matrix_row[38]), .DI39(matrix_row[39]), .DI40(matrix_row[40]), .DI41(matrix_row[41]),
                            .DI42(matrix_row[42]), .DI43(matrix_row[43]), .DI44(matrix_row[44]), .DI45(matrix_row[45]), .DI46(matrix_row[46]), .DI47(matrix_row[47]), .DI48(matrix_row[48]), .DI49(matrix_row[49]),
                            .DI50(matrix_row[50]), .DI51(matrix_row[51]), .DI52(matrix_row[52]), .DI53(matrix_row[53]), .DI54(matrix_row[54]), .DI55(matrix_row[55]), .DI56(matrix_row[56]), .DI57(matrix_row[57]),
                            .DI58(matrix_row[58]), .DI59(matrix_row[59]), .DI60(matrix_row[60]), .DI61(matrix_row[61]), .DI62(matrix_row[62]), .DI63(matrix_row[63]), .CK(clk), .WEB(web_sram_img_1), .OE(1'b1), .CS(1'b1));


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
                            .DO63(DO_SRAM_IMG2[63]), .DI0(matrix_row[0]), .DI1(matrix_row[1]), .DI2(matrix_row[2]), .DI3(matrix_row[3]), .DI4(matrix_row[4]), .DI5(matrix_row[5]), .DI6(matrix_row[6]), .DI7(matrix_row[7]), .DI8(matrix_row[8]),
                            .DI9(matrix_row[9]), .DI10(matrix_row[10]), .DI11(matrix_row[11]), .DI12(matrix_row[12]), .DI13(matrix_row[13]), .DI14(matrix_row[14]), .DI15(matrix_row[15]), .DI16(matrix_row[16]), .DI17(matrix_row[17]),
                            .DI18(matrix_row[18]), .DI19(matrix_row[19]), .DI20(matrix_row[20]), .DI21(matrix_row[21]), .DI22(matrix_row[22]), .DI23(matrix_row[23]), .DI24(matrix_row[24]), .DI25(matrix_row[25]),
                            .DI26(matrix_row[26]), .DI27(matrix_row[27]), .DI28(matrix_row[28]), .DI29(matrix_row[29]), .DI30(matrix_row[30]), .DI31(matrix_row[31]), .DI32(matrix_row[32]), .DI33(matrix_row[33]),
                            .DI34(matrix_row[34]), .DI35(matrix_row[35]), .DI36(matrix_row[36]), .DI37(matrix_row[37]), .DI38(matrix_row[38]), .DI39(matrix_row[39]), .DI40(matrix_row[40]), .DI41(matrix_row[41]),
                            .DI42(matrix_row[42]), .DI43(matrix_row[43]), .DI44(matrix_row[44]), .DI45(matrix_row[45]), .DI46(matrix_row[46]), .DI47(matrix_row[47]), .DI48(matrix_row[48]), .DI49(matrix_row[49]),
                            .DI50(matrix_row[50]), .DI51(matrix_row[51]), .DI52(matrix_row[52]), .DI53(matrix_row[53]), .DI54(matrix_row[54]), .DI55(matrix_row[55]), .DI56(matrix_row[56]), .DI57(matrix_row[57]),
                            .DI58(matrix_row[58]), .DI59(matrix_row[59]), .DI60(matrix_row[60]), .DI61(matrix_row[61]), .DI62(matrix_row[62]), .DI63(matrix_row[63]), .CK(clk), .WEB(web_sram_img_2), .OE(1'b1), .CS(1'b1));

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
                            .DO63(DO_SRAM_IMG3[63]), .DI0(matrix_row[0]), .DI1(matrix_row[1]), .DI2(matrix_row[2]), .DI3(matrix_row[3]), .DI4(matrix_row[4]), .DI5(matrix_row[5]), .DI6(matrix_row[6]), .DI7(matrix_row[7]), .DI8(matrix_row[8]),
                            .DI9(matrix_row[9]), .DI10(matrix_row[10]), .DI11(matrix_row[11]), .DI12(matrix_row[12]), .DI13(matrix_row[13]), .DI14(matrix_row[14]), .DI15(matrix_row[15]), .DI16(matrix_row[16]), .DI17(matrix_row[17]),
                            .DI18(matrix_row[18]), .DI19(matrix_row[19]), .DI20(matrix_row[20]), .DI21(matrix_row[21]), .DI22(matrix_row[22]), .DI23(matrix_row[23]), .DI24(matrix_row[24]), .DI25(matrix_row[25]),
                            .DI26(matrix_row[26]), .DI27(matrix_row[27]), .DI28(matrix_row[28]), .DI29(matrix_row[29]), .DI30(matrix_row[30]), .DI31(matrix_row[31]), .DI32(matrix_row[32]), .DI33(matrix_row[33]),
                            .DI34(matrix_row[34]), .DI35(matrix_row[35]), .DI36(matrix_row[36]), .DI37(matrix_row[37]), .DI38(matrix_row[38]), .DI39(matrix_row[39]), .DI40(matrix_row[40]), .DI41(matrix_row[41]),
                            .DI42(matrix_row[42]), .DI43(matrix_row[43]), .DI44(matrix_row[44]), .DI45(matrix_row[45]), .DI46(matrix_row[46]), .DI47(matrix_row[47]), .DI48(matrix_row[48]), .DI49(matrix_row[49]),
                            .DI50(matrix_row[50]), .DI51(matrix_row[51]), .DI52(matrix_row[52]), .DI53(matrix_row[53]), .DI54(matrix_row[54]), .DI55(matrix_row[55]), .DI56(matrix_row[56]), .DI57(matrix_row[57]),
                            .DI58(matrix_row[58]), .DI59(matrix_row[59]), .DI60(matrix_row[60]), .DI61(matrix_row[61]), .DI62(matrix_row[62]), .DI63(matrix_row[63]), .CK(clk), .WEB(web_sram_img_3), .OE(1'b1), .CS(1'b1));

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
                            .DO63(DO_SRAM_IMG4[63]), .DI0(matrix_row[0]), .DI1(matrix_row[1]), .DI2(matrix_row[2]), .DI3(matrix_row[3]), .DI4(matrix_row[4]), .DI5(matrix_row[5]), .DI6(matrix_row[6]), .DI7(matrix_row[7]), .DI8(matrix_row[8]),
                            .DI9(matrix_row[9]), .DI10(matrix_row[10]), .DI11(matrix_row[11]), .DI12(matrix_row[12]), .DI13(matrix_row[13]), .DI14(matrix_row[14]), .DI15(matrix_row[15]), .DI16(matrix_row[16]), .DI17(matrix_row[17]),
                            .DI18(matrix_row[18]), .DI19(matrix_row[19]), .DI20(matrix_row[20]), .DI21(matrix_row[21]), .DI22(matrix_row[22]), .DI23(matrix_row[23]), .DI24(matrix_row[24]), .DI25(matrix_row[25]),
                            .DI26(matrix_row[26]), .DI27(matrix_row[27]), .DI28(matrix_row[28]), .DI29(matrix_row[29]), .DI30(matrix_row[30]), .DI31(matrix_row[31]), .DI32(matrix_row[32]), .DI33(matrix_row[33]),
                            .DI34(matrix_row[34]), .DI35(matrix_row[35]), .DI36(matrix_row[36]), .DI37(matrix_row[37]), .DI38(matrix_row[38]), .DI39(matrix_row[39]), .DI40(matrix_row[40]), .DI41(matrix_row[41]),
                            .DI42(matrix_row[42]), .DI43(matrix_row[43]), .DI44(matrix_row[44]), .DI45(matrix_row[45]), .DI46(matrix_row[46]), .DI47(matrix_row[47]), .DI48(matrix_row[48]), .DI49(matrix_row[49]),
                            .DI50(matrix_row[50]), .DI51(matrix_row[51]), .DI52(matrix_row[52]), .DI53(matrix_row[53]), .DI54(matrix_row[54]), .DI55(matrix_row[55]), .DI56(matrix_row[56]), .DI57(matrix_row[57]),
                            .DI58(matrix_row[58]), .DI59(matrix_row[59]), .DI60(matrix_row[60]), .DI61(matrix_row[61]), .DI62(matrix_row[62]), .DI63(matrix_row[63]), .CK(clk), .WEB(web_sram_img_4), .OE(1'b1), .CS(1'b1));


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
                            .DI0(matrix_row[0]), .DI1(matrix_row[1]), .DI2(matrix_row[2]), .DI3(matrix_row[3]), .DI4(matrix_row[4]), .DI5(matrix_row[5]), .DI6(matrix_row[6]), .DI7(matrix_row[7]), .DI8(matrix_row[8]), .DI9(matrix_row[9]),
                            .DI10(matrix_row[10]), .DI11(matrix_row[11]), .DI12(matrix_row[12]), .DI13(matrix_row[13]), .DI14(matrix_row[14]), .DI15(matrix_row[15]), .DI16(matrix_row[16]), .DI17(matrix_row[17]),
                            .DI18(matrix_row[18]), .DI19(matrix_row[19]), .DI20(matrix_row[20]), .DI21(matrix_row[21]), .DI22(matrix_row[22]), .DI23(matrix_row[23]), .DI24(matrix_row[24]), .DI25(matrix_row[25]),
                            .DI26(matrix_row[26]), .DI27(matrix_row[27]), .DI28(matrix_row[28]), .DI29(matrix_row[29]), .DI30(matrix_row[30]), .DI31(matrix_row[31]), .DI32(matrix_row[32]), .DI33(matrix_row[33]),
                            .DI34(matrix_row[34]), .DI35(matrix_row[35]), .DI36(matrix_row[36]), .DI37(matrix_row[37]), .DI38(matrix_row[38]), .DI39(matrix_row[39]), .CK(clk), .WEB(web_sram_kernel), .OE(1'b1), .CS(1'b1));



endmodule