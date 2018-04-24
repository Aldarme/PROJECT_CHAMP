EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:switches
LIBS:relays
LIBS:motors
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:OPB821S-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "OPB821 and AOP"
Date "2018-03-27"
Rev ""
Comp "LPNHE"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 1200 2550 0    60   Input ~ 0
Blue
Text GLabel 1700 2650 2    60   Input ~ 0
White
Text GLabel 1200 2400 0    60   Input ~ 0
Green
Text GLabel 1700 2300 2    60   Input ~ 0
Orange
$Comp
L R R2
U 1 1 5AB1164E
P 2300 2450
F 0 "R2" V 2380 2450 50  0000 C CNN
F 1 "10K" V 2300 2450 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 2230 2450 50  0001 C CNN
F 3 "" H 2300 2450 50  0001 C CNN
	1    2300 2450
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 5AB11709
P 2300 3200
F 0 "R4" V 2380 3200 50  0000 C CNN
F 1 "10K" V 2300 3200 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 2230 3200 50  0001 C CNN
F 3 "" H 2300 3200 50  0001 C CNN
	1    2300 3200
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 5AB11744
P 2300 2650
F 0 "R3" V 2380 2650 50  0000 C CNN
F 1 "10K" V 2300 2650 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 2230 2650 50  0001 C CNN
F 3 "" H 2300 2650 50  0001 C CNN
	1    2300 2650
	0    1    1    0   
$EndComp
$Comp
L R R5
U 1 1 5AB11787
P 2300 3400
F 0 "R5" V 2380 3400 50  0000 C CNN
F 1 "10K" V 2300 3400 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 2230 3400 50  0001 C CNN
F 3 "" H 2300 3400 50  0001 C CNN
	1    2300 3400
	0    1    1    0   
$EndComp
$Comp
L GND #PWR01
U 1 1 5AB11A06
P 1300 3550
F 0 "#PWR01" H 1300 3300 50  0001 C CNN
F 1 "GND" H 1300 3400 50  0000 C CNN
F 2 "" H 1300 3550 50  0001 C CNN
F 3 "" H 1300 3550 50  0001 C CNN
	1    1300 3550
	1    0    0    -1  
$EndComp
$Comp
L 74HC14 U1
U 1 1 5AB11A9E
P 3400 2900
F 0 "U1" H 3550 3000 50  0000 C CNN
F 1 "74HC14" H 3600 2800 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm_LongPads" H 3400 2900 50  0001 C CNN
F 3 "" H 3400 2900 50  0001 C CNN
	1    3400 2900
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x02 J3
U 1 1 5AB91AF8
P 1600 4500
F 0 "J3" H 1600 4600 50  0000 C CNN
F 1 "Conn_01x02" H 1600 4300 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 1600 4500 50  0001 C CNN
F 3 "" H 1600 4500 50  0001 C CNN
	1    1600 4500
	-1   0    0    1   
$EndComp
$Comp
L C C1
U 1 1 5AB91CFF
P 2150 4550
F 0 "C1" H 2175 4650 50  0000 L CNN
F 1 "100nF" H 2175 4450 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 2188 4400 50  0001 C CNN
F 3 "" H 2150 4550 50  0001 C CNN
	1    2150 4550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5AB924F4
P 1800 4900
F 0 "#PWR02" H 1800 4650 50  0001 C CNN
F 1 "GND" H 1800 4750 50  0000 C CNN
F 2 "" H 1800 4900 50  0001 C CNN
F 3 "" H 1800 4900 50  0001 C CNN
	1    1800 4900
	1    0    0    -1  
$EndComp
$Comp
L OP249 U2
U 1 1 5AB9283B
P 8150 3800
F 0 "U2" H 8150 4000 50  0000 L CNN
F 1 "OP249" H 8150 3600 50  0000 L CNN
F 2 "Housings_DIP:DIP-8_W7.62mm_LongPads" H 8150 3800 50  0001 C CNN
F 3 "" H 8150 3800 50  0001 C CNN
	1    8150 3800
	1    0    0    -1  
$EndComp
$Comp
L R R6
U 1 1 5AB92C06
P 7500 4600
F 0 "R6" V 7580 4600 50  0000 C CNN
F 1 "10K" V 7500 4600 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 7430 4600 50  0001 C CNN
F 3 "" H 7500 4600 50  0001 C CNN
	1    7500 4600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 5AB92E8D
P 7500 5100
F 0 "#PWR03" H 7500 4850 50  0001 C CNN
F 1 "GND" H 7500 4950 50  0000 C CNN
F 2 "" H 7500 5100 50  0001 C CNN
F 3 "" H 7500 5100 50  0001 C CNN
	1    7500 5100
	1    0    0    -1  
$EndComp
$Comp
L POT RV1
U 1 1 5AB93280
P 8150 4350
F 0 "RV1" V 7975 4350 50  0000 C CNN
F 1 "10k - 50k" V 8050 4350 50  0000 C CNN
F 2 "Potentiometers:Potentiometer_Trimmer_Bourns_3296W" H 8150 4350 50  0001 C CNN
F 3 "" H 8150 4350 50  0001 C CNN
	1    8150 4350
	0    1    1    0   
$EndComp
$Comp
L GND #PWR04
U 1 1 5AB935EB
P 8450 3150
F 0 "#PWR04" H 8450 2900 50  0001 C CNN
F 1 "GND" H 8450 3000 50  0000 C CNN
F 2 "" H 8450 3150 50  0001 C CNN
F 3 "" H 8450 3150 50  0001 C CNN
	1    8450 3150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 5AB938BE
P 6700 4300
F 0 "#PWR05" H 6700 4050 50  0001 C CNN
F 1 "GND" H 6700 4150 50  0000 C CNN
F 2 "" H 6700 4300 50  0001 C CNN
F 3 "" H 6700 4300 50  0001 C CNN
	1    6700 4300
	1    0    0    -1  
$EndComp
Text GLabel 8000 2600 1    60   Input ~ 0
15v
Text GLabel 8150 2600 1    60   Input ~ 0
-15v
Text GLabel 8300 2600 1    60   Input ~ 0
GND
Text Label 8050 3050 1    60   ~ 0
Vp
Text Label 8150 3050 1    60   ~ 0
Vm
$Comp
L C C2
U 1 1 5AB94F19
P 6600 2600
F 0 "C2" H 6625 2700 50  0000 L CNN
F 1 "100nF" H 6625 2500 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 6638 2450 50  0001 C CNN
F 3 "" H 6600 2600 50  0001 C CNN
	1    6600 2600
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 5AB94F99
P 7050 2600
F 0 "C3" H 7075 2700 50  0000 L CNN
F 1 "100nF" H 7075 2500 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 7088 2450 50  0001 C CNN
F 3 "" H 7050 2600 50  0001 C CNN
	1    7050 2600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 5AB95061
P 6600 3000
F 0 "#PWR06" H 6600 2750 50  0001 C CNN
F 1 "GND" H 6600 2850 50  0000 C CNN
F 2 "" H 6600 3000 50  0001 C CNN
F 3 "" H 6600 3000 50  0001 C CNN
	1    6600 3000
	1    0    0    -1  
$EndComp
Text GLabel 8050 4600 2    60   Input ~ 0
GAIN_x2/x5
$Comp
L GND #PWR07
U 1 1 5AB95A16
P 9500 4400
F 0 "#PWR07" H 9500 4150 50  0001 C CNN
F 1 "GND" H 9500 4250 50  0000 C CNN
F 2 "" H 9500 4400 50  0001 C CNN
F 3 "" H 9500 4400 50  0001 C CNN
	1    9500 4400
	1    0    0    -1  
$EndComp
Text Label 6750 2250 0    60   ~ 0
Vp
Text Label 7200 2250 0    60   ~ 0
Vm
Text Label 2750 2250 0    60   ~ 0
Vopb
$Comp
L C C4
U 1 1 5AB979FE
P 3700 2000
F 0 "C4" H 3725 2100 50  0000 L CNN
F 1 "100nF" H 3725 1900 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206" H 3738 1850 50  0001 C CNN
F 3 "" H 3700 2000 50  0001 C CNN
	1    3700 2000
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR08
U 1 1 5AB97B67
P 3700 2350
F 0 "#PWR08" H 3700 2100 50  0001 C CNN
F 1 "GND" H 3700 2200 50  0000 C CNN
F 2 "" H 3700 2350 50  0001 C CNN
F 3 "" H 3700 2350 50  0001 C CNN
	1    3700 2350
	1    0    0    -1  
$EndComp
Text Label 4050 1700 0    60   ~ 0
Vopb
$Comp
L R R1
U 1 1 5AB98241
P 2750 4100
F 0 "R1" V 2830 4100 50  0000 C CNN
F 1 "10K" V 2650 4100 50  0000 C CNN
F 2 "Resistors_SMD:R_1206" V 2680 4100 50  0001 C CNN
F 3 "" H 2750 4100 50  0001 C CNN
	1    2750 4100
	-1   0    0    1   
$EndComp
$Comp
L 74HC14 U1
U 3 1 5AB99268
P 4300 3100
F 0 "U1" H 4450 3200 50  0000 C CNN
F 1 "74HC14" H 4500 3000 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm_LongPads" H 4300 3100 50  0001 C CNN
F 3 "" H 4300 3100 50  0001 C CNN
	3    4300 3100
	1    0    0    -1  
$EndComp
$Comp
L 74HC14 U1
U 4 1 5AB99316
P 4300 3450
F 0 "U1" H 4450 3550 50  0000 C CNN
F 1 "74HC14" H 4500 3350 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm_LongPads" H 4300 3450 50  0001 C CNN
F 3 "" H 4300 3450 50  0001 C CNN
	4    4300 3450
	1    0    0    -1  
$EndComp
$Comp
L Screw_Terminal_01x03 J8
U 1 1 5AB9B63B
P 8150 2700
F 0 "J8" H 8150 2900 50  0000 C CNN
F 1 "Screw_Terminal_01x03" V 8650 2700 50  0000 C CNN
F 2 "Connectors_Terminal_Blocks:TerminalBlock_bornier-3_P5.08mm" H 8150 2700 50  0001 C CNN
F 3 "" H 8150 2700 50  0001 C CNN
	1    8150 2700
	0    -1   -1   0   
$EndComp
$Comp
L Screw_Terminal_01x02 J10
U 1 1 5ABA8CEF
P 2750 1850
F 0 "J10" H 2750 1950 50  0000 C CNN
F 1 "Screw_Terminal_01x02" V 3100 1850 50  0000 C CNN
F 2 "Connectors_Terminal_Blocks:TerminalBlock_bornier-2_P5.08mm" H 2750 1850 50  0001 C CNN
F 3 "" H 2750 1850 50  0001 C CNN
	1    2750 1850
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR09
U 1 1 5ABA8EBB
P 3150 2150
F 0 "#PWR09" H 3150 1900 50  0001 C CNN
F 1 "GND" H 3150 2000 50  0000 C CNN
F 2 "" H 3150 2150 50  0001 C CNN
F 3 "" H 3150 2150 50  0001 C CNN
	1    3150 2150
	1    0    0    -1  
$EndComp
Text GLabel 2750 1750 1    60   Input ~ 0
5V
$Comp
L LEMO5 J7
U 1 1 5ABA9D1D
P 6250 3700
F 0 "J7" H 6450 4000 50  0000 C CNN
F 1 "LEMO5" H 6550 3400 50  0000 C CNN
F 2 "LEMO-footprint:LEMO_footprint" H 6250 3700 50  0001 C CNN
F 3 "" H 6250 3700 50  0001 C CNN
	1    6250 3700
	0    -1   -1   0   
$EndComp
$Comp
L LEMO5 J9
U 1 1 5ABA9E33
P 10100 3800
F 0 "J9" H 10300 4100 50  0000 C CNN
F 1 "LEMO5" H 10400 3500 50  0000 C CNN
F 2 "LEMO-footprint:LEMO_footprint" H 10100 3800 50  0001 C CNN
F 3 "" H 10100 3800 50  0001 C CNN
	1    10100 3800
	0    1    1    0   
$EndComp
Wire Wire Line
	2450 3400 2750 3400
Connection ~ 2750 3400
Wire Wire Line
	2450 3200 2750 3200
Connection ~ 2750 3200
Wire Wire Line
	2450 2650 2750 2650
Connection ~ 2750 2650
Wire Wire Line
	2450 2450 2750 2450
Connection ~ 2750 2450
Wire Wire Line
	2100 2550 2100 2900
Connection ~ 2100 2650
Wire Wire Line
	2050 3300 2050 3700
Connection ~ 2050 3400
Wire Wire Line
	9700 3800 8450 3800
Wire Wire Line
	7850 3900 7500 3900
Wire Wire Line
	7500 3900 7500 4450
Wire Wire Line
	8000 4350 7500 4350
Connection ~ 7500 4350
Wire Wire Line
	7500 4750 7500 5100
Wire Wire Line
	8300 4350 8800 4350
Wire Wire Line
	8800 4350 8800 3800
Connection ~ 8800 3800
Wire Wire Line
	8150 4500 8650 4500
Wire Wire Line
	8650 4500 8650 4350
Connection ~ 8650 4350
Wire Wire Line
	8050 2900 8050 3500
Wire Wire Line
	8150 2900 8150 3450
Wire Wire Line
	8150 3450 8450 3450
Wire Wire Line
	8450 3450 8450 4100
Wire Wire Line
	8450 4100 8050 4100
Wire Wire Line
	8250 2900 8250 3150
Wire Wire Line
	8250 3150 8450 3150
Wire Wire Line
	6650 3700 7850 3700
Wire Wire Line
	6100 4000 6700 4000
Wire Wire Line
	6700 4000 6700 4300
Wire Wire Line
	9500 4200 10550 4200
Wire Wire Line
	9500 4200 9500 4400
Wire Wire Line
	6750 2250 6600 2250
Wire Wire Line
	6600 2250 6600 2450
Wire Wire Line
	7200 2250 7050 2250
Wire Wire Line
	7050 2250 7050 2450
Wire Wire Line
	7050 2900 7050 2750
Wire Wire Line
	6100 2900 7050 2900
Wire Wire Line
	6600 2750 6600 3000
Connection ~ 6600 2900
Wire Wire Line
	3700 2350 3700 2150
Wire Wire Line
	4050 1700 3700 1700
Wire Wire Line
	3700 1700 3700 1850
Wire Wire Line
	1800 4500 1800 4900
Wire Wire Line
	2750 2050 2750 3950
Wire Wire Line
	2750 4400 2750 4250
Connection ~ 1800 4700
Wire Wire Line
	2850 2050 3150 2050
Wire Wire Line
	3150 2050 3150 2150
Connection ~ 6400 4000
Wire Wire Line
	6100 3400 6100 2900
Wire Wire Line
	6400 3400 6400 2900
Connection ~ 6400 2900
Wire Wire Line
	9950 4200 9950 4100
Wire Wire Line
	10250 4200 10250 4100
Connection ~ 9950 4200
Wire Wire Line
	9950 3500 10550 3500
Wire Wire Line
	10550 3500 10550 4200
Connection ~ 10250 4200
Connection ~ 10250 3500
Wire Wire Line
	1800 4400 2750 4400
Connection ~ 2150 4400
Connection ~ 2150 4700
Wire Wire Line
	2050 3700 2950 3700
Wire Wire Line
	2100 2900 2950 2900
Wire Wire Line
	3850 2900 5100 2900
Wire Wire Line
	5100 2900 5100 3250
Wire Wire Line
	4750 3100 4750 3350
Wire Wire Line
	3850 2900 3850 3100
$Comp
L GND #PWR010
U 1 1 5ABB00D4
P 5600 3900
F 0 "#PWR010" H 5600 3650 50  0001 C CNN
F 1 "GND" H 5600 3750 50  0000 C CNN
F 2 "" H 5600 3900 50  0001 C CNN
F 3 "" H 5600 3900 50  0001 C CNN
	1    5600 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 2650 2150 2650
Wire Wire Line
	2050 3400 2150 3400
$Comp
L 74HC14 U1
U 2 1 5AB11AFD
P 3400 3700
F 0 "U1" H 3550 3800 50  0000 C CNN
F 1 "74HC14" H 3600 3600 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm_LongPads" H 3400 3700 50  0001 C CNN
F 3 "" H 3400 3700 50  0001 C CNN
	2    3400 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	4750 3350 5100 3350
Wire Wire Line
	4750 3450 5100 3450
Wire Wire Line
	3850 3450 3850 3700
Wire Wire Line
	3850 3700 4700 3700
Wire Wire Line
	4700 3700 4700 3550
Wire Wire Line
	4700 3550 5100 3550
Wire Wire Line
	1800 4700 3250 4700
Wire Wire Line
	3250 4700 3250 3950
Wire Wire Line
	3250 3950 4950 3950
Wire Wire Line
	4950 3950 4950 3650
Wire Wire Line
	4950 3650 5100 3650
Wire Wire Line
	5600 3250 5600 3900
Connection ~ 5600 3350
Connection ~ 5600 3450
Connection ~ 5600 3550
Connection ~ 5600 3650
Text GLabel 1200 3150 0    60   Input ~ 0
Green
Text GLabel 1200 3300 0    60   Input ~ 0
Orange
Text GLabel 1750 3100 2    60   Input ~ 0
White
Text GLabel 1700 3400 2    60   Input ~ 0
Blue
$Comp
L Conn_02x05_Odd_Even J4
U 1 1 5ADF7432
P 5300 3450
F 0 "J4" H 5350 3750 50  0000 C CNN
F 1 "Conn_02x05_Odd_Even" H 5350 3150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x05_Pitch2.54mm" H 5300 3450 50  0001 C CNN
F 3 "" H 5300 3450 50  0001 C CNN
	1    5300 3450
	1    0    0    -1  
$EndComp
$Comp
L Conn_02x02_Odd_Even J1
U 1 1 5ADF8A8E
P 1500 2550
F 0 "J1" H 1550 2650 50  0000 C CNN
F 1 "Conn_02x02" H 1500 2200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x02_Pitch2.54mm" H 1500 2550 50  0001 C CNN
F 3 "" H 1500 2550 50  0001 C CNN
	1    1500 2550
	1    0    0    1   
$EndComp
$Comp
L Conn_02x02_Odd_Even J2
U 1 1 5ADF9006
P 1500 3300
F 0 "J2" H 1550 3400 50  0000 C CNN
F 1 "Conn_02x02" H 1550 3000 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x02_Pitch2.54mm" H 1500 3300 50  0001 C CNN
F 3 "" H 1500 3300 50  0001 C CNN
	1    1500 3300
	1    0    0    1   
$EndComp
Wire Wire Line
	1300 2450 1300 3550
Connection ~ 1300 2550
Connection ~ 1300 3200
Connection ~ 1300 3300
Wire Wire Line
	2150 2450 1800 2450
Wire Wire Line
	2100 2550 1800 2550
Wire Wire Line
	2150 3200 1800 3200
Wire Wire Line
	1800 3300 2050 3300
$EndSCHEMATC
