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
LIBS:accelerometers
LIBS:KIONIX-KX224-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Kionix KX3624 eval_board"
Date "2018-10-09"
Rev "1.0"
Comp "LPNHE"
Comment1 "ROMET Pierre"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L KX224 Kx1
U 1 1 5BBCC8A2
P 6350 3600
F 0 "Kx1" H 6300 3650 60  0000 C CNN
F 1 "KX224" H 6350 3750 60  0000 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:KX224" H 6350 3600 60  0001 C CNN
F 3 "" H 6350 3600 60  0001 C CNN
	1    6350 3600
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5BBCCA62
P 5050 3700
F 0 "C1" H 5075 3800 50  0000 L CNN
F 1 "100nF" H 5075 3600 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603" H 5088 3550 50  0001 C CNN
F 3 "" H 5050 3700 50  0001 C CNN
	1    5050 3700
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 5BBCCB06
P 7250 3250
F 0 "C2" H 7275 3350 50  0000 L CNN
F 1 "100nF" H 7275 3150 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603" H 7288 3100 50  0001 C CNN
F 3 "" H 7250 3250 50  0001 C CNN
	1    7250 3250
	1    0    0    -1  
$EndComp
Text Label 2300 2300 2    60   ~ 0
VDD
$Comp
L GNDREF #PWR01
U 1 1 5BBCCD74
P 2950 2750
F 0 "#PWR01" H 2950 2500 50  0001 C CNN
F 1 "GNDREF" H 2950 2600 50  0000 C CNN
F 2 "" H 2950 2750 50  0001 C CNN
F 3 "" H 2950 2750 50  0001 C CNN
	1    2950 2750
	1    0    0    -1  
$EndComp
Text Label 4600 2300 0    60   ~ 0
CS/SCL
Text Label 4600 2400 0    60   ~ 0
SCLK
Text Label 5200 2500 0    60   ~ 0
Miso/Mosi
Text Label 4750 3400 2    60   ~ 0
VDD
$Comp
L GNDREF #PWR02
U 1 1 5BBCD063
P 5050 4500
F 0 "#PWR02" H 5050 4250 50  0001 C CNN
F 1 "GNDREF" H 5050 4350 50  0000 C CNN
F 2 "" H 5050 4500 50  0001 C CNN
F 3 "" H 5050 4500 50  0001 C CNN
	1    5050 4500
	1    0    0    -1  
$EndComp
Text Label 5550 3700 2    60   ~ 0
SCLK
Text Label 6250 4450 3    60   ~ 0
Miso/Mosi
Text Label 6450 4450 3    60   ~ 0
CS/SCL
$Comp
L GNDREF #PWR03
U 1 1 5BBCD232
P 7250 4350
F 0 "#PWR03" H 7250 4100 50  0001 C CNN
F 1 "GNDREF" H 7250 4200 50  0000 C CNN
F 2 "" H 7250 4350 50  0001 C CNN
F 3 "" H 7250 4350 50  0001 C CNN
	1    7250 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 2300 2900 2300
Wire Wire Line
	3600 2400 2950 2400
Wire Wire Line
	2950 2400 2950 2750
Wire Wire Line
	3600 2500 2950 2500
Connection ~ 2950 2500
Wire Wire Line
	4100 2300 4600 2300
Wire Wire Line
	4100 2400 4600 2400
Wire Wire Line
	4750 3400 5950 3400
Wire Wire Line
	5050 2800 5050 3550
Connection ~ 5050 3400
Wire Wire Line
	5050 3850 5050 4500
Wire Wire Line
	5550 3700 5950 3700
Wire Wire Line
	6250 4050 6250 4450
Wire Wire Line
	6350 4050 6350 4250
Wire Wire Line
	6350 4250 6250 4250
Connection ~ 6250 4250
Wire Wire Line
	6450 4050 6450 4450
Wire Wire Line
	7250 3400 7250 4350
Wire Wire Line
	7250 2800 7250 3100
Wire Wire Line
	5050 2800 7250 2800
Wire Wire Line
	6450 2800 6450 3150
Wire Wire Line
	6750 3500 7250 3500
Connection ~ 7250 3500
Wire Wire Line
	5950 3800 5550 3800
Wire Wire Line
	5550 3800 5550 4050
Wire Wire Line
	5550 4050 5050 4050
Connection ~ 5050 4050
Text Label 6450 2800 2    60   ~ 0
VDD
Connection ~ 6450 2800
$Comp
L Conn_01x01 J1
U 1 1 5BBDD490
P 3800 2300
F 0 "J1" H 3800 2400 50  0000 C CNN
F 1 "Conn_01x01" H 3800 2200 50  0001 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:pastilles_CMS_rect_1,2_3,5" H 3800 2300 50  0001 C CNN
F 3 "" H 3800 2300 50  0001 C CNN
	1    3800 2300
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J2
U 1 1 5BBDD4CD
P 3800 2400
F 0 "J2" H 3800 2500 50  0000 C CNN
F 1 "Conn_01x01" H 3800 2300 50  0001 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:pastilles_CMS_rect_1,2_3,5" H 3800 2400 50  0001 C CNN
F 3 "" H 3800 2400 50  0001 C CNN
	1    3800 2400
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J3
U 1 1 5BBDD4FF
P 3800 2500
F 0 "J3" H 3800 2600 50  0000 C CNN
F 1 "Conn_01x01" H 3800 2400 50  0001 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:pastilles_CMS_rect_1,2_3,5" H 3800 2500 50  0001 C CNN
F 3 "" H 3800 2500 50  0001 C CNN
	1    3800 2500
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J6
U 1 1 5BBDD554
P 3900 2500
F 0 "J6" H 3900 2600 50  0000 C CNN
F 1 "Conn_01x01" H 3900 2400 50  0001 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:pastilles_CMS_rect_1,2_3,5" H 3900 2500 50  0001 C CNN
F 3 "" H 3900 2500 50  0001 C CNN
	1    3900 2500
	-1   0    0    1   
$EndComp
$Comp
L Conn_01x01 J5
U 1 1 5BBDD592
P 3900 2400
F 0 "J5" H 3900 2500 50  0000 C CNN
F 1 "Conn_01x01" H 3900 2300 50  0001 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:pastilles_CMS_rect_1,2_3,5" H 3900 2400 50  0001 C CNN
F 3 "" H 3900 2400 50  0001 C CNN
	1    3900 2400
	-1   0    0    1   
$EndComp
$Comp
L Conn_01x01 J4
U 1 1 5BBDD5BA
P 3900 2300
F 0 "J4" H 3900 2400 50  0000 C CNN
F 1 "Conn_01x01" H 3900 2200 50  0001 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:pastilles_CMS_rect_1,2_3,5" H 3900 2300 50  0001 C CNN
F 3 "" H 3900 2300 50  0001 C CNN
	1    3900 2300
	-1   0    0    1   
$EndComp
$Comp
L Jumper JP1
U 1 1 5BBDF0A5
P 4900 2500
F 0 "JP1" H 4900 2650 50  0000 C CNN
F 1 "Jumper" H 4900 2420 50  0000 C CNN
F 2 "Capacitors_SMD:C_0805" H 4900 2500 50  0001 C CNN
F 3 "" H 4900 2500 50  0001 C CNN
	1    4900 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4600 2500 4100 2500
$Comp
L Jumper JP2
U 1 1 5BBDF7F0
P 2600 2300
F 0 "JP2" H 2600 2450 50  0000 C CNN
F 1 "Jumper" H 2600 2220 50  0000 C CNN
F 2 "Capacitors_SMD:C_1210" H 2600 2300 50  0001 C CNN
F 3 "" H 2600 2300 50  0001 C CNN
	1    2600 2300
	1    0    0    -1  
$EndComp
$EndSCHEMATC
