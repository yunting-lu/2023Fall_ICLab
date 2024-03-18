###################################################################

# Created by write_sdc on Mon Nov 20 17:11:43 2023

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_load -pin_load 0.05 [get_ports out_valid]
set_load -pin_load 0.05 [get_ports {out[31]}]
set_load -pin_load 0.05 [get_ports {out[30]}]
set_load -pin_load 0.05 [get_ports {out[29]}]
set_load -pin_load 0.05 [get_ports {out[28]}]
set_load -pin_load 0.05 [get_ports {out[27]}]
set_load -pin_load 0.05 [get_ports {out[26]}]
set_load -pin_load 0.05 [get_ports {out[25]}]
set_load -pin_load 0.05 [get_ports {out[24]}]
set_load -pin_load 0.05 [get_ports {out[23]}]
set_load -pin_load 0.05 [get_ports {out[22]}]
set_load -pin_load 0.05 [get_ports {out[21]}]
set_load -pin_load 0.05 [get_ports {out[20]}]
set_load -pin_load 0.05 [get_ports {out[19]}]
set_load -pin_load 0.05 [get_ports {out[18]}]
set_load -pin_load 0.05 [get_ports {out[17]}]
set_load -pin_load 0.05 [get_ports {out[16]}]
set_load -pin_load 0.05 [get_ports {out[15]}]
set_load -pin_load 0.05 [get_ports {out[14]}]
set_load -pin_load 0.05 [get_ports {out[13]}]
set_load -pin_load 0.05 [get_ports {out[12]}]
set_load -pin_load 0.05 [get_ports {out[11]}]
set_load -pin_load 0.05 [get_ports {out[10]}]
set_load -pin_load 0.05 [get_ports {out[9]}]
set_load -pin_load 0.05 [get_ports {out[8]}]
set_load -pin_load 0.05 [get_ports {out[7]}]
set_load -pin_load 0.05 [get_ports {out[6]}]
set_load -pin_load 0.05 [get_ports {out[5]}]
set_load -pin_load 0.05 [get_ports {out[4]}]
set_load -pin_load 0.05 [get_ports {out[3]}]
set_load -pin_load 0.05 [get_ports {out[2]}]
set_load -pin_load 0.05 [get_ports {out[1]}]
set_load -pin_load 0.05 [get_ports {out[0]}]
create_clock [get_ports clk]  -period 70  -waveform {0 35}
set_max_delay 70  -from [list [get_ports clk] [get_ports rst_n] [get_ports cg_en] [get_ports    \
in_valid] [get_ports {Img[31]}] [get_ports {Img[30]}] [get_ports {Img[29]}]    \
[get_ports {Img[28]}] [get_ports {Img[27]}] [get_ports {Img[26]}] [get_ports   \
{Img[25]}] [get_ports {Img[24]}] [get_ports {Img[23]}] [get_ports {Img[22]}]   \
[get_ports {Img[21]}] [get_ports {Img[20]}] [get_ports {Img[19]}] [get_ports   \
{Img[18]}] [get_ports {Img[17]}] [get_ports {Img[16]}] [get_ports {Img[15]}]   \
[get_ports {Img[14]}] [get_ports {Img[13]}] [get_ports {Img[12]}] [get_ports   \
{Img[11]}] [get_ports {Img[10]}] [get_ports {Img[9]}] [get_ports {Img[8]}]     \
[get_ports {Img[7]}] [get_ports {Img[6]}] [get_ports {Img[5]}] [get_ports      \
{Img[4]}] [get_ports {Img[3]}] [get_ports {Img[2]}] [get_ports {Img[1]}]       \
[get_ports {Img[0]}] [get_ports {Kernel[31]}] [get_ports {Kernel[30]}]         \
[get_ports {Kernel[29]}] [get_ports {Kernel[28]}] [get_ports {Kernel[27]}]     \
[get_ports {Kernel[26]}] [get_ports {Kernel[25]}] [get_ports {Kernel[24]}]     \
[get_ports {Kernel[23]}] [get_ports {Kernel[22]}] [get_ports {Kernel[21]}]     \
[get_ports {Kernel[20]}] [get_ports {Kernel[19]}] [get_ports {Kernel[18]}]     \
[get_ports {Kernel[17]}] [get_ports {Kernel[16]}] [get_ports {Kernel[15]}]     \
[get_ports {Kernel[14]}] [get_ports {Kernel[13]}] [get_ports {Kernel[12]}]     \
[get_ports {Kernel[11]}] [get_ports {Kernel[10]}] [get_ports {Kernel[9]}]      \
[get_ports {Kernel[8]}] [get_ports {Kernel[7]}] [get_ports {Kernel[6]}]        \
[get_ports {Kernel[5]}] [get_ports {Kernel[4]}] [get_ports {Kernel[3]}]        \
[get_ports {Kernel[2]}] [get_ports {Kernel[1]}] [get_ports {Kernel[0]}]        \
[get_ports {Weight[31]}] [get_ports {Weight[30]}] [get_ports {Weight[29]}]     \
[get_ports {Weight[28]}] [get_ports {Weight[27]}] [get_ports {Weight[26]}]     \
[get_ports {Weight[25]}] [get_ports {Weight[24]}] [get_ports {Weight[23]}]     \
[get_ports {Weight[22]}] [get_ports {Weight[21]}] [get_ports {Weight[20]}]     \
[get_ports {Weight[19]}] [get_ports {Weight[18]}] [get_ports {Weight[17]}]     \
[get_ports {Weight[16]}] [get_ports {Weight[15]}] [get_ports {Weight[14]}]     \
[get_ports {Weight[13]}] [get_ports {Weight[12]}] [get_ports {Weight[11]}]     \
[get_ports {Weight[10]}] [get_ports {Weight[9]}] [get_ports {Weight[8]}]       \
[get_ports {Weight[7]}] [get_ports {Weight[6]}] [get_ports {Weight[5]}]        \
[get_ports {Weight[4]}] [get_ports {Weight[3]}] [get_ports {Weight[2]}]        \
[get_ports {Weight[1]}] [get_ports {Weight[0]}] [get_ports {Opt[1]}]           \
[get_ports {Opt[0]}]]  -to [list [get_ports out_valid] [get_ports {out[31]}] [get_ports {out[30]}]   \
[get_ports {out[29]}] [get_ports {out[28]}] [get_ports {out[27]}] [get_ports   \
{out[26]}] [get_ports {out[25]}] [get_ports {out[24]}] [get_ports {out[23]}]   \
[get_ports {out[22]}] [get_ports {out[21]}] [get_ports {out[20]}] [get_ports   \
{out[19]}] [get_ports {out[18]}] [get_ports {out[17]}] [get_ports {out[16]}]   \
[get_ports {out[15]}] [get_ports {out[14]}] [get_ports {out[13]}] [get_ports   \
{out[12]}] [get_ports {out[11]}] [get_ports {out[10]}] [get_ports {out[9]}]    \
[get_ports {out[8]}] [get_ports {out[7]}] [get_ports {out[6]}] [get_ports      \
{out[5]}] [get_ports {out[4]}] [get_ports {out[3]}] [get_ports {out[2]}]       \
[get_ports {out[1]}] [get_ports {out[0]}]]
set_false_path   -from [get_clocks clk]  -to [list [get_cells GATED_out/latch_or_sleep_reg] [get_cells                 \
GATED_encoding2/latch_or_sleep_reg] [get_cells                                 \
GATED_data33/latch_or_sleep_reg] [get_cells GATED_data32/latch_or_sleep_reg]   \
[get_cells GATED_data31/latch_or_sleep_reg] [get_cells                         \
GATED_data30/latch_or_sleep_reg] [get_cells GATED_data23/latch_or_sleep_reg]   \
[get_cells GATED_data22/latch_or_sleep_reg] [get_cells                         \
GATED_data21/latch_or_sleep_reg] [get_cells GATED_data20/latch_or_sleep_reg]   \
[get_cells GATED_data13/latch_or_sleep_reg] [get_cells                         \
GATED_data12/latch_or_sleep_reg] [get_cells GATED_data11/latch_or_sleep_reg]   \
[get_cells GATED_data10/latch_or_sleep_reg] [get_cells                         \
GATED_data03/latch_or_sleep_reg] [get_cells GATED_data02/latch_or_sleep_reg]   \
[get_cells GATED_data01/latch_or_sleep_reg] [get_cells                         \
GATED_data00/latch_or_sleep_reg] [get_cells                                    \
gated_cnt_array_47__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_46__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_45__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_44__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_43__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_42__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_41__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_40__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_39__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_38__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_37__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_36__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_35__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_34__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_33__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_32__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_31__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_30__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_29__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_28__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_27__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_26__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_25__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_24__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_23__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_22__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_21__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_20__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_19__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_18__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_17__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_16__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_15__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_14__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_13__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_12__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_11__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_10__GATED_cnt/latch_or_sleep_reg] [get_cells                   \
gated_cnt_array_9__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_8__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_7__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_6__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_5__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_4__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_3__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_2__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_1__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_cnt_array_0__GATED_cnt/latch_or_sleep_reg] [get_cells                    \
gated_kernelweight_array_25__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_24__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_23__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_22__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_21__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_20__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_19__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_18__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_17__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_16__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_15__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_14__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_13__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_12__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_11__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_10__GATED_kernelweight/latch_or_sleep_reg] [get_cells \
gated_kernelweight_array_9__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_8__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_7__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_6__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_5__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_4__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_3__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_2__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_1__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_kernelweight_array_0__GATED_kernelweight/latch_or_sleep_reg] [get_cells  \
gated_img_array_14__GATED_imgarray/latch_or_sleep_reg] [get_cells              \
gated_img_array_13__GATED_imgarray/latch_or_sleep_reg] [get_cells              \
gated_img_array_12__GATED_imgarray/latch_or_sleep_reg] [get_cells              \
gated_img_array_11__GATED_imgarray/latch_or_sleep_reg] [get_cells              \
gated_img_array_10__GATED_imgarray/latch_or_sleep_reg] [get_cells              \
gated_img_array_9__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_8__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_7__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_6__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_5__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_4__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_3__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_2__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_1__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
gated_img_array_0__GATED_imgarray/latch_or_sleep_reg] [get_cells               \
GATED_img0/latch_or_sleep_reg] [get_cells GATED_opt/latch_or_sleep_reg]]
set_input_delay -clock clk  0  [get_ports clk]
set_input_delay -clock clk  0  [get_ports rst_n]
set_input_delay -clock clk  35  [get_ports cg_en]
set_input_delay -clock clk  35  [get_ports in_valid]
set_input_delay -clock clk  35  [get_ports {Img[31]}]
set_input_delay -clock clk  35  [get_ports {Img[30]}]
set_input_delay -clock clk  35  [get_ports {Img[29]}]
set_input_delay -clock clk  35  [get_ports {Img[28]}]
set_input_delay -clock clk  35  [get_ports {Img[27]}]
set_input_delay -clock clk  35  [get_ports {Img[26]}]
set_input_delay -clock clk  35  [get_ports {Img[25]}]
set_input_delay -clock clk  35  [get_ports {Img[24]}]
set_input_delay -clock clk  35  [get_ports {Img[23]}]
set_input_delay -clock clk  35  [get_ports {Img[22]}]
set_input_delay -clock clk  35  [get_ports {Img[21]}]
set_input_delay -clock clk  35  [get_ports {Img[20]}]
set_input_delay -clock clk  35  [get_ports {Img[19]}]
set_input_delay -clock clk  35  [get_ports {Img[18]}]
set_input_delay -clock clk  35  [get_ports {Img[17]}]
set_input_delay -clock clk  35  [get_ports {Img[16]}]
set_input_delay -clock clk  35  [get_ports {Img[15]}]
set_input_delay -clock clk  35  [get_ports {Img[14]}]
set_input_delay -clock clk  35  [get_ports {Img[13]}]
set_input_delay -clock clk  35  [get_ports {Img[12]}]
set_input_delay -clock clk  35  [get_ports {Img[11]}]
set_input_delay -clock clk  35  [get_ports {Img[10]}]
set_input_delay -clock clk  35  [get_ports {Img[9]}]
set_input_delay -clock clk  35  [get_ports {Img[8]}]
set_input_delay -clock clk  35  [get_ports {Img[7]}]
set_input_delay -clock clk  35  [get_ports {Img[6]}]
set_input_delay -clock clk  35  [get_ports {Img[5]}]
set_input_delay -clock clk  35  [get_ports {Img[4]}]
set_input_delay -clock clk  35  [get_ports {Img[3]}]
set_input_delay -clock clk  35  [get_ports {Img[2]}]
set_input_delay -clock clk  35  [get_ports {Img[1]}]
set_input_delay -clock clk  35  [get_ports {Img[0]}]
set_input_delay -clock clk  35  [get_ports {Kernel[31]}]
set_input_delay -clock clk  35  [get_ports {Kernel[30]}]
set_input_delay -clock clk  35  [get_ports {Kernel[29]}]
set_input_delay -clock clk  35  [get_ports {Kernel[28]}]
set_input_delay -clock clk  35  [get_ports {Kernel[27]}]
set_input_delay -clock clk  35  [get_ports {Kernel[26]}]
set_input_delay -clock clk  35  [get_ports {Kernel[25]}]
set_input_delay -clock clk  35  [get_ports {Kernel[24]}]
set_input_delay -clock clk  35  [get_ports {Kernel[23]}]
set_input_delay -clock clk  35  [get_ports {Kernel[22]}]
set_input_delay -clock clk  35  [get_ports {Kernel[21]}]
set_input_delay -clock clk  35  [get_ports {Kernel[20]}]
set_input_delay -clock clk  35  [get_ports {Kernel[19]}]
set_input_delay -clock clk  35  [get_ports {Kernel[18]}]
set_input_delay -clock clk  35  [get_ports {Kernel[17]}]
set_input_delay -clock clk  35  [get_ports {Kernel[16]}]
set_input_delay -clock clk  35  [get_ports {Kernel[15]}]
set_input_delay -clock clk  35  [get_ports {Kernel[14]}]
set_input_delay -clock clk  35  [get_ports {Kernel[13]}]
set_input_delay -clock clk  35  [get_ports {Kernel[12]}]
set_input_delay -clock clk  35  [get_ports {Kernel[11]}]
set_input_delay -clock clk  35  [get_ports {Kernel[10]}]
set_input_delay -clock clk  35  [get_ports {Kernel[9]}]
set_input_delay -clock clk  35  [get_ports {Kernel[8]}]
set_input_delay -clock clk  35  [get_ports {Kernel[7]}]
set_input_delay -clock clk  35  [get_ports {Kernel[6]}]
set_input_delay -clock clk  35  [get_ports {Kernel[5]}]
set_input_delay -clock clk  35  [get_ports {Kernel[4]}]
set_input_delay -clock clk  35  [get_ports {Kernel[3]}]
set_input_delay -clock clk  35  [get_ports {Kernel[2]}]
set_input_delay -clock clk  35  [get_ports {Kernel[1]}]
set_input_delay -clock clk  35  [get_ports {Kernel[0]}]
set_input_delay -clock clk  35  [get_ports {Weight[31]}]
set_input_delay -clock clk  35  [get_ports {Weight[30]}]
set_input_delay -clock clk  35  [get_ports {Weight[29]}]
set_input_delay -clock clk  35  [get_ports {Weight[28]}]
set_input_delay -clock clk  35  [get_ports {Weight[27]}]
set_input_delay -clock clk  35  [get_ports {Weight[26]}]
set_input_delay -clock clk  35  [get_ports {Weight[25]}]
set_input_delay -clock clk  35  [get_ports {Weight[24]}]
set_input_delay -clock clk  35  [get_ports {Weight[23]}]
set_input_delay -clock clk  35  [get_ports {Weight[22]}]
set_input_delay -clock clk  35  [get_ports {Weight[21]}]
set_input_delay -clock clk  35  [get_ports {Weight[20]}]
set_input_delay -clock clk  35  [get_ports {Weight[19]}]
set_input_delay -clock clk  35  [get_ports {Weight[18]}]
set_input_delay -clock clk  35  [get_ports {Weight[17]}]
set_input_delay -clock clk  35  [get_ports {Weight[16]}]
set_input_delay -clock clk  35  [get_ports {Weight[15]}]
set_input_delay -clock clk  35  [get_ports {Weight[14]}]
set_input_delay -clock clk  35  [get_ports {Weight[13]}]
set_input_delay -clock clk  35  [get_ports {Weight[12]}]
set_input_delay -clock clk  35  [get_ports {Weight[11]}]
set_input_delay -clock clk  35  [get_ports {Weight[10]}]
set_input_delay -clock clk  35  [get_ports {Weight[9]}]
set_input_delay -clock clk  35  [get_ports {Weight[8]}]
set_input_delay -clock clk  35  [get_ports {Weight[7]}]
set_input_delay -clock clk  35  [get_ports {Weight[6]}]
set_input_delay -clock clk  35  [get_ports {Weight[5]}]
set_input_delay -clock clk  35  [get_ports {Weight[4]}]
set_input_delay -clock clk  35  [get_ports {Weight[3]}]
set_input_delay -clock clk  35  [get_ports {Weight[2]}]
set_input_delay -clock clk  35  [get_ports {Weight[1]}]
set_input_delay -clock clk  35  [get_ports {Weight[0]}]
set_input_delay -clock clk  35  [get_ports {Opt[1]}]
set_input_delay -clock clk  35  [get_ports {Opt[0]}]
set_output_delay -clock clk  35  [get_ports out_valid]
set_output_delay -clock clk  35  [get_ports {out[31]}]
set_output_delay -clock clk  35  [get_ports {out[30]}]
set_output_delay -clock clk  35  [get_ports {out[29]}]
set_output_delay -clock clk  35  [get_ports {out[28]}]
set_output_delay -clock clk  35  [get_ports {out[27]}]
set_output_delay -clock clk  35  [get_ports {out[26]}]
set_output_delay -clock clk  35  [get_ports {out[25]}]
set_output_delay -clock clk  35  [get_ports {out[24]}]
set_output_delay -clock clk  35  [get_ports {out[23]}]
set_output_delay -clock clk  35  [get_ports {out[22]}]
set_output_delay -clock clk  35  [get_ports {out[21]}]
set_output_delay -clock clk  35  [get_ports {out[20]}]
set_output_delay -clock clk  35  [get_ports {out[19]}]
set_output_delay -clock clk  35  [get_ports {out[18]}]
set_output_delay -clock clk  35  [get_ports {out[17]}]
set_output_delay -clock clk  35  [get_ports {out[16]}]
set_output_delay -clock clk  35  [get_ports {out[15]}]
set_output_delay -clock clk  35  [get_ports {out[14]}]
set_output_delay -clock clk  35  [get_ports {out[13]}]
set_output_delay -clock clk  35  [get_ports {out[12]}]
set_output_delay -clock clk  35  [get_ports {out[11]}]
set_output_delay -clock clk  35  [get_ports {out[10]}]
set_output_delay -clock clk  35  [get_ports {out[9]}]
set_output_delay -clock clk  35  [get_ports {out[8]}]
set_output_delay -clock clk  35  [get_ports {out[7]}]
set_output_delay -clock clk  35  [get_ports {out[6]}]
set_output_delay -clock clk  35  [get_ports {out[5]}]
set_output_delay -clock clk  35  [get_ports {out[4]}]
set_output_delay -clock clk  35  [get_ports {out[3]}]
set_output_delay -clock clk  35  [get_ports {out[2]}]
set_output_delay -clock clk  35  [get_ports {out[1]}]
set_output_delay -clock clk  35  [get_ports {out[0]}]
