getFillerMode -quiet
addFiller -cell FILLER8 FILLER64 FILLER4 FILLER32 FILLER2 FILLER16 FILLER1 -prefix FILLER
saveDesign CHIP.inn
all_hold_analysis_views 
all_setup_analysis_views 
write_sdf CHIP.sdf
saveNetlist CHIP.v