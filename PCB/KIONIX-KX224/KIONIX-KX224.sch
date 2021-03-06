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
Date "2018-11-12"
Rev "v2.0"
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
F 2 "Capacitors_SMD:C_0805" H 5088 3550 50  0001 C CNN
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
Text Label 2900 2300 2    60   ~ 0
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
Text Label 4600 2500 0    60   ~ 0
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
Text Label 6450 2800 2    60   ~ 0
VDD
Wire Wire Line
	5050 4050 5800 4050
Wire Wire Line
	5800 4050 5800 3800
Wire Wire Line
	5800 3800 5950 3800
Wire Wire Line
	6450 2800 7250 2800
Wire Wire Line
	4600 2500 4100 2500
Connection ~ 6450 2800
Connection ~ 5050 4050
Connection ~ 7250 3500
Wire Wire Line
	6750 3500 7250 3500
Wire Wire Line
	6450 2800 6450 3150
Wire Wire Line
	7250 2800 7250 3100
Wire Wire Line
	7250 3400 7250 4350
Wire Wire Line
	6450 4050 6450 4450
Wire Wire Line
	5550 3700 5950 3700
Wire Wire Line
	5050 3850 5050 4500
Connection ~ 5050 3400
Wire Wire Line
	5050 3400 5050 3550
Wire Wire Line
	4750 3400 5950 3400
Wire Wire Line
	4100 2400 4600 2400
Wire Wire Line
	4100 2300 4600 2300
Connection ~ 2950 2500
Wire Wire Line
	3600 2500 2950 2500
Wire Wire Line
	2950 2400 2950 2750
Wire Wire Line
	3600 2400 2950 2400
Wire Wire Line
	3600 2300 2900 2300
$Comp
L Conn_02x03_Odd_Even J1
U 1 1 5BD03BD2
P 3800 2400
F 0 "J1" H 3850 2600 50  0000 C CNN
F 1 "Conn_02x03_Odd_Even" H 3850 2200 50  0001 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03_Pitch2.54mm" H 3800 2400 50  0001 C CNN
F 3 "" H 3800 2400 50  0001 C CNN
	1    3800 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 4450 6250 4050
$EndSCHEMATC
