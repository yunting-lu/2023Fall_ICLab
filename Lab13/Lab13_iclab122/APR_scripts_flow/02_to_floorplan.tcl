#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Fri Dec 22 22:57:58 2023                
#                                                     
#######################################################

#@(#)CDS: Innovus v20.15-s105_1 (64bit) 07/27/2021 14:15 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: NanoRoute 20.15-s105_1 NR210726-1341/20_15-UB (database version 18.20.554) {superthreading v2.14}
#@(#)CDS: AAE 20.15-s020 (64bit) 07/27/2021 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: CTE 20.15-s024_1 () Jul 23 2021 04:46:45 ( )
#@(#)CDS: SYNTECH 20.15-s012_1 () Jul 12 2021 23:29:38 ( )
#@(#)CDS: CPE v20.15-s071
#@(#)CDS: IQuantus/TQuantus 20.1.1-s460 (64bit) Fri Mar 5 18:46:16 PST 2021 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getVersion
win
set init_design_uniquify 1
setDesignMode -process 180
suppressMessage TECHLIB 1318
suppressMessage ENCEXT-2799
set init_mmmc_file CHIP_mmmc.view
set init_lef_file {
    /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/UMC018_CBDK/CIC/SOCE//lef/header6_V55_20ka_cic.lef
    /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/UMC018_CBDK/CIC/SOCE//lef/fsa0m_a_generic_core.lef
    /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/UMC018_CBDK/CIC/SOCE//lef/FSA0M_A_GENERIC_CORE_ANT_V55.lef
    /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/UMC018_CBDK/CIC/SOCE//lef/fsa0m_a_t33_generic_io.lef
    /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/UMC018_CBDK/CIC/SOCE//lef/FSA0M_A_T33_GENERIC_IO_ANT_V55.lef
    /RAID2/COURSE/BackUp/2023_Spring/iclab/iclabta01/UMC018_CBDK/CIC/SOCE//lef/BONDPAD.lef
}
set init_verilog ./CHIP_SYN.v
set init_top_cell CHIP
set init_io_file ./CHIP.io
set init_pwr_net VCC
set init_gnd_net GND
init_design -setup av_func_mode_max -hold av_func_mode_min
save_global CHIP.globals
win
fit
fit
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site core_5040 -r 1.15643136726 0.355925 100 100 100 100
uiSetTool select
getIoFlowFlag
fit
