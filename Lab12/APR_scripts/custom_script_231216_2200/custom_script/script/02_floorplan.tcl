# set init_design_uniquify 1
# setDesignMode -process 180
# suppressMessage TECHLIB 1318
# restoreDesign CHIP_initail.inn.dat CHIP

# placeInstance CORE/SRAM0 461.634 1176.338  R0
# placeInstance CORE/SRAM1 656.843 1448.998 R0
# placeInstance CORE/SRAMK 1225.986 1441.208 R0

# V 1.0

# floorPlan -site core_5040 -r 1 0.5 250 250 250 250
# 
# setObjFPlanBox Instance CORE/SI_0/U 1190.28  405.88 1743.32  797.88
# setObjFPlanBox Instance CORE/SI_1/U  683.52  405.88 1075.52  958.92
# setObjFPlanBox Instance CORE/SI_2/U 1190.28 1349.72 1743.32 1741.72
# setObjFPlanBox Instance CORE/SI_3/U  683.52 1188.68 1075.52 1741.72
# setObjFPlanBox Instance CORE/SI_4/U 1190.28  877.80 1743.32 1269.80
# 
# # Rotate
# selectInst CORE/SI_0/U
# flipOrRotateObject -rotate R90 -group
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SI_1/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SI_3/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# 
# setObjFPlanBox Instance CORE/SK_0/U  405.60 1538.36  567.44 1741.72
# setObjFPlanBox Instance CORE/SK_1/U  405.60 1255.24  567.44 1458.60
# setObjFPlanBox Instance CORE/SK_2/U  405.60  972.12  567.44 1175.48
# setObjFPlanBox Instance CORE/SK_3/U  405.60  689.00  567.44  892.36
# setObjFPlanBox Instance CORE/SK_4/U  405.60  405.88  567.44  609.24
# 
# # Rotate
# selectInst CORE/SK_0/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_1/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_2/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_3/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_4/U
# flipOrRotateObject -rotate R90 -group
# deselectAll



# V 2.0

floorPlan -site core_5040 -r 1 0.73 250 250 250 250

setObjFPlanBox Instance CORE/SI_0/U 1212.6 405.88 1765.64 797.88
setObjFPlanBox Instance CORE/SI_1/U 629.56 405.88 1182.6 797.88
setObjFPlanBox Instance CORE/SI_2/U 1212.6 1364.84 1765.64 1756.84
setObjFPlanBox Instance CORE/SI_3/U 629.56 1364.84 1182.6 1756.84
setObjFPlanBox Instance CORE/SI_4/U 1212.6 900.36 1765.64 1292.36

selectInst CORE/SI_0/U
flipOrRotateObject -rotate R90 -group
flipOrRotateObject -rotate R90 -group
deselectAll
selectInst CORE/SI_1/U
flipOrRotateObject -rotate R90 -group
flipOrRotateObject -rotate R90 -group
deselectAll

#setObjFPlanBox Instance CORE/SK_0/U 405.6 1446.4 567.44 1649.76
#setObjFPlanBox Instance CORE/SK_1/U 405.6 1213.04 567.44 1416.4
#setObjFPlanBox Instance CORE/SK_2/U 405.6 979.68 567.44 1183.04
#setObjFPlanBox Instance CORE/SK_3/U 405.6 746.32 567.44 949.68
#setObjFPlanBox Instance CORE/SK_4/U 405.6 512.96 567.44 716.32

setObjFPlanBox Instance CORE/SK_0/U 405.6 1553.48 567.44 1756.84
setObjFPlanBox Instance CORE/SK_1/U 405.6 1320.12 567.44 1523.48
setObjFPlanBox Instance CORE/SK_2/U 405.6 979.68 567.44 1183.04
setObjFPlanBox Instance CORE/SK_3/U 405.6 639.24 567.44 842.6
setObjFPlanBox Instance CORE/SK_4/U 405.6 405.88 567.44 609.24

selectInst CORE/SK_0/U
flipOrRotateObject -rotate R90 -group
deselectAll
selectInst CORE/SK_1/U
flipOrRotateObject -rotate R90 -group
deselectAll
selectInst CORE/SK_2/U
flipOrRotateObject -rotate R90 -group
deselectAll
selectInst CORE/SK_3/U
flipOrRotateObject -rotate R90 -group
deselectAll
selectInst CORE/SK_4/U
flipOrRotateObject -rotate R90 -group
deselectAll


# V 3.0

# floorPlan -site core_5040 -r 1 0.66 250 250 250 250
# 
# setObjFPlanBox Instance CORE/SI_0/U 1212.6 405.88 1765.64 797.88
# setObjFPlanBox Instance CORE/SI_1/U 629.56 405.88 1182.6 797.88
# setObjFPlanBox Instance CORE/SI_2/U 1212.6 1364.84 1765.64 1756.84
# setObjFPlanBox Instance CORE/SI_3/U 629.56 1364.84 1182.6 1756.84
# setObjFPlanBox Instance CORE/SI_4/U 1212.6 900.36 1765.64 1292.36
# 
# selectInst CORE/SI_0/U
# flipOrRotateObject -rotate R90 -group
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SI_1/U
# flipOrRotateObject -rotate R90 -group
# flipOrRotateObject -rotate R90 -group
# deselectAll
# 
# setObjFPlanBox Instance CORE/SK_0/U 405.6 1553.48 567.44 1756.84
# setObjFPlanBox Instance CORE/SK_1/U 405.6 1320.12 567.44 1523.48
# setObjFPlanBox Instance CORE/SK_2/U 405.6 979.68 567.44 1183.04
# setObjFPlanBox Instance CORE/SK_3/U 405.6 639.24 567.44 842.6
# setObjFPlanBox Instance CORE/SK_4/U 405.6 405.88 567.44 609.24
# 
# selectInst CORE/SK_0/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_1/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_2/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_3/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# selectInst CORE/SK_4/U
# flipOrRotateObject -rotate R90 -group
# deselectAll
# 
addHaloToBlock 15 15 15 15 -allMacro

#left-bottom X Y right-top X Y
# createPlaceBlockage -box 600.05300 779.80900 1969.50700 1035.64100 -type hard
# createPlaceBlockage -box 600.05300 508.92800 1969.50700 749.71100 -type hard
# createPlaceBlockage -box 2989.04600 1479.16800 3221.11800 2845.81700 -type hard
# createPlaceBlockage -box 590.96500 499.30700 1957.61300 757.16500 -type hard
# createPlaceBlockage -box 2292.22100 810.24500 2546.28600 2171.30800 -type hard
# createPlaceBlockage -box 590.89200 574.32800 1965.56600 823.85600 -type hard

# createPlaceBlockage -box 2296.99900 800.16500 2538.49400 2177.87200 -type hard
# createPlaceBlockage -box 634.24800 576.88100 2000.07900 814.41700 -type hard

# createPlaceBlockage -box 2034.97100 976.34500 2292.82900 2342.99400 -type hard
# createPlaceBlockage -box 616.75000 563.77200 2009.18500 834.52300 -type hard

# createPlaceBlockage -box 1809.34500 1234.20300 3175.99300 1492.06100 -type hard
# createPlaceBlockage -box 1802.89800 602.45100 3169.54700 860.30900 -type hard

# createPlaceBlockage -box 1802.89800 1002.13100 3175.99300 1253.54300 -type hard
# createPlaceBlockage -box 1802.89800 602.45100 3169.54700 860.30900 -type hard

#
# createPlaceBlockage -box 465.44400 853.92100 2432.55700 1207.86500 -type hard
# createPlaceBlockage -box 461.26800 451.08800 2430.10200 814.75800 -type hard
# createPlaceBlockage -box 2647.46800 505.43000 3366.44800 747.87700 -type hard

saveDesign ./CHIP_floorplan.inn


# setObjFPlanBox Instance U_MMSA/W0 618.693 604.32 1931.433 802.17
# setObjFPlanBox Instance U_MMSA/X0 2319.942 831.031 2517.792 2143.771