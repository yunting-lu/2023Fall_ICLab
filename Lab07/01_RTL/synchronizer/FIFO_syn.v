module FIFO_syn #(parameter WIDTH=32, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output rempty;

// You can change the input / output of the custom flag ports
input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

wire [WIDTH-1:0] rdata_q;

reg rinc_d1;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr; //[6:0]
reg [$clog2(WORDS):0] rptr; //[6:0]

wire [$clog2(WORDS):0] rq2_wptr, wq2_rptr;
reg [5:0] waddr, raddr;

// rdata
//  Add one more register stage to rdata
always @(posedge rclk) begin
    if (rinc || rinc_d1)
        rdata <= rdata_q;
end

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n)  rinc_d1 <= 1'b0;
    else        rinc_d1 <= rinc;
end

//----------------------------------------------
//  addr
//----------------------------------------------

rptr_empty #(6) rptr_empty_m0 (.rempty(rempty), .raddr(raddr), .rptr(rptr), .rq2_wptr(rq2_wptr), .rinc(rinc), .rclk(rclk), .rst_n(rst_n));
wptr_full #(6) wptr_full_m0 (.wfull(wfull), .waddr(waddr), .wptr(wptr), .wq2_rptr(wq2_rptr), .winc(winc), .wclk(wclk), .rst_n(rst_n));


//----------------------------------------------
//  ptr - gray code
//----------------------------------------------

NDFF_BUS_syn #(7) sync_r2w_m0(.D(rptr), .Q(wq2_rptr), .clk(wclk), .rst_n(rst_n));
NDFF_BUS_syn #(7) sync_w2r_m0(.D(wptr), .Q(rq2_wptr), .clk(rclk), .rst_n(rst_n));



//----------------------------------------------
//  SRAM
//----------------------------------------------

wire wean;

assign wean = ~winc;

//A for write and B for read
DUAL_64X32X1BM1 u_dual_sram (
    .CKA(wclk),
    .CKB(rclk),
    .WEAN(wean),
    .WEBN(1'b1),
    .CSA(1'b1),
    .CSB(1'b1),
    .OEA(1'b1),
    .OEB(1'b1),
    .A0(waddr[0]),
    .A1(waddr[1]),
    .A2(waddr[2]),
    .A3(waddr[3]),
    .A4(waddr[4]),
    .A5(waddr[5]),
    .B0(raddr[0]),
    .B1(raddr[1]),
    .B2(raddr[2]),
    .B3(raddr[3]),
    .B4(raddr[4]),
    .B5(raddr[5]),
    .DIA0(wdata[0]),
    .DIA1(wdata[1]),
    .DIA2(wdata[2]),
    .DIA3(wdata[3]),
    .DIA4(wdata[4]),
    .DIA5(wdata[5]),
    .DIA6(wdata[6]),
    .DIA7(wdata[7]),
    .DIA8(wdata[8]),
    .DIA9(wdata[9]),
    .DIA10(wdata[10]),
    .DIA11(wdata[11]),
    .DIA12(wdata[12]),
    .DIA13(wdata[13]),
    .DIA14(wdata[14]),
    .DIA15(wdata[15]),
    .DIA16(wdata[16]),
    .DIA17(wdata[17]),
    .DIA18(wdata[18]),
    .DIA19(wdata[19]),
    .DIA20(wdata[20]),
    .DIA21(wdata[21]),
    .DIA22(wdata[22]),
    .DIA23(wdata[23]),
    .DIA24(wdata[24]),
    .DIA25(wdata[25]),
    .DIA26(wdata[26]),
    .DIA27(wdata[27]),
    .DIA28(wdata[28]),
    .DIA29(wdata[29]),
    .DIA30(wdata[30]),
    .DIA31(wdata[31]),
    .DIB0(),
    .DIB1(),
    .DIB2(),
    .DIB3(),
    .DIB4(),
    .DIB5(),
    .DIB6(),
    .DIB7(),
    .DIB8(),
    .DIB9(),
    .DIB10(),
    .DIB11(),
    .DIB12(),
    .DIB13(),
    .DIB14(),
    .DIB15(),
    .DIB16(),
    .DIB17(),
    .DIB18(),
    .DIB19(),
    .DIB20(),
    .DIB21(),
    .DIB22(),
    .DIB23(),
    .DIB24(),
    .DIB25(),
    .DIB26(),
    .DIB27(),
    .DIB28(),
    .DIB29(),
    .DIB30(),
    .DIB31(),
    .DOB0(rdata_q[0]),
    .DOB1(rdata_q[1]),
    .DOB2(rdata_q[2]),
    .DOB3(rdata_q[3]),
    .DOB4(rdata_q[4]),
    .DOB5(rdata_q[5]),
    .DOB6(rdata_q[6]),
    .DOB7(rdata_q[7]),
    .DOB8(rdata_q[8]),
    .DOB9(rdata_q[9]),
    .DOB10(rdata_q[10]),
    .DOB11(rdata_q[11]),
    .DOB12(rdata_q[12]),
    .DOB13(rdata_q[13]),
    .DOB14(rdata_q[14]),
    .DOB15(rdata_q[15]),
    .DOB16(rdata_q[16]),
    .DOB17(rdata_q[17]),
    .DOB18(rdata_q[18]),
    .DOB19(rdata_q[19]),
    .DOB20(rdata_q[20]),
    .DOB21(rdata_q[21]),
    .DOB22(rdata_q[22]),
    .DOB23(rdata_q[23]),
    .DOB24(rdata_q[24]),
    .DOB25(rdata_q[25]),
    .DOB26(rdata_q[26]),
    .DOB27(rdata_q[27]),
    .DOB28(rdata_q[28]),
    .DOB29(rdata_q[29]),
    .DOB30(rdata_q[30]),
    .DOB31(rdata_q[31])
);


endmodule




module rptr_empty #(parameter ASIZE = 6)(
	//Input Port
	rq2_wptr,
	rclk,
	rst_n,
	rinc,

    //Output Port
	rptr,
	raddr,
	rempty
); 

input [ASIZE:0] rq2_wptr;
input rclk, rinc, rst_n;

output reg [ASIZE:0] rptr;
output [ASIZE-1:0] raddr;
output reg rempty;

reg [ASIZE:0] rbin;
wire [ASIZE:0] rgraynext, rbinnext;
wire rempty_comb;

//rptr gray code
assign rbinnext = rbin + (rinc & ~rempty);
assign rgraynext = (rbinnext>>1) ^ rbinnext;

always @(posedge rclk or negedge rst_n)begin
	if(!rst_n) begin
		{rbin, rptr} <= 'd0;
    end
	else begin
		{rbin, rptr} <= {rbinnext, rgraynext};
    end
end

//raddr
assign raddr = rbin[ASIZE-1:0];

//rempty
assign rempty_comb = (rgraynext == rq2_wptr);

always @(posedge rclk or negedge rst_n)begin
	if(!rst_n)  rempty <= 1'b1;
	else        rempty <= rempty_comb;
end



endmodule

module wptr_full #(parameter ASIZE = 6)(
	//Input Port
	wq2_rptr,
	wclk,
	rst_n,
	winc,

    //Output Port
	wptr,
	waddr,
	wfull
); 
input [ASIZE:0] wq2_rptr;
input wclk, winc, rst_n;

output reg [ASIZE:0] wptr;
output [ASIZE-1:0] waddr;
output reg wfull;

reg [ASIZE:0] wbin;
wire [ASIZE:0] wgraynext, wbinnext;
wire wfull_comb;

//wptr gray code
assign wbinnext = wbin + (winc & ~wfull);
assign wgraynext = (wbinnext>>1) ^ wbinnext;

always @(posedge wclk or negedge rst_n)begin
	if(!rst_n) begin
		{wbin, wptr} <= 'd0;
    end
	else begin
		{wbin, wptr} <= {wbinnext, wgraynext};
    end
end

//waddr
assign waddr = wbin[ASIZE-1:0];

//wfull
assign wfull_comb = (wgraynext=={~wq2_rptr[ASIZE:ASIZE-1],wq2_rptr[ASIZE-2:0]});

always @(posedge wclk or negedge rst_n)begin
	if(!rst_n)  wfull <= 1'b0;
	else        wfull <= wfull_comb;
end



endmodule 