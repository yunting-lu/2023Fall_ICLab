`include "Usertype_BEV.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

typedef struct packed {
    ING black_tea;
    ING green_tea;
    ING milk;
    ING pineapple_juice;
} Ingredient;


//========================================================================
//  PARAMETERS
//========================================================================

parameter PAT_NUM = 3600;

parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter DRAM_OFFSET = 'h10000;
parameter DRAM_SHIFT = 8;
parameter BOX_NUM = 256;
parameter DRAM_GEN = 0;

integer SEED = 567;
integer DRAM_SEED = 8592;

parameter LATENCY_LIMIT = 10000;


//========================================================================
//  VARIABLES
//========================================================================

//DRAM_GENERATE
integer file;
int dram_id;
int dram_addr;
Bev_Bal dram_data;
logic [7:0] golden_DRAM [(DRAM_OFFSET):((DRAM_OFFSET+BOX_NUM*8)-1)];

//MAIN_EXE
integer total_latency, wait_val_time;
integer pat;

//TASK
Action input_act;
integer cnt_make;
Bev_Size input_size;
Bev_Type input_type;

Action in_action;
Barrel_No in_box_id;
Order_Info in_bev_info;
Date in_date;
Ingredient in_ing;
Bev_Bal d_data;

Bev_Bal new_data;

logic [7:0] Bev_Volume; //total_volume / 4
logic [2:0] ratio_black, ratio_green, ratio_milk, ratio_pine;
Ingredient make_ing;
Ingredient left_space;
logic overflow_black, overflow_green, overflow_milk, overflow_pine;

Error_Msg golden_err_msg;
logic golden_complete;

integer out_cycle;

//========================================================================
//  FONT_SETTING
//========================================================================

// String control
// Should use %0s
string rst_color  = "\033[1;0m";
string txt_black  = "\033[1;30m";
string txt_red    = "\033[1;31m";
string txt_green  = "\033[1;32m";
string txt_yellow = "\033[1;33m";
string txt_blue   = "\033[1;34m";

string bg_black  = "\033[40;1m";
string bg_red    = "\033[41;1m";
string bg_green  = "\033[42;1m";
string bg_yellow = "\033[43;1m";
string bg_blue   = "\033[0;30;46m";
string bg_white  = "\033[47;1m";

string bg_red_s = "\033[41;5m";


//========================================================================
//  CLASS - RANDOM
//========================================================================

class rand_action;
    rand Action action;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        action inside {Make_drink, Supply, Check_Valid_Date};
    }

endclass //rand_action

class rand_bev_type;
    randc Bev_Type bev_type;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        bev_type inside {Black_Tea, Milk_Tea, Extra_Milk_Tea,
                        Green_Tea, Green_Milk_Tea,
                        Pineapple_Juice, Super_Pineapple_Tea, Super_Pineapple_Milk_Tea};
    }

endclass //rand_bev_type

class rand_bev_size;
    rand Bev_Size bev_size;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        bev_size inside {L, M, S};
    }

endclass //rand_bev_size

class rand_date;
    rand Date date;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        date.M inside {[1:12]};
        (date.M==2) -> date.D inside {[1:28]};
        (date.M==4 || date.M==6 || date.M==9 || date.M==11) -> date.D inside {[1:30]};
        (date.M==1 || date.M==3 || date.M==5 || date.M==7 || date.M==8 || date.M==10 || date.M==12) -> date.D inside {[1:31]};
    }

endclass //rand_date

class rand_box_no;
    rand Barrel_No box_no;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        box_no inside {[0:255]};
    }

endclass //rand_box_no

class rand_box_sup;
    rand Ingredient ingredient;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        ingredient.black_tea        inside {[0:4095]};
        ingredient.green_tea        inside {[0:4095]};
        ingredient.milk             inside {[0:4095]};
        ingredient.pineapple_juice  inside {[0:4095]};
    }

endclass //rand_box_sup






rand_action rand_action_obj = new(SEED);
rand_bev_type rand_bev_type_obj = new(SEED);
rand_bev_size rand_bev_size_obj = new(SEED);
rand_date rand_date_obj = new(SEED);
rand_box_no rand_box_no_obj = new(SEED);
rand_box_sup rand_box_sup_obj = new(SEED);



//========================================================================
//  DRAM_GENERATE
//========================================================================

task dram_generate; begin
    //call obj for dram
    rand_box_sup dram_rand_box_sup_obj = new(DRAM_SEED);
    rand_date dram_rand_date_obj = new(DRAM_SEED);

    file = $fopen(DRAM_p_r,"w");
    for(dram_id = 0; dram_id < BOX_NUM; dram_id++) begin
        dram_addr = DRAM_OFFSET + dram_id * DRAM_SHIFT;
        //randomize info
        void'(dram_rand_box_sup_obj.randomize());
        void'(dram_rand_date_obj.randomize());
        //fetch randomized info
        dram_data.black_tea         = dram_rand_box_sup_obj.ingredient.black_tea;
        dram_data.green_tea         = dram_rand_box_sup_obj.ingredient.green_tea;
        dram_data.milk              = dram_rand_box_sup_obj.ingredient.milk;
        dram_data.pineapple_juice   = dram_rand_box_sup_obj.ingredient.pineapple_juice;
        dram_data.M                 = dram_rand_date_obj.date.M;
        dram_data.D                 = dram_rand_date_obj.date.D;
        //write file
        $fwrite(file, "@%5h\n", dram_addr);
        $fwrite(file, "%2h %2h %2h %2h\n",
                dram_data.D,
                dram_data.pineapple_juice[7:0],
                {dram_data.milk[3:0], dram_data.pineapple_juice[11:8]},
                dram_data.milk[11:4]
        );
        $fwrite(file, "@%5h\n", dram_addr+4);
        $fwrite(file, "%2h %2h %2h %2h\n",
                dram_data.M,
                dram_data.green_tea[7:0],
                {dram_data.black_tea[3:0], dram_data.green_tea[11:8]},
                dram_data.black_tea[11:4]
        );
    end

    $fclose(file);
end endtask


//========================================================================
//  MAIN_EXE
//========================================================================

initial begin
    if(DRAM_GEN)    dram_generate;
    $readmemh(DRAM_p_r, golden_DRAM);

    total_latency = 0;
    cnt_make = 0;
    reset_task;
    for(pat = 0; pat < PAT_NUM; pat = pat + 1) begin
        input_task;
        gen_gold_task;
        wait_outvalid_task;
        check_ans_task;
    end
    YOU_PASS_task;
end


//========================================================================
//  TASK
//========================================================================

//------------------------------------------------------
//  RESET_TASK
//------------------------------------------------------

task reset_task; begin
    inf.rst_n               = 1'b1;
    inf.sel_action_valid    = 1'b0;
    inf.type_valid          = 1'b0;
    inf.size_valid          = 1'b0;
    inf.date_valid          = 1'b0;
    inf.box_no_valid        = 1'b0;
    inf.box_sup_valid       = 1'b0;
    inf.D                   = 'dx;

    #(10) inf.rst_n = 1'b0;
    #(10) inf.rst_n = 1'b1;
    if(inf.out_valid !== 'd0 || inf.err_msg !== 'd0 || inf.complete !== 'd0) begin
        TAT_task;
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("%0s                                                      RESET SPEC : BEV.sv                                                                %0s",bg_red_s,rst_color);
        $display ("                                   All output signals should be reset after the reset signal is asserted.                                   ");
        $display ("out_valid:\t%8d|golden out_valid:\t%8d",inf.out_valid,0);
        $display ("err_msg:\t%8d|golden err_msg:\t%8d",inf.err_msg,0);
        $display ("complete:\t%8d|golden complete:\t%8d",inf.complete,0);
        $display("    Output signal should be 0 at %-12d ps  ", $time*1000);
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        //#(100);
        $finish;
    end

end endtask

//------------------------------------------------------
//  INPUT_TASK
//------------------------------------------------------

task random_gap_task; begin
    //repeat($random(SEED) % 4 + 0) @(negedge clk);
    //@(negedge clk);
end endtask

task input_action_task; begin
    //void'(rand_action_obj.randomize());
    inf.sel_action_valid = 1'b1;
    //inf.D = rand_action_obj.action;
    if(pat < 1800) begin
        if((pat%9 == 0) || (pat%9 == 6) || (pat%9 == 8))        input_act = Make_drink;
        else if((pat%9 == 1) || (pat%9 == 2) || (pat%9 == 5))   input_act = Supply;
        else                                                    input_act = Check_Valid_Date;
    end
    else    input_act = Make_drink;
    if(input_act==Make_drink)   cnt_make = cnt_make + 1;
    inf.D = input_act;
    @(negedge clk);
    inf.sel_action_valid = 1'b0;
    inf.D = 'dx;
end endtask

task input_type_task; begin
    //void'(rand_bev_type_obj.randomize());
    inf.type_valid = 1'b1;
    //inf.D = rand_bev_type_obj.bev_type;
    if(cnt_make%8 == 1)         input_type = Black_Tea;
    else if(cnt_make%8 == 2)    input_type = Milk_Tea;
    else if(cnt_make%8 == 3)    input_type = Extra_Milk_Tea;
    else if(cnt_make%8 == 4)    input_type = Green_Tea;
    else if(cnt_make%8 == 5)    input_type = Green_Milk_Tea;
    else if(cnt_make%8 == 6)    input_type = Pineapple_Juice;
    else if(cnt_make%8 == 7)    input_type = Super_Pineapple_Tea;
    else                        input_type = Super_Pineapple_Milk_Tea;
    inf.D = input_type;
    @(negedge clk);
    inf.type_valid = 1'b0;
    inf.D = 'dx;
end endtask

task input_size_task; begin
    //void'(rand_bev_size_obj.randomize());
    inf.size_valid = 1'b1;
    //inf.D = rand_bev_size_obj.bev_size;
    if(cnt_make%24 >= 1 && cnt_make%24 <= 8)        input_size = L;
    else if(cnt_make%24 >= 9 && cnt_make%24 <= 16)  input_size = M;
    else                                            input_size = S;
    inf.D = input_size;
    @(negedge clk);
    inf.size_valid = 1'b0;
    inf.D = 'dx;
end endtask

task input_date_task; begin
    void'(rand_date_obj.randomize());
    inf.date_valid = 1'b1;
    inf.D = rand_date_obj.date;
    @(negedge clk);
    inf.date_valid = 1'b0;
    inf.D = 'dx;
end endtask

task input_box_no_task; begin
    void'(rand_box_no_obj.randomize());
    inf.box_no_valid = 1'b1;
    inf.D = rand_box_no_obj.box_no;
    @(negedge clk);
    inf.box_no_valid = 1'b0;
    inf.D = 'dx;
end endtask

task input_box_sup_task; begin
    void'(rand_box_sup_obj.randomize());
    //black_tea
    inf.box_sup_valid = 1'b1;
    inf.D = rand_box_sup_obj.ingredient.black_tea;
    @(negedge clk);
    inf.box_sup_valid = 1'b0;
    inf.D = 'dx;
    random_gap_task;
    //green_tea
    inf.box_sup_valid = 1'b1;
    inf.D = rand_box_sup_obj.ingredient.green_tea;
    @(negedge clk);
    inf.box_sup_valid = 1'b0;
    inf.D = 'dx;
    random_gap_task;
    //milk
    inf.box_sup_valid = 1'b1;
    inf.D = rand_box_sup_obj.ingredient.milk;
    @(negedge clk);
    inf.box_sup_valid = 1'b0;
    inf.D = 'dx;
    random_gap_task;
    //pineapple_juice
    inf.box_sup_valid = 1'b1;
    inf.D = rand_box_sup_obj.ingredient.pineapple_juice;
    @(negedge clk);
    inf.box_sup_valid = 1'b0;
    inf.D = 'dx;

end endtask

task input_task; begin
    //next input in 1~4 cycles
    //repeat($random(SEED) % 4 + 1) @(negedge clk);
    @(negedge clk);
    //input
    input_action_task;
    random_gap_task;
    case(input_act) //rand_action_obj.action
        Make_drink: begin
            input_type_task;
            random_gap_task;
            input_size_task;
            random_gap_task;
            input_date_task;
            random_gap_task;
            input_box_no_task;
        end
        Supply: begin
            input_date_task;
            random_gap_task;
            input_box_no_task;
            random_gap_task;
            input_box_sup_task;
        end
        Check_Valid_Date: begin
            input_date_task;
            random_gap_task;
            input_box_no_task;
        end
    endcase
end endtask

//------------------------------------------------------
//  GEN_GOLD_TASK
//------------------------------------------------------

task gen_gold_task; begin
    //get input action and box_no
    in_action = input_act; //rand_action_obj.action;
    in_box_id = rand_box_no_obj.box_no;
    //get dram data
    get_d_data_task;
    //run action
    if(in_action == Make_drink)             make_drink_task;
    else if(in_action == Supply)            supply_task;
    else if(in_action == Check_Valid_Date)  check_valid_date_task;
    else begin
        $display("!!!!!!!!!!!!!!Invalid Action!!!!!!!!!!!!!!");
        //#(10);
        $finish;
    end
end endtask

task get_d_data_task; begin
    d_data.black_tea        = {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+7], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+6][7:4]};
    d_data.green_tea        = {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+6][3:0], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+5]};
    d_data.milk             = {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+3], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+2][7:4]};
    d_data.pineapple_juice  = {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+2][3:0], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+1]};
    d_data.M                = golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+4][3:0];
    d_data.D                = golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+0][4:0];
end endtask

//TODO
task update_dram_task; begin
    //new_data
    if(in_action == Make_drink) begin
        new_data.black_tea          = d_data.black_tea - make_ing.black_tea;
        new_data.green_tea          = d_data.green_tea - make_ing.green_tea;
        new_data.milk               = d_data.milk - make_ing.milk;
        new_data.pineapple_juice    = d_data.pineapple_juice - make_ing.pineapple_juice;
        new_data.M                  = d_data.M;
        new_data.D                  = d_data.D;
    end
    else if(in_action == Supply) begin
        new_data.M                  = in_date.M;
        new_data.D                  = in_date.D;
        if(overflow_black)  new_data.black_tea          = 12'hfff;
        else                new_data.black_tea          = d_data.black_tea + in_ing.black_tea;
        if(overflow_green)  new_data.green_tea          = 12'hfff;
        else                new_data.green_tea          = d_data.green_tea + in_ing.green_tea;
        if(overflow_milk)   new_data.milk               = 12'hfff;
        else                new_data.milk               = d_data.milk + in_ing.milk;
        if(overflow_pine)   new_data.pineapple_juice    = 12'hfff;
        else                new_data.pineapple_juice    = d_data.pineapple_juice + in_ing.pineapple_juice;
    end
    //update info
    {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+7], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+6][7:4]} = new_data.black_tea;
    {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+6][3:0], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+5]} = new_data.green_tea;
    {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+3], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+2][7:4]} = new_data.milk;
    {golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+2][3:0], golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+1]} = new_data.pineapple_juice;
    golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+4][3:0] = new_data.M;
    golden_DRAM[DRAM_OFFSET+in_box_id*DRAM_SHIFT+0][4:0] = new_data.D;
end endtask

task make_drink_task; begin
    in_bev_info.Bev_Type_O  = input_type; //rand_bev_type_obj.bev_type;
    in_bev_info.Bev_Size_O  = input_size; //rand_bev_size_obj.bev_size;
    in_date                 = rand_date_obj.date;
    //VOLUME
    case(in_bev_info.Bev_Size_O)
        L:  Bev_Volume = 'd240;
        M:  Bev_Volume = 'd180;
        S:  Bev_Volume = 'd120;
    endcase
    
    case(in_bev_info.Bev_Type_O)
        Black_Tea: begin                ratio_black = 'd4;  ratio_green = 'd0;  ratio_milk = 'd0;   ratio_pine = 'd0;   end
        Milk_Tea: begin                 ratio_black = 'd3;  ratio_green = 'd0;  ratio_milk = 'd1;   ratio_pine = 'd0;   end
        Extra_Milk_Tea: begin           ratio_black = 'd2;  ratio_green = 'd0;  ratio_milk = 'd2;   ratio_pine = 'd0;   end
        Green_Tea: begin                ratio_black = 'd0;  ratio_green = 'd4;  ratio_milk = 'd0;   ratio_pine = 'd0;   end
        Green_Milk_Tea: begin           ratio_black = 'd0;  ratio_green = 'd2;  ratio_milk = 'd2;   ratio_pine = 'd0;   end
        Pineapple_Juice: begin          ratio_black = 'd0;  ratio_green = 'd0;  ratio_milk = 'd0;   ratio_pine = 'd4;   end
        Super_Pineapple_Tea: begin      ratio_black = 'd2;  ratio_green = 'd0;  ratio_milk = 'd0;   ratio_pine = 'd2;   end
        Super_Pineapple_Milk_Tea: begin ratio_black = 'd2;  ratio_green = 'd0;  ratio_milk = 'd1;   ratio_pine = 'd1;   end
    endcase

    make_ing.black_tea          = Bev_Volume * ratio_black;
    make_ing.green_tea          = Bev_Volume * ratio_green;
    make_ing.milk               = Bev_Volume * ratio_milk;
    make_ing.pineapple_juice    = Bev_Volume * ratio_pine;

    //No_Exp
    if(in_date.M > d_data.M) begin
        golden_err_msg = No_Exp;
        golden_complete = 1'b0;
    end
    else if((in_date.M === d_data.M) && (in_date.D > d_data.D)) begin
        golden_err_msg = No_Exp;
        golden_complete = 1'b0;
    end
    //No_Ing
    else if((make_ing.black_tea > d_data.black_tea) || (make_ing.green_tea > d_data.green_tea) 
            || (make_ing.milk > d_data.milk) || (make_ing.pineapple_juice > d_data.pineapple_juice)) begin
        golden_err_msg = No_Ing;
        golden_complete = 1'b0;
    end
    //No_Err
    else begin
        golden_err_msg = No_Err;
        golden_complete = 1'b1;
        update_dram_task;
    end
end endtask

task supply_task; begin
    in_date                 = rand_date_obj.date;
    in_ing.black_tea        = rand_box_sup_obj.ingredient.black_tea;
    in_ing.green_tea        = rand_box_sup_obj.ingredient.green_tea;
    in_ing.milk             = rand_box_sup_obj.ingredient.milk;
    in_ing.pineapple_juice  = rand_box_sup_obj.ingredient.pineapple_juice;

    left_space.black_tea        = 12'hfff - d_data.black_tea;
    left_space.green_tea        = 12'hfff - d_data.green_tea;
    left_space.milk             = 12'hfff - d_data.milk;
    left_space.pineapple_juice  = 12'hfff - d_data.pineapple_juice;

    overflow_black = (in_ing.black_tea > left_space.black_tea);
    overflow_green = (in_ing.green_tea > left_space.green_tea);
    overflow_milk  = (in_ing.milk > left_space.milk);
    overflow_pine  = (in_ing.pineapple_juice > left_space.pineapple_juice);

    if(overflow_black || overflow_green || overflow_milk || overflow_pine) begin
        golden_err_msg = Ing_OF;
        golden_complete = 1'b0;
        update_dram_task;
    end
    else begin
        golden_err_msg = No_Err;
        golden_complete = 1'b1;
        update_dram_task;
    end
end endtask

task check_valid_date_task; begin
    in_date                 = rand_date_obj.date;
    if(in_date.M > d_data.M) begin
        golden_err_msg = No_Exp;
        golden_complete = 1'b0;
    end
    else if((in_date.M === d_data.M) && (in_date.D > d_data.D)) begin
        golden_err_msg = No_Exp;
        golden_complete = 1'b0;
    end
    else begin
        golden_err_msg = No_Err;
        golden_complete = 1'b1;
    end
end endtask


//------------------------------------------------------
//  WAIT_OUTVALID_TASK
//------------------------------------------------------

task wait_outvalid_task; begin
    wait_val_time = -1; //?
    while(inf.out_valid !== 1) begin
        wait_val_time = wait_val_time + 1;
        if(inf.err_msg !== 0 || inf.complete !== 0) begin
            TAT_task;
            $display("==========================================================================");
            $display("          err_msg and complete should be 0 when out_valid is 0            ");
            $display ("err_msg:\t%8d|golden err_msg:\t%8d",inf.err_msg,0);
            $display ("complete:\t%8d|golden complete:\t%8d",inf.complete,0);
            $display("    Output signal should be 0 at %-12d ps  ", $time*1000);
            $display("==========================================================================");
            //repeat(5) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
end endtask

//------------------------------------------------------
//  CHECK_ANS_TASK
//------------------------------------------------------

task check_ans_task; begin
    
    out_cycle = 0;
    while(inf.out_valid === 1) begin
        out_cycle = out_cycle + 1;
        //only high for one cycle
        if(out_cycle > 1) begin
            TAT_task;
            $display("==========================================================================");
            $display("    Out cycles is more than 1 at %-12d ps", $time*1000);
            $display("==========================================================================");
            //repeat(5) @(negedge clk);
            $finish;
        end
        //check ans correctness
        if((inf.err_msg !== golden_err_msg) || (inf.complete !== golden_complete)) begin
            if(in_action == Check_Valid_Date) begin
                $display("today's date:%2d/%2d | expired date:%2d/%2d", in_date.M, in_date.D, d_data.M, d_data.D);
            end
            TAT_task;
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("%0s                                                                CHECK_ANS                                                                %0s",bg_red_s,rst_color);    
            $display ("err_msg:\t%8d|golden err_msg:\t%8d",inf.err_msg,golden_err_msg);
            $display ("complete:\t%8d|golden complete:\t%8d",inf.complete,golden_complete);
            $display ("out_valid:\t%8d|golden out_valid:\t%8d",inf.out_valid,1);
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            //repeat(5) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end

    total_latency = total_latency + wait_val_time;
    $display("%0sPASS Action  : %16s, PATTERN NO.%4d, %0sCycles: %3d%0s",txt_blue, 
                (in_action==Make_drink)?("Make_drink"):((in_action==Supply)?("Supply"):("Check_Valid_Date")), 
                pat, txt_green, wait_val_time, rst_color);

end endtask

//------------------------------------------------------
//  PASS_TASK
//------------------------------------------------------

task YOU_PASS_task; begin
    
    $display ("--------------------------------------------------------------------");
    $display ("           ~(￣▽￣)~(＿△＿)~(￣▽￣)~(＿△＿)~(￣▽￣)~             ");
    $display ("                         Congratulations                            ");
    $display ("                  You have passed all patterns!                     ");
    $display ("                  total cycles: %10d", total_latency);
    $display ("--------------------------------------------------------------------");
    //repeat(5) @(negedge clk);
    $finish;

end endtask

task TAT_task; begin
    
    $display ("--------------------------------------------------------------------");
    $display ("                 (T⌓T)(T⌓T)(T⌓T)(T⌓T)(T⌓T)                      ");
    $display ("                         Wrong Answer                               ");
    $display ("--------------------------------------------------------------------");

end endtask


endprogram