//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : SORT_IP.v
//   	Module Name : SORT_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SORT_IP #(parameter IP_WIDTH = 8) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output reg [IP_WIDTH*4-1:0] OUT_character;

// ===============================================================
// Design
// ===============================================================

//for IP_WIDTH==8
/*
reg  [3:0] in_c [0:IP_WIDTH-1];
reg  [4:0] in_w [0:IP_WIDTH-1];
reg  [3:0] temp_c;
reg  [4:0] temp_w;
//reg  [3:0] in_c1 [0:IP_WIDTH-1];
//reg  [4:0] in_w1 [0:IP_WIDTH-1];
reg  [3:0] c_sorted [0:IP_WIDTH-1];
//integer i, j, k;
*/

generate


if(IP_WIDTH==8) begin

    reg  [3:0] in_c[0:7];
    reg  [4:0] in_w[0:7];
    reg  [3:0] temp_c;
    reg  [4:0] temp_w;
    reg  [3:0] c_sorted[0:7];
    integer i, j, k;

    always@(*) begin
        in_c[0] = IN_character[3:0];   //IN_character[31:28];
        in_c[1] = IN_character[7:4];   //IN_character[27:24];
        in_c[2] = IN_character[11:8];  //IN_character[23:20];
        in_c[3] = IN_character[15:12]; //IN_character[19:16];
        in_c[4] = IN_character[19:16]; //IN_character[15:12];
        in_c[5] = IN_character[23:20]; //IN_character[11:8];
        in_c[6] = IN_character[27:24]; //IN_character[7:4];
        in_c[7] = IN_character[31:28]; //IN_character[3:0];
        in_w[0] = IN_weight[4:0];    //IN_weight[39:35];
        in_w[1] = IN_weight[9:5];    //IN_weight[34:30];
        in_w[2] = IN_weight[14:10];  //IN_weight[29:25];
        in_w[3] = IN_weight[19:15];  //IN_weight[24:20];
        in_w[4] = IN_weight[24:20];  //IN_weight[19:15];
        in_w[5] = IN_weight[29:25];  //IN_weight[14:10];
        in_w[6] = IN_weight[34:30];  //IN_weight[9:5];
        in_w[7] = IN_weight[39:35];  //IN_weight[4:0];


        //sort (bubble) //0: smallest
        for(i = 0; i < 8; i = i+1) begin
            for(j = i+1; j < 8; j = j+1) begin
                if(in_w[i] > in_w[j])begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
                else if(in_w[i]==in_w[j] && in_c[i]>in_c[j]) begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
            end
        end
        //sorted
        for(k = 0; k < 8; k = k+1) begin
            c_sorted[k] = in_c[k];
        end
        //output
        OUT_character = {c_sorted[7],c_sorted[6],c_sorted[5],c_sorted[4],c_sorted[3],c_sorted[2],c_sorted[1],c_sorted[0]};

    end
end

else if(IP_WIDTH==7) begin
    reg  [3:0] in_c[0:6];
    reg  [4:0] in_w[0:6];
    reg  [3:0] temp_c;
    reg  [4:0] temp_w;
    reg  [3:0] c_sorted[0:6];
    integer i, j, k;

    always@(*) begin
        in_c[0] = IN_character[3:0];   //IN_character[31:28];
        in_c[1] = IN_character[7:4];   //IN_character[27:24];
        in_c[2] = IN_character[11:8];  //IN_character[23:20];
        in_c[3] = IN_character[15:12]; //IN_character[19:16];
        in_c[4] = IN_character[19:16]; //IN_character[15:12];
        in_c[5] = IN_character[23:20]; //IN_character[11:8];
        in_c[6] = IN_character[27:24]; //IN_character[7:4];
        in_w[0] = IN_weight[4:0];    //IN_weight[39:35];
        in_w[1] = IN_weight[9:5];    //IN_weight[34:30];
        in_w[2] = IN_weight[14:10];  //IN_weight[29:25];
        in_w[3] = IN_weight[19:15];  //IN_weight[24:20];
        in_w[4] = IN_weight[24:20];  //IN_weight[19:15];
        in_w[5] = IN_weight[29:25];  //IN_weight[14:10];
        in_w[6] = IN_weight[34:30];  //IN_weight[9:5];


        //sort (bubble) //0: smallest
        for(i = 0; i < 7; i = i+1) begin
            for(j = i+1; j < 7; j = j+1) begin
                if(in_w[i] > in_w[j])begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
                else if(in_w[i]==in_w[j] && in_c[i]>in_c[j]) begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
            end
        end
        //sorted
        for(k = 0; k < 7; k = k+1) begin
            c_sorted[k] = in_c[k];
        end
        //output
        OUT_character = {c_sorted[6],c_sorted[5],c_sorted[4],c_sorted[3],c_sorted[2],c_sorted[1],c_sorted[0]};

    end
end

else if(IP_WIDTH==6) begin
    reg  [3:0] in_c[0:5];
    reg  [4:0] in_w[0:5];
    reg  [3:0] temp_c;
    reg  [4:0] temp_w;
    reg  [3:0] c_sorted[0:5];
    integer i, j, k;

    always@(*) begin
        in_c[0] = IN_character[3:0];   //IN_character[31:28];
        in_c[1] = IN_character[7:4];   //IN_character[27:24];
        in_c[2] = IN_character[11:8];  //IN_character[23:20];
        in_c[3] = IN_character[15:12]; //IN_character[19:16];
        in_c[4] = IN_character[19:16]; //IN_character[15:12];
        in_c[5] = IN_character[23:20]; //IN_character[11:8];
        in_w[0] = IN_weight[4:0];    //IN_weight[39:35];
        in_w[1] = IN_weight[9:5];    //IN_weight[34:30];
        in_w[2] = IN_weight[14:10];  //IN_weight[29:25];
        in_w[3] = IN_weight[19:15];  //IN_weight[24:20];
        in_w[4] = IN_weight[24:20];  //IN_weight[19:15];
        in_w[5] = IN_weight[29:25];  //IN_weight[14:10];


        //sort (bubble) //0: smallest
        for(i = 0; i < 6; i = i+1) begin
            for(j = i+1; j < 6; j = j+1) begin
                if(in_w[i] > in_w[j])begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
                else if(in_w[i]==in_w[j] && in_c[i]>in_c[j]) begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
            end
        end
        //sorted
        for(k = 0; k < 6; k = k+1) begin
            c_sorted[k] = in_c[k];
        end
        //output
        OUT_character = {c_sorted[5],c_sorted[4],c_sorted[3],c_sorted[2],c_sorted[1],c_sorted[0]};

    end
end

else if(IP_WIDTH==5) begin
    reg  [3:0] in_c[0:4];
    reg  [4:0] in_w[0:4];
    reg  [3:0] temp_c;
    reg  [4:0] temp_w;
    reg  [3:0] c_sorted[0:4];
    integer i, j, k;

    always@(*) begin
        in_c[0] = IN_character[3:0];   //IN_character[31:28];
        in_c[1] = IN_character[7:4];   //IN_character[27:24];
        in_c[2] = IN_character[11:8];  //IN_character[23:20];
        in_c[3] = IN_character[15:12]; //IN_character[19:16];
        in_c[4] = IN_character[19:16]; //IN_character[15:12];
        in_w[0] = IN_weight[4:0];    //IN_weight[39:35];
        in_w[1] = IN_weight[9:5];    //IN_weight[34:30];
        in_w[2] = IN_weight[14:10];  //IN_weight[29:25];
        in_w[3] = IN_weight[19:15];  //IN_weight[24:20];
        in_w[4] = IN_weight[24:20];  //IN_weight[19:15];


        //sort (bubble) //0: smallest
        for(i = 0; i < 5; i = i+1) begin
            for(j = i+1; j < 5; j = j+1) begin
                if(in_w[i] > in_w[j])begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
                else if(in_w[i]==in_w[j] && in_c[i]>in_c[j]) begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
            end
        end
        //sorted
        for(k = 0; k < 5; k = k+1) begin
            c_sorted[k] = in_c[k];
        end
        //output
        OUT_character = {c_sorted[4],c_sorted[3],c_sorted[2],c_sorted[1],c_sorted[0]};

    end
end

else if(IP_WIDTH==4) begin
    reg  [3:0] in_c[0:3];
    reg  [4:0] in_w[0:3];
    reg  [3:0] temp_c;
    reg  [4:0] temp_w;
    reg  [3:0] c_sorted[0:3];
    integer i, j, k;

    always@(*) begin
        in_c[0] = IN_character[3:0];   //IN_character[31:28];
        in_c[1] = IN_character[7:4];   //IN_character[27:24];
        in_c[2] = IN_character[11:8];  //IN_character[23:20];
        in_c[3] = IN_character[15:12]; //IN_character[19:16];
        in_w[0] = IN_weight[4:0];    //IN_weight[39:35];
        in_w[1] = IN_weight[9:5];    //IN_weight[34:30];
        in_w[2] = IN_weight[14:10];  //IN_weight[29:25];
        in_w[3] = IN_weight[19:15];  //IN_weight[24:20];


        //sort (bubble) //0: smallest
        for(i = 0; i < 4; i = i+1) begin
            for(j = i+1; j < 4; j = j+1) begin
                if(in_w[i] > in_w[j])begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
                else if(in_w[i]==in_w[j] && in_c[i]>in_c[j]) begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
            end
        end
        //sorted
        for(k = 0; k < 4; k = k+1) begin
            c_sorted[k] = in_c[k];
        end
        //output
        OUT_character = {c_sorted[3],c_sorted[2],c_sorted[1],c_sorted[0]};

    end
end

//IP_WIDTH==3
else begin
    reg  [3:0] in_c[0:2];
    reg  [4:0] in_w[0:2];
    reg  [3:0] temp_c;
    reg  [4:0] temp_w;
    reg  [3:0] c_sorted[0:2];
    integer i, j, k;

    always@(*) begin
        in_c[0] = IN_character[3:0];   //IN_character[31:28];
        in_c[1] = IN_character[7:4];   //IN_character[27:24];
        in_c[2] = IN_character[11:8];  //IN_character[23:20];
        in_w[0] = IN_weight[4:0];    //IN_weight[39:35];
        in_w[1] = IN_weight[9:5];    //IN_weight[34:30];
        in_w[2] = IN_weight[14:10];  //IN_weight[29:25];


        //sort (bubble) //0: smallest
        for(i = 0; i < 3; i = i+1) begin
            for(j = i+1; j < 3; j = j+1) begin
                if(in_w[i] > in_w[j])begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
                else if(in_w[i]==in_w[j] && in_c[i]>in_c[j]) begin
                    temp_w = in_w[i];   temp_c = in_c[i];
                    in_w[i] = in_w[j];  in_c[i] = in_c[j];
                    in_w[j] = temp_w;   in_c[j] = temp_c;
                end
            end
        end
        //sorted
        for(k = 0; k < 3; k = k+1) begin
            c_sorted[k] = in_c[k];
        end
        //output
        OUT_character = {c_sorted[2],c_sorted[1],c_sorted[0]};

    end
end

endgenerate


endmodule