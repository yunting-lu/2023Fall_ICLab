module bridge(input clk, INF.bridge_inf inf);

//================================================================
// logic 
//================================================================

//typedef enum logic [1:0] { IDLE, READ, WRITE, OUTPUT } state_bridge;
//state_bridge curr_state, next_state;

logic [16:0] addr_comb;

//================================================================
// FSM 
//================================================================
/*
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)  curr_state <= 'b0;    
    else            curr_state <= next_state;
end

always_comb begin
    case(curr_state)
        IDLE:   if(inf.C_in_valid) begin
                    if(inf.C_r_wb)  next_state = READ;
                    else            next_state = WRITE;
                end
                else                next_state = IDLE;
        READ:   if(inf.R_VALID)     next_state = OUTPUT;
                else                next_state = READ;
        WRITE:  if(inf.B_VALID)     next_state = OUTPUT;
                else                next_state = WRITE;
        OUTPUT:                     next_state = IDLE;
        default:                    next_state = IDLE;
    endcase
end
*/
//================================================================
// Combinations 
//================================================================

assign addr_comb = {6'b100000,inf.C_addr,3'b000};

//================================================================
// OUTPUT CTR 
//================================================================
//--------------------------
//  BEV
//--------------------------

//C_out_valid
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.C_out_valid <= 'b0;
    else if(inf.R_VALID || inf.B_VALID)     inf.C_out_valid <= 'b1; //next_state == OUTPUT
    else                                    inf.C_out_valid <= 'b0;
end
//C_data_r
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.C_data_r <= 'b0;
    else if(inf.R_VALID)                    inf.C_data_r <= inf.R_DATA; //next_state==OUTPUT&inf.R_VALID
    else                                    inf.C_data_r <= 'b0;
end

//--------------------------
//  DRAM
//--------------------------

//AR_VALID
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.AR_VALID <= 'b0;
    else if(inf.C_in_valid&inf.C_r_wb)      inf.AR_VALID <= 'b1;
    else if(inf.AR_READY)                   inf.AR_VALID <= 'b0;
    else                                    inf.AR_VALID <= inf.AR_VALID;
end
//AR_ADDR
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.AR_ADDR <= 'b0;
    else if(inf.C_in_valid&inf.C_r_wb)      inf.AR_ADDR <= addr_comb;
    else if(inf.AR_READY)                   inf.AR_ADDR <= 'b0;
    else                                    inf.AR_ADDR <= inf.AR_ADDR;
end
//R_READY
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.R_READY <= 'b0;
    else if(inf.AR_READY)                   inf.R_READY <= 'b1;
    else if(inf.R_VALID)                    inf.R_READY <= 'b0;
    else                                    inf.R_READY <= inf.R_READY;
end
//AW_VALID
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.AW_VALID <= 'b0;
    else if(inf.C_in_valid&(~inf.C_r_wb))   inf.AW_VALID <= 'b1;
    else if(inf.AW_READY)                   inf.AW_VALID <= 'b0;
    else                                    inf.AW_VALID <= inf.AW_VALID;
end
//AW_ADDR
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.AW_ADDR <= 'b0;
    else if(inf.C_in_valid&(~inf.C_r_wb))   inf.AW_ADDR <= addr_comb;
    else if(inf.AW_READY)                   inf.AW_ADDR <= 'b0;
    else                                    inf.AW_ADDR <= inf.AW_ADDR;
end
//W_VALID
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.W_VALID <= 'b0;
    else if(inf.AW_READY)                   inf.W_VALID <= 'b1;
    else if(inf.W_READY)                    inf.W_VALID <= 'b0;
    else                                    inf.W_VALID <= inf.W_VALID;
end
//W_DATA
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.W_DATA <= 'b0;
    else if(inf.C_in_valid&(~inf.C_r_wb))   inf.W_DATA <= inf.C_data_w;
    else if(inf.W_READY)                    inf.W_DATA <= 'b0;
    else                                    inf.W_DATA <= inf.W_DATA;
end
//B_READY
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(~inf.rst_n)                          inf.B_READY <= 'b0;
    else if(inf.AW_READY)                   inf.B_READY <= 'b1;
    else if(inf.B_VALID)                    inf.B_READY <= 'b0;
    else                                    inf.B_READY <= inf.B_READY;
end



endmodule