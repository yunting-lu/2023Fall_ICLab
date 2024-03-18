wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/RAID2/COURSE/iclab/iclab122/Lab08/EXERCISE/01_RTL/SNN_CG.fsdb}
wvRestoreSignal -win $_nWave1 \
           "/RAID2/COURSE/iclab/iclab122/Lab08/EXERCISE/signal_CG.rc" \
           -overWriteAutoAlias on -appendSignals on
wvResizeWindow -win $_nWave1 0 23 1536 793
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 8)}
wvSetPosition -win $_nWave1 {("G3" 8)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cg_en} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/image_reg\[0:3\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/G_clk_img0} \
{/TESTBED/u_SNN/G_clk_img\[0:14\]} \
{/TESTBED/u_SNN/G_clk_first_input} \
{/TESTBED/u_SNN/G_clk_input\[0:25\]} \
{/TESTBED/u_SNN/kern2_reg\[0:2\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/G_clk_out} \
}
wvCollapseGroup -win $_nWave1 "G2"
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/u_SNN/sum_z\[0:3\]} \
{/TESTBED/u_SNN/sum_z\[0\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[1\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[2\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[3\]\[31:0\]} \
{/TESTBED/u_SNN/c0_max\[31:0\]} \
{/TESTBED/u_SNN/mult_a\[0:10\]} \
{/TESTBED/u_SNN/mult_b\[0:10\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 7 8 )} 
wvSetPosition -win $_nWave1 {("G3" 8)}
wvSetPosition -win $_nWave1 {("G3" 8)}
wvSetPosition -win $_nWave1 {("G3" 8)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cg_en} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/image_reg\[0:3\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/G_clk_img0} \
{/TESTBED/u_SNN/G_clk_img\[0:14\]} \
{/TESTBED/u_SNN/G_clk_first_input} \
{/TESTBED/u_SNN/G_clk_input\[0:25\]} \
{/TESTBED/u_SNN/kern2_reg\[0:2\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/G_clk_out} \
}
wvCollapseGroup -win $_nWave1 "G2"
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/u_SNN/sum_z\[0:3\]} \
{/TESTBED/u_SNN/sum_z\[0\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[1\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[2\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[3\]\[31:0\]} \
{/TESTBED/u_SNN/c0_max\[31:0\]} \
{/TESTBED/u_SNN/mult_a\[0:10\]} \
{/TESTBED/u_SNN/mult_b\[0:10\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 7 8 )} 
wvSetPosition -win $_nWave1 {("G3" 8)}
wvGetSignalClose -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 9)}
wvSetPosition -win $_nWave1 {("G3" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cg_en} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/image_reg\[0:3\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/G_clk_img0} \
{/TESTBED/u_SNN/G_clk_img\[0:14\]} \
{/TESTBED/u_SNN/G_clk_first_input} \
{/TESTBED/u_SNN/G_clk_input\[0:25\]} \
{/TESTBED/u_SNN/kern2_reg\[0:2\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/G_clk_out} \
}
wvCollapseGroup -win $_nWave1 "G2"
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/u_SNN/sum_z\[0:3\]} \
{/TESTBED/u_SNN/sum_z\[0\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[1\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[2\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[3\]\[31:0\]} \
{/TESTBED/u_SNN/c0_max\[31:0\]} \
{/TESTBED/u_SNN/mult_a\[0:10\]} \
{/TESTBED/u_SNN/mult_b\[0:10\]} \
{/TESTBED/u_SNN/mult_z\[0:10\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 9 )} 
wvSetPosition -win $_nWave1 {("G3" 9)}
wvSetPosition -win $_nWave1 {("G3" 9)}
wvSetPosition -win $_nWave1 {("G3" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cg_en} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/image_reg\[0:3\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/G_clk_img0} \
{/TESTBED/u_SNN/G_clk_img\[0:14\]} \
{/TESTBED/u_SNN/G_clk_first_input} \
{/TESTBED/u_SNN/G_clk_input\[0:25\]} \
{/TESTBED/u_SNN/kern2_reg\[0:2\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/G_clk_out} \
}
wvCollapseGroup -win $_nWave1 "G2"
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/u_SNN/sum_z\[0:3\]} \
{/TESTBED/u_SNN/sum_z\[0\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[1\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[2\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[3\]\[31:0\]} \
{/TESTBED/u_SNN/c0_max\[31:0\]} \
{/TESTBED/u_SNN/mult_a\[0:10\]} \
{/TESTBED/u_SNN/mult_b\[0:10\]} \
{/TESTBED/u_SNN/mult_z\[0:10\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 9 )} 
wvSetPosition -win $_nWave1 {("G3" 9)}
wvGetSignalClose -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 10)}
wvSetPosition -win $_nWave1 {("G3" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cg_en} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/image_reg\[0:3\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/G_clk_img0} \
{/TESTBED/u_SNN/G_clk_img\[0:14\]} \
{/TESTBED/u_SNN/G_clk_first_input} \
{/TESTBED/u_SNN/G_clk_input\[0:25\]} \
{/TESTBED/u_SNN/kern2_reg\[0:2\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/G_clk_out} \
}
wvCollapseGroup -win $_nWave1 "G2"
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/u_SNN/sum_z\[0:3\]} \
{/TESTBED/u_SNN/sum_z\[0\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[1\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[2\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[3\]\[31:0\]} \
{/TESTBED/u_SNN/c0_max\[31:0\]} \
{/TESTBED/u_SNN/mult_a\[0:10\]} \
{/TESTBED/u_SNN/mult_b\[0:10\]} \
{/TESTBED/u_SNN/mult_z\[0:10\]} \
{/TESTBED/u_SNN/d0_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 10 )} 
wvSetPosition -win $_nWave1 {("G3" 10)}
wvSetPosition -win $_nWave1 {("G3" 10)}
wvSetPosition -win $_nWave1 {("G3" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cg_en} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/image_reg\[0:3\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/G_clk_img0} \
{/TESTBED/u_SNN/G_clk_img\[0:14\]} \
{/TESTBED/u_SNN/G_clk_first_input} \
{/TESTBED/u_SNN/G_clk_input\[0:25\]} \
{/TESTBED/u_SNN/kern2_reg\[0:2\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/G_clk_out} \
}
wvCollapseGroup -win $_nWave1 "G2"
wvAddSignal -win $_nWave1 -group {"G3" \
{/TESTBED/u_SNN/sum_z\[0:3\]} \
{/TESTBED/u_SNN/sum_z\[0\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[1\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[2\]\[31:0\]} \
{/TESTBED/u_SNN/sum_z\[3\]\[31:0\]} \
{/TESTBED/u_SNN/c0_max\[31:0\]} \
{/TESTBED/u_SNN/mult_a\[0:10\]} \
{/TESTBED/u_SNN/mult_b\[0:10\]} \
{/TESTBED/u_SNN/mult_z\[0:10\]} \
{/TESTBED/u_SNN/d0_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 10 )} 
wvSetPosition -win $_nWave1 {("G3" 10)}
wvGetSignalClose -win $_nWave1
