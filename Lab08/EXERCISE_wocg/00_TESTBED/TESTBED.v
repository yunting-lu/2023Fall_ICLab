/**************************************************************************/
// Copyright (c) 2023, Si2 Lab
// MODULE: TESTBED
// FILE NAME: TESTBED.v
// VERSRION: 1.0
// DATE: Oct 31, 2023
// AUTHOR: Hsien-Chi Peng, NYCU IEE
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2023 fall IC Lab / Exercise Lab08 / SNN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
`timescale 1ns/10ps

// PATTERN
`include "PATTERN.v"

// DESIGN
`ifdef RTL
	`include "SNN_wocg.v"
`elsif GATE
	`include "SNN_SYN.v"
`endif


module TESTBED();
wire          clk, rst_n, in_valid;
wire          cg_en;
wire  [31:0]  Img;
wire  [31:0]  Kernel;
wire  [31:0]  Weight;
wire  [ 1:0]  Opt;
wire          out_valid;
wire  [31:0]  out;

initial begin
  `ifdef RTL
//    $fsdbDumpfile("SNN.fsdb");
//	$fsdbDumpvars(0,"+mda");
    $fsdbDumpvars();
  `endif
  `ifdef GATE
    $sdf_annotate("SNN_SYN.sdf", u_SNN);
    $fsdbDumpfile("SNN_SYN.fsdb");
    $fsdbDumpvars();    
  `endif
end

SNN u_SNN(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .Img(Img),
    .Kernel(Kernel),
    .Weight(Weight),
    .Opt(Opt),
    .out_valid(out_valid),
    .out(out)
    );


PATTERN u_PATTERN(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .Img(Img),
    .Kernel(Kernel),
    .Weight(Weight),
    .Opt(Opt),
    .out_valid(out_valid),
    .out(out)
    );
  

endmodule
