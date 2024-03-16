setPlaceMode -prerouteAsObs {2 3}
setPlaceMode -fp false
place_design -noPrePlaceOpt
setDrawView place
saveDesign CHIP_placement.inn