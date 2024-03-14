module CC(
    //Input Port
    clk,
    rst_n,
	in_valid,
	mode,
    xi,
    yi,

    //Output Port
    out_valid,
	xo,
	yo
    );

input               clk, rst_n, in_valid;
input       [1:0]   mode;
input       [7:0]   xi, yi;  

output reg          out_valid;
output reg  [7:0]   xo, yo;
//==============================================//
//             Parameter and Integer            //
//==============================================//

parameter IDLE  = 3'd0;
parameter INPUT = 3'd1;
parameter CAL1  = 3'd2;
parameter CAL2  = 3'd3;
parameter OUT   = 3'd4;

integer i, j;
genvar k;

//==============================================//
//            FSM State Declaration             //
//==============================================//

reg [2:0] curr_state, next_state;
reg       calc_finish;

//==============================================//
//                 reg declaration              //
//==============================================//

//*input block
reg [1:0] input_cnt;
reg signed [8:0] xin [0:3];
reg signed [8:0] yin [0:3];
reg signed [7:0] xin_reg [0:3];
reg signed [7:0] yin_reg [0:3];
reg signed [5:0] xin_reg_mode1 [0:3];
reg signed [5:0] yin_reg_mode1 [0:3];
reg        [1:0] mode_reg, mode_comb;

//*cal1
reg                swap;
reg  signed [7:0]  y1_choose_lv2, y2_choose_lv2, x_small, y_choose;
reg         [7:0]  x_ans_part_lv1;
reg         [15:0] numerator;
reg         [7:0]  denominator;

reg  signed [7:0]  x1_choose, x2_choose, y1_choose, y2_choose;
reg  signed [7:0]  y_cal, y_cal_comb;
reg  signed [7:0]  x_ans;

reg  signed [7:0]  xo_mode0, yo_mode0, xo_mode0_comb, yo_mode0_comb;

//*calc2
wire signed [6:0]  eq_a, eq_b;
wire signed [12:0] eq_c;
wire signed [6:0]  ra, rb;
wire        [12:0] radius_square;

wire signed [12:0] equation_dist;
wire        [12:0] normal_vector_square;

wire        [23:0] equation_dist_square;
wire        [23:0] r_square_nv_square;

reg         [1:0]  yo_mode1;

//*calc3
wire signed [18:0] op_2, op_3;
wire signed [19:0] twice_area;
wire signed [18:0] area;
reg         [18:0] area_final;

//*output block
reg       out_valid_comb;
reg [7:0] xo_comb, yo_comb;

//==============================================//
//             Current State Block              //
//==============================================//

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  curr_state <= IDLE;
    else        curr_state <= next_state;
end

//==============================================//
//              Next State Block                //
//==============================================//

always@(*) begin
    case(curr_state)
        IDLE: begin
            if(in_valid)    next_state = INPUT;
            else            next_state = IDLE;
        end
        INPUT: begin
            if(in_valid)        next_state = INPUT;
            else if(mode_reg)   next_state = OUT;
            else                next_state = CAL1;
        end
        CAL1: begin
            if(xo_mode0 < x_ans-1)  next_state = CAL1;
            else                    next_state = CAL2;
        end
        CAL2: begin
            if(calc_finish) next_state = IDLE;
            else            next_state = CAL1;
        end
        OUT: begin
            next_state = IDLE;
        end
        default: begin
            next_state = curr_state;
        end
    endcase
end

always@(*) begin
    calc_finish = 0;
    if(mode_reg && next_state == OUT)                       calc_finish = 1;
    if(yo_mode0 == yin_reg[1] && xo_mode0 == xin_reg[1])    calc_finish = 1;
end

//==============================================//
//                  Input Block                 //
//==============================================//

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        input_cnt <= 2'd0;
    end
    else begin
        if(in_valid)    input_cnt <= input_cnt + 'd1;
        else            input_cnt <= 2'd0;
    end
end

//*xi
genvar xin_index;
generate
    for(xin_index=0; xin_index<4; xin_index = xin_index+1) begin
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                xin[xin_index] <= 9'b0;
            end
            else begin
                if(xin_index==input_cnt[1:0] && in_valid) begin
                    if(mode==2'd2 && input_cnt) xin[xin_index] <= $signed(xi) - xin[0];
                    else                        xin[xin_index] <= {xi[7], xi[7:0]};
                end
                else    xin[xin_index] <= xin[xin_index];
            end
        end
    end
endgenerate

//*yi
genvar yin_index;
generate
    for(yin_index=0; yin_index<4; yin_index = yin_index+1) begin
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                yin[yin_index] <= 9'b0;
            end
            else begin
                if(yin_index==input_cnt[1:0] && in_valid) begin
                    if(mode==2'd2 && input_cnt) yin[yin_index] <= $signed(yi) - yin[0];
                    else                        yin[yin_index] <= {yi[7], yi[7:0]};
                end
                else    yin[yin_index] <= yin[yin_index];
            end
        end
    end
endgenerate


generate
    for(k=0;k<4;k=k+1) begin: xin_yin_change_bit
        always@(*) begin
            xin_reg[k] = xin[k][7:0];
            yin_reg[k] = yin[k][7:0];
            xin_reg_mode1[k] = xin[k][5:0];
            yin_reg_mode1[k] = yin[k][5:0];
        end
    end
endgenerate

//*mode
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)          mode_reg <= 2'b0;
    else                mode_reg <= mode_comb;
end
always@(*) begin
    if(in_valid)    mode_comb = mode;
    else            mode_comb = mode_reg;
end

//==============================================//
//              Calculation Block1              //
//==============================================//

always@(*) begin
    if(curr_state == INPUT || curr_state == CAL1) begin
        x1_choose = xin_reg[3];
        y1_choose = yin_reg[3];
        x2_choose = xin_reg[1];
        y2_choose = yin_reg[1];
    end
    else begin
        x1_choose = xin_reg[2];
        y1_choose = yin_reg[2];
        x2_choose = xin_reg[0];
        y2_choose = yin_reg[0];
    end
end

always@(*) begin
    swap = (x2_choose < x1_choose)? 1:0;
    x_small = swap ? x2_choose : x1_choose;
    y_choose = swap ? y2_choose : y1_choose;
    numerator = ((x2_choose-x1_choose)*(y_cal-y_choose));
    denominator = y2_choose - y1_choose;
    x_ans_part_lv1 = numerator/denominator;
    x_ans = x_small + x_ans_part_lv1;
end

//------------------------------------------------------------------------------------------------------------------//

always@(*) begin
    if(curr_state == INPUT) y_cal_comb = yin_reg[2];
    else if(next_state == CAL2) y_cal_comb = y_cal + 1;
    else y_cal_comb = y_cal;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  y_cal <= 0;
    else        y_cal <= y_cal_comb;
end

//*output
always@(*) begin
    if(curr_state == INPUT) begin
        xo_mode0_comb = xin_reg[2];
        yo_mode0_comb = yin_reg[2];
    end
    else if(curr_state == CAL1) begin
        xo_mode0_comb = xo_mode0 + 1;
        yo_mode0_comb = yo_mode0;
    end
    else begin
        xo_mode0_comb = x_ans;
        yo_mode0_comb = yo_mode0 + 1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  xo_mode0 <= 0;
    else        xo_mode0 <= xo_mode0_comb;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  yo_mode0 <= 0;
    else        yo_mode0 <= yo_mode0_comb;
end

//==============================================//
//              Calculation Block2              //
//==============================================//
//*the input coordinates here will be limited to 6 bits
//TODO: minimize bits

assign eq_a = yin_reg_mode1[1] - yin_reg_mode1[0];
assign eq_b = xin_reg_mode1[0] - xin_reg_mode1[1];
assign eq_c = xin_reg_mode1[1]*yin_reg_mode1[0] - xin_reg_mode1[0]*yin_reg_mode1[1]; //x2y1 - x1y2 //6x6 signed
assign equation_dist = eq_a*xin_reg_mode1[2] + eq_b*yin_reg_mode1[2] + eq_c; //ax+by+c //7x6 signed
assign equation_dist_square = equation_dist*equation_dist;

assign ra = xin_reg_mode1[3] - xin_reg_mode1[2];
assign rb = yin_reg_mode1[3] - yin_reg_mode1[2];
assign radius_square = ra*ra + rb*rb; //7x7 signed

assign normal_vector_square = eq_a*eq_a + eq_b*eq_b; //eq_a^2 + eq_b^2 

assign r_square_nv_square = radius_square*normal_vector_square;

always@(*) begin
    if(equation_dist_square > r_square_nv_square)       yo_mode1 = 2'd0; //non-intersecting 
    else if(equation_dist_square == r_square_nv_square) yo_mode1 = 2'd2; //tangent 
    else                                                yo_mode1 = 2'd1; //intersecting 
end

//==============================================//
//              Calculation Block3              //
//==============================================//

assign op_2 = xin[1]*yin[2] - xin[2]*yin[1]; //x1y2 - x2y1
assign op_3 = xin[2]*yin[3] - xin[3]*yin[2]; //x1y2 - x2y1

assign twice_area = op_2 + op_3; 
assign area = twice_area / 2;

always@(*) begin
    if(area[18])    area_final = ~area + 1;
    else            area_final = area;
end


//==============================================//
//                Output Block                  //
//==============================================//

always@(*) begin
    out_valid_comb = 0;
    xo_comb = 0;
    yo_comb = 0;
    if(mode_reg) begin
        if(calc_finish) begin
            out_valid_comb = 1;
            if(mode_reg[0]) begin //mode 1 
                xo_comb = 0;
                yo_comb = yo_mode1;
            end
            else begin //mode 2 
                xo_comb = area_final[15:8];
                yo_comb = area_final[7:0];
            end
        end
    end
    else begin //mode 0 
        if(input_cnt == 0 && curr_state) begin
            if(!calc_finish) begin
                out_valid_comb = 1;
                xo_comb = xo_mode0_comb;
                yo_comb = yo_mode0_comb;
            end
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  out_valid <= 0;
    else        out_valid <= out_valid_comb;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  xo <= 0;
    else        xo <= xo_comb;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  yo <= 0;
    else        yo <= yo_comb;
end

endmodule 
