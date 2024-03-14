//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab01 Exercise		: Supper MOSFET Calculator
//   Author     		: Lin-Hung Lai (lhlai@ieee.org)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SMC.v
//   Module Name : SMC
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

 
 


 /*
 
****************************************
Report : area
Design : SMC
Version: T-2022.03
Date   : Mon Sep 25 10:27:16 2023
****************************************

Library(s) Used:

    slow (File: /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/umc018/Synthesis/slow.db)

Number of ports:                           64
Number of nets:                          1947
Number of cells:                         1783
Number of combinational cells:           1782
Number of sequential cells:                 0
Number of macros/black boxes:               0
Number of buf/inv:                        410
Number of references:                      92

Combinational area:              41031.144162
Buf/Inv area:                     4573.800136
Noncombinational area:               0.000000
Macro/Black Box area:                0.000000
Net Interconnect area:          186667.601685

Total cell area:                 41031.144162
Total area:                     227698.745847
1

*/



module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
//output [7:0] out_n;         					// use this if using continuous assignment for out_n  // Ex: assign out_n = XXX;
output reg [7:0] out_n; 								// use this if using procedure assignment for out_n   // Ex: always@(*) begin out_n = XXX; end

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

integer a, k;

reg [2:0] W [0:5];
reg [2:0] V_GS [0:5];
reg [2:0] V_DS [0:5];

reg [2:0] vgs_mode [0:5];
reg [5:0] mos_mode;

//share
reg [2:0] vds_or_vov [0:5];
wire [5:0] w_mult [0:5];
reg [3:0] multiplicand [0:5];

//reg [5:0] w_mult_vds [0:5];
//reg [5:0] w_mult_vgs_mode [0:5];

reg [7:0] idgm_l2 [0:5];
//wire [6:0] idgm_l3 [0:5];

//sort
reg [6:0] sort_l0 [0:5];  
wire [6:0] sort_l1 [0:5]; 
wire [6:0] sort_l2 [0:5]; 
wire [6:0] sort_l3 [0:3]; 
wire [6:0] sort_l4 [0:1]; 
wire [6:0] sort_out [0:5];

//calculate
reg [6:0] cal1_0, cal2_0, cal3_0;
reg [7:0] cal1;
reg [8:0] cal2, cal3;
reg [9:0] sum_lv1;
reg [7:0] sum_lv2;
wire [6:0] sum_lv3;



//================================================================
//    DESIGN
//================================================================

always@(*)begin
  W[0] = W_0; V_GS[0] = V_GS_0; V_DS[0] = V_DS_0;
  W[1] = W_1; V_GS[1] = V_GS_1; V_DS[1] = V_DS_1;
  W[2] = W_2; V_GS[2] = V_GS_2; V_DS[2] = V_DS_2;
  W[3] = W_3; V_GS[3] = V_GS_3; V_DS[3] = V_DS_3;
  W[4] = W_4; V_GS[4] = V_GS_4; V_DS[4] = V_DS_4;
  W[5] = W_5; V_GS[5] = V_GS_5; V_DS[5] = V_DS_5;
end

// --------------------------------------------------
// write your design here
// --------------------------------------------------

/*Calculate Id or gm*/
always@(*)begin
  //*check mode (vgs-vth)
  vgs_mode[0] = V_GS[0]-'b1; mos_mode[0] = (vgs_mode[0]>V_DS[0]) ? 1'b1 : 1'b0;
  vgs_mode[1] = V_GS[1]-'b1; mos_mode[1] = (vgs_mode[1]>V_DS[1]) ? 1'b1 : 1'b0;
  vgs_mode[2] = V_GS[2]-'b1; mos_mode[2] = (vgs_mode[2]>V_DS[2]) ? 1'b1 : 1'b0;
  vgs_mode[3] = V_GS[3]-'b1; mos_mode[3] = (vgs_mode[3]>V_DS[3]) ? 1'b1 : 1'b0;
  vgs_mode[4] = V_GS[4]-'b1; mos_mode[4] = (vgs_mode[4]>V_DS[4]) ? 1'b1 : 1'b0;
  vgs_mode[5] = V_GS[5]-'b1; mos_mode[5] = (vgs_mode[5]>V_DS[5]) ? 1'b1 : 1'b0;

  //*calculate
  for(a=0; a<6; a=a+1) begin
    vds_or_vov[a] = (mos_mode[a])? V_DS[a] : vgs_mode[a];
    //w_mult[a] = W[a]*vds_or_vov[a];
    if(mode[0]) multiplicand[a] = mos_mode[a]?((vgs_mode[a]<<1)-V_DS[a]):vgs_mode[a];
    else        multiplicand[a] = 4'd2;
    idgm_l2[a] = w_mult[a]*multiplicand[a];
  end
  
end

//module mult3x3(in1, in2, out);
mult3x3 m0(.in1(W[0]), .in2(vds_or_vov[0]), .out(w_mult[0]));
mult3x3 m1(.in1(W[1]), .in2(vds_or_vov[1]), .out(w_mult[1]));
mult3x3 m2(.in1(W[2]), .in2(vds_or_vov[2]), .out(w_mult[2]));
mult3x3 m3(.in1(W[3]), .in2(vds_or_vov[3]), .out(w_mult[3]));
mult3x3 m4(.in1(W[4]), .in2(vds_or_vov[4]), .out(w_mult[4]));
mult3x3 m5(.in1(W[5]), .in2(vds_or_vov[5]), .out(w_mult[5]));

//module LUT(in, out);
LUT L0(idgm_l2[0], sort_l0[0]);
LUT L1(idgm_l2[1], sort_l0[1]);
LUT L2(idgm_l2[2], sort_l0[2]);
LUT L3(idgm_l2[3], sort_l0[3]);
LUT L4(idgm_l2[4], sort_l0[4]);
LUT L5(idgm_l2[5], sort_l0[5]);


/*Sort*/

//module comp(in1,in2,out1,out2);
//level 1~5
//0-->5, large-->small
comp c01(sort_l0[0], sort_l0[1], sort_l1[0],  sort_l1[1]);
comp c02(sort_l0[2], sort_l0[3], sort_l1[2],  sort_l1[3]);
comp c03(sort_l0[4], sort_l0[5], sort_l1[4],  sort_l1[5]);
comp c04(sort_l1[0], sort_l1[2], sort_l2[0],  sort_l2[1]);
comp c05(sort_l1[1], sort_l1[4], sort_l2[2],  sort_l2[3]);
comp c06(sort_l1[3], sort_l1[5], sort_l2[4],  sort_l2[5]);
comp c07(sort_l2[0], sort_l2[2], sort_out[0], sort_l3[0]);
comp c08(sort_l2[1], sort_l2[4], sort_l3[1],  sort_l3[2]);
comp c09(sort_l2[3], sort_l2[5], sort_l3[3],  sort_out[5]);
comp c10(sort_l3[0], sort_l3[1], sort_out[1], sort_l4[0]);
comp c11(sort_l3[2], sort_l3[3], sort_l4[1],  sort_out[4]);
comp c12(sort_l4[0], sort_l4[1], sort_out[2], sort_out[3]);

/*Select according to mode*/
always@(*) begin
  if(mode[1]) begin //larger
    cal1_0 = sort_out[0];
    cal2_0 = sort_out[1];
    cal3_0 = sort_out[2];
  end
  else begin //smaller
    cal1_0 = sort_out[3];
    cal2_0 = sort_out[4];
    cal3_0 = sort_out[5];
  end

  //Id or gm
  if(mode[0]) begin //Id
    cal1 = cal1_0 << 'd1;
    cal2 = cal2_0 << 'd2;
    cal3 = cal3_0 << 'd2;
  end
  else begin //gm
    cal1 = 8'd0;
    cal2 = cal2_0;
    cal3 = 9'd0;
  end

end

/*Output*/
always@(*)begin
  sum_lv1 = cal1_0 + cal3_0 + cal1 + cal2 + cal3;
  if(mode[0]) sum_lv2 = sum_lv1 >> 2;
  else        sum_lv2 = sum_lv1[7:0];

end

LUT L6(sum_lv2, sum_lv3);


always@(*)begin
  out_n = {1'b0, sum_lv3};

end





endmodule


//================================================================
//   SUB MODULE
//================================================================

// module BBQ (meat,vagetable,water,cost);
// input XXX;
// output XXX;
// 
// endmodule

// --------------------------------------------------
// Example for using submodule 
// BBQ bbq0(.meat(meat_0), .vagetable(vagetable_0), .water(water_0),.cost(cost[0]));
// --------------------------------------------------
// Example for continuous assignment
// assign out_n = XXX;
// --------------------------------------------------
// Example for procedure assignment
// always@(*) begin 
// 	out_n = XXX; 
// end
// --------------------------------------------------
// Example for case statement
// always @(*) begin
// 	case(op)
// 		2'b00: output_reg = a + b;
// 		2'b10: output_reg = a - b;
// 		2'b01: output_reg = a * b;
// 		2'b11: output_reg = a / b;
// 		default: output_reg = 0;
// 	endcase
// end
// --------------------------------------------------

module comp(in1,in2,out1,out2);

input [6:0] in1, in2;
output reg [6:0] out1,out2;

//assign out1=(in1>in2)?in2:in1;
//assign out2=(in1>in2)?in1:in2;

always@(*) begin
	if(in2>in1)begin
	    out1=in2;
	    out2=in1;
	end
	else begin
	    out1=in1;
	    out2=in2;
	end
end

endmodule

module mult3x3(in1, in2, out);

input [2:0] in1, in2;
output reg [5:0] out;

reg [2:0] temp1, temp2, temp3;
reg [5:0] temp4, temp5, temp6;

always@(*)begin
  temp1 = {in1[2]&in2[0], in1[1]&in2[0], in1[0]&in2[0]};
  temp2 = {in1[2]&in2[1], in1[1]&in2[1], in1[0]&in2[1]};
  temp3 = {in1[2]&in2[2], in1[1]&in2[2], in1[0]&in2[2]};

  temp4 = {3'b0, temp1};
  temp5 = {2'b0, temp2, 1'b0};
  temp6 = {1'b0, temp3, 2'b0};

  out = temp4+temp5+temp6;
end

endmodule

module LUT(in, out);

input [7:0] in;
output reg [6:0] out;

//divide by 3
always@(*) begin
    casez(in) //in: 8 bits
        8'b0000_0000,8'b0000_0001,8'b0000_0010: out = 0;
        8'b0000_0011,8'b0000_0100,8'b0000_0101: out = 1;
        8'b0000_0110,8'b0000_0111,8'b0000_1000: out = 2;
        8'b0000_1001,8'b0000_1010,8'b0000_1011: out = 3;
        8'b0000_1100,8'b0000_1101,8'b0000_1110: out = 4;
        8'b0000_1111,8'b0001_0000,8'b0001_0001: out = 5;
        8'b0001_0010,8'b0001_0011,8'b0001_0100: out = 6;
        8'b0001_0101,8'b0001_0110,8'b0001_0111: out = 7;
        8'b0001_1000,8'b0001_1001,8'b0001_1010: out = 8;
        8'b0001_1011,8'b0001_1100,8'b0001_1101: out = 9;
        8'b0001_1110,8'b0001_1111,8'b0010_0000: out = 10;
        8'b0010_0001,8'b0010_0010,8'b0010_0011: out = 11;
        8'b0010_0100,8'b0010_0101,8'b0010_0110: out = 12;
        8'b0010_0111,8'b0010_1000,8'b0010_1001: out = 13;
        8'b0010_1010,8'b0010_1011,8'b0010_1100: out = 14;
        8'b0010_1101,8'b0010_1110,8'b0010_1111: out = 15;
        8'b0011_0000,8'b0011_0001,8'b0011_0010: out = 16;
        8'b0011_0011,8'b0011_0100,8'b0011_0101: out = 17;
        8'b0011_0110,8'b0011_0111,8'b0011_1000: out = 18;
        8'b0011_1001,8'b0011_1010,8'b0011_1011: out = 19;
        8'b0011_1100,8'b0011_1101,8'b0011_1110: out = 20;
        8'b0011_1111,8'b0100_0000,8'b0100_0001: out = 21;
        8'b0100_0010,8'b0100_0011,8'b0100_0100: out = 22;
        8'b0100_0101,8'b0100_0110,8'b0100_0111: out = 23;
        8'b0100_1000,8'b0100_1001,8'b0100_1010: out = 24;
        8'b0100_1011,8'b0100_1100,8'b0100_1101: out = 25;
        8'b0100_1110,8'b0100_1111,8'b0101_0000: out = 26;
        8'b0101_0001,8'b0101_0010,8'b0101_0011: out = 27;
        8'b0101_0100,8'b0101_0101,8'b0101_0110: out = 28;
        8'b0101_0111,8'b0101_1000,8'b0101_1001: out = 29;
        8'b0101_1010,8'b0101_1011,8'b0101_1100: out = 30;
        8'b0101_1101,8'b0101_1110,8'b0101_1111: out = 31;
        8'b0110_0000,8'b0110_0001,8'b0110_0010: out = 32;
        8'b0110_0011,8'b0110_0100,8'b0110_0101: out = 33;
        8'b0110_0110,8'b0110_0111,8'b0110_1000: out = 34;
        8'b0110_1001,8'b0110_1010,8'b0110_1011: out = 35;
        8'b0110_1100,8'b0110_1101,8'b0110_1110: out = 36;
        8'b0110_1111,8'b0111_0000,8'b0111_0001: out = 37;
        8'b0111_0010,8'b0111_0011,8'b0111_0100: out = 38;
        8'b0111_0101,8'b0111_0110,8'b0111_0111: out = 39;
        8'b0111_1000,8'b0111_1001,8'b0111_1010: out = 40;
        8'b0111_1011,8'b0111_1100,8'b0111_1101: out = 41;
        8'b0111_1110,8'b0111_1111,8'b1000_0000: out = 42;
        8'b1000_0001,8'b1000_0010,8'b1000_0011: out = 43;
        8'b1000_0100,8'b1000_0101,8'b1000_0110: out = 44;
        8'b1000_0111,8'b1000_1000,8'b1000_1001: out = 45;
        8'b1000_1010,8'b1000_1011,8'b1000_1100: out = 46;
        8'b1000_1101,8'b1000_1110,8'b1000_1111: out = 47;
        8'b1001_0000,8'b1001_0001,8'b1001_0010: out = 48;
        8'b1001_0011,8'b1001_0100,8'b1001_0101: out = 49;
        8'b1001_0110,8'b1001_0111,8'b1001_1000: out = 50;
        8'b1001_1001,8'b1001_1010,8'b1001_1011: out = 51;
        8'b1001_1100,8'b1001_1101,8'b1001_1110: out = 52;
        8'b1001_1111,8'b1010_0000,8'b1010_0001: out = 53;
        8'b1010_0010,8'b1010_0011,8'b1010_0100: out = 54;
        8'b1010_0101,8'b1010_0110,8'b1010_0111: out = 55;
        8'b1010_1000,8'b1010_1001,8'b1010_1010: out = 56;
        8'b1010_1011,8'b1010_1100,8'b1010_1101: out = 57;
        8'b1010_1110,8'b1010_1111,8'b1011_0000: out = 58;
        8'b1011_0001,8'b1011_0010,8'b1011_0011: out = 59;
        8'b1011_0100,8'b1011_0101,8'b1011_0110: out = 60;
        8'b1011_0111,8'b1011_1000,8'b1011_1001: out = 61;
        8'b1011_1010,8'b1011_1011,8'b1011_1100: out = 62;
        8'b1011_1101,8'b1011_1110,8'b1011_1111: out = 63;
        8'b1100_0000,8'b1100_0001,8'b1100_0010: out = 64;
        8'b1100_0011,8'b1100_0100,8'b1100_0101: out = 65;
        8'b1100_0110,8'b1100_0111,8'b1100_1000: out = 66;
        8'b1100_1001,8'b1100_1010,8'b1100_1011: out = 67;
        8'b1100_1100,8'b1100_1101,8'b1100_1110: out = 68;
        8'b1100_1111,8'b1101_0000,8'b1101_0001: out = 69;
        8'b1101_0010,8'b1101_0011,8'b1101_0100: out = 70;
        8'b1101_0101,8'b1101_0110,8'b1101_0111: out = 71;
        8'b1101_1000,8'b1101_1001,8'b1101_1010: out = 72;
        8'b1101_1011,8'b1101_1100,8'b1101_1101: out = 73;
        8'b1101_1110,8'b1101_1111,8'b1110_0000: out = 74;
        8'b1110_0001,8'b1110_0010,8'b1110_0011: out = 75;
        8'b1110_0100,8'b1110_0101,8'b1110_0110: out = 76;
        8'b1110_0111,8'b1110_1000,8'b1110_1001: out = 77;
        8'b1110_1010,8'b1110_1011,8'b1110_1100: out = 78;
        8'b1110_1101,8'b1110_1110,8'b1110_1111: out = 79;
        8'b1111_0000,8'b1111_0001,8'b1111_0010: out = 80;
        8'b1111_0011,8'b1111_0100,8'b1111_0101: out = 81;
        8'b1111_0110,8'b1111_0111,8'b1111_1000: out = 82;
        8'b1111_1001,8'b1111_1010,8'b1111_1011: out = 83;
        8'b1111_1100,8'b1111_1101,8'b1111_1110: out = 84;
        8'b1111_1111: out = 85;
        //default:      out = 85;

    endcase
end

endmodule