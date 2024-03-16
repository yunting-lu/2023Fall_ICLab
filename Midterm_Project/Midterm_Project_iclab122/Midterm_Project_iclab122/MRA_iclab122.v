//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Midterm Proejct            : MRA  
//   Author                     : Lin-Hung, Lai
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//   Release version : V2.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
    loc_y         	,
	cost	 		,		
	busy         	,

    // AXI4 IO
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
	   rready_m_inf,
	
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
	   bready_m_inf 
);

// ===============================================================
//  					Parameter Declaration 
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32; 

// ===============================================================
//  					Input / Output 
// ===============================================================

// << CHIP io port with system >>
input 			  	clk,rst_n;
input 			   	in_valid;
input  [4:0] 		frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;       
  
// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       Your AXI-4 interface could be designed as a bridge in submodule,
	   therefore I declared output of AXI as wire.  
	   Ex: AXI4_interface AXI4_INF(...);
*/

// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf; //0
output wire [1:0]            arburst_m_inf; //INCR
output wire [2:0]             arsize_m_inf; //128
output wire [7:0]              arlen_m_inf; //128
output reg                  arvalid_m_inf; //
input  wire                  arready_m_inf; 
output wire [ADDR_WIDTH-1:0]  araddr_m_inf; 
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf; //don't care
input  wire                   rvalid_m_inf; 
output reg                   rready_m_inf; //
input  wire [DATA_WIDTH-1:0]   rdata_m_inf; 
input  wire                    rlast_m_inf; 
input  wire [1:0]              rresp_m_inf; //OKAY, don't care
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf; //0
output wire [1:0]            awburst_m_inf; //INCR
output wire [2:0]             awsize_m_inf; //128
output wire [7:0]              awlen_m_inf; //128
output reg                  awvalid_m_inf; //
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf; //
// -------------------------
// (2)	axi write data channel 
output reg                   wvalid_m_inf; //
input  wire                   wready_m_inf; 
output reg [DATA_WIDTH-1:0]   wdata_m_inf; //
output reg                    wlast_m_inf; //
// -------------------------
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf; //don't care
input  wire                   bvalid_m_inf;
output reg                   bready_m_inf; //
input  wire  [1:0]             bresp_m_inf; //OKAY, don't care
// -----------------------------

//-------------------------------------------
//  Global AXI parameter setting
//-------------------------------------------

assign arid_m_inf = 4'b0;
assign arburst_m_inf = 2'b01; //INCR
assign arsize_m_inf = 3'b100; //16bytes(128bits)
assign arlen_m_inf = 8'd127;

assign awid_m_inf = 4'b0;
assign awburst_m_inf = 2'b01; //INCR
assign awsize_m_inf = 3'b100; //16bytes(128bits)
assign awlen_m_inf = 8'd127;

// ===============================================================
//  					Wire / Reg Declaration 
// ===============================================================

//FSM
reg [3:0] curr_state, next_state;
parameter IDLE			= 4'b0000; //'d0;  0
parameter WAIT_ARREADY	= 4'b0001; //'d1;  1
parameter GET_FRAME		= 4'b0011; //'d2;  3
parameter WAIT_WEIGHT	= 4'b0010; //'d3;  2
parameter SOURCE_INIT	= 4'b0110; //'d4;  6
parameter FILLING		= 4'b0111; //'d5;  7
parameter RETRACE_READ	= 4'b0101; //'d6;  5
parameter RETRACE_WRITE = 4'b0100; //'d7;  4
parameter CLEAR_MAP 	= 4'b1100; //'d8;  12
parameter WAIT_AWREADY	= 4'b1101; //'d9;  13
parameter WRITE_BACK	= 4'b1111; //'d10; 15
parameter WAIT_BVALID	= 4'b1110; //'d11; 14

reg frame_ready, frame_ready_comb;
reg weight_ready, weight_ready_comb;

integer i, j;

//AXI-4
wire [3:0] weight_or_frame;

//INPUT
reg [4:0] cnt_input;
reg [4:0] frame_id_reg;
reg [3:0] net_id_reg[0:14];
reg [5:0] source_x_reg[0:14];
reg [5:0] source_y_reg[0:14];
reg [5:0] sink_x_reg[0:14];
reg [5:0] sink_y_reg[0:14];
wire [3:0] s_idx;
reg [3:0] cur_net;
wire [5:0] cur_source_x, cur_source_y, cur_sink_x, cur_sink_y;
wire [3:0] cur_net_id;

//OUTPUT
reg [13:0]	cost_comb;
reg			busy_comb;

//CALC
wire [6:0] retrace_addr;
reg [6:0] addr, addr_comb;
wire [6:0] addr_p1;
wire [5:0] map_y;
wire [5:0] map_x_offset;
reg [1:0] cnt_cur_seq;
reg [1:0] cur_seq;
reg [1:0] Location_Map[0:63][0:63];
reg [1:0] Location_Map_nxt[0:63][0:63];
reg [5:0] trace_x, trace_y, trace_x_nxt, trace_y_nxt;

reg [6:0] trans_loc;
reg [3:0] weight, weight_comb;

//SRAM
reg [6:0] addr_f, addr_w;
reg [127:0] data_in_f, data_in_w;
reg [127:0] data_out_f, data_out_w;
reg wen_f, wen_w; //1 for read, 0 for write

// ===============================================================
//  					FSM 
// ===============================================================

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	curr_state <= IDLE;
	else		curr_state <= next_state;
end
always @(*) begin
	//next_state = curr_state;
	case(curr_state)
		IDLE: 	if(in_valid)	next_state = WAIT_ARREADY;
				else			next_state = IDLE;
		WAIT_ARREADY: begin
			if(arready_m_inf) begin
				if(frame_ready)	next_state = SOURCE_INIT;
				else			next_state = GET_FRAME;
			end
			else					next_state = WAIT_ARREADY;
		end
		GET_FRAME:	if(rlast_m_inf)	next_state = WAIT_ARREADY;
					else			next_state = GET_FRAME;
		//GET_WEIGHT:	if(rlast_m_inf)	next_state = SOURCE_INIT;
		//				else			next_state = GET_WEIGHT;
		SOURCE_INIT:				next_state = FILLING;
		FILLING:	if(Location_Map[cur_sink_y][cur_sink_x][1] && !weight_ready)	next_state = WAIT_WEIGHT;
					else if(Location_Map[cur_sink_y][cur_sink_x][1])				next_state = RETRACE_READ;
					else															next_state = FILLING;
		WAIT_WEIGHT:	if(rlast_m_inf)	next_state = RETRACE_READ; //weight_ready
						else				next_state = WAIT_WEIGHT;
		RETRACE_READ:	next_state = RETRACE_WRITE;
		RETRACE_WRITE:	if(trace_y_nxt==cur_source_y && trace_x_nxt==cur_source_x)	next_state = CLEAR_MAP;
						else														next_state = RETRACE_READ;
		CLEAR_MAP:	if((cur_net+'d1)==s_idx)	next_state = WAIT_AWREADY;
					else						next_state = SOURCE_INIT;
		WAIT_AWREADY:	if(awready_m_inf)	next_state = WRITE_BACK;
						else				next_state = WAIT_AWREADY;
		WRITE_BACK:	if(addr=='d127)	next_state = WAIT_BVALID;
					else			next_state = WRITE_BACK;
		WAIT_BVALID:	if(bvalid_m_inf)	next_state = IDLE;
						else				next_state = WAIT_BVALID;
		default: begin
			next_state = IDLE;
		end
	endcase
end

//frame_ready
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	frame_ready <= 1'b0;
	else		frame_ready <= frame_ready_comb;
end
//weight_ready
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	weight_ready <= 1'b0;
	else		weight_ready <= weight_ready_comb;
end

// ===============================================================
//  					AXI-4
// ===============================================================


assign araddr_m_inf = {12'd0, weight_or_frame, frame_id_reg, 11'd0};
assign awaddr_m_inf = {12'd0, 4'd1, frame_id_reg, 11'd0}; //only need to write frame

//weight_or_frame
assign weight_or_frame = (frame_ready)? 4'd2 : 4'd1; //4'd1 for frame, 4'd2 for weight 


always @(*) begin
	frame_ready_comb = frame_ready;
	weight_ready_comb = weight_ready;
	arvalid_m_inf = 1'b0;
	rready_m_inf  = 1'b0;
	awvalid_m_inf = 1'b0;
	wvalid_m_inf  = 1'b0;
	wdata_m_inf   = 128'd0;
	wlast_m_inf   = 1'b0;
	bready_m_inf  = 1'b0;

	case(curr_state)
		IDLE: begin
			frame_ready_comb = 1'b0;
			weight_ready_comb = 1'b0;
		end
		WAIT_ARREADY: begin
			arvalid_m_inf = 1'b1;
		end
		GET_FRAME: begin
			if(rlast_m_inf)	frame_ready_comb = 1'b1; //addr=='d127
			rready_m_inf = 1'b1;
		end
		SOURCE_INIT, FILLING, WAIT_WEIGHT: begin //GET_WEIGHT
			if(rlast_m_inf)	weight_ready_comb = 1'b1;
			if(!weight_ready)	rready_m_inf = 1'b1;
		end
		WAIT_AWREADY: begin
			awvalid_m_inf = 1'b1;
		end
		WRITE_BACK: begin
			wvalid_m_inf = 1'b1;
			wdata_m_inf = data_out_f;
			if(addr=='d127)	wlast_m_inf = 1'b1;
			bready_m_inf = 1'b1;
		end
		WAIT_BVALID: begin
			bready_m_inf = 1'b1;
		end
	endcase
end

// ===============================================================
//  					INPUT 
// ===============================================================

assign s_idx = cnt_input[4:1];

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	cnt_input <= 5'd0;
	else begin
		if(in_valid)				cnt_input <= cnt_input + 'd1;
		else if(curr_state==IDLE)	cnt_input <= 5'd0;
		else						cnt_input <= cnt_input;
	end
end
//frame_id
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)			frame_id_reg <= 'd0;
	else if(in_valid)	frame_id_reg <= frame_id;
	else				frame_id_reg <= frame_id_reg;
end

//source, net_id
genvar sour_idx;
generate
	for(sour_idx = 0; sour_idx < 15; sour_idx = sour_idx+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) begin
				net_id_reg[sour_idx] <= 'd0;
				source_x_reg[sour_idx] <= 'd0;
				source_y_reg[sour_idx] <= 'd0;
			end
			else begin
				if(in_valid && (~cnt_input[0]) && (sour_idx==s_idx)) begin
					net_id_reg[sour_idx] <= net_id;
					source_x_reg[sour_idx] <= loc_x;
					source_y_reg[sour_idx] <= loc_y;
				end
			end
		end
	end
endgenerate

//sink
genvar sink_idx;
generate
	for(sink_idx = 0;sink_idx < 15;sink_idx = sink_idx+1) begin
		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) begin
				sink_x_reg[sink_idx] <= 'd0;
				sink_y_reg[sink_idx] <= 'd0;
			end
			else begin
				if(in_valid && cnt_input[0] && (sink_idx==s_idx)) begin
					sink_x_reg[sink_idx] <= loc_x;
					sink_y_reg[sink_idx] <= loc_y;
				end
			end
		end
	end
endgenerate

//cur_net
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	cur_net <= 'd0;
	else begin
		//if finish one trace, plus one 
		if(curr_state==IDLE)			cur_net <= 'd0;
		else if(curr_state==CLEAR_MAP)	cur_net <= cur_net + 'd1;
		else 							cur_net <= cur_net;
	end
end
//cur_source, cur_sink
assign cur_source_x = source_x_reg[cur_net];
assign cur_source_y = source_y_reg[cur_net];
assign cur_sink_x	= sink_x_reg[cur_net];
assign cur_sink_y	= sink_y_reg[cur_net];
assign cur_net_id	= net_id_reg[cur_net];

// ===============================================================
//  					CALC 
// ===============================================================

/* SRAM related */
//write data from DRAM to SRAM
//retrace read/write
//SRAM_FRAME to DRAM

assign retrace_addr = {trace_y, trace_x[5]};
assign addr_p1 = addr + 'd1;

always @(*) begin
	addr_comb = 'd0;
	addr_w = 'd0;
	addr_f = 'd0;
	wen_w = 1'b1;
	wen_f = 1'b1;
	data_in_w = 'd0;
	data_in_f = rdata_m_inf;

	case(curr_state)
		GET_FRAME: begin
			if(rvalid_m_inf) begin
				addr_comb = addr_p1;
				wen_f = 1'b0;
			end
			else begin
				addr_comb = addr;
				//wen_f = 1'b1;
			end
			addr_f = addr;
			//data_in_f = rdata_m_inf;
		end
		SOURCE_INIT, FILLING, WAIT_WEIGHT: begin //GET_WEIGHT
			if(!weight_ready) begin
				if(rvalid_m_inf) begin
					addr_comb = addr_p1;
					wen_w = 1'b0;
				end
				else begin
					addr_comb = addr;
					//wen_w = 1'b1;
				end
			end
			addr_w = addr;
			data_in_w = rdata_m_inf;
		end
		RETRACE_READ: begin
			addr_w = retrace_addr;
			addr_f = retrace_addr;
		end
		RETRACE_WRITE: begin
			addr_w = retrace_addr;
			addr_f = retrace_addr;
			wen_f = 1'b0;
			data_in_f = data_out_f;
			data_in_f[trans_loc] = cur_net_id[0];
			data_in_f[trans_loc+'d1] = cur_net_id[1];
			data_in_f[trans_loc+'d2] = cur_net_id[2];
			data_in_f[trans_loc+'d3] = cur_net_id[3];
		end
		WRITE_BACK: begin
			if(wready_m_inf)	addr_comb = addr_p1;
			else				addr_comb = addr;
			if(wready_m_inf)	addr_f = addr_p1;
		end
	endcase
end

//addr
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	addr <= 'd0;
	else 		addr <= addr_comb;
end

//* translate location in Location_Map to SRAM place
assign trans_loc = {trace_x[4:0], 2'd0};

/* read weight from SRAM_WEIGHT and accumulate to cost */
//weight
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	weight <= 'd0;
	else		weight <= weight_comb;
end
always @(*) begin
	case(curr_state)
		RETRACE_WRITE: begin
			if(trace_x==cur_sink_x && trace_y==cur_sink_y)	weight_comb = 'd0;
			else begin
				weight_comb[0] = data_out_w[trans_loc];
				weight_comb[1] = data_out_w[trans_loc+'d1];
				weight_comb[2] = data_out_w[trans_loc+'d2];
				weight_comb[3] = data_out_w[trans_loc+'d3];
			end
		end
		default: weight_comb = 'd0;
	endcase
end


/* write macro to location map at GET_FRAME */
//map_y
assign map_y = addr[6:1];
//map_x_offset
assign map_x_offset = (addr[0]) ? 6'd32 : 6'd0;

/* create sequence for filling and retrace */
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	cnt_cur_seq <= 'd0;
	else begin
		case(curr_state)
			SOURCE_INIT:	cnt_cur_seq <= 'd1;
			FILLING:		if(Location_Map[cur_sink_y][cur_sink_x][1])	cnt_cur_seq <= cnt_cur_seq - 'd2;
							else										cnt_cur_seq <= cnt_cur_seq + 'd1;
			WAIT_WEIGHT, RETRACE_READ:	cnt_cur_seq <= cnt_cur_seq;
			RETRACE_WRITE:	cnt_cur_seq <= cnt_cur_seq - 'd1;
			default:		cnt_cur_seq <= 'd0;
		endcase
	end
end
always @(*) begin
	case(cnt_cur_seq)
		2'd0:	cur_seq = 2'd2;
		2'd1:	cur_seq = 2'd2;
		2'd2:	cur_seq = 2'd3;
		2'd3:	cur_seq = 2'd3;
	endcase
end
/* retrace path pointer */
//trace_x, trace_y
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		trace_x <= 'd0;
		trace_y <= 'd0;
	end
	else begin
		trace_x <= trace_x_nxt;
		trace_y <= trace_y_nxt;
	end
end
always @(*) begin
	case(curr_state)
		SOURCE_INIT: begin
			trace_x_nxt = cur_sink_x;
			trace_y_nxt = cur_sink_y;
		end
		RETRACE_WRITE: begin
			if(Location_Map[trace_y+'d1][trace_x]==cur_seq && trace_y!=6'd63) begin
				trace_x_nxt = trace_x;
				trace_y_nxt = trace_y + 'd1;
			end
			else if(Location_Map[trace_y-'d1][trace_x]==cur_seq && trace_y!=6'd0) begin
				trace_x_nxt = trace_x;
				trace_y_nxt = trace_y - 'd1;
			end
			else if(Location_Map[trace_y][trace_x+'d1]==cur_seq && trace_x!=6'd63) begin
				trace_x_nxt = trace_x + 'd1;
				trace_y_nxt = trace_y;
			end
			else begin
				trace_x_nxt = trace_x - 'd1;
				trace_y_nxt = trace_y;
			end
		end
		default: begin
			trace_x_nxt = trace_x;
			trace_y_nxt = trace_y;
		end
	endcase
end

//Location_Map
always @(posedge clk) begin // or negedge rst_n
	if(curr_state==IDLE) begin //!rst_n
		for(i=0;i<64;i=i+1) begin
			for(j=0;j<64;j=j+1) begin
				Location_Map[i][j] <= 2'd0;
			end
		end
	end
	else begin
		for(i=0;i<64;i=i+1) begin
			for(j=0;j<64;j=j+1) begin
				Location_Map[i][j] <= Location_Map_nxt[i][j];
			end
		end
	end
end
always @(*) begin
	//no change
	for(i=0;i<64;i=i+1) begin
		for(j=0;j<64;j=j+1) begin
			Location_Map_nxt[i][j] = Location_Map[i][j];
		end
	end

	case(curr_state)
		GET_FRAME: begin //macro: 1
			Location_Map_nxt[map_y][map_x_offset+'d0] = (rdata_m_inf[3:0]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d1] = (rdata_m_inf[7:4]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d2] = (rdata_m_inf[11:8]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d3] = (rdata_m_inf[15:12]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d4] = (rdata_m_inf[19:16]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d5] = (rdata_m_inf[23:20]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d6] = (rdata_m_inf[27:24]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d7] = (rdata_m_inf[31:28]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d8] = (rdata_m_inf[35:32]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d9] = (rdata_m_inf[39:36]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d10] = (rdata_m_inf[43:40]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d11] = (rdata_m_inf[47:44]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d12] = (rdata_m_inf[51:48]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d13] = (rdata_m_inf[55:52]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d14] = (rdata_m_inf[59:56]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d15] = (rdata_m_inf[63:60]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d16] = (rdata_m_inf[67:64]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d17] = (rdata_m_inf[71:68]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d18] = (rdata_m_inf[75:72]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d19] = (rdata_m_inf[79:76]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d20] = (rdata_m_inf[83:80]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d21] = (rdata_m_inf[87:84]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d22] = (rdata_m_inf[91:88]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d23] = (rdata_m_inf[95:92]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d24] = (rdata_m_inf[99:96]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d25] = (rdata_m_inf[103:100]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d26] = (rdata_m_inf[107:104]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d27] = (rdata_m_inf[111:108]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d28] = (rdata_m_inf[115:112]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d29] = (rdata_m_inf[119:116]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d30] = (rdata_m_inf[123:120]) ? 2'd1 : 2'd0;
			Location_Map_nxt[map_y][map_x_offset+'d31] = (rdata_m_inf[127:124]) ? 2'd1 : 2'd0;
		end
		SOURCE_INIT: begin //source: 2, sink: 0
			Location_Map_nxt[cur_source_y][cur_source_x] = 2'd2;
			Location_Map_nxt[cur_sink_y][cur_sink_x] = 2'd0;
		end
		FILLING: begin //sequence: 2, 2, 3, 3 (cur_seq)
			for(i=0;i<64;i=i+1) begin
				for(j=0;j<64;j=j+1) begin
					if(Location_Map[i][j][1]) begin
						if(i!=63)	if(~|(Location_Map[i+1][j]))	Location_Map_nxt[i+1][j] = cur_seq;
						if(i!=0)	if(~|(Location_Map[i-1][j]))	Location_Map_nxt[i-1][j] = cur_seq;
						if(j!=63)	if(~|(Location_Map[i][j+1]))	Location_Map_nxt[i][j+1] = cur_seq;
						if(j!=0)	if(~|(Location_Map[i][j-1]))	Location_Map_nxt[i][j-1] = cur_seq;
					end
				end
			end
		end
		RETRACE_WRITE: begin
			Location_Map_nxt[trace_y][trace_x] = 2'd1;
		end
		CLEAR_MAP: begin
			for(i=0;i<64;i=i+1) begin
				for(j=0;j<64;j=j+1) begin
					if(Location_Map[i][j][1])	Location_Map_nxt[i][j] = 2'd0;
				end
			end
			Location_Map_nxt[cur_source_y][cur_source_x] = 2'd1;
		end
	endcase
end


// ===============================================================
//  					OUTPUT 
// ===============================================================

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	cost <= 14'd0;
	else		cost <= cost_comb;
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	busy <= 1'b0;
	else		busy <= busy_comb;
end

always @(*) begin
	if(!in_valid && curr_state!=IDLE)	busy_comb = 1'b1;
	else								busy_comb = 1'b0;
end
always @(*) begin
	case(curr_state)
		WAIT_ARREADY:	cost_comb = 'd0;
		default:		cost_comb = cost + weight;
	endcase
end


// ===============================================================
//  					SRAM 
// ===============================================================


//SRAM_FRAME	(.Q(data_out_f),.CLK(clk),.CS(1'b1),.WEN(wen_f),.A(addr_f),.D(data_in_f),.OE(1'b1));   //128-bit x 128
//SRAM_WEIGHT	(.Q(data_out_w),.CLK(clk),.CS(1'b1),.WEN(wen_w),.A(addr_w),.D(data_in_w),.OE(1'b1));   //128-bit x 128

SUMA180_128X128X1BM1 SRAM_FRAME(.A0(addr_f[0]), .A1(addr_f[1]), .A2(addr_f[2]), .A3(addr_f[3]), .A4(addr_f[4]), .A5(addr_f[5]), .A6(addr_f[6]), 
							.DO0(data_out_f[0]),  .DO1(data_out_f[1]),  .DO2(data_out_f[2]),  .DO3(data_out_f[3]),  .DO4(data_out_f[4]),  .DO5(data_out_f[5]),  .DO6(data_out_f[6]),  .DO7(data_out_f[7]), 
							.DO8(data_out_f[8]),  .DO9(data_out_f[9]),  .DO10(data_out_f[10]), .DO11(data_out_f[11]), .DO12(data_out_f[12]), .DO13(data_out_f[13]), .DO14(data_out_f[14]), .DO15(data_out_f[15]),
                            .DO16(data_out_f[16]), .DO17(data_out_f[17]), .DO18(data_out_f[18]), .DO19(data_out_f[19]), .DO20(data_out_f[20]), .DO21(data_out_f[21]), .DO22(data_out_f[22]), .DO23(data_out_f[23]),
                            .DO24(data_out_f[24]), .DO25(data_out_f[25]), .DO26(data_out_f[26]), .DO27(data_out_f[27]), .DO28(data_out_f[28]), .DO29(data_out_f[29]), .DO30(data_out_f[30]), .DO31(data_out_f[31]),
                            .DO32(data_out_f[32]), .DO33(data_out_f[33]), .DO34(data_out_f[34]), .DO35(data_out_f[35]), .DO36(data_out_f[36]), .DO37(data_out_f[37]), .DO38(data_out_f[38]), .DO39(data_out_f[39]),
                            .DO40(data_out_f[40]), .DO41(data_out_f[41]), .DO42(data_out_f[42]), .DO43(data_out_f[43]), .DO44(data_out_f[44]), .DO45(data_out_f[45]), .DO46(data_out_f[46]), .DO47(data_out_f[47]),
                            .DO48(data_out_f[48]), .DO49(data_out_f[49]), .DO50(data_out_f[50]), .DO51(data_out_f[51]), .DO52(data_out_f[52]), .DO53(data_out_f[53]), .DO54(data_out_f[54]), .DO55(data_out_f[55]),
                            .DO56(data_out_f[56]), .DO57(data_out_f[57]), .DO58(data_out_f[58]), .DO59(data_out_f[59]), .DO60(data_out_f[60]), .DO61(data_out_f[61]), .DO62(data_out_f[62]), .DO63(data_out_f[63]),
                            .DO64(data_out_f[64]), .DO65(data_out_f[65]), .DO66(data_out_f[66]), .DO67(data_out_f[67]), .DO68(data_out_f[68]), .DO69(data_out_f[69]), .DO70(data_out_f[70]), .DO71(data_out_f[71]),
                            .DO72(data_out_f[72]), .DO73(data_out_f[73]), .DO74(data_out_f[74]), .DO75(data_out_f[75]), .DO76(data_out_f[76]), .DO77(data_out_f[77]), .DO78(data_out_f[78]), .DO79(data_out_f[79]),
                            .DO80(data_out_f[80]), .DO81(data_out_f[81]), .DO82(data_out_f[82]), .DO83(data_out_f[83]), .DO84(data_out_f[84]), .DO85(data_out_f[85]), .DO86(data_out_f[86]), .DO87(data_out_f[87]),
                            .DO88(data_out_f[88]), .DO89(data_out_f[89]), .DO90(data_out_f[90]), .DO91(data_out_f[91]), .DO92(data_out_f[92]), .DO93(data_out_f[93]), .DO94(data_out_f[94]), .DO95(data_out_f[95]),
                            .DO96(data_out_f[96]), .DO97(data_out_f[97]), .DO98(data_out_f[98]), .DO99(data_out_f[99]), .DO100(data_out_f[100]), .DO101(data_out_f[101]), .DO102(data_out_f[102]), .DO103(data_out_f[103]), 
                            .DO104(data_out_f[104]), .DO105(data_out_f[105]), .DO106(data_out_f[106]), .DO107(data_out_f[107]), .DO108(data_out_f[108]), .DO109(data_out_f[109]), .DO110(data_out_f[110]), 
                            .DO111(data_out_f[111]), .DO112(data_out_f[112]), .DO113(data_out_f[113]), .DO114(data_out_f[114]), .DO115(data_out_f[115]), .DO116(data_out_f[116]), .DO117(data_out_f[117]), 
                            .DO118(data_out_f[118]), .DO119(data_out_f[119]), .DO120(data_out_f[120]), .DO121(data_out_f[121]), .DO122(data_out_f[122]), .DO123(data_out_f[123]), .DO124(data_out_f[124]), 
                            .DO125(data_out_f[125]), .DO126(data_out_f[126]), .DO127(data_out_f[127]), 
							.DI0(data_in_f[0]),  .DI1(data_in_f[1]),  .DI2(data_in_f[2]),  .DI3(data_in_f[3]),  .DI4(data_in_f[4]),  .DI5(data_in_f[5]),  .DI6(data_in_f[6]),  .DI7(data_in_f[7]), 
							.DI8(data_in_f[8]),  .DI9(data_in_f[9]),  .DI10(data_in_f[10]), .DI11(data_in_f[11]), .DI12(data_in_f[12]), .DI13(data_in_f[13]), .DI14(data_in_f[14]), .DI15(data_in_f[15]),
                            .DI16(data_in_f[16]), .DI17(data_in_f[17]), .DI18(data_in_f[18]), .DI19(data_in_f[19]), .DI20(data_in_f[20]), .DI21(data_in_f[21]), .DI22(data_in_f[22]), .DI23(data_in_f[23]),
                            .DI24(data_in_f[24]), .DI25(data_in_f[25]), .DI26(data_in_f[26]), .DI27(data_in_f[27]), .DI28(data_in_f[28]), .DI29(data_in_f[29]), .DI30(data_in_f[30]), .DI31(data_in_f[31]),
                            .DI32(data_in_f[32]), .DI33(data_in_f[33]), .DI34(data_in_f[34]), .DI35(data_in_f[35]), .DI36(data_in_f[36]), .DI37(data_in_f[37]), .DI38(data_in_f[38]), .DI39(data_in_f[39]),
                            .DI40(data_in_f[40]), .DI41(data_in_f[41]), .DI42(data_in_f[42]), .DI43(data_in_f[43]), .DI44(data_in_f[44]), .DI45(data_in_f[45]), .DI46(data_in_f[46]), .DI47(data_in_f[47]),
                            .DI48(data_in_f[48]), .DI49(data_in_f[49]), .DI50(data_in_f[50]), .DI51(data_in_f[51]), .DI52(data_in_f[52]), .DI53(data_in_f[53]), .DI54(data_in_f[54]), .DI55(data_in_f[55]),
                            .DI56(data_in_f[56]), .DI57(data_in_f[57]), .DI58(data_in_f[58]), .DI59(data_in_f[59]), .DI60(data_in_f[60]), .DI61(data_in_f[61]), .DI62(data_in_f[62]), .DI63(data_in_f[63]),
                            .DI64(data_in_f[64]), .DI65(data_in_f[65]), .DI66(data_in_f[66]), .DI67(data_in_f[67]), .DI68(data_in_f[68]), .DI69(data_in_f[69]), .DI70(data_in_f[70]), .DI71(data_in_f[71]),
                            .DI72(data_in_f[72]), .DI73(data_in_f[73]), .DI74(data_in_f[74]), .DI75(data_in_f[75]), .DI76(data_in_f[76]), .DI77(data_in_f[77]), .DI78(data_in_f[78]), .DI79(data_in_f[79]),
                            .DI80(data_in_f[80]), .DI81(data_in_f[81]), .DI82(data_in_f[82]), .DI83(data_in_f[83]), .DI84(data_in_f[84]), .DI85(data_in_f[85]), .DI86(data_in_f[86]), .DI87(data_in_f[87]),
                            .DI88(data_in_f[88]), .DI89(data_in_f[89]), .DI90(data_in_f[90]), .DI91(data_in_f[91]), .DI92(data_in_f[92]), .DI93(data_in_f[93]), .DI94(data_in_f[94]), .DI95(data_in_f[95]),
                            .DI96(data_in_f[96]), .DI97(data_in_f[97]), .DI98(data_in_f[98]), .DI99(data_in_f[99]), .DI100(data_in_f[100]), .DI101(data_in_f[101]), .DI102(data_in_f[102]), .DI103(data_in_f[103]), 
                            .DI104(data_in_f[104]), .DI105(data_in_f[105]), .DI106(data_in_f[106]), .DI107(data_in_f[107]), .DI108(data_in_f[108]), .DI109(data_in_f[109]), .DI110(data_in_f[110]), 
                            .DI111(data_in_f[111]), .DI112(data_in_f[112]), .DI113(data_in_f[113]), .DI114(data_in_f[114]), .DI115(data_in_f[115]), .DI116(data_in_f[116]), .DI117(data_in_f[117]), 
                            .DI118(data_in_f[118]), .DI119(data_in_f[119]), .DI120(data_in_f[120]), .DI121(data_in_f[121]), .DI122(data_in_f[122]), .DI123(data_in_f[123]), .DI124(data_in_f[124]), 
                            .DI125(data_in_f[125]), .DI126(data_in_f[126]), .DI127(data_in_f[127]), 
							.CK(clk), .WEB(wen_f), .OE(1'b1), .CS(1'b1));

SUMA180_128X128X1BM1 SRAM_WEIGHT(.A0(addr_w[0]), .A1(addr_w[1]), .A2(addr_w[2]), .A3(addr_w[3]), .A4(addr_w[4]), .A5(addr_w[5]), .A6(addr_w[6]), 
							.DO0(data_out_w[0]),  .DO1(data_out_w[1]),  .DO2(data_out_w[2]),  .DO3(data_out_w[3]),  .DO4(data_out_w[4]),  .DO5(data_out_w[5]),  .DO6(data_out_w[6]),  .DO7(data_out_w[7]), 
							.DO8(data_out_w[8]),  .DO9(data_out_w[9]),  .DO10(data_out_w[10]), .DO11(data_out_w[11]), .DO12(data_out_w[12]), .DO13(data_out_w[13]), .DO14(data_out_w[14]), .DO15(data_out_w[15]),
                            .DO16(data_out_w[16]), .DO17(data_out_w[17]), .DO18(data_out_w[18]), .DO19(data_out_w[19]), .DO20(data_out_w[20]), .DO21(data_out_w[21]), .DO22(data_out_w[22]), .DO23(data_out_w[23]),
                            .DO24(data_out_w[24]), .DO25(data_out_w[25]), .DO26(data_out_w[26]), .DO27(data_out_w[27]), .DO28(data_out_w[28]), .DO29(data_out_w[29]), .DO30(data_out_w[30]), .DO31(data_out_w[31]),
                            .DO32(data_out_w[32]), .DO33(data_out_w[33]), .DO34(data_out_w[34]), .DO35(data_out_w[35]), .DO36(data_out_w[36]), .DO37(data_out_w[37]), .DO38(data_out_w[38]), .DO39(data_out_w[39]),
                            .DO40(data_out_w[40]), .DO41(data_out_w[41]), .DO42(data_out_w[42]), .DO43(data_out_w[43]), .DO44(data_out_w[44]), .DO45(data_out_w[45]), .DO46(data_out_w[46]), .DO47(data_out_w[47]),
                            .DO48(data_out_w[48]), .DO49(data_out_w[49]), .DO50(data_out_w[50]), .DO51(data_out_w[51]), .DO52(data_out_w[52]), .DO53(data_out_w[53]), .DO54(data_out_w[54]), .DO55(data_out_w[55]),
                            .DO56(data_out_w[56]), .DO57(data_out_w[57]), .DO58(data_out_w[58]), .DO59(data_out_w[59]), .DO60(data_out_w[60]), .DO61(data_out_w[61]), .DO62(data_out_w[62]), .DO63(data_out_w[63]),
                            .DO64(data_out_w[64]), .DO65(data_out_w[65]), .DO66(data_out_w[66]), .DO67(data_out_w[67]), .DO68(data_out_w[68]), .DO69(data_out_w[69]), .DO70(data_out_w[70]), .DO71(data_out_w[71]),
                            .DO72(data_out_w[72]), .DO73(data_out_w[73]), .DO74(data_out_w[74]), .DO75(data_out_w[75]), .DO76(data_out_w[76]), .DO77(data_out_w[77]), .DO78(data_out_w[78]), .DO79(data_out_w[79]),
                            .DO80(data_out_w[80]), .DO81(data_out_w[81]), .DO82(data_out_w[82]), .DO83(data_out_w[83]), .DO84(data_out_w[84]), .DO85(data_out_w[85]), .DO86(data_out_w[86]), .DO87(data_out_w[87]),
                            .DO88(data_out_w[88]), .DO89(data_out_w[89]), .DO90(data_out_w[90]), .DO91(data_out_w[91]), .DO92(data_out_w[92]), .DO93(data_out_w[93]), .DO94(data_out_w[94]), .DO95(data_out_w[95]),
                            .DO96(data_out_w[96]), .DO97(data_out_w[97]), .DO98(data_out_w[98]), .DO99(data_out_w[99]), .DO100(data_out_w[100]), .DO101(data_out_w[101]), .DO102(data_out_w[102]), .DO103(data_out_w[103]), 
                            .DO104(data_out_w[104]), .DO105(data_out_w[105]), .DO106(data_out_w[106]), .DO107(data_out_w[107]), .DO108(data_out_w[108]), .DO109(data_out_w[109]), .DO110(data_out_w[110]), 
                            .DO111(data_out_w[111]), .DO112(data_out_w[112]), .DO113(data_out_w[113]), .DO114(data_out_w[114]), .DO115(data_out_w[115]), .DO116(data_out_w[116]), .DO117(data_out_w[117]), 
                            .DO118(data_out_w[118]), .DO119(data_out_w[119]), .DO120(data_out_w[120]), .DO121(data_out_w[121]), .DO122(data_out_w[122]), .DO123(data_out_w[123]), .DO124(data_out_w[124]), 
                            .DO125(data_out_w[125]), .DO126(data_out_w[126]), .DO127(data_out_w[127]), 
							.DI0(data_in_w[0]),  .DI1(data_in_w[1]),  .DI2(data_in_w[2]),  .DI3(data_in_w[3]),  .DI4(data_in_w[4]),  .DI5(data_in_w[5]),  .DI6(data_in_w[6]),  .DI7(data_in_w[7]), 
							.DI8(data_in_w[8]),  .DI9(data_in_w[9]),  .DI10(data_in_w[10]), .DI11(data_in_w[11]), .DI12(data_in_w[12]), .DI13(data_in_w[13]), .DI14(data_in_w[14]), .DI15(data_in_w[15]),
                            .DI16(data_in_w[16]), .DI17(data_in_w[17]), .DI18(data_in_w[18]), .DI19(data_in_w[19]), .DI20(data_in_w[20]), .DI21(data_in_w[21]), .DI22(data_in_w[22]), .DI23(data_in_w[23]),
                            .DI24(data_in_w[24]), .DI25(data_in_w[25]), .DI26(data_in_w[26]), .DI27(data_in_w[27]), .DI28(data_in_w[28]), .DI29(data_in_w[29]), .DI30(data_in_w[30]), .DI31(data_in_w[31]),
                            .DI32(data_in_w[32]), .DI33(data_in_w[33]), .DI34(data_in_w[34]), .DI35(data_in_w[35]), .DI36(data_in_w[36]), .DI37(data_in_w[37]), .DI38(data_in_w[38]), .DI39(data_in_w[39]),
                            .DI40(data_in_w[40]), .DI41(data_in_w[41]), .DI42(data_in_w[42]), .DI43(data_in_w[43]), .DI44(data_in_w[44]), .DI45(data_in_w[45]), .DI46(data_in_w[46]), .DI47(data_in_w[47]),
                            .DI48(data_in_w[48]), .DI49(data_in_w[49]), .DI50(data_in_w[50]), .DI51(data_in_w[51]), .DI52(data_in_w[52]), .DI53(data_in_w[53]), .DI54(data_in_w[54]), .DI55(data_in_w[55]),
                            .DI56(data_in_w[56]), .DI57(data_in_w[57]), .DI58(data_in_w[58]), .DI59(data_in_w[59]), .DI60(data_in_w[60]), .DI61(data_in_w[61]), .DI62(data_in_w[62]), .DI63(data_in_w[63]),
                            .DI64(data_in_w[64]), .DI65(data_in_w[65]), .DI66(data_in_w[66]), .DI67(data_in_w[67]), .DI68(data_in_w[68]), .DI69(data_in_w[69]), .DI70(data_in_w[70]), .DI71(data_in_w[71]),
                            .DI72(data_in_w[72]), .DI73(data_in_w[73]), .DI74(data_in_w[74]), .DI75(data_in_w[75]), .DI76(data_in_w[76]), .DI77(data_in_w[77]), .DI78(data_in_w[78]), .DI79(data_in_w[79]),
                            .DI80(data_in_w[80]), .DI81(data_in_w[81]), .DI82(data_in_w[82]), .DI83(data_in_w[83]), .DI84(data_in_w[84]), .DI85(data_in_w[85]), .DI86(data_in_w[86]), .DI87(data_in_w[87]),
                            .DI88(data_in_w[88]), .DI89(data_in_w[89]), .DI90(data_in_w[90]), .DI91(data_in_w[91]), .DI92(data_in_w[92]), .DI93(data_in_w[93]), .DI94(data_in_w[94]), .DI95(data_in_w[95]),
                            .DI96(data_in_w[96]), .DI97(data_in_w[97]), .DI98(data_in_w[98]), .DI99(data_in_w[99]), .DI100(data_in_w[100]), .DI101(data_in_w[101]), .DI102(data_in_w[102]), .DI103(data_in_w[103]), 
                            .DI104(data_in_w[104]), .DI105(data_in_w[105]), .DI106(data_in_w[106]), .DI107(data_in_w[107]), .DI108(data_in_w[108]), .DI109(data_in_w[109]), .DI110(data_in_w[110]), 
                            .DI111(data_in_w[111]), .DI112(data_in_w[112]), .DI113(data_in_w[113]), .DI114(data_in_w[114]), .DI115(data_in_w[115]), .DI116(data_in_w[116]), .DI117(data_in_w[117]), 
                            .DI118(data_in_w[118]), .DI119(data_in_w[119]), .DI120(data_in_w[120]), .DI121(data_in_w[121]), .DI122(data_in_w[122]), .DI123(data_in_w[123]), .DI124(data_in_w[124]), 
                            .DI125(data_in_w[125]), .DI126(data_in_w[126]), .DI127(data_in_w[127]), 
							.CK(clk), .WEB(wen_w), .OE(1'b1), .CS(1'b1));



endmodule
