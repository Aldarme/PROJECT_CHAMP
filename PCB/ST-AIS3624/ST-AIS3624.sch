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
LIBS:ST-AIS3624-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "EvalBoard_AIS3624"
Date "2018-10-09"
Rev "1.2"
Comp "LPNHE"
Comment1 "ROMET Pierre"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L AIS3624DQTR AIS36241
U 1 1 5BBC7853
P 6350 3450
F 0 "AIS36241" H 6350 3550 60  0000 C CNN
F 1 "AIS3624DQTR" H 6350 3650 60  0000 C CNN
F 2 "DIY_KICAD_FOOTPRINT_LIBRARY:ADIS3624DQ" H 6350 3450 60  0001 C CNN
F 3 "" H 6350 3450 60  0001 C CNN
	1    6350 3450
	1    0    0    -1  
$EndComp
$Comp
L Conn_02x03_Odd_Even J1
U 1 1 5BBC7978
P 3650 2500
F 0 "J1" H 3700 2700 50  0000 C CNN
F 1 "Conn_02x03_Odd_Even" H 3700 2300 50  0001 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03_Pitch2.54mm" H 3650 2500 50  0001 C CNN
F 3 "" H 3650 2500 50  0001 C CNN
	1    3650 2500
	1    0    0    -1  
$EndComp
Text Label 2900 2400 0    60   ~ 0
VDD
Wire Wire Line
	3450 2400 2900 2400
Wire Wire Line
	3450 2600 3200 2600
Wire Wire Line
	3200 2500 3200 2900
Connection ~ 3200 2500
$Comp
L GNDREF #PWR01
U 1 1 5BBC7E0B
P 3200 2900
F 0 "#PWR01" H 3200 2650 50  0001 C CNN
F 1 "GNDREF" H 3200 2750 50  0000 C CNN
F 2 "" H 3200 2900 50  0001 C CNN
F 3 "" H 3200 2900 50  0001 C CNN
	1    3200 2900
	1    0    0    -1  
$EndComp
Connection ~ 3200 2600
Text Label 4300 2400 0    60   ~ 0
CS/SCL
Text Label 4300 2500 0    60   ~ 0
SCLK
Text Label 4300 2600 0    60   ~ 0
Miso/Mosi
Wire Wire Line
	3950 2400 4300 2400
Wire Wire Line
	3950 2500 4300 2500
Wire Wire Line
	3950 2600 4300 2600
Wire Wire Line
	3450 2500 3200 2500
$Comp
L GNDREF #PWR02
U 1 1 5BBC7F93
P 5300 4500
F 0 "#PWR02" H 5300 4250 50  0001 C CNN
F 1 "GNDREF" H 5300 4350 50  0000 C CNN
F 2 "" H 5300 4500 50  0001 C CNN
F 3 "" H 5300 4500 50  0001 C CNN
	1    5300 4500
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 3500 5600 3500
Wire Wire Line
	5600 3500 5600 4300
Wire Wire Line
	5000 4300 6400 4300
Wire Wire Line
	5300 4100 5300 4500
Text Label 4550 3600 0    60   ~ 0
VDD
Wire Wire Line
	5850 3600 4550 3600
Wire Wire Line
	5850 3700 5600 3700
Connection ~ 5600 3700
Wire Wire Line
	6200 4300 6200 3950
Connection ~ 5600 4300
Wire Wire Line
	6300 4300 6300 3950
Connection ~ 6200 4300
Wire Wire Line
	6400 4300 6400 3950
Connection ~ 6300 4300
Text Label 7550 3700 0    60   ~ 0
VDD
Wire Wire Line
	6850 3700 7550 3700
Wire Wire Line
	6850 3600 7150 3600
Wire Wire Line
	7150 3600 7150 3700
Connection ~ 7150 3700
$Comp
L C C2
U 1 1 5BBC8138
P 5300 3950
F 0 "C2" H 5325 4050 50  0000 L CNN
F 1 "10uF" H 5325 3850 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603" H 5338 3800 50  0001 C CNN
F 3 "" H 5300 3950 50  0001 C CNN
	1    5300 3950
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5BBC817A
P 5000 3950
F 0 "C1" H 5025 4050 50  0000 L CNN
F 1 "100nF" H 5025 3850 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603" H 5038 3800 50  0001 C CNN
F 3 "" H 5000 3950 50  0001 C CNN
	1    5000 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 3600 5300 3800
Connection ~ 5300 3600
Connection ~ 5300 4300
Wire Wire Line
	5000 3800 5000 3600
Connection ~ 5000 3600
Text Label 6600 4550 3    60   ~ 0
CS/SCL
Text Label 6500 4550 3    60   ~ 0
SCLK
Wire Wire Line
	6500 3950 6500 4550
Wire Wire Line
	6600 3950 6600 4550
Text Label 7550 3400 0    60   ~ 0
Miso/Mosi
Wire Wire Line
	6850 3400 7550 3400
Wire Wire Line
	6850 3500 7150 3500
Wire Wire Line
	7150 3500 7150 3400
Connection ~ 7150 3400
Wire Wire Line
	5000 4100 5000 4300
$EndSCHEMATC
