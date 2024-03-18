# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2023.09
# platform  : Linux 3.10.0-1160.88.1.el7.x86_64
# version   : 2023.09p001 64 bits
# build date: 2023.10.25 14:35:20 UTC
# ----------------------------------------
# started   : 2023-11-19 16:14:06 CST
# hostname  : ee26.EEHPC
# pid       : 185856
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:46312' '-style' 'windows' '-data' 'AAAAnnicVYq9CkBgGEbPR0omV+AOKLvVRmKwGiQlGfwsFi7VnXzehDj1/NWjgGjTWnNhrmIuCSkFsXhGKfmijrtEii8q338J1nN8LobIxmeioZbu0dFS3btiZGEgJGCW3cvD4QR+RxEM' '-proj' '/RAID2/COURSE/iclab/iclab122/Lab08/JG/jgproject/sessionLogs/session_0' '-init' '-hidden' '/RAID2/COURSE/iclab/iclab122/Lab08/JG/jgproject/.tmp/.initCmds.tcl' 'jg_sec_run1.tcl'
clear -all 
set DW_SIM "/usr/cad/synopsys/synthesis/cur/dw/sim_ver/"
#set_resilient_compilation on

check_sec -analyze -sv -spec ../EXERCISE_wocg/01_RTL/SNN_wocg.v +define+RTL -y ${DW_SIM} +libext+.v +incdir+${DW_SIM}
#check_sec -analyze -spec -sv -f dw.f -ignore_translate_off
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/GATED_OR.v 
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/SNN.v +define+RTL -y ${DW_SIM} +libext+.v +incdir+${DW_SIM}
#check_sec -analyze -sv -imp -f dw.f -ignore_translate_off
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
