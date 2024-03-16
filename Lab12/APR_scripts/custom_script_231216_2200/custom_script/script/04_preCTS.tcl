# set init_design_uniquify 1
# setDesignMode -process 180
# suppressMessage TECHLIB 1318
# restoreDesign CHIP_powerplan.inn.dat CHIP

createBasicPathGroups -expanded
get_path_groups
setPlaceMode -prerouteAsObs {2 3}
place_opt_design

redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports

# ECO
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports

#setOptMode -fixCap true -fixTran true -fixFanoutLoad true
#optDesign -preCTS
#timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports

saveDesign ./CHIP_preCTS.inn

# setPlaceMode -prerouteAsObs {2 3}
# setPlaceMode -fp false
# placeDesign -noPrePlaceOpt
# setDrawView place

# timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports

# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# optDesign -preCTS

# timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_preCTS -outDir timingReports

# saveDesign CHIP_preCTS.inn