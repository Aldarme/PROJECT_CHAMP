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
LIBS:AOP_evalBoard-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "AOP_evalBoard"
Date "2018-03-08"
Rev ""
Comp "LPNHE"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L OP249 U1
U 1 1 5AA14CAF
P 5950 3100
F 0 "U1" H 5950 3300 50  0000 L CNN
F 1 "OP249" H 5950 2900 50  0000 L CNN
F 2 "" H 5950 3100 50  0001 C CNN
F 3 "" H 5950 3100 50  0001 C CNN
	1    5950 3100
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 5AA14D9F
P 5500 3950
F 0 "R1" V 5580 3950 50  0000 C CNN
F 1 "10K" V 5500 3950 50  0000 C CNN
F 2 "" V 5430 3950 50  0001 C CNN
F 3 "" H 5500 3950 50  0001 C CNN
	1    5500 3950
	1    0    0    -1  
$EndComp
$Comp
L Screw_Terminal_01x03 J3
U 1 1 5AA24B36
P 5950 2250
F 0 "J3" H 5950 2450 50  0000 C CNN
F 1 "Screw_Terminal_01x03" V 6450 2250 50  0000 C CNN
F 2 "" H 5950 2250 50  0001 C CNN
F 3 "" H 5950 2250 50  0001 C CNN
	1    5950 2250
	0    -1   -1   0   
$EndComp
$Comp
L GNDREF #PWR4
U 1 1 5AA252CE
P 6500 2550
F 0 "#PWR4" H 6500 2300 50  0001 C CNN
F 1 "GNDREF" H 6500 2400 50  0000 C CNN
F 2 "" H 6500 2550 50  0001 C CNN
F 3 "" H 6500 2550 50  0001 C CNN
	1    6500 2550
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR3
U 1 1 5AA25518
P 5500 4350
F 0 "#PWR3" H 5500 4100 50  0001 C CNN
F 1 "GNDREF" H 5500 4200 50  0000 C CNN
F 2 "" H 5500 4350 50  0001 C CNN
F 3 "" H 5500 4350 50  0001 C CNN
	1    5500 4350
	1    0    0    -1  
$EndComp
Text GLabel 5800 2150 1    60   Input ~ 0
+15V
Text GLabel 5950 2150 1    60   Input ~ 0
-15V
Text GLabel 6100 2150 1    60   Input ~ 0
GND
$Comp
L POT RV1
U 1 1 5AA2874C
P 5900 3650
F 0 "RV1" V 6000 3550 50  0000 C CNN
F 1 "10k - 50k" V 5800 3650 50  0000 C CNN
F 2 "" H 5900 3650 50  0001 C CNN
F 3 "" H 5900 3650 50  0001 C CNN
	1    5900 3650
	0    1    1    0   
$EndComp
Text GLabel 5950 3900 2    60   Input ~ 0
Gain_x2/x5
$Comp
L Conn_02x01 J1
U 1 1 5AA29636
P 4750 3000
F 0 "J1" H 4800 3100 50  0000 C CNN
F 1 "Conn_02x01" H 4800 2900 50  0000 C CNN
F 2 "" H 4750 3000 50  0001 C CNN
F 3 "" H 4750 3000 50  0001 C CNN
	1    4750 3000
	-1   0    0    1   
$EndComp
$Comp
L Conn_02x01 J2
U 1 1 5AA29710
P 7250 3100
F 0 "J2" H 7300 3200 50  0000 C CNN
F 1 "Conn_02x01" H 7300 3000 50  0000 C CNN
F 2 "" H 7250 3100 50  0001 C CNN
F 3 "" H 7250 3100 50  0001 C CNN
	1    7250 3100
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR5
U 1 1 5AA299CD
P 7850 3300
F 0 "#PWR5" H 7850 3050 50  0001 C CNN
F 1 "GNDREF" H 7850 3150 50  0000 C CNN
F 2 "" H 7850 3300 50  0001 C CNN
F 3 "" H 7850 3300 50  0001 C CNN
	1    7850 3300
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR1
U 1 1 5AA29A19
P 4250 3150
F 0 "#PWR1" H 4250 2900 50  0001 C CNN
F 1 "GNDREF" H 4250 3000 50  0000 C CNN
F 2 "" H 4250 3150 50  0001 C CNN
F 3 "" H 4250 3150 50  0001 C CNN
	1    4250 3150
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5AA2A1CF
P 4450 2200
F 0 "C1" H 4475 2300 50  0000 L CNN
F 1 "100nF" H 4475 2100 50  0000 L CNN
F 2 "" H 4488 2050 50  0001 C CNN
F 3 "" H 4450 2200 50  0001 C CNN
	1    4450 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 3000 5650 3000
Wire Wire Line
	6250 3100 7050 3100
Wire Wire Line
	5650 3200 5500 3200
Wire Wire Line
	5500 3200 5500 3800
Wire Wire Line
	5500 3650 5750 3650
Connection ~ 5500 3650
Wire Wire Line
	5500 4100 5500 4350
Wire Wire Line
	6050 3650 6400 3650
Wire Wire Line
	6400 3650 6400 3100
Connection ~ 6400 3100
Wire Wire Line
	6050 2450 6500 2450
Wire Wire Line
	6500 2450 6500 2550
Wire Wire Line
	6300 2750 6300 3400
Wire Wire Line
	6300 3400 5850 3400
Wire Wire Line
	7550 3100 7850 3100
Wire Wire Line
	7850 3100 7850 3300
Wire Wire Line
	4450 3000 4250 3000
Wire Wire Line
	4250 3000 4250 3150
Wire Wire Line
	5900 3800 6350 3800
Wire Wire Line
	6350 3800 6350 3650
Connection ~ 6350 3650
Wire Wire Line
	5850 2450 5850 2800
Wire Wire Line
	5950 2750 6300 2750
Wire Wire Line
	5950 2450 5950 2750
Text Label 5850 2550 1    60   ~ 0
Vp
Text Label 5950 2600 1    60   ~ 0
Vm
Wire Wire Line
	4450 2350 4450 2450
Wire Wire Line
	4450 2450 4850 2450
Wire Wire Line
	4850 2350 4850 2550
$Comp
L GNDREF #PWR2
U 1 1 5AA2A8EB
P 4850 2550
F 0 "#PWR2" H 4850 2300 50  0001 C CNN
F 1 "GNDREF" H 4850 2400 50  0000 C CNN
F 2 "" H 4850 2550 50  0001 C CNN
F 3 "" H 4850 2550 50  0001 C CNN
	1    4850 2550
	1    0    0    -1  
$EndComp
Connection ~ 4850 2450
Wire Wire Line
	4450 2050 4450 2000
Wire Wire Line
	4450 2000 4650 2000
Wire Wire Line
	4850 2050 4850 2000
Wire Wire Line
	4850 2000 5050 2000
Text Label 4550 2000 2    60   ~ 0
Vp
Text Label 4900 2000 0    60   ~ 0
Vm
$Comp
L C C2
U 1 1 5AA2AA98
P 4850 2200
F 0 "C2" H 4875 2300 50  0000 L CNN
F 1 "100nF" H 4875 2100 50  0000 L CNN
F 2 "" H 4888 2050 50  0001 C CNN
F 3 "" H 4850 2200 50  0001 C CNN
	1    4850 2200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
