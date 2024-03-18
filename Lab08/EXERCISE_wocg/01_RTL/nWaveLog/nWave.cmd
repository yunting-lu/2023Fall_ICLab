wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/RAID2/COURSE/iclab/iclab122/Lab08/EXERCISE_wocg/01_RTL/SNN.fsdb}
wvResizeWindow -win $_nWave1 0 23 1536 793
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/rst_n} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/rst_n} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvGetSignalClose -win $_nWave1
wvZoom -win $_nWave1 0.000000 756112.248760
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/in_valid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/in_valid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 0)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSelectSignal -win $_nWave1 {( "G1" 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvResizeWindow -win $_nWave1 0 23 1536 793
wvSelectSignal -win $_nWave1 {( "G1" 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 10)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSetPosition -win $_nWave1 {("G1" 11)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 344277.247560 -snap {("G1" 9)}
wvSaveSignal -win $_nWave1 \
           "/RAID2/COURSE/iclab/iclab122/Lab08/EXERCISE_wocg/signal.rc"
wvSelectGroup -win $_nWave1 {G2}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvMoveSelected -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 565357.244768 -snap {("G2" 1)}
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 928198.461560 -snap {("G1" 10)}
wvZoomIn -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 23 1536 793
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSetPosition -win $_nWave1 {("G2" 3)}
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 4 )} 
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 4 )} 
wvSetPosition -win $_nWave1 {("G2" 4)}
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetPosition -win $_nWave1 {("G2" 5)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetRadix -win $_nWave1 -format 754
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 6)}
wvSetPosition -win $_nWave1 {("G2" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 6 )} 
wvSetPosition -win $_nWave1 {("G2" 6)}
wvSetPosition -win $_nWave1 {("G2" 6)}
wvSetPosition -win $_nWave1 {("G2" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 6 )} 
wvSetPosition -win $_nWave1 {("G2" 6)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSelectSignal -win $_nWave1 {( "G2" 6 )} 
wvSetCursor -win $_nWave1 892322.008533 -snap {("G2" 6)}
wvSetCursor -win $_nWave1 899919.739835 -snap {("G2" 6)}
wvSetCursor -win $_nWave1 906673.278769 -snap {("G2" 6)}
wvSetCursor -win $_nWave1 913989.612615 -snap {("G2" 6)}
wvSelectSignal -win $_nWave1 {( "G2" 6 )} 
wvSetRadix -win $_nWave1 -format 754
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 7)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 7 )} 
wvSetPosition -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 7)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 7 )} 
wvSetPosition -win $_nWave1 {("G2" 7)}
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 9)}
wvSetPosition -win $_nWave1 {("G2" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 8 9 )} 
wvSetPosition -win $_nWave1 {("G2" 9)}
wvSetPosition -win $_nWave1 {("G2" 9)}
wvSetPosition -win $_nWave1 {("G2" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 8 9 )} 
wvSetPosition -win $_nWave1 {("G2" 9)}
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 23 1536 793
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/max_reg\[31:0\]} \
{/TESTBED/u_SNN/min_reg\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 10 11 )} 
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/max_reg\[31:0\]} \
{/TESTBED/u_SNN/min_reg\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 10 11 )} 
wvSetPosition -win $_nWave1 {("G2" 11)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetCursor -win $_nWave1 892383.063112 -snap {("G2" 9)}
wvSetCursor -win $_nWave1 898774.272502 -snap {("G2" 6)}
wvSetCursor -win $_nWave1 906376.151512 -snap {("G2" 6)}
wvSetCursor -win $_nWave1 893143.251013 -snap {("G2" 9)}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvExpandBus -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 15)}
wvSelectSignal -win $_nWave1 {( "G2" 7 )} 
wvSetPosition -win $_nWave1 {("G2" 7)}
wvExpandBus -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 17)}
wvSelectSignal -win $_nWave1 {( "G2" 7 )} 
wvSetPosition -win $_nWave1 {("G2" 7)}
wvCollapseBus -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 15)}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvCollapseBus -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSelectSignal -win $_nWave1 {( "G2" 4 )} 
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 12)}
wvSetPosition -win $_nWave1 {("G2" 12)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/max_reg\[31:0\]} \
{/TESTBED/u_SNN/min_reg\[31:0\]} \
{/TESTBED/u_SNN/d0_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 12 )} 
wvSetPosition -win $_nWave1 {("G2" 12)}
wvSetPosition -win $_nWave1 {("G2" 12)}
wvSetPosition -win $_nWave1 {("G2" 12)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/max_reg\[31:0\]} \
{/TESTBED/u_SNN/min_reg\[31:0\]} \
{/TESTBED/u_SNN/d0_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 12 )} 
wvSetPosition -win $_nWave1 {("G2" 12)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 529710.191457 -snap {("G2" 12)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/u_SNN"
wvSetPosition -win $_nWave1 {("G2" 13)}
wvSetPosition -win $_nWave1 {("G2" 13)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/max_reg\[31:0\]} \
{/TESTBED/u_SNN/min_reg\[31:0\]} \
{/TESTBED/u_SNN/d0_z\[31:0\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 13 )} 
wvSetPosition -win $_nWave1 {("G2" 13)}
wvSetPosition -win $_nWave1 {("G2" 13)}
wvSetPosition -win $_nWave1 {("G2" 13)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/u_SNN/rst_n} \
{/TESTBED/u_SNN/clk} \
{/TESTBED/u_SNN/in_valid} \
{/TESTBED/u_SNN/Img\[31:0\]} \
{/TESTBED/u_SNN/Kernel\[31:0\]} \
{/TESTBED/u_SNN/Opt\[1:0\]} \
{/TESTBED/u_SNN/Weight\[31:0\]} \
{/TESTBED/u_SNN/cnt\[5:0\]} \
{/TESTBED/u_SNN/curr_state\[1:0\]} \
{/TESTBED/u_SNN/out_valid} \
{/TESTBED/u_SNN/out\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/TESTBED/u_SNN/a7_z\[31:0\]} \
{/TESTBED/u_SNN/eqdata_reg\[0:3\]} \
{/TESTBED/u_SNN/pooling_reg\[0:1\]} \
{/TESTBED/u_SNN/feature_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding1_reg\[0:3\]} \
{/TESTBED/u_SNN/encoding2_reg\[31:0\]} \
{/TESTBED/u_SNN/s3_z\[31:0\]} \
{/TESTBED/u_SNN/s3_a\[31:0\]} \
{/TESTBED/u_SNN/s3_b\[31:0\]} \
{/TESTBED/u_SNN/max_reg\[31:0\]} \
{/TESTBED/u_SNN/min_reg\[31:0\]} \
{/TESTBED/u_SNN/d0_z\[31:0\]} \
{/TESTBED/u_SNN/d1_z\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 13 )} 
wvSetPosition -win $_nWave1 {("G2" 13)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 549981.868817 -snap {("G1" 8)}
wvResizeWindow -win $_nWave1 0 23 1536 793
wvSetCursor -win $_nWave1 557095.400855 -snap {("G2" 13)}
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetCursor -win $_nWave1 870929.600396 -snap {("G2" 12)}
wvSetCursor -win $_nWave1 865576.952468 -snap {("G2" 12)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSaveSignal -win $_nWave1 \
           "/RAID2/COURSE/iclab/iclab122/Lab08/EXERCISE_wocg/signal.rc"
wvExit
