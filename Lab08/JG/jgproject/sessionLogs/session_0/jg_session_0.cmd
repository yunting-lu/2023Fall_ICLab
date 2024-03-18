# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2023.09
# platform  : Linux 3.10.0-1160.88.1.el7.x86_64
# version   : 2023.09p001 64 bits
# build date: 2023.10.25 14:35:20 UTC
# ----------------------------------------
# started   : 2023-11-19 16:14:29 CST
# hostname  : ee26.EEHPC
# pid       : 187288
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:33404' '-style' 'windows' '-data' 'AAAAnnicVYq9CkBgGEbPR0omV+AOGMxWG4nBapCUZPCzWLhUd/J5E+LU81ePAqJNa82FuYq5JKQUxOIZpeSLOu4SKb6ofP8lWM/xuRgiG5+Jhlq6R0dLde+KkYWBkIBZdi8PhxN+VREN' '-proj' '/RAID2/COURSE/iclab/iclab122/Lab08/JG/jgproject/sessionLogs/session_0' '-init' '-hidden' '/RAID2/COURSE/iclab/iclab122/Lab08/JG/jgproject/.tmp/.initCmds.tcl' 'jg_sec_run2.tcl'
clear -all 
set DW_SIM "/usr/cad/synopsys/synthesis/cur/dw/sim_ver/"
#set_resilient_compilation on

set_proofgrid_max_local_jobs 10
#check_sec -analyze -sv -both -f dw.f -ignore_translate_off
check_sec -analyze -sv -both ../EXERCISE/01_RTL/GATED_OR.v
check_sec -analyze -sv -both ../EXERCISE/01_RTL/SNN.v -y ${DW_SIM} +libext+.v +incdir+${DW_SIM}
check_sec -elaborate -both  -top SNN  -disable_auto_bbox
check_sec -setup


clock clk -both_edge 
reset ~rst_n

check_sec -gen
check_sec -interface

assume cg_en==0
assume SNN_imp.cg_en==1
check_sec -waive -waive_signals cg_en
check_sec -waive -waive_signals SNN_imp.cg_en

check_sec -interface


set_sec_autoprove_strategy design_style
set_sec_autoprove_design_style_type clock_gating


check_sec -prove -bg
