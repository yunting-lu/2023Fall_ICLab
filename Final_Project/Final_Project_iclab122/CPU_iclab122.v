//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2023-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  reg [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               Parameters
//####################################################

parameter s_IDLE  = 'd0;
parameter s_FETCH = 'd1;
parameter s_DECODE= 'd2;
parameter s_LOAD  = 'd3;
parameter s_STORE = 'd4;
parameter s_EXE   = 'd5;

//####################################################
//               reg & wire
//####################################################
//FSM
reg [2:0] curr_state, next_state;
//======================================================================
//            INSTRUCTION STRUCTURE
//-----------------------------------------------------------------------
//  R-TYPE  | opcode(3bit) | rs(4bit) | rt(4bit)| rd(4bit) | func(1bit) |
//  I-TYPE  | opcode(3bit) | rs(4bit) | rt(4bit)| immediate(5bit)       |
//  J-TYPE  | opcode(3bit) | Address(13bit)                             |
//-----------------------------------------------------------------------
reg [15:0] inst_fetched;
reg [2:0] opcode;
reg [3:0] rs_id, rt_id, rd_id;
reg [4:0] immediate;
reg func;
reg [10:0] j_addr_val_part;
//**********************************
reg signed [15:0] rs_value, rt_value;
//======================================================================
//PC:   Use 11bit
//pc_curr: 13bit, {1'b1,curr_pc,1'b0}
reg [10:0] curr_pc, next_pc;
reg [10:0] next_pc_comb;
//======================================================================
//AXI_DATA_WRITE
//  INPUT:  data_addr[11:1], data_content[15:0], in_valid
//  OUTPUT: out_valid
//----------------------------------------------------------------------
//INPUT
reg [10:0] data_addr2Cache;
reg [15:0] data_2_Cache;
reg        write_req;
//OUTPUT
wire       w_dram_finish;
//****************************************
reg check_cache;
reg check_dram;
//======================================================================
//AXI_READ_INST
//  INPUT:  inst_addr[11:1],  search_flag 
//  OUTPUT: inst_2_cpu[15:0], inst_valid
//  SHARED: inst_addr[11:1](curr_pc[10:0])
//----------------------------------------------------------------------
//INPUT
reg         fetch_req;
//OUTPUT
wire [15:0] inst_comb;
wire        fetch_finish;
//======================================================================
//AXI_DATA_CACHE
//  INPUT:  in_valid, en_write, data_addr[10:0], in_data
//  OUTPUT: data_2_cpu[15:0], out_valid
//  SHARED: data_addr[10:0] (data_addr2Cache[10:0]), in_data (data_2_Cache[15:0])
//
//----------------------------------------------------------------------
//INPUT
reg data_req;
reg write_mod;
//OUTPUT
wire [15:0] data_comb;
wire        rw_sram_finish;
//####################################################
//               ALU
//####################################################
reg signed [15:0] alu_in0, alu_in1;

reg [15:0] alu_result;
reg signed [15:0] add_res;
reg signed [15:0] sub_res;
reg        slt_res;
reg signed [15:0] mult_res;

//####################################################
//               Output CTR
//####################################################
//IO_stall
always@(posedge clk or negedge rst_n)begin
  if(~rst_n)                                            begin IO_stall <= 'b1; end
  else if(((curr_state!=s_IDLE)&(curr_state!=s_FETCH))&&(next_state==s_FETCH))  
                                                        begin IO_stall <= 'b0; end
  else                                                  begin IO_stall <= 'b1; end
end

//####################################################
//           FSM CTR
//---------------------------------------------------
//Function type:  ver.3
//  ADD, SUB, MULT, SLT:
//          FETCH -> DECODE -> EXE -> (NEXT FETCH)(WB)
//  LOAD:   FETCH -> DECODE -> EXE -> LOAD          -> (NEXT FETCH)(WB)
//  STORE:  FETCH -> DECODE -> EXE -> STORE         -> (NEXT FETCH)
//  BEQ:    FETCH -> DECODE -> EXE -> (NEXT FETCH)
//  Jr:     FETCH -> DECODE -> EXE -> (NEXT FETCH)
//####################################################
always@(posedge clk or negedge rst_n)begin
  if(~rst_n) begin curr_state <= s_IDLE;     end
  else       begin curr_state <= next_state; end
end
always@(*)begin
  case(curr_state)
    s_IDLE: begin     next_state = s_FETCH; end
    s_FETCH: begin    if(fetch_finish)  next_state = s_DECODE;
                      else              next_state = curr_state; end
    s_DECODE: begin   next_state = s_EXE; end
    s_EXE: begin
          case({opcode, func})
            4'b0000, 4'b0001, 4'b0010, 4'b0011: begin next_state = s_FETCH; end //R-type
            4'b0100, 4'b0101:                   begin next_state = s_LOAD;  end //I-type, LOAD
            4'b0110, 4'b0111:                   begin next_state = s_STORE; end //I-type, STORE
            4'b1010, 4'b1011, 4'b1000, 4'b1001: begin next_state = s_FETCH; end //J-type, JUMP & I-type, BEQ
            default:                            begin next_state = s_FETCH; end
          endcase
    end
    s_LOAD: begin     if(rw_sram_finish)              next_state = s_FETCH;
                      else                            next_state = s_LOAD; end
    s_STORE: begin    if((check_cache&w_dram_finish)|(rw_sram_finish&write_mod&check_dram)|(rw_sram_finish&write_mod&w_dram_finish))
                                                begin next_state = s_FETCH; end
                else                            begin next_state = s_STORE; end end
    default:    next_state = s_IDLE;
  endcase
end

//####################################################
//               CORE_REG
//####################################################

//reg0~reg3
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)  core_r0 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h0)&(opcode<'d2))|(rt_id==4'h0)&(opcode=='d2)))begin
      if(opcode[1]) core_r0 <= data_comb; //LOAD
      else          core_r0 <= alu_result; //R-type
  end
  else            core_r0 <= core_r0;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r1 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h1)&(opcode<'d2))|(rt_id==4'h1)&(opcode=='d2)))begin
      if(opcode[1]) core_r1 <= data_comb;
      else          core_r1 <= alu_result;
  end
  else              core_r1 <= core_r1;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r2 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h2)&(opcode<'d2))|(rt_id==4'h2)&(opcode=='d2)))begin
      if(opcode[1]) core_r2 <= data_comb;
      else          core_r2 <= alu_result;
  end
  else              core_r2 <= core_r2;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r3 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h3)&(opcode<'d2))|(rt_id==4'h3)&(opcode=='d2)))begin
      if(opcode[1]) core_r3 <= data_comb;
      else          core_r3 <= alu_result;
  end
  else              core_r3 <= core_r3;
end
//reg4~reg7
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r4 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h4)&(opcode<'d2))|(rt_id==4'h4)&(opcode=='d2)))begin
      if(opcode[1]) core_r4 <= data_comb;
      else          core_r4 <= alu_result;
  end
  else              core_r4 <= core_r4;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r5 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h5)&(opcode<'d2))|(rt_id==4'h5)&(opcode=='d2)))begin
      if(opcode[1]) core_r5 <= data_comb;
      else          core_r5 <= alu_result;
  end
  else              core_r5 <= core_r5;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r6 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h6)&(opcode<'d2))|(rt_id==4'h6)&(opcode=='d2)))begin
      if(opcode[1]) core_r6 <= data_comb;
      else          core_r6 <= alu_result;
  end
  else              core_r6 <= core_r6;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r7 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h7)&(opcode<'d2))|(rt_id==4'h7)&(opcode=='d2)))begin
      if(opcode[1]) core_r7 <= data_comb;
      else          core_r7 <= alu_result;
  end
  else              core_r7 <= core_r7;
end
//reg8~reg11
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r8 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h8)&(opcode<'d2))|(rt_id==4'h8)&(opcode=='d2)))begin
      if(opcode[1]) core_r8 <= data_comb;
      else          core_r8 <= alu_result;
  end
  else              core_r8 <= core_r8;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r9 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'h9)&(opcode<'d2))|(rt_id==4'h9)&(opcode=='d2)))begin
      if(opcode[1]) core_r9 <= data_comb;
      else          core_r9 <= alu_result;
  end
  else              core_r9 <= core_r9;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r10 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'ha)&(opcode<'d2))|(rt_id==4'ha)&(opcode=='d2)))begin
      if(opcode[1]) core_r10 <= data_comb;
      else          core_r10 <= alu_result;
  end
  else              core_r10 <= core_r10;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r11 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'hb)&(opcode<'d2))|(rt_id==4'hb)&(opcode=='d2)))begin
      if(opcode[1]) core_r11 <= data_comb;
      else          core_r11 <= alu_result;
  end
  else              core_r11 <= core_r11;
end
//reg12~reg15
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r12 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'hc)&(opcode<'d2))|(rt_id==4'hc)&(opcode=='d2)))begin
      if(opcode[1]) core_r12 <= data_comb;
      else          core_r12 <= alu_result;
  end
  else            core_r12 <= core_r12;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r13 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'hd)&(opcode<'d2))|(rt_id==4'hd)&(opcode=='d2)))begin
      if(opcode[1]) core_r13 <= data_comb;
      else          core_r13 <= alu_result;
  end
  else              core_r13 <= core_r13;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r14 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'he)&(opcode<'d2))|(rt_id==4'he)&(opcode=='d2)))begin
      if(opcode[1]) core_r14 <= data_comb;
      else          core_r14 <= alu_result;
  end
  else              core_r14 <= core_r14;
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        core_r15 <= 'b0;
  else if((next_state==s_FETCH)&(((rd_id==4'hf)&(opcode<'d2))|(rt_id==4'hf)&(opcode=='d2)))begin
      if(opcode[1]) core_r15 <= data_comb;
      else          core_r15 <= alu_result;
  end
  else              core_r15 <= core_r15;
end

//####################################################
//               PC CTR
//####################################################

//curr_pc
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                                      begin curr_pc <= 11'b0;   end 
  else if((curr_state>'d1)&(next_state==s_FETCH)) begin curr_pc <= next_pc; end
  else                                            begin curr_pc <= curr_pc; end
end
always@(*)begin next_pc_comb = curr_pc + 'b1; end
always@(*)begin
  if(curr_state==s_IDLE)  next_pc = 'b0;
  else begin
      if(opcode[2])begin
        if((~opcode[0]))begin //BEQ
            if((rt_value==rs_value)) begin next_pc = alu_result[10:0]; end
            else                     begin next_pc = next_pc_comb;     end
        end            
        else                         begin next_pc = j_addr_val_part; end //JUMP
      end
      else                           begin next_pc = next_pc_comb; end
  end
end

//####################################################
//               ALU
//####################################################
always @(*) begin
  case({opcode,func})
    4'b0000:          begin alu_result = add_res;  end  //ADD
    4'b0001:          begin alu_result = sub_res;  end  //SUB
    4'b0010:          begin alu_result = slt_res;  end  //SLT
    4'b0011:          begin alu_result = mult_res; end  //MULT
    4'b0100, 4'b0101: begin alu_result = add_res;  end  //LOAD
    4'b0110, 4'b0111: begin alu_result = add_res;  end  //STORE
    4'b1000, 4'b1001: begin alu_result = add_res;  end  //BEQ
    default:          begin alu_result = add_res;  end     
  endcase
end
always @(*) begin
  add_res = alu_in0 + alu_in1;
  sub_res = alu_in0 - alu_in1;
  slt_res = (alu_in0 < alu_in1) ? 1'b1 : 1'b0;
  mult_res = alu_in0 * alu_in1;
end

//rs -> alu_in0
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                    begin alu_in0 <= 16'b0; end
  else if(curr_state==s_DECODE)begin
    if(~opcode[2])              begin alu_in0 <= rs_value;     end
    else                        begin alu_in0 <= next_pc_comb; end //BEQ
  end
  else                          begin alu_in0 <= alu_in0; end
end
always @(*)begin
  case(rs_id)
    4'h0:     begin rs_value = core_r0;  end
    4'h1:     begin rs_value = core_r1;  end
    4'h2:     begin rs_value = core_r2;  end
    4'h3:     begin rs_value = core_r3;  end
    4'h4:     begin rs_value = core_r4;  end
    4'h5:     begin rs_value = core_r5;  end
    4'h6:     begin rs_value = core_r6;  end
    4'h7:     begin rs_value = core_r7;  end
    4'h8:     begin rs_value = core_r8;  end
    4'h9:     begin rs_value = core_r9;  end
    4'ha:     begin rs_value = core_r10; end
    4'hb:     begin rs_value = core_r11; end
    4'hc:     begin rs_value = core_r12; end
    4'hd:     begin rs_value = core_r13; end
    4'he:     begin rs_value = core_r14; end
    4'hf:     begin rs_value = core_r15; end
    default:  begin rs_value = 16'b0;    end  
  endcase
end
//rt -> alu_in1
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                    begin alu_in1 <= 16'b0; end
  else if(curr_state==s_DECODE) begin
    if(opcode[2:1]==2'b00)      begin alu_in1 <= rt_value;                       end
    else                        begin alu_in1 <= {{11{immediate[4]}},immediate}; end //LOAD, STORE, BEQ
  end
  else                          begin alu_in1 <= alu_in1; end
end
always @(*)begin
  case(rt_id)
    4'h0:    begin rt_value = core_r0;  end
    4'h1:    begin rt_value = core_r1;  end
    4'h2:    begin rt_value = core_r2;  end
    4'h3:    begin rt_value = core_r3;  end
    4'h4:    begin rt_value = core_r4;  end
    4'h5:    begin rt_value = core_r5;  end
    4'h6:    begin rt_value = core_r6;  end
    4'h7:    begin rt_value = core_r7;  end
    4'h8:    begin rt_value = core_r8;  end
    4'h9:    begin rt_value = core_r9;  end
    4'ha:    begin rt_value = core_r10; end
    4'hb:    begin rt_value = core_r11; end
    4'hc:    begin rt_value = core_r12; end
    4'hd:    begin rt_value = core_r13; end
    4'he:    begin rt_value = core_r14; end
    4'hf:    begin rt_value = core_r15; end
    default: begin rt_value = 16'b0;    end
  endcase
end

//-------------------------------------------
//  Global AXI parameter setting
//-------------------------------------------
assign awid_m_inf     = 4'b0;
assign awsize_m_inf   = 3'b001; //DATA_WIDTH=16
assign awburst_m_inf  = 2'b01; //INCR
assign awlen_m_inf    = 7'b0;


assign arid_m_inf     = 8'b0;
//assign arlen_m_inf    = 14'b11_1111_1111_1111; //127, 127
assign arsize_m_inf   = 6'b00_1001; //DATA_WIDTH=16, 16
assign arburst_m_inf  = 4'b0101; //INCR, INCR

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  arlen_m_inf <= 14'b0;
  else        arlen_m_inf <= 14'b11_1111_1111_1111;
end

//####################################################################
//           AXI write/response: STORE submodule
//####################################################################

//data_addr2Cache
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin data_addr2Cache <= 11'b0;            end 
  else       begin data_addr2Cache <= alu_result[10:0]; end
end
//data_2_Cache
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin data_2_Cache <= 16'b0;    end
  else       begin data_2_Cache <= rt_value; end
end
//write_req
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                        begin write_req <= 1'b0;      end 
  else if(w_dram_finish|check_dram) begin write_req <= 1'b0;      end
  else if(next_state==s_STORE)      begin write_req <= 1'b1;      end 
  else                              begin write_req <= write_req; end
end
//check_dram
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                    begin check_dram <= 1'b0;       end
  else if(next_state==s_DECODE) begin check_dram <= 1'b0;       end //may change condition
  else if(w_dram_finish)        begin check_dram <= 1'b1;       end 
  else                          begin check_dram <= check_dram; end
end

//submodule
AXI_DATA_WRITE AXI_DATA_WRITE_INS(
  //inputs
      .clk(clk), .rst_n(rst_n),
      .awready_m(awready_m_inf),
      .wready_m(wready_m_inf),
      .bvalid_m(bvalid_m_inf),
      .data_addr(data_addr2Cache),.data_content(data_2_Cache),.in_valid(write_req),
  //outputs
      .awaddr_m(awaddr_m_inf),    .awvalid_m(awvalid_m_inf),
      .wdata_m(wdata_m_inf),      .wlast_m(wlast_m_inf),      .wvalid_m(wvalid_m_inf),
      .bready_m(bready_m_inf),
      .out_valid(w_dram_finish)
);

//####################################################################
//           AXI read:  Inst. read submodule
//####################################################################

//inst_fetched
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)            begin inst_fetched <= 16'b0;        end 
  else if(fetch_finish) begin inst_fetched <= inst_comb;    end 
  else                  begin inst_fetched <= inst_fetched; end
end
//instruction_decode
always @(*) begin
  opcode = inst_fetched[15:13];
  rs_id =  inst_fetched[12:9];
  rt_id =  inst_fetched[8:5];
  rd_id =  inst_fetched[4:1];
  func  =  inst_fetched[0];
  immediate = inst_fetched[4:0];
  j_addr_val_part = inst_fetched[11:1];
end

//fetch_req
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                   begin fetch_req <= 1'b0;      end
  else if(fetch_finish)        begin fetch_req <= 1'b0;      end
  else if(next_state==s_FETCH) begin fetch_req <= 1'b1;      end
  else                         begin fetch_req <= fetch_req; end
end

//submodule
AXI_READ_INST AXI_READ_INST_INS(
  //inputs
      .clk(clk), .rst_n(rst_n),
      .arready_m(arready_m_inf[1]),
      .rdata_m(rdata_m_inf[31:16]),
      .rlast_m(rlast_m_inf[1]),     .rvalid_m(rvalid_m_inf[1]),
      .inst_addr(curr_pc),          .search_flag(fetch_req),
  //outputs
      .araddr_m(araddr_m_inf[63:32]),   .arvalid_m(arvalid_m_inf[1]),
      .rready_m(rready_m_inf[1]),
      .inst_2_cpu(inst_comb),           .inst_valid(fetch_finish)
);

//####################################################################
//           AXI read:  Data read submodule
//####################################################################

//data_req
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                                          begin data_req <= 1'b0;     end 
  else if(rw_sram_finish|check_cache)                 begin data_req <= 1'b0;     end //TODO: do not need |check_cache?
  else if((next_state==s_LOAD)|(next_state==s_STORE)) begin data_req <= 1'b1;     end 
  else                                                begin data_req <= data_req; end
end
//write_mod
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                          begin write_mod <= 1'b0;      end 
  else if(rw_sram_finish|check_cache) begin write_mod <= 1'b0;      end //TODO: do not need |check_cache?
  else if(next_state==s_STORE)        begin write_mod <= 1'b1;      end 
  else                                begin write_mod <= write_mod; end
end
//check_cache
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                          begin check_cache <= 1'b0;        end
  else if(next_state==s_DECODE)       begin check_cache <= 1'b0;        end 
  else if(rw_sram_finish & write_mod) begin check_cache <= 1'b1;        end 
  else                                begin check_cache <= check_cache; end
end

//submodule
AXI_DATA_CACHE AXI_DATA_CACHE_INS(
  //inputs
      .clk(clk), .rst_n(rst_n),
      .arready_m(arready_m_inf[0]),
      .rdata_m(rdata_m_inf[15:0]),
      .rlast_m(rlast_m_inf[0]),       .rvalid_m(rvalid_m_inf[0]),
      .in_valid(data_req),            .en_write(write_mod),         .data_addr(data_addr2Cache),
      .in_data(data_2_Cache),
  //outputs
      .araddr_m(araddr_m_inf[31:0]),  .arvalid_m(arvalid_m_inf[0]),
      .rready_m(rready_m_inf[0]),
      .data_2_cpu(data_comb),         .out_valid(rw_sram_finish)
);



endmodule


//####################################################################
//           AXI read:  Inst. read submodule
//----------------------------------------------------
//    Input:      clk, rst_n
//                arready_m_inf[1],  
//                rid_m_inf[7:4],    rdata_m_inf[31:16],  rresp_m_inf[3:2], rlast_m_inf[1], rvalid_m_inf[1],
//                inst_addr[11:1],   search_flag
//        
//    Output:     araddr_m_inf[63:32], arvalid_m_inf[1], rready_m_inf[1],
//                inst_2_cpu[15:0],    inst_valid
// Global ports:  
//                arid_m_inf[7:4],   arsize_m_inf[5:3],   arburst_m_inf[3:2]
//####################################################################
module AXI_READ_INST(
//inputs
      clk, rst_n,
      arready_m,
      rdata_m,    rlast_m,      rvalid_m,
      inst_addr,  search_flag,
//outputs
      araddr_m,   arvalid_m,    rready_m,
      inst_2_cpu, inst_valid
);
// input port  
input wire clk, rst_n;
input wire arready_m;
input wire [15:0] rdata_m;
input wire rlast_m;
input wire rvalid_m;
input wire [10:0] inst_addr;
input wire search_flag;
// output port
output reg [31:0] araddr_m;
output reg arvalid_m;
output reg rready_m;
output wire [15:0] inst_2_cpu;
output reg inst_valid;
//----------------------------------------
//  Parameter
//----------------------------------------
parameter i_IDLE =           'd0;
parameter i_WAIT =           'd1;
parameter i_FIND =           'd2;
parameter i_MISS =           'd3;
parameter i_UPDATE =         'd4;
parameter i_FIND_AF_MISS  =  'd5;
parameter i_FIND_AF_MISS2 =  'd6;
//----------------------------------------
//  Regs and Wires
//----------------------------------------
reg fix_flag_comb, fix_flag;
reg [2:0] curr_state_ir, next_state_ir;
reg sram_avail;
reg [10:0] addr_center, addr_center_pre;

reg [2:0] inst_addr_pg;
reg       inst_addr_prefix;
reg [6:0] inst_addr_id;

reg [10:0] addr_lower;
reg [2:0] addr_upper;
reg [10:0] addr_lower_comp;
reg [10:0] addr_upper_comp;
reg [2:0] addr_lower_R, addr_upper_R;

reg lower_check_comb, upper_check_comb;
reg lower_check, upper_check;
//SRAM CTR------------------------------
wire addr_prefix;
reg [7:0] sram_addr;
reg [7:0] sram_addr_filter, sram_addr_filter_ff;
reg  sram_wen, sram_wen_ff;
reg [15:0] data_in, data_in_ff;
//--------------------------------------

//----------------------------------------
//  GLOBAL WIRES
//----------------------------------------
//  INSTRUCTION ADDR 32bit {19'b0,1'b1,12'h000}~{19'b0,1'b1,12'hfff}
//  valid range:  
//      {19'b0,1'b1,{11'b000_0000_0000},1'b0}
//  ~   {19'b0,1'b1,{11'b111_1111_1111},1'b0}
//----------------------------------------

always @(*) begin
  inst_addr_pg =     inst_addr[10:8];
  inst_addr_prefix = inst_addr[7];
  inst_addr_id =     inst_addr[6:0];
end

//----------------------------------------
//  OUTPUT CTR
//----------------------------------------

//araddr_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin araddr_m <= 32'b0;                          end
  else       begin araddr_m <= {19'b0,1'b1,{addr_lower},1'b0}; end
end
//arvalid_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                     begin arvalid_m <= 1'b0;      end
  else if(next_state_ir==i_MISS) begin arvalid_m <= 1'b1;      end
  else if(arready_m)             begin arvalid_m <= 1'b0;      end
  else                           begin arvalid_m <= arvalid_m; end
end
//rready_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)         begin rready_m <= 1'b0;     end
  else if(arready_m) begin rready_m <= 1'b1;     end
  else if(rlast_m)   begin rready_m <= 1'b0;     end
  else               begin rready_m <= rready_m; end
end
//inst_valid
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                         begin inst_valid <= 1'b0; end
  else if((curr_state_ir==i_FIND)&(next_state_ir==i_IDLE))
                                     begin inst_valid <= 1'b1; end
  else                               begin inst_valid <= 1'b0; end
end
//----------------------------------------
//  FSM CTR
//----------------------------------------

always @(*) begin
  if((addr_upper_R[0]!=addr_lower_R[0]) &
      ((inst_addr_pg==addr_upper_R & inst_addr_prefix)|(inst_addr_pg==addr_lower_R & ~inst_addr_prefix)))
        fix_flag = 1'b1;
  else  fix_flag = 1'b0;
end
//always @(posedge clk or negedge rst_n) begin
//  if(!rst_n)  fix_flag <= 1'b0;
//  else        fix_flag <= fix_flag_comb;
//end

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin curr_state_ir <= i_IDLE;        end
  else       begin curr_state_ir <= next_state_ir; end
end
always @(*) begin
  case(curr_state_ir)
    i_IDLE: begin   if(search_flag&(~inst_valid))         next_state_ir = i_WAIT;
                    else                    next_state_ir = i_IDLE; end
    i_WAIT: next_state_ir = i_FIND;
    i_FIND: begin   if((addr_prefix!=inst_addr_prefix)|(~sram_avail)|(~lower_check)|(~upper_check)|(fix_flag))
                                      begin next_state_ir = i_MISS; end
                    else              begin next_state_ir = i_IDLE; end end //HIT
    i_MISS: begin   if(arvalid_m&arready_m) next_state_ir = i_UPDATE;
                    else                    next_state_ir = i_MISS; end
    i_UPDATE: begin if(rlast_m)             next_state_ir = i_FIND_AF_MISS;
                    else                    next_state_ir = i_UPDATE; end
    i_FIND_AF_MISS:                   begin next_state_ir = i_FIND_AF_MISS2; end //why need this state? to get addr_prefix
    i_FIND_AF_MISS2:                  begin next_state_ir = i_FIND; end //why need this state? to get addr_prefix
    default:                          begin next_state_ir = i_IDLE; end
  endcase
end

//----------------------------------------
//  addr bound
//----------------------------------------

//addr_center
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                      begin addr_center <= 11'b0; end
  else if((search_flag)&(curr_state_ir==i_IDLE))
                                  begin addr_center <= inst_addr;   end 
  else                            begin addr_center <= addr_center; end
end
//addr_lower
always @(*) begin addr_lower_comp = addr_center -'d63; end
always @(*) begin
  if(addr_center<='d63)      begin addr_lower = 11'd0; end
  else begin
    if(addr_center>11'd1983) begin addr_lower = 11'd1920;        end 
    else                     begin addr_lower = addr_lower_comp; end
  end
end
//addr_lower_R
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                     begin addr_lower_R <= 3'b0;             end
  else if(next_state_ir==i_MISS) begin addr_lower_R <= addr_lower[10:8]; end
  else                           begin addr_lower_R <= addr_lower_R;     end  
end
//addr_upper
always @(*) begin addr_upper_comp = addr_center + 'd64; end
always @(*) begin
  if(addr_center<='d63)      begin addr_upper = 3'd0; end
  else begin
    if(addr_center>11'd1983) begin addr_upper = 3'd7;                  end
    else                     begin addr_upper = addr_upper_comp[10:8]; end
  end
end
//addr_upper_R
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                     begin addr_upper_R <= 3'b0;         end  
  else if(next_state_ir==i_MISS) begin addr_upper_R <= addr_upper;   end  
  else                           begin addr_upper_R <= addr_upper_R; end
end


always @(*) begin
  lower_check = (inst_addr_pg>=addr_lower_R);
  upper_check = (inst_addr_pg<=addr_upper_R);
end
//always @(posedge clk or negedge rst_n) begin
//  if(!rst_n) begin
//    lower_check <= 1'b0;
//    upper_check <= 1'b0;
//  end
//  else begin
//    lower_check <= lower_check_comb;
//    upper_check <= upper_check_comb;
//  end
//end

//----------------------------------------
//  SRAM MACRO
//----------------------------------------

//sram_avail
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                       begin sram_avail <= 1'b0;       end
  else if(curr_state_ir==i_UPDATE) begin sram_avail <= 1'b1;       end
  else                             begin sram_avail <= sram_avail; end
end
//sram_addr
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                       begin sram_addr <= 8'b0;            end
  else if(next_state_ir==i_MISS)   begin sram_addr <= addr_lower[7:0]; end
  else if(((rvalid_m)&(rready_m))) begin sram_addr <= sram_addr + 'b1; end
  else                             begin sram_addr <= sram_addr;       end
end
//sram_addr_filter
always @(*) begin
  if(curr_state_ir==i_UPDATE) begin sram_addr_filter = sram_addr[7:0]; end
  else                        begin sram_addr_filter = inst_addr[7:0]; end
end
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  sram_addr_filter_ff <= 8'b0;
  else        sram_addr_filter_ff <= sram_addr_filter;
end
//sram_wen
always @(*) begin
    case(curr_state_ir)
      i_UPDATE: begin
        sram_wen = ~((rvalid_m)&(rready_m));
      end
      default:  sram_wen = 1'b1;
    endcase
  //sram_wen = ~((rvalid_m)&(rready_m));
end
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  sram_wen_ff <= 1'b1;
  else        sram_wen_ff <= sram_wen;
end

//data_in
always @(*) begin
  case(curr_state_ir)
    i_UPDATE: begin
      data_in = rdata_m;
    end
    default: begin
      data_in = 16'b0;
    end
  endcase
end
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  data_in_ff <= 16'b0;
  else        data_in_ff <= data_in;
end

//SRAM(.Q({addr_prefix, inst_2_cpu}), .CLK(clk), .CEN(1'b0), .WEN(sram_wen), .A(sram_addr_filter[6:0]), .D({sram_addr_filter[7],data_in}), .OEN(1'b0));

SUMA180_128X17X1BM1 SRAM_inst(
    .A0(sram_addr_filter_ff[0]), .A1(sram_addr_filter_ff[1]), .A2(sram_addr_filter_ff[2]), .A3(sram_addr_filter_ff[3]),
    .A4(sram_addr_filter_ff[4]), .A5(sram_addr_filter_ff[5]), .A6(sram_addr_filter_ff[6]),
     .DO0(inst_2_cpu[ 0]),  .DO1(inst_2_cpu[ 1]),  .DO2(inst_2_cpu[ 2]),  .DO3(inst_2_cpu[ 3]),
     .DO4(inst_2_cpu[ 4]),  .DO5(inst_2_cpu[ 5]),  .DO6(inst_2_cpu[ 6]),  .DO7(inst_2_cpu[ 7]),
     .DO8(inst_2_cpu[ 8]),  .DO9(inst_2_cpu[ 9]), .DO10(inst_2_cpu[10]), .DO11(inst_2_cpu[11]),
    .DO12(inst_2_cpu[12]), .DO13(inst_2_cpu[13]), .DO14(inst_2_cpu[14]), .DO15(inst_2_cpu[15]),
    .DO16(addr_prefix),
     .DI0(data_in_ff[ 0]),  .DI1(data_in_ff[ 1]),  .DI2(data_in_ff[ 2]),  .DI3(data_in_ff[ 3]),
     .DI4(data_in_ff[ 4]),  .DI5(data_in_ff[ 5]),  .DI6(data_in_ff[ 6]),  .DI7(data_in_ff[ 7]),
     .DI8(data_in_ff[ 8]),  .DI9(data_in_ff[ 9]), .DI10(data_in_ff[10]), .DI11(data_in_ff[11]),
    .DI12(data_in_ff[12]), .DI13(data_in_ff[13]), .DI14(data_in_ff[14]), .DI15(data_in_ff[15]),
    .DI16(sram_addr_filter_ff[7]),
    .CK(clk), .WEB(sram_wen_ff), .OE(1'b1), .CS(1'b1));



endmodule

//####################################################################
//           AXI read:  Data read submodule
//----------------------------------------------------
//    Input:      clk, rst_n
//                arready_m_inf[0],  
//                rid_m_inf[3:0],   rdata_m_inf[15:0],  rresp_m_inf[1:0], rlast_m_inf[0], rvalid_m_inf[0],                
//                in_valid,          en_write,          data_addr[11:1],  in_data[15:0]  
//
//    Output:     araddr_m_inf[31:0], arvalid_m_inf[0], rready_m_inf[0]
//                data_2_cpu[15:0],  out_valid
// Global ports:  
//                arid_m_inf[3:0], arsize_m_inf[2:0],   arburst_m_inf[1:0]
//####################################################################
module AXI_DATA_CACHE(
//inputs
      clk, rst_n,
      arready_m,
      rdata_m,    rlast_m,     rvalid_m,
      in_valid,   en_write,    data_addr, in_data,
//outputs
      araddr_m,    arvalid_m,  rready_m,
      data_2_cpu, out_valid
);
// input port  
input  wire clk, rst_n;
input wire arready_m;
input wire [15:0] rdata_m;
input wire rlast_m;
input wire rvalid_m;

input wire in_valid;
input wire en_write;
input wire [10:0] data_addr;
input wire [15:0] in_data;
// output port
output reg [31:0] araddr_m;
output reg arvalid_m;
output reg rready_m;
output wire [15:0] data_2_cpu;
output reg out_valid;
//----------------------------------------
//  Parameter
//----------------------------------------
parameter d_IDLE =           'd0;
parameter d_WAIT =           'd1;
parameter d_FIND =           'd2;
parameter d_MISS =           'd3;
parameter d_UPDATE =         'd4;
parameter d_FIND_AF_MISS =   'd5;
parameter d_WRITE =          'd6;
parameter d_FIND_AF_MISS2 =  'd7;
//----------------------------------------
//  Regs and Wires
//----------------------------------------
reg fix_flag;
reg [2:0] curr_state_dr, next_state_dr;
reg sram_avail;
reg [10:0] addr_center;

reg [2:0] data_addr_pg;
reg       data_addr_prefix;
reg [6:0] data_addr_id;

reg [10:0] addr_lower;
reg [2:0]  addr_upper;
reg [10:0] addr_lower_comp;
reg [10:0] addr_upper_comp;
reg [2:0] addr_lower_R, addr_upper_R;

reg lower_check, upper_check;
//SRAM CTR------------------------------
wire addr_prefix;
reg [7:0] sram_addr;
reg [7:0] sram_addr_filter, sram_addr_filter_ff;
reg  sram_wen, sram_wen_ff;
reg [15:0] data_filter, data_filter_ff; 
//--------------------------------------

//----------------------------------------
//  GLOBAL WIRES
//----------------------------------------

always @(*) begin
  data_addr_pg =     data_addr[10:8];
  data_addr_prefix = data_addr[7];
  data_addr_id =     data_addr[6:0];
end

//----------------------------------------
//  OUTPUT CTR
//----------------------------------------

//araddr_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin araddr_m <= 32'b0;                          end
  else       begin araddr_m <= {19'b0,1'b1,{addr_lower},1'b0}; end
end
//arvalid_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                     begin arvalid_m <= 1'b0;      end
  else if(next_state_dr==d_MISS) begin arvalid_m <= 1'b1;      end
  else if(arready_m)             begin arvalid_m <= 1'b0;      end
  else                           begin arvalid_m <= arvalid_m; end
end
//rready_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)         begin rready_m <= 1'b0;     end
  else if(arready_m) begin rready_m <= 1'b1;     end
  else if(rlast_m)   begin rready_m <= 1'b0;     end
  else               begin rready_m <= rready_m; end
end
//out_valid
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                         begin out_valid <= 1'b0; end
  else if(((curr_state_dr==d_FIND)&(next_state_dr==d_IDLE))|(curr_state_dr==d_WRITE))
                                     begin out_valid <= 1'b1; end
  else                               begin out_valid <= 1'b0; end
end

//----------------------------------------
//  FSM CTR
//----------------------------------------

//fix_flag
always @(*) begin
  if((addr_upper_R[0]!=addr_lower_R[0])&(((data_addr_pg==addr_upper_R)&(data_addr_prefix==1'b1))|((data_addr_pg==addr_lower_R)&(data_addr_prefix==1'b0))))
        fix_flag = 1'b1;
  else  fix_flag = 1'b0;
end

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin curr_state_dr <= d_IDLE;        end
  else       begin curr_state_dr <= next_state_dr; end
end
always @(*) begin
  case(curr_state_dr)
    d_IDLE: begin     if(in_valid&~out_valid) next_state_dr = d_WAIT;
                      else                    next_state_dr = d_IDLE; end
    d_WAIT: next_state_dr = d_FIND;
    d_FIND: begin     if((addr_prefix!=data_addr_prefix)|(~sram_avail)|(~lower_check)|(~upper_check)|(fix_flag))
                                 begin next_state_dr = d_MISS; end
                      else begin
                          if(en_write) begin next_state_dr = d_WRITE; end //HIT
                          else         begin next_state_dr = d_IDLE;  end //HIT
                      end end
    d_MISS: begin     if(arvalid_m&arready_m) begin next_state_dr = d_UPDATE; end
                      else                    begin next_state_dr = d_MISS;   end end
    d_UPDATE: begin   if(rlast_m)begin
                        if(en_write)          begin next_state_dr = d_WRITE;        end 
                        else                  begin next_state_dr = d_FIND_AF_MISS; end
                      end
                      else                    next_state_dr = d_UPDATE; end
    d_FIND_AF_MISS: begin                     next_state_dr = d_FIND_AF_MISS2; end
    d_FIND_AF_MISS2:begin                     next_state_dr = d_FIND;          end
    d_WRITE:        begin                     next_state_dr = d_IDLE; end //TODO: delay one cycle?
    default:        begin                     next_state_dr = d_IDLE; end
  endcase
end

//----------------------------------------
//  addr bound
//----------------------------------------

//addr_center
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                      begin addr_center <= 11'b0; end
  else if((in_valid)&(curr_state_dr==d_IDLE))
                                  begin addr_center <= data_addr;   end 
  else                            begin addr_center <= addr_center; end
end
//addr_lower
always @(*) addr_lower_comp = addr_center -'d63;
always @(*) begin
  if(addr_center<='d63)       begin addr_lower = 11'd0; end
  else begin
    if(addr_center>11'd1983)  begin addr_lower = 11'd1920;        end 
    else                      begin addr_lower = addr_lower_comp; end
  end
end
//addr_lower_R
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                     begin addr_lower_R <= 3'b0;             end
  else if(next_state_dr==d_MISS) begin addr_lower_R <= addr_lower[10:8]; end
  else                           begin addr_lower_R <= addr_lower_R;     end
end
//addr_upper
always @(*) addr_upper_comp = addr_center + 'd64;
always @(*) begin
  if(addr_center<='d63)    begin addr_upper = 3'd0; end
  else begin
    if(addr_center>'d1983) begin addr_upper = 3'd7;                  end
    else                   begin addr_upper = addr_upper_comp[10:8]; end
  end
end
//addr_upper_R
always @(posedge clk or negedge rst_n)begin
  if(~rst_n)                     begin addr_upper_R <= 3'b0;         end
  else if(next_state_dr==d_MISS) begin addr_upper_R <= addr_upper;   end
  else                           begin addr_upper_R <= addr_upper_R; end
end

always @(*) begin
  lower_check = (data_addr_pg>=addr_lower_R);
  upper_check = (data_addr_pg<=addr_upper_R);
end

//----------------------------------------
//  SRAM MACRO
//----------------------------------------

//sram_avail
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                       begin sram_avail <= 1'b0;       end  
  else if(curr_state_dr==d_UPDATE) begin sram_avail <= 1'b1;       end
  else                             begin sram_avail <= sram_avail; end
end
//sram_addr
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                       begin sram_addr <= 8'b0;            end
  else if(next_state_dr==d_MISS)   begin sram_addr <= addr_lower[7:0]; end
  else if(((rvalid_m)&(rready_m))) begin sram_addr <= sram_addr + 'b1; end
  else                             begin sram_addr <= sram_addr;       end  
end
//sram_addr_filter
always @(*) begin
  if(curr_state_dr==d_UPDATE) begin sram_addr_filter = sram_addr[7:0]; end
  else                        begin sram_addr_filter = data_addr[7:0]; end
end
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  sram_addr_filter_ff <= 8'b0;
  else        sram_addr_filter_ff <= sram_addr_filter;
end
//sram_wen
always @(*) begin
    case(curr_state_dr)
      d_UPDATE: begin
        sram_wen = ~((rvalid_m)&(rready_m));
      end
      d_WRITE:  begin sram_wen = 1'b0;                     end
      default:  begin sram_wen = 1'b1;                     end
    endcase
  //if(curr_state_dr==d_UPDATE)     begin sram_wen = ~((rvalid_m)&(rready_m)); end
  //else if(curr_state_dr==d_WRITE) begin sram_wen = 1'b0;                     end
  //else                            begin sram_wen = 1'b1;                     end
end
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  sram_wen_ff <= 1'b1;
  else        sram_wen_ff <= sram_wen;
end

//data_filter
always @(*) begin
  case(curr_state_dr)
    d_UPDATE: begin
      data_filter = rdata_m;
    end
    default:  begin
      data_filter = in_data;
    end
  endcase
  //if(curr_state_dr==d_UPDATE) begin data_filter = rdata_m; end
  //else                        begin data_filter = in_data; end
end
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  data_filter_ff <= 16'b0;
  else        data_filter_ff <= data_filter;
end

//SRAM(.Q({addr_prefix, data_2_cpu}), .CLK(clk), .CEN(1'b0), .WEN(sram_wen), .A(sram_addr_filter[6:0]), .D({sram_addr_filter[7],data_filter}), .OEN(1'b0));

SUMA180_128X17X1BM1 SRAM_data(
    .A0(sram_addr_filter_ff[0]), .A1(sram_addr_filter_ff[1]), .A2(sram_addr_filter_ff[2]), .A3(sram_addr_filter_ff[3]),
    .A4(sram_addr_filter_ff[4]), .A5(sram_addr_filter_ff[5]), .A6(sram_addr_filter_ff[6]),
     .DO0(data_2_cpu[ 0]),  .DO1(data_2_cpu[ 1]),  .DO2(data_2_cpu[ 2]),  .DO3(data_2_cpu[ 3]),
     .DO4(data_2_cpu[ 4]),  .DO5(data_2_cpu[ 5]),  .DO6(data_2_cpu[ 6]),  .DO7(data_2_cpu[ 7]),
     .DO8(data_2_cpu[ 8]),  .DO9(data_2_cpu[ 9]), .DO10(data_2_cpu[10]), .DO11(data_2_cpu[11]),
    .DO12(data_2_cpu[12]), .DO13(data_2_cpu[13]), .DO14(data_2_cpu[14]), .DO15(data_2_cpu[15]),
    .DO16(addr_prefix),
     .DI0(data_filter_ff[ 0]),  .DI1(data_filter_ff[ 1]),  .DI2(data_filter_ff[ 2]),  .DI3(data_filter_ff[ 3]),
     .DI4(data_filter_ff[ 4]),  .DI5(data_filter_ff[ 5]),  .DI6(data_filter_ff[ 6]),  .DI7(data_filter_ff[ 7]),
     .DI8(data_filter_ff[ 8]),  .DI9(data_filter_ff[ 9]), .DI10(data_filter_ff[10]), .DI11(data_filter_ff[11]),
    .DI12(data_filter_ff[12]), .DI13(data_filter_ff[13]), .DI14(data_filter_ff[14]), .DI15(data_filter_ff[15]),
    .DI16(sram_addr_filter_ff[7]),
    .CK(clk), .WEB(sram_wen_ff), .OE(1'b1), .CS(1'b1));



endmodule



//####################################################################
//           AXI write/response: STORE submodule
//----------------------------------------------------
//    Input:      clk, rst_n,
//                awready_m_inf,  
//                wready_m_inf,   
//                bresp_m_inf[1:0],   bvalid_m_inf,
//                data_addr[11:1],     data_content[15:0], in_valid
//    Output:     awaddr_m_inf[31:0],  awvalid_m_inf,  
//                wdata_m_inf[15:0],   wlast_m_inf,       wvalid_m_inf,
//                bready_m_inf,
//                out_valid
// Global ports:  
//                awid_m_inf, awsize_m_inf, awburst_m_inf, awlen_m_inf
//####################################################################
module AXI_DATA_WRITE(
//inputs
      clk, rst_n,
      awready_m,
      wready_m,
      bvalid_m,
      data_addr,  data_content, in_valid,
//outputs
      awaddr_m,   awvalid_m,
      wdata_m,    wlast_m,    wvalid_m,
      bready_m,
      out_valid
);
// input port  
input wire clk, rst_n;
input wire awready_m;
input wire wready_m;
input wire bvalid_m;
input wire [10:0] data_addr;
input wire [15:0] data_content;
input wire in_valid;
// output port
output reg [31:0] awaddr_m;
output reg awvalid_m;
output reg [15:0] wdata_m;
output reg wlast_m;
output reg wvalid_m;
output reg bready_m;
output reg out_valid;
//----------------------------------------
//  Parameter
//----------------------------------------
parameter w_IDLE =  'd0;
parameter w_CONN =  'd1;
parameter w_WRITE = 'd2;
parameter w_BRES =  'd3;
//----------------------------------------
//  Regs and Wires
//----------------------------------------
reg [1:0] curr_state_dw, next_state_dw;
//----------------------------------------
//  GLOBAL WIRES
//----------------------------------------
//----------------------------------------
//  OUTPUT CTR
//----------------------------------------
//awaddr_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)        begin awaddr_m <= 32'b0;                         end
  else if(in_valid) begin awaddr_m <= {19'b0,1'b1,{data_addr},1'b0}; end
  else              begin awaddr_m <= awaddr_m;                      end
end
//awvalid_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                     begin awvalid_m <= 1'b0; end
  else if(next_state_dw==w_CONN) begin awvalid_m <= 1'b1; end
  else                           begin awvalid_m <= 1'b0; end
end
//wdata_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                    begin wdata_m <= 16'b0;        end
  else if(in_valid)             begin wdata_m <= data_content; end
  else                          begin wdata_m <= wdata_m;      end
end
//wlast_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                      begin wlast_m <= 1'b0; end
  else if(next_state_dw==w_WRITE) begin wlast_m <= 1'b1; end
  else                            begin wlast_m <= 1'b0; end
end
//wvalid_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                      begin wvalid_m <= 1'b0; end
  else if(next_state_dw==w_WRITE) begin wvalid_m <= 1'b1; end
  else                            begin wvalid_m <= 1'b0; end
end
//bready_m
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                     begin bready_m <= 1'b0; end
  else if(next_state_dw==w_BRES) begin bready_m <= 1'b1; end
  else                           begin bready_m <= 1'b0; end
end
//out_valid
always @(posedge clk or negedge rst_n) begin
  if(~rst_n)                      begin out_valid <= 1'b0; end
  else if((bvalid_m)&(bready_m)) //&(bresp_m==2'b00)
                                  begin out_valid <= 1'b1; end
  else                            begin out_valid <= 1'b0; end
end
//----------------------------------------
//  FSM CTR
//----------------------------------------
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin curr_state_dw <= w_IDLE;        end
  else       begin curr_state_dw <= next_state_dw; end
end
always @(*)begin
  case(curr_state_dw)
    w_IDLE: begin if(in_valid&~out_valid) next_state_dw = w_CONN;
                  else                    next_state_dw = w_IDLE; end
    w_CONN: begin if(awready_m)           next_state_dw = w_WRITE;
                  else                    next_state_dw = w_CONN; end
    w_WRITE: begin  if(wready_m)          next_state_dw = w_BRES;
                    else                  next_state_dw = w_WRITE; end
    w_BRES: begin if((bvalid_m)&(bready_m)) next_state_dw = w_IDLE; //&(bresp_m==2'b00)
                  else                      next_state_dw = w_BRES; end
    default:      next_state_dw = w_IDLE;
  endcase
end



endmodule
