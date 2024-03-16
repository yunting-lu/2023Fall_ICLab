# set init_design_uniquify 1
# setDesignMode -process 180
# suppressMessage TECHLIB 1318
# restoreDesign CHIP_preCTS.inn.dat CHIP

source ./cmd/ccopt.cmd

redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

# ECO
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports


#setOptMode -fixCap true -fixTran true -fixFanoutLoad true
#optDesign -postCTS
# timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

# ECO
# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# optDesign -postCTS -hold
# timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

saveDesign ./CHIP_postCTS.inn


# timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# optDesign -postCTS
# timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports


# timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# optDesign -postCTS -hold
# timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_postCTS -outDir timingReports

# saveDesign CHIP_postCTS.inn