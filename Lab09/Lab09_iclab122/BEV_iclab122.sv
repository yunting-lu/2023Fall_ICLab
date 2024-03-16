module BEV(input clk, INF.BEV_inf inf);
import usertype::*;
// This file contains the definition of several state machines used in the BEV (Beverage) System RTL design.
// The state machines are defined using SystemVerilog enumerated types.
// The state machines are:
// - state_t: used to represent the overall state of the BEV system
//
// Each enumerated type defines a set of named states that the corresponding process can be in.

//==================================
//  logics
//==================================

typedef struct packed {
    ING black_tea;
    ING green_tea;
    ING milk;
    ING pineapple_juice;
} Ingredient;

typedef enum logic [2:0]{
    IDLE,
    MAKE_DRINK,
    SUPPLY,
    CHECK_DATE,
    COMPARE0,
    COMPARE,
    OUTPUT
} state_t;

// REGISTERS
state_t state, nstate;

logic ing_finish_supply, ing_finish_supply_comb;
logic read_dram_finish, read_dram_finish_comb;

//INPUT
Action in_action;
Order_Info in_bev_info;
Date in_date;
Barrel_No in_box_num;
Bev_Bal dram_bev;
Ingredient in_ing;
logic [1:0] cnt_ing;

//ERR
Error_Msg er_state;
logic today_bigger_than_expire, today_bigger_than_expire_comb;
logic [12:0] left_black, left_green, left_milk, left_pine;
logic ing_insufficient, ing_insufficient_comb;
logic [12:0] new_black, new_green, new_milk, new_pine;
logic [12:0] new_black_comb, new_green_comb, new_milk_comb, new_pine_comb;
logic ing_too_much, ing_too_much_comb;
Ingredient newtodram;

//DRAM
logic write_dram_flag, write_dram_flag_comb;
logic [63:0] C_data_writeback;
logic busy, busy_comb;
logic input_ready, input_ready_comb;
logic read_dram_flag;
logic read_busy, read_busy_comb;

//VOLUME
logic [9:0] need_black, need_green, need_milk, need_pine;
logic [9:0] need_black_reg, need_green_reg, need_milk_reg, need_pine_reg;

//==================================
//  OUTPUT CTR
//==================================
//-------------------
//  USER port
//-------------------

//out_valid
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)          inf.out_valid <= 1'b0;
    else if(nstate==OUTPUT) inf.out_valid <= 1'b1; //
    else                    inf.out_valid <= 1'b0;
end
//err_msg //2
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)          inf.err_msg <= 2'b0;
    else                    inf.err_msg <= er_state;
    //else if(nstate==OUTPUT) inf.err_msg <= er_state; //
    //else                    inf.err_msg <= 2'b0;
end
//complete
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                              inf.complete <= 1'b0;
    //else if(er_state==No_Err)                   inf.complete <= 1'b1;
    //else                                        inf.complete <= 1'b0;
    else if(nstate==OUTPUT && er_state==No_Err) inf.complete <= 1'b1; //
    else                                        inf.complete <= 1'b0;
end

//-------------------
//  Bridge port
//-------------------

//C_in_valid
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)              inf.C_in_valid <= 1'b0;
    else if(read_dram_flag)     inf.C_in_valid <= 1'b1; //read
    else if(write_dram_flag)    inf.C_in_valid <= 1'b1; //write
    else                        inf.C_in_valid <= 1'b0;
end
//C_r_wb
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)              inf.C_r_wb <= 1'b0;
    else if(read_dram_flag)     inf.C_r_wb <= 1'b1; //read
    else                        inf.C_r_wb <= 1'b0;
end
//C_addr //8
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                              inf.C_addr <= 8'd0;
    else if(read_dram_flag & inf.box_no_valid)  inf.C_addr <= inf.D.d_box_no[0]; //read
    else if(read_dram_flag)                     inf.C_addr <= in_box_num; //read
    else if(write_dram_flag)                    inf.C_addr <= in_box_num; //write
    else                                        inf.C_addr <= 8'd0;
end
//C_data_w //64
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)              inf.C_data_w <= 64'd0;
    else if(write_dram_flag)    inf.C_data_w <= C_data_writeback;
    else                        inf.C_data_w <= 64'd0;
end

//==================================
//  FSM
//==================================

// STATE MACHINE
always_ff @( posedge clk or negedge inf.rst_n ) begin : TOP_FSM_SEQ
    if (!inf.rst_n) state <= IDLE;
    else            state <= nstate;
end

always_comb begin : TOP_FSM_COMB
    case(state)
        IDLE: begin
            if (inf.sel_action_valid) begin
                case(inf.D.d_act[0])
                    Make_drink:         nstate = MAKE_DRINK;
                    Supply:             nstate = SUPPLY;
                    Check_Valid_Date:   nstate = CHECK_DATE;
                    default:            nstate = IDLE;
                endcase
            end
            else                        nstate = IDLE;
        end
        MAKE_DRINK: if(inf.C_out_valid && read_busy)    nstate = COMPARE0;
                    else                                nstate = MAKE_DRINK;
        SUPPLY:     if(ing_finish_supply_comb & read_dram_finish_comb)  nstate = COMPARE0;
                    else                                                nstate = SUPPLY;
        CHECK_DATE: if(inf.C_out_valid && read_busy)    nstate = COMPARE0;
                    else                                nstate = CHECK_DATE;
        COMPARE0:   nstate = COMPARE;
        COMPARE:    nstate = OUTPUT;
        OUTPUT:     nstate = IDLE;
        default:    nstate = IDLE;
    endcase
end

//ing_finish_supply
always_ff @( posedge clk ) begin
    ing_finish_supply <= ing_finish_supply_comb;
end
always_comb begin
    if(cnt_ing==2'd3 && inf.box_sup_valid)  ing_finish_supply_comb = 1'b1;
    else if(state==IDLE)                    ing_finish_supply_comb = 1'b0;
    else                                    ing_finish_supply_comb = ing_finish_supply;
end

//read_dram_finish
always_ff @( posedge clk ) begin
    read_dram_finish <= read_dram_finish_comb;
end
always_comb begin
    if(inf.C_out_valid && read_busy)    read_dram_finish_comb = 1'b1;
    else if(state==IDLE)                read_dram_finish_comb = 1'b0;
    else                                read_dram_finish_comb = read_dram_finish;
end

//==================================
//  INPUT CTR
//==================================

//in_action
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                  in_action <= 2'b0;
    else if(inf.sel_action_valid)   in_action <= inf.D.d_act[0];
    else                            in_action <= in_action;
end
//in_beverage_type
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                  in_bev_info.Bev_Type_O <= 3'b0;
    else if(inf.type_valid)         in_bev_info.Bev_Type_O <= inf.D.d_type[0];
    else                            in_bev_info.Bev_Type_O <= in_bev_info.Bev_Type_O;
end
//in_beverage_size
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                  in_bev_info.Bev_Size_O <= 2'b0;
    else if(inf.size_valid)         in_bev_info.Bev_Size_O <= inf.D.d_size[0];
    else                            in_bev_info.Bev_Size_O <= in_bev_info.Bev_Size_O;
end
//in_date
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                  in_date <= 9'b0;
    else if(inf.date_valid)         in_date <= inf.D.d_date[0];
    else                            in_date <= in_date;
end
//in_box_num
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)                  in_box_num <= 8'b0;
    else if(inf.box_no_valid)       in_box_num <= inf.D.d_box_no[0];
    else                            in_box_num <= in_box_num;
end

//dram_bev
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)              dram_bev <= 'd0;
    else if(inf.C_out_valid) begin
        dram_bev.black_tea       <= inf.C_data_r[63:52];
        dram_bev.green_tea       <= inf.C_data_r[51:40];
        dram_bev.M               <= inf.C_data_r[35:32];
        dram_bev.milk            <= inf.C_data_r[31:20];
        dram_bev.pineapple_juice <= inf.C_data_r[19:8];
        dram_bev.D               <= inf.C_data_r[4:0];
    end
    else                dram_bev <= dram_bev;
end

//in_ing
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n) begin
        in_ing.black_tea        <= 12'd0;
        in_ing.green_tea        <= 12'd0;
        in_ing.milk             <= 12'd0;
        in_ing.pineapple_juice  <= 12'd0;
    end
    else if(inf.box_sup_valid) begin
        in_ing.black_tea        <= in_ing.green_tea;
        in_ing.green_tea        <= in_ing.milk;
        in_ing.milk             <= in_ing.pineapple_juice;
        in_ing.pineapple_juice  <= inf.D.d_ing[0];
    end
    else begin
        in_ing.black_tea        <= in_ing.black_tea;
        in_ing.green_tea        <= in_ing.green_tea;
        in_ing.milk             <= in_ing.milk;
        in_ing.pineapple_juice  <= in_ing.pineapple_juice;
    end
end

//cnt_ing
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)              cnt_ing <= 2'd0;
    else if(inf.box_sup_valid)  cnt_ing <= cnt_ing + 'd1;
    else                        cnt_ing <= cnt_ing;
end

//==================================
//  ERR CTR
//==================================

//today_bigger_than_expire
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)  today_bigger_than_expire <= 1'b0;
    else            today_bigger_than_expire <= today_bigger_than_expire_comb;
end
always_comb begin
    if(in_date > {dram_bev.M, dram_bev.D})  today_bigger_than_expire_comb = 1'b1;
    else                                    today_bigger_than_expire_comb = 1'b0;
end
//ing_insufficient
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)  ing_insufficient <= 1'b0;
    else            ing_insufficient <= ing_insufficient_comb;
end
always_comb begin
    left_black = dram_bev.black_tea - need_black_reg;
    left_green = dram_bev.green_tea - need_green_reg;
    left_milk  = dram_bev.milk - need_milk_reg;
    left_pine  = dram_bev.pineapple_juice - need_pine_reg;

    if(left_black[12] | left_green[12] | left_milk[12] | left_pine[12]) ing_insufficient_comb = 1'b1;
    else                                                                ing_insufficient_comb = 1'b0;
end
//ing_too_much
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if(~inf.rst_n)  ing_too_much <= 1'b0;
    else            ing_too_much <= ing_too_much_comb;
end
always_comb begin
    new_black = dram_bev.black_tea + in_ing.black_tea;
    new_green = dram_bev.green_tea + in_ing.green_tea;
    new_milk  = dram_bev.milk + in_ing.milk;
    new_pine  = dram_bev.pineapple_juice + in_ing.pineapple_juice;

    if(new_black[12] | new_green[12] | new_milk[12] | new_pine[12]) ing_too_much_comb = 1'b1;
    else                                                            ing_too_much_comb = 1'b0;
end
//newtodram
always_comb begin
    newtodram.black_tea       = (new_black[12]) ? 12'hfff : new_black[11:0];
    newtodram.green_tea       = (new_green[12]) ? 12'hfff : new_green[11:0];
    newtodram.milk            = (new_milk[12])  ? 12'hfff : new_milk[11:0];
    newtodram.pineapple_juice = (new_pine[12])  ? 12'hfff : new_pine[11:0];
end

//er_state
always_comb begin
    if(state==COMPARE) begin // || state==WRITE_DRAM
        case(in_action)
            Make_drink:         if(today_bigger_than_expire)    er_state = No_Exp;
                                else if(ing_insufficient)       er_state = No_Ing;
                                else                            er_state = No_Err;
            Supply:             if(ing_too_much)                er_state = Ing_OF;
                                else                            er_state = No_Err;
            Check_Valid_Date:   if(today_bigger_than_expire)    er_state = No_Exp;
                                else                            er_state = No_Err;
            default:                                            er_state = No_Err;
        endcase
    end
    else    er_state = No_Err;
end

//==================================
//  DRAM CTR
//==================================

//write_dram_flag
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)  write_dram_flag <= 1'b0;
    else            write_dram_flag <= write_dram_flag_comb;
end
always_comb begin
    if(state==COMPARE) begin
        case(in_action)
            Make_drink: if(today_bigger_than_expire | ing_insufficient) write_dram_flag_comb = 1'b0;
                        else                                            write_dram_flag_comb = 1'b1;
            Supply:                                                     write_dram_flag_comb = 1'b1;
            Check_Valid_Date:                                           write_dram_flag_comb = 1'b0;
            default:                                                    write_dram_flag_comb = 1'b0;
        endcase
    end
    else    write_dram_flag_comb = 1'b0;
end
//C_data_writeback
always_comb begin
    if(in_action==Supply) begin
        C_data_writeback = {newtodram.black_tea,newtodram.green_tea,4'd0,in_date.M,newtodram.milk,newtodram.pineapple_juice,3'd0,in_date.D};
    end
    else if(in_action==Make_drink) begin
        C_data_writeback = {left_black[11:0],left_green[11:0],4'd0,dram_bev.M,left_milk[11:0],left_pine[11:0],3'd0,dram_bev.D};
    end
    
    else    C_data_writeback = 64'd0;
end

//busy
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)  busy <= 1'b0;
    else            busy <= busy_comb;
end
always_comb begin
    if(write_dram_flag)         busy_comb = 1'b1;
    else if(inf.C_out_valid)    busy_comb = 1'b0;
    else                        busy_comb = busy;
end
//input_ready
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)  input_ready <= 1'b0;
    else            input_ready <= input_ready_comb;
end
always_comb begin
    if(state==COMPARE)          input_ready_comb = 1'b0;
    else if(inf.box_no_valid)   input_ready_comb = 1'b1;
    else                        input_ready_comb = input_ready;
end
//read_dram_flag
always_comb begin
    if((~busy) & input_ready_comb & (~input_ready))                         read_dram_flag = 1'b1;
    else if(busy & (~busy_comb) & input_ready)                              read_dram_flag = 1'b1;
    else if((busy & (~busy_comb)) & (input_ready_comb & (~input_ready)))    read_dram_flag = 1'b1;
    else                                                                    read_dram_flag = 1'b0;
end

//read_busy
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n)  read_busy <= 1'b0;
    else            read_busy <= read_busy_comb;
end
always_comb begin
    if(read_dram_flag)          read_busy_comb = 1'b1;
    else if(inf.C_out_valid)    read_busy_comb = 1'b0;
    else                        read_busy_comb = read_busy;
end

//==================================
//  VOLUME
//==================================

always_ff @( posedge clk or negedge inf.rst_n ) begin
    if(~inf.rst_n) begin
        need_black_reg <= 'd0;
        need_green_reg <= 'd0;
        need_milk_reg <= 'd0;
        need_pine_reg <= 'd0;
    end
    else begin
        need_black_reg <= need_black;
        need_green_reg <= need_green;
        need_milk_reg <= need_milk;
        need_pine_reg <= need_pine;
    end
end

always_comb begin
    case(in_bev_info.Bev_Size_O)
        L: begin
            case(in_bev_info.Bev_Type_O)
                Black_Tea: begin
                    need_black = 'd960;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd0;
                end
                Milk_Tea: begin
                    need_black = 'd720;
                    need_green = 'd0;
                    need_milk  = 'd240;
                    need_pine  = 'd0;
                end
                Extra_Milk_Tea: begin
                    need_black = 'd480;
                    need_green = 'd0;
                    need_milk  = 'd480;
                    need_pine  = 'd0;
                end
                Green_Tea: begin
                    need_black = 'd0;
                    need_green = 'd960;
                    need_milk  = 'd0;
                    need_pine  = 'd0;
                end
                Green_Milk_Tea: begin
                    need_black = 'd0;
                    need_green = 'd480;
                    need_milk  = 'd480;
                    need_pine  = 'd0;
                end
                Pineapple_Juice: begin
                    need_black = 'd0;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd960;
                end
                Super_Pineapple_Tea: begin
                    need_black = 'd480;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd480;
                end
                Super_Pineapple_Milk_Tea: begin
                    need_black = 'd480;
                    need_green = 'd0;
                    need_milk  = 'd240;
                    need_pine  = 'd240;
                end
            endcase
        end
        M: begin
            case(in_bev_info.Bev_Type_O)
                Black_Tea: begin
                    need_black = 'd720;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd0;
                end
                Milk_Tea: begin
                    need_black = 'd540;
                    need_green = 'd0;
                    need_milk  = 'd180;
                    need_pine  = 'd0;
                end
                Extra_Milk_Tea: begin
                    need_black = 'd360;
                    need_green = 'd0;
                    need_milk  = 'd360;
                    need_pine  = 'd0;
                end
                Green_Tea: begin
                    need_black = 'd0;
                    need_green = 'd720;
                    need_milk  = 'd0;
                    need_pine  = 'd0;
                end
                Green_Milk_Tea: begin
                    need_black = 'd0;
                    need_green = 'd360;
                    need_milk  = 'd360;
                    need_pine  = 'd0;
                end
                Pineapple_Juice: begin
                    need_black = 'd0;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd720;
                end
                Super_Pineapple_Tea: begin
                    need_black = 'd360;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd360;
                end
                Super_Pineapple_Milk_Tea: begin
                    need_black = 'd360;
                    need_green = 'd0;
                    need_milk  = 'd180;
                    need_pine  = 'd180;
                end
            endcase
        end
        S: begin
            case(in_bev_info.Bev_Type_O)
                Black_Tea: begin
                    need_black = 'd480;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd0;
                end
                Milk_Tea: begin
                    need_black = 'd360;
                    need_green = 'd0;
                    need_milk  = 'd120;
                    need_pine  = 'd0;
                end
                Extra_Milk_Tea: begin
                    need_black = 'd240;
                    need_green = 'd0;
                    need_milk  = 'd240;
                    need_pine  = 'd0;
                end
                Green_Tea: begin
                    need_black = 'd0;
                    need_green = 'd480;
                    need_milk  = 'd0;
                    need_pine  = 'd0;
                end
                Green_Milk_Tea: begin
                    need_black = 'd0;
                    need_green = 'd240;
                    need_milk  = 'd240;
                    need_pine  = 'd0;
                end
                Pineapple_Juice: begin
                    need_black = 'd0;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd480;
                end
                Super_Pineapple_Tea: begin
                    need_black = 'd240;
                    need_green = 'd0;
                    need_milk  = 'd0;
                    need_pine  = 'd240;
                end
                Super_Pineapple_Milk_Tea: begin
                    need_black = 'd240;
                    need_green = 'd0;
                    need_milk  = 'd120;
                    need_pine  = 'd120;
                end
            endcase
        end
        default: begin
            need_black = 'd0;
            need_green = 'd0;
            need_milk  = 'd0;
            need_pine  = 'd0;
        end
    endcase
end



endmodule