`ifdef RTL
`define CYCLE_TIME 15
`endif
`ifdef GATE
`define CYCLE_TIME 15
`endif


`include "../00_TESTBED/MEM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM.v"


module PATTERN #(parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32)(
// CHIP IO 
                clk,
              rst_n,
           in_valid,
           frame_id,
             net_id,
              loc_x,
              loc_y,
               cost,
               busy,

// AXI4 IO
         awid_s_inf,
       awaddr_s_inf,
       awsize_s_inf,
      awburst_s_inf,
        awlen_s_inf,
      awvalid_s_inf,
      awready_s_inf,

        wdata_s_inf,
        wlast_s_inf,
       wvalid_s_inf,
       wready_s_inf,

          bid_s_inf,
        bresp_s_inf,
       bvalid_s_inf,
       bready_s_inf,

         arid_s_inf,
       araddr_s_inf,
        arlen_s_inf,
       arsize_s_inf,
      arburst_s_inf,
      arvalid_s_inf,

      arready_s_inf, 
          rid_s_inf,
        rdata_s_inf,
        rresp_s_inf,
        rlast_s_inf,
       rvalid_s_inf,
       rready_s_inf 
             );

//======================================
//      I/O PORTS
//======================================

// << CHIP io port with system >>
output reg              clk;
output reg            rst_n;
output reg         in_valid;
output reg [4:0]   frame_id;
output reg [3:0]     net_id;
output reg [5:0]      loc_x;
output reg [5:0]      loc_y;
input [13:0]           cost;
input                  busy;
 
// << AXI Interface wire connecttion for pseudo DRAM read/write >>
// (1)  axi write address channel 
//      src master
input wire [ID_WIDTH-1:0]      awid_s_inf;
input wire [ADDR_WIDTH-1:0]  awaddr_s_inf;
input wire [2:0]             awsize_s_inf;
input wire [1:0]            awburst_s_inf;
input wire [7:0]              awlen_s_inf;
input wire                  awvalid_s_inf;
//      src slave
output wire                 awready_s_inf;
// -----------------------------

// (2)  axi write data channel 
//      src master
input wire [DATA_WIDTH-1:0]   wdata_s_inf;
input wire                    wlast_s_inf;
input wire                   wvalid_s_inf;
//      src slave
output wire                  wready_s_inf;

// (3)  axi write response channel 
//      src slave
output wire  [ID_WIDTH-1:0]     bid_s_inf;
output wire  [1:0]            bresp_s_inf;
output wire                  bvalid_s_inf;
//      src master 
input wire                   bready_s_inf;
// -----------------------------

// (4)  axi read address channel 
//      src master
input wire [ID_WIDTH-1:0]      arid_s_inf;
input wire [ADDR_WIDTH-1:0]  araddr_s_inf;
input wire [7:0]              arlen_s_inf;
input wire [2:0]             arsize_s_inf;
input wire [1:0]            arburst_s_inf;
input wire                  arvalid_s_inf;
//      src slave
output wire                 arready_s_inf;
// -----------------------------

// (5)  axi read data channel 
//      src slave
output wire [ID_WIDTH-1:0]      rid_s_inf;
output wire [DATA_WIDTH-1:0]  rdata_s_inf;
output wire [1:0]             rresp_s_inf;
output wire                   rlast_s_inf;
output wire                  rvalid_s_inf;
//      src master
input wire                   rready_s_inf;

//======================================
//      PARAMETERS & VARIABLES
//======================================
parameter CYCLE         = `CYCLE_TIME;
parameter DELAY         = 1000000;
parameter FRAME_OFFSET  = 'h10000;
parameter FRAME_SHIFT   = 'h800;
parameter WEIGHT_OFFSET = 'h20000;
integer   SEED          = 1208;
integer   PATNUM;

integer           i;
integer           j;
integer           m;
integer           n;
integer         pat;
integer     exe_lat;
integer     out_lat;
integer    file_ptr;
integer  input_file;
integer    map_file;
integer weight_file;
integer output_file;

//======================================
//      REGISTER DECLARATION
//======================================
// For input
integer numFrame;
integer numMacro;

integer net_start_x[0:15];
integer net_start_y[0:15];

integer net_end_x[0:15];
integer net_end_y[0:15];

integer net_id_queue[0:15];

integer orig_map[0:63][0:63];
integer wght_map[0:63][0:63];
integer your_map[0:63][0:63];

// For check
integer multi_path_flag;
integer gold_cost;

//======================================
//      CLOCK
//======================================
initial clk = 1'b0;
always #(CYCLE/2.0) clk = ~clk;

//======================================
//              MAIN
//======================================
initial exe_task;

//======================================
//              TASKS
//======================================
task exe_task; begin
    reset_task;
    for ( pat=0 ; pat<PATNUM ; pat=pat+1 ) begin
        input_task;
        load_orig_task;
        wait_task;
        check_task;
    end
    pass_task;
    $finish;
end endtask

task reset_task; begin

    force clk = 0;
    rst_n     = 1;
    in_valid  = 0;
    frame_id  = 'dx;
    net_id    = 'dx;
    loc_x     = 'dx;
    loc_y     = 'dx;

    input_file  = $fopen("../00_TESTBED/TEST_CASE/input_1.txt", "r");
    map_file    = $fopen("../00_TESTBED/TEST_CASE/map_0.txt", "r");
    weight_file = $fopen("../00_TESTBED/TEST_CASE/weight_0.txt", "r");

    file_ptr = $fscanf(input_file,"%d", PATNUM);

    #(CYCLE/2.0) rst_n = 0;
    #(CYCLE/2.0) rst_n = 1;
    if ( busy !== 0 ) begin
        $display("\033[1;34m");
        $display("====================================");
        $display("Busy should be 0 after initial reset");
        $display("====================================");
        $display("\033[1;0m");
        repeat(5) #(CYCLE);
        $finish;
    end
    #(CYCLE/2.0) release clk;
end endtask

task input_task; begin
    clear_net_task;
    repeat(3)@(negedge clk);
    file_ptr = $fscanf(input_file,"%d %d",numFrame, numMacro);
    in_valid = 1;
    for( i=0 ; i<numMacro ; i=i+1 ) begin
        if ( busy !== 0 ) begin
            $display("\033[1;34m");
            $display("=====================================");
            $display("Busy should be 0 when input is giving");
            $display("=====================================");
            $display("\033[1;0m");
            repeat(5) @ (negedge clk);
            $finish;
        end
        // Frame id 
        frame_id = numFrame;

        // Net id
        file_ptr = $fscanf(input_file,"%d", net_id);
        net_id_queue[i] = net_id;

        // Net start location
        file_ptr = $fscanf(input_file,"%d %d",loc_x, loc_y);
        net_start_x[i] = loc_x;
        net_start_y[i] = loc_y;

        @(negedge clk);

        // Net end location
        file_ptr = $fscanf(input_file,"%d %d",loc_x, loc_y);
        net_end_x[i] = loc_x;
        net_end_y[i] = loc_y;

        @(negedge clk);
    end
    in_valid  = 0;
    frame_id  = 'dx;
    net_id    = 'dx;
    loc_x     = 'dx;
    loc_y     = 'dx;
end endtask

task wait_task; begin
    exe_lat = -1;
    @( negedge clk );
    while ( busy!==0 ) begin
        if ( exe_lat==DELAY ) begin
            $display("\033[1;34m");
            $display("========================================");
            $display("The execution latency is over 1,000,000 ");
            $display("========================================");
            $display("\033[1;0m");
            repeat(5) @ (negedge clk);
            $finish;
        end
        exe_lat = exe_lat + 1;
        @ (negedge clk); 
    end
end endtask

task check_task; begin
    load_out_task;
    dump_task;
    // Check the map
    // (Consistent   Check) : check whether macros are moved or not
    for( i=0 ; i<64 ; i=i+1 ) begin
        for( j=0 ; j<64 ; j=j+1 ) begin
            // If original map is greater than zero which is mean that this location is macro
            if( orig_map[i][j] > 0 ) begin
                if( your_map[i][j] !== orig_map[i][j] ) begin
                    $display("\033[1;34m");
                    $display("==============================");
                    $display("The macros shouldn't be moved ");
                    $display("==============================");
                    $display("The Moved Macros id : %d", orig_map[i][j]);
                    $display("The original pixel  : %d", orig_map[i][j]);
                    $display("The output   pixel  : %d", your_map[i][j]);
                    $display("The index of pixel  : (%d, %d)", i, j);
                    $display("==============================");
                    $display("\033[1;0m");
                    repeat(5) @ (negedge clk);
                    $finish;
                end
            end
        end
    end
    /*
    // (Connectivity Check) : check whether source can reach sink or not
    for( i=0 ; i<64 ; i=i+1 ) begin
        for( j=0 ; j<64 ; j=j+1 ) begin
            // If original map is zero which is mean that this location is routable
            if( orig_map[i][j] === 0 ) begin
                if( i==0 && )
            end
        end
    end*/

    // (Cost         Check) : check whether weight output is correct or not
end endtask

task pass_task; begin
    $display("\033[1;34m");
    $display("====================================");
    $display("          PASS THIS LAB             ");
    $display("====================================");
    $display("\033[1;0m");
    repeat (5) @(negedge clk);
    $finish;
end endtask

//==========================================
// For net info operation
//==========================================
task clear_net_task; begin
    for( i=0 ; i<16 ; i=i+1 ) begin
        net_start_x[i]  = 'dx;
        net_start_y[i]  = 'dx;
        net_end_x[i]    = 'dx;
        net_end_y[i]    = 'dx;
        net_id_queue[i] = 'dx;
    end
end endtask

//==========================================
// For map operation
//==========================================
// Load the original map and weight map
task load_orig_task; begin
    for( i=0 ; i<64 ; i=i+1 ) begin
        for( j=0 ; j<32 ; j=j+1 ) begin
            // Original map
            orig_map[i][2*j  ] = u_DRAM.DRAM_r[ FRAME_OFFSET  + numFrame*FRAME_SHIFT + 32*i + j ][3:0];
            orig_map[i][2*j+1] = u_DRAM.DRAM_r[ FRAME_OFFSET  + numFrame*FRAME_SHIFT + 32*i + j ][7:4];

            // Weight map
            wght_map[i][2*j  ] = u_DRAM.DRAM_r[ WEIGHT_OFFSET + numFrame*FRAME_SHIFT + 32*i + j ][3:0];
            wght_map[i][2*j+1] = u_DRAM.DRAM_r[ WEIGHT_OFFSET + numFrame*FRAME_SHIFT + 32*i + j ][7:4];
        end
    end
end endtask

// Load the output map
task load_out_task; begin
    for( i=0 ; i<64 ; i=i+1 ) begin
        for( j=0 ; j<32 ; j=j+1 ) begin
            // Original map
            your_map[i][2*j  ] = u_DRAM.DRAM_r[ FRAME_OFFSET  + numFrame*FRAME_SHIFT + 32*i + j ][3:0];
            your_map[i][2*j+1] = u_DRAM.DRAM_r[ FRAME_OFFSET  + numFrame*FRAME_SHIFT + 32*i + j ][7:4];
        end
    end
end endtask

// Load the original map and weight map
task dump_task; begin
    output_file = $fopen("Midterm_Ouput_Result.txt", "w");
    //==================================================
    // Original map
    //==================================================
    $fwrite(output_file, "ORIGINAL MAP\n");
    // Display line
    for(i=0 ; i<65 ; i=i+1) $fwrite(output_file, "===");
    $fwrite(output_file, "\n");
    // Original map
    // x axis
    $fwrite(output_file, "   ");
    for(i=0 ; i<64 ; i=i+1) begin
        $fwrite(output_file, "%-2d ", i);
    end
    $fwrite(output_file, "\n");
    for(i=0 ; i<64 ; i=i+1) begin
        // y axis
        $fwrite(output_file, "%-2d ", i);
        for(j=0 ; j<64 ; j=j+1) begin
            // original map
            $fwrite(output_file, "%-2d ", orig_map[i][j]);
        end
        $fwrite(output_file, "\n");
    end
    // Display line
    for(i=0 ; i<65 ; i=i+1) $fwrite(output_file, "===");
    $fwrite(output_file, "\n");

    //==================================================
    // Weight map
    //==================================================
    $fwrite(output_file, "WEIGHT MAP\n");
    // Display line
    for(i=0 ; i<65 ; i=i+1) $fwrite(output_file, "===");
    $fwrite(output_file, "\n");
    // Original map
    // x axis
    $fwrite(output_file, "   ");
    for(i=0 ; i<64 ; i=i+1) begin
        $fwrite(output_file, "%-2d ", i);
    end
    $fwrite(output_file, "\n");
    for(i=0 ; i<64 ; i=i+1) begin
        // y axis
        $fwrite(output_file, "%-2d ", i);
        for(j=0 ; j<64 ; j=j+1) begin
            // original map
            $fwrite(output_file, "%-2d ", wght_map[i][j]);
        end
        $fwrite(output_file, "\n");
    end
    // Display line
    for(i=0 ; i<65 ; i=i+1) $fwrite(output_file, "===");
    $fwrite(output_file, "\n");

    //==================================================
    // Your map
    //==================================================
    $fwrite(output_file, "YOUR MAP\n");
    // Display line
    for(i=0 ; i<65 ; i=i+1) $fwrite(output_file, "===");
    $fwrite(output_file, "\n");
    // Original map
    // x axis
    $fwrite(output_file, "   ");
    for(i=0 ; i<64 ; i=i+1) begin
        $fwrite(output_file, "%-2d ", i);
    end
    $fwrite(output_file, "\n");
    for(i=0 ; i<64 ; i=i+1) begin
        // y axis
        $fwrite(output_file, "%-2d ", i);
        for(j=0 ; j<64 ; j=j+1) begin
            // original map
            $fwrite(output_file, "%-2d ", your_map[i][j]);
        end
        $fwrite(output_file, "\n");
    end
    // Display line
    for(i=0 ; i<65 ; i=i+1) $fwrite(output_file, "===");
    $fwrite(output_file, "\n");
    $fclose(output_file);

end endtask

// -------------------------//
//     DRAM Connection      //
//--------------------------//

pseudo_DRAM u_DRAM(

      .clk(clk),
      .rst_n(rst_n),

   .   awid_s_inf(   awid_s_inf),
   . awaddr_s_inf( awaddr_s_inf),
   . awsize_s_inf( awsize_s_inf),
   .awburst_s_inf(awburst_s_inf),
   .  awlen_s_inf(  awlen_s_inf),
   .awvalid_s_inf(awvalid_s_inf),
   .awready_s_inf(awready_s_inf),

   .  wdata_s_inf(  wdata_s_inf),
   .  wlast_s_inf(  wlast_s_inf),
   . wvalid_s_inf( wvalid_s_inf),
   . wready_s_inf( wready_s_inf),

   .    bid_s_inf(    bid_s_inf),
   .  bresp_s_inf(  bresp_s_inf),
   . bvalid_s_inf( bvalid_s_inf),
   . bready_s_inf( bready_s_inf),

   .   arid_s_inf(   arid_s_inf),
   . araddr_s_inf( araddr_s_inf),
   .  arlen_s_inf(  arlen_s_inf),
   . arsize_s_inf( arsize_s_inf),
   .arburst_s_inf(arburst_s_inf),
   .arvalid_s_inf(arvalid_s_inf),
   .arready_s_inf(arready_s_inf), 

   .    rid_s_inf(    rid_s_inf),
   .  rdata_s_inf(  rdata_s_inf),
   .  rresp_s_inf(  rresp_s_inf),
   .  rlast_s_inf(  rlast_s_inf),
   . rvalid_s_inf( rvalid_s_inf),
   . rready_s_inf( rready_s_inf) 
);

endmodule

