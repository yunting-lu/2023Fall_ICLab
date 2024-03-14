//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : pseudo_SD.v
//   Module Name : pseudo_SD
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module pseudo_SD (
    clk,
    MOSI,
    MISO
);

input clk;
input MOSI;
output reg MISO;

parameter SD_p_r = "../00_TESTBED/SD_init.dat";

reg [63:0] SD [0:65535];
initial $readmemh(SD_p_r, SD);

reg [47:0] com_in;

integer latency, modulo;


//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////

//*read
//MOSI - command - 2'b01 + 6'd17 + 32bit_addr + CRC-7bit + 1'b1
//wait 0~8 units, units = 8 cycles
//MISO - response - 8'b0
//wait 1~32 units, units = 8 cycles
//MISO - data - 8'b1111_1110 + 64bit_data + CRC-16-CCITT

//*write
//MOSI - command - 2'b01 + 6'd24 + 32bit_addr + CRC-7bit + 1'b1
//wait 0~8 units, units = 8 cycles
//MISO - response - 8'b0
//wait 1~32 units, units = 8 cycles
//MOSI - data - 8'b1111_1110 + 64bit_data + CRC-16-CCITT
//wait 0 units, units = 8 cycles
//MISO - data response - 8'b00000101
//MISO keep low - busy - wait 0~32 units, units = 8 cycles

//{Start bit, Transmission bit, Command, Argument}

integer i, j, k;
parameter UNIT = 'd8;
integer SEED = 187;

reg Start, Transmission, End_bit;
reg [5:0] Command;
reg [31:0] Argument;
reg [6:0] CRC_in;

reg [6:0] crc7_golden;

integer wait_cycle, wait_time;

reg [7:0] start_token;

reg [63:0] data_SD;
reg [15:0] crc_16_sd;

reg [63:0] data_bridge;
reg [15:0] crc_16_bridge, crc16_golden;

reg [7:0] data_response_reg;


initial begin
    MISO = 1;
    
    while(1) begin
        com_in = 'd0;
        //store input MOSI
        if(MOSI === 1'b0) begin
            for(i=0;i<48;i=i+1) begin
                com_in[47-i] = MOSI;
                @(posedge clk);
            end
            command_format_input_task;
            wait_0_8_unit_task;
            response_task;
            MISO = 1;
            //split read and write
            if(Command === 'd17) begin //read
                wait_1_32_unit_task;
                data_out_from_SD_task;
            end
            else if(Command === 'd24) begin //write
                check_wait_1_32_unit_task;
                data_from_bridge_task;
                data_response_task;
            end
            else begin //fail
                YOU_FAIL_task;
                $display("---------------------------------------------------------------------");
    	    	$display("                          SPEC SD-1 FAIL                             ");
                $display("                 Command format should be correct                    ");
                $display("                  Command not equal to 17 or 24                      ");
                $display("---------------------------------------------------------------------");
    	    	$finish;
            end
            MISO = 1;
        end

        @(posedge clk); //?
    end
end



//////////////////////////////////////////////////////////////////////

task command_format_input_task; begin
    //split the part
    Start           = com_in[47];
    Transmission    = com_in[46];
    Command         = com_in[45:40];
    Argument        = com_in[39:8]; //address 
    CRC_in          = com_in[7:1];
    End_bit         = com_in[0];
    //check command format //length?, start, transmission, end
    if((Start !== 1'b0)||(Transmission !== 1'b1)||(End_bit !== 1'b1)) begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    		$display("                          SPEC SD-1 FAIL                             ");
            $display("                 Command format should be correct                    ");
            $display("---------------------------------------------------------------------");
    		$finish;
    end
    //check address range
    if(Argument > 'd65535) begin
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
    	$display("                          SPEC SD-2 FAIL                             ");
        $display("       The address should be within the legal range (0~65535)        ");
        $display("---------------------------------------------------------------------");
    	$finish;
    end
    //check crc-7
    crc7_golden = CRC7({Start,Transmission,Command,Argument});
    if(CRC_in !== crc7_golden) begin
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
        $display("                          SPEC SD-3 FAIL                             ");
        $display("                  CRC-7 check should be correct                      ");
        $display("---------------------------------------------------------------------");
    	$finish;
    end
end endtask



task wait_0_8_unit_task; begin

    wait_cycle = $urandom(SEED) % 9;
    wait_time = wait_cycle * UNIT;
    repeat(wait_time-1) @(posedge clk);

end endtask

task response_task; begin

    for(i=0;i<8;i=i+1) begin
        MISO = 1'b0;
        @(posedge clk);
    end

end endtask

task wait_1_32_unit_task; begin
    MISO = 1'b1;
    wait_cycle = $urandom(SEED) % 32;
    wait_time = (wait_cycle + 1) * UNIT;
    repeat(wait_time) @(posedge clk);

end endtask

task data_out_from_SD_task; begin
    //start token
    start_token = 8'hfe;
    for(i=0;i<8;i=i+1) begin
        MISO = start_token[7-i];
        @(posedge clk);
    end
    //data block //addr. stored in Argument
    data_SD = SD[Argument];
    for(j=0;j<64;j=j+1) begin
        MISO = data_SD[63-j];
        @(posedge clk);
    end
    //CRC-16-CCITT
    crc_16_sd = CRC16_CCITT(data_SD);
    for(k=0;k<16;k=k+1) begin
        MISO = crc_16_sd[15-k];
        @(posedge clk);
    end
end endtask


//TODO: spec sd-5-2 wrong result -- spec sd-2
task check_wait_1_32_unit_task; begin
    //first byte --- must be 8'b1111_1111
    for(i=0;i<8;i=i+1) begin
        @(posedge clk);
        if(MOSI !== 1'b1) begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    	    $display("                          SPEC SD-5 FAIL                             ");
            $display("         Time between each transmission should be correct            ");
            $display("---------------------------------------------------------------------");
    	    $finish;
        end
        
    end
    //other 31 byte --- can be 8'b1111_1111 or 8'b1111_1110
    latency = 0;
    while(MOSI === 1'b1) begin
        latency = latency + 1;
        @(posedge clk);
    end
    modulo = latency % UNIT;
    if((modulo != 'd0)||(latency > 256)) begin //248
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
    	$display("                          SPEC SD-5 FAIL                             ");
        $display("         Time between each transmission should be correct            ");
        $display("               (Only integer time units is allowed)                  ");
        $display("---------------------------------------------------------------------");
    	$finish;
    end
    //cannot be more than 32 bytes
    //if(latency > 248) begin //31*8 
    //    YOU_FAIL_task;
    //    $display("---------------------------------------------------------------------");
    //	$display("                          SPEC SD-5 FAIL                             ");
    //    $display("         Time between each transmission should be correct            ");
    //    $display("                    (latency over 32*8 cycles)                       ");
    //    $display("---------------------------------------------------------------------");
    //	$finish;
    //end

end endtask

//
task data_from_bridge_task; begin
    //data block
    //@(posedge clk); //! why
    for(i=0;i<64;i=i+1) begin
        @(posedge clk);
        data_bridge[63-i] = MOSI;
        //$display("data_bridge[%d] = %d", 63-i, data_bridge[63-i]);
        
    end
    //CRC-16-CCITT
    for(j=0;j<16;j=j+1) begin
        @(posedge clk);
        crc_16_bridge[15-j] = MOSI;
        
    end
    //check crc-16
    crc16_golden = CRC16_CCITT(data_bridge);
    if(crc_16_bridge !== crc16_golden) begin
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
        $display("                          SPEC SD-4 FAIL                             ");
        $display("               CRC-16-CCITT check should be correct                  ");
        $display("---------------------------------------------------------------------");
    	$finish;
    end
    //write data to SD //?
    //$display("SD before write: %b", SD[Argument]);
    //$display("Argument: %h", Argument);
    SD[Argument] = data_bridge;
    //$display("SD after write: %b", SD[Argument]);
end endtask

//
task data_response_task; begin
    //data response
    data_response_reg = 8'b0000_0101;
    for(i=0;i<8;i=i+1) begin
        
        MISO = data_response_reg[7-i];
        @(posedge clk);
    end
    //busy //wait 0~32 units, units = 8 cycles 
    MISO = 0;
    wait_cycle = $urandom(SEED) % 33;
    wait_time = wait_cycle * UNIT;
    repeat(wait_time) @(posedge clk);
end endtask





task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                 Error message from pseudo_SD.v                        *");
end endtask

function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1

    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;
    // Try to implement CRC-16-CCITT function by yourself.
    input [63:0] data;
    reg [15:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 13'h1021; //x^16 + x^12 + x^5 + 1 //?

    begin
        crc = 16'd0;
        for(i = 0; i < 64; i = i + 1) begin
            data_in = data[63-i];
            data_out = crc[15];
            crc = crc << 1;
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC16_CCITT = crc;
    end
endfunction

endmodule