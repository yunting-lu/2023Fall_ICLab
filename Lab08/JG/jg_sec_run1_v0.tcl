clear -all 

set_resilient_compilation on

check_sec -analyze -sv -spec ../EXERCISE_wocg/01_RTL/SNN_wocg.v -ignore_translate_off +define+RTL
check_sec -analyze -spec -sv -f dw.f -ignore_translate_off
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_dp3.v
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_sum4.v
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_cmp.v
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_exp.v 
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_sub.v 
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_div.v
#check_sec -analyze -sv -spec /usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_sum3.v
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/GATED_OR.v 
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/SNN.v -ignore_translate_off +define+RTL
check_sec -analyze -sv -imp -f dw.f -ignore_translate_off
check_sec -elaborate -spec -top SNN -disable_x_handling 
check_sec -elaborate -imp  -top SNN -disable_x_handling 
check_sec -setup

clock clk -both_edge 
reset ~rst_n

check_sec -gen
check_sec -interface

assume SNN_imp.cg_en==0 
check_sec -waive -waive_signals SNN_imp.cg_en

check_sec -interface


set_sec_autoprove_strategy design_style
set_sec_autoprove_design_style_type clock_gating




check_sec -prove -bg
