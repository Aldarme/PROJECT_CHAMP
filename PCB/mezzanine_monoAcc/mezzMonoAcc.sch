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
LIBS:mezzMonoAcc-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Mezzanine DE2-115 mono Accéléromètre"
Date "2018-05-23"
Rev "0.1"
Comp "LPNHE"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Conn_02x20_Odd_Even J1
U 1 1 5B055C65
P 4200 3200
F 0 "J1" H 4250 4200 50  0000 C CNN
F 1 "Conn_02x20_Odd_Even" H 4200 4300 50  0000 C CNN
F 2 "Socket_Strips:Socket_Strip_Straight_2x20_Pitch2.54mm" H 4200 3200 50  0001 C CNN
F 3 "" H 4200 3200 50  0001 C CNN
	1    4200 3200
	1    0    0    -1  
$EndComp
$Comp
L Conn_02x03_Odd_Even J7
U 1 1 5B055D5D
P 6650 3300
F 0 "J7" H 6700 3500 50  0000 C CNN
F 1 "Conn_02x03_Odd_Even" V 8050 3300 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03_Pitch2.54mm" H 6650 3300 50  0001 C CNN
F 3 "" H 6650 3300 50  0001 C CNN
	1    6650 3300
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR01
U 1 1 5B056CD7
P 4750 3700
F 0 "#PWR01" H 4750 3450 50  0001 C CNN
F 1 "GNDREF" V 4750 3350 50  0000 C CNN
F 2 "" H 4750 3700 50  0001 C CNN
F 3 "" H 4750 3700 50  0001 C CNN
	1    4750 3700
	0    -1   -1   0   
$EndComp
$Comp
L GNDREF #PWR02
U 1 1 5B056D54
P 6300 3500
F 0 "#PWR02" H 6300 3250 50  0001 C CNN
F 1 "GNDREF" V 6200 3550 50  0000 C CNN
F 2 "" H 6300 3500 50  0001 C CNN
F 3 "" H 6300 3500 50  0001 C CNN
	1    6300 3500
	1    0    0    -1  
$EndComp
Text Label 6150 3200 2    60   ~ 0
VDD(3.3V)
Text Label 3750 3700 2    60   ~ 0
VDD(3.3V)
Text Label 4750 3400 0    60   ~ 0
ACC_CS_1
Text Label 4750 3300 0    60   ~ 0
ACC_CLK_1
Text Label 4750 3200 0    60   ~ 0
ACC_MI/MO_1
$Comp
L GNDREF #PWR03
U 1 1 5B05805A
P 4750 2800
F 0 "#PWR03" H 4750 2550 50  0001 C CNN
F 1 "GNDREF" V 4750 2450 50  0000 C CNN
F 2 "" H 4750 2800 50  0001 C CNN
F 3 "" H 4750 2800 50  0001 C CNN
	1    4750 2800
	0    -1   -1   0   
$EndComp
Text Label 3750 2800 2    60   ~ 0
VDD(5V)
Text Label 6200 2350 2    60   ~ 0
VDD(5V)
$Comp
L GNDREF #PWR04
U 1 1 5B0581C2
P 6200 2450
F 0 "#PWR04" H 6200 2200 50  0001 C CNN
F 1 "GNDREF" V 6200 2100 50  0000 C CNN
F 2 "" H 6200 2450 50  0001 C CNN
F 3 "" H 6200 2450 50  0001 C CNN
	1    6200 2450
	0    1    1    0   
$EndComp
Text Label 7200 2450 0    60   ~ 0
DAC_CLK
Text Label 4750 2500 0    60   ~ 0
DAC_CLK
Text Label 7200 2550 0    60   ~ 0
DAC_CS
Text Label 4750 2400 0    60   ~ 0
DAC_CS
Text Label 4750 2300 0    60   ~ 0
DAC_MISO
Text Label 6200 2650 2    60   ~ 0
DAC_MISO
$Comp
L GNDREF #PWR05
U 1 1 5B0591A6
P 6200 2950
F 0 "#PWR05" H 6200 2700 50  0001 C CNN
F 1 "GNDREF" V 6200 2600 50  0000 C CNN
F 2 "" H 6200 2950 50  0001 C CNN
F 3 "" H 6200 2950 50  0001 C CNN
	1    6200 2950
	0    1    1    0   
$EndComp
$Comp
L GNDREF #PWR06
U 1 1 5B0591CC
P 7200 2750
F 0 "#PWR06" H 7200 2500 50  0001 C CNN
F 1 "GNDREF" V 7200 2400 50  0000 C CNN
F 2 "" H 7200 2750 50  0001 C CNN
F 3 "" H 7200 2750 50  0001 C CNN
	1    7200 2750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6450 3300 6300 3300
Wire Wire Line
	6300 3300 6300 3500
Wire Wire Line
	6450 3400 6300 3400
Connection ~ 6300 3400
Wire Wire Line
	6450 3200 6150 3200
Wire Wire Line
	3750 3700 4000 3700
Wire Wire Line
	4500 3700 4750 3700
Wire Wire Line
	4500 2800 4750 2800
Wire Wire Line
	3750 2800 4000 2800
Wire Wire Line
	6200 2350 6450 2350
Wire Wire Line
	4500 3200 4750 3200
Wire Wire Line
	4750 3300 4500 3300
Wire Wire Line
	4500 3400 4750 3400
Wire Wire Line
	6950 3200 7200 3200
Wire Wire Line
	7200 3300 6950 3300
Wire Wire Line
	6950 3400 7200 3400
Wire Wire Line
	4350 4850 4350 5050
Wire Wire Line
	4750 4850 4750 5050
Wire Wire Line
	5150 4850 5150 5050
Wire Wire Line
	5550 4850 5550 5050
Wire Wire Line
	6000 4850 6000 5050
Wire Wire Line
	6450 4850 6450 5050
$Comp
L Conn_01x02 J2
U 1 1 5B05BD19
P 4350 4650
F 0 "J2" H 4350 4750 50  0000 C CNN
F 1 "Conn_01x02" H 4350 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 4350 4650 50  0001 C CNN
F 3 "" H 4350 4650 50  0001 C CNN
	1    4350 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J3
U 1 1 5B05BDAA
P 4750 4650
F 0 "J3" H 4750 4750 50  0000 C CNN
F 1 "Conn_01x02" H 4750 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 4750 4650 50  0001 C CNN
F 3 "" H 4750 4650 50  0001 C CNN
	1    4750 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J4
U 1 1 5B05BDD3
P 5150 4650
F 0 "J4" H 5150 4750 50  0000 C CNN
F 1 "Conn_01x02" H 5150 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 5150 4650 50  0001 C CNN
F 3 "" H 5150 4650 50  0001 C CNN
	1    5150 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J5
U 1 1 5B05BDFB
P 5550 4650
F 0 "J5" H 5550 4750 50  0000 C CNN
F 1 "Conn_01x02" H 5550 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 5550 4650 50  0001 C CNN
F 3 "" H 5550 4650 50  0001 C CNN
	1    5550 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J6
U 1 1 5B05BE28
P 6000 4650
F 0 "J6" H 6000 4750 50  0000 C CNN
F 1 "Conn_01x02" H 6000 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 6000 4650 50  0001 C CNN
F 3 "" H 6000 4650 50  0001 C CNN
	1    6000 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J8
U 1 1 5B05BE56
P 6450 4650
F 0 "J8" H 6450 4750 50  0000 C CNN
F 1 "Conn_01x02" H 6450 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 6450 4650 50  0001 C CNN
F 3 "" H 6450 4650 50  0001 C CNN
	1    6450 4650
	0    -1   -1   0   
$EndComp
$Comp
L GNDREF #PWR07
U 1 1 5B05BFC7
P 4450 5050
F 0 "#PWR07" H 4450 4800 50  0001 C CNN
F 1 "GNDREF" V 4450 4700 50  0000 C CNN
F 2 "" H 4450 5050 50  0001 C CNN
F 3 "" H 4450 5050 50  0001 C CNN
	1    4450 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR08
U 1 1 5B05BFED
P 4850 5050
F 0 "#PWR08" H 4850 4800 50  0001 C CNN
F 1 "GNDREF" V 4850 4700 50  0000 C CNN
F 2 "" H 4850 5050 50  0001 C CNN
F 3 "" H 4850 5050 50  0001 C CNN
	1    4850 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR09
U 1 1 5B05C013
P 5250 5050
F 0 "#PWR09" H 5250 4800 50  0001 C CNN
F 1 "GNDREF" V 5250 4700 50  0000 C CNN
F 2 "" H 5250 5050 50  0001 C CNN
F 3 "" H 5250 5050 50  0001 C CNN
	1    5250 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR010
U 1 1 5B05C039
P 5650 5050
F 0 "#PWR010" H 5650 4800 50  0001 C CNN
F 1 "GNDREF" V 5650 4700 50  0000 C CNN
F 2 "" H 5650 5050 50  0001 C CNN
F 3 "" H 5650 5050 50  0001 C CNN
	1    5650 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR011
U 1 1 5B05C05F
P 6100 5050
F 0 "#PWR011" H 6100 4800 50  0001 C CNN
F 1 "GNDREF" V 6100 4700 50  0000 C CNN
F 2 "" H 6100 5050 50  0001 C CNN
F 3 "" H 6100 5050 50  0001 C CNN
	1    6100 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR012
U 1 1 5B05C085
P 6550 5050
F 0 "#PWR012" H 6550 4800 50  0001 C CNN
F 1 "GNDREF" V 6550 4700 50  0000 C CNN
F 2 "" H 6550 5050 50  0001 C CNN
F 3 "" H 6550 5050 50  0001 C CNN
	1    6550 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4450 5050 4450 4850
Wire Wire Line
	4850 4850 4850 5050
Wire Wire Line
	5250 5050 5250 4850
Wire Wire Line
	5650 5050 5650 4850
Wire Wire Line
	6100 5050 6100 4850
Wire Wire Line
	6550 4850 6550 5050
$Comp
L Conn_02x07_Odd_Even J9
U 1 1 5B05C4A6
P 6650 2650
F 0 "J9" H 6700 3050 50  0000 C CNN
F 1 "Conn_02x07_Odd_Even" V 7800 2650 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x07_Pitch2.00mm" H 6650 2650 50  0001 C CNN
F 3 "" H 6650 2650 50  0001 C CNN
	1    6650 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6950 2750 7200 2750
Wire Wire Line
	6200 2450 6450 2450
Wire Wire Line
	6200 2650 6450 2650
Wire Wire Line
	6200 2950 6450 2950
Wire Wire Line
	6950 2550 7200 2550
Wire Wire Line
	7200 2450 6950 2450
$Comp
L Conn_02x03_Odd_Even J10
U 1 1 5B05CF34
P 6650 3800
F 0 "J10" H 6700 4000 50  0000 C CNN
F 1 "Conn_02x03_Odd_Even" V 8050 3800 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03_Pitch2.54mm" H 6650 3800 50  0001 C CNN
F 3 "" H 6650 3800 50  0001 C CNN
	1    6650 3800
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR013
U 1 1 5B05CF66
P 6300 3950
F 0 "#PWR013" H 6300 3700 50  0001 C CNN
F 1 "GNDREF" V 6200 4000 50  0000 C CNN
F 2 "" H 6300 3950 50  0001 C CNN
F 3 "" H 6300 3950 50  0001 C CNN
	1    6300 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 3800 6300 3800
Wire Wire Line
	6300 3800 6300 3950
Wire Wire Line
	6450 3900 6300 3900
Connection ~ 6300 3900
Text Label 6150 3700 2    60   ~ 0
VDD(3.3V)
Wire Wire Line
	6450 3700 6150 3700
Wire Wire Line
	4750 2300 4500 2300
Wire Wire Line
	4500 2400 4750 2400
Wire Wire Line
	4750 2500 4500 2500
Text Label 7200 3200 0    60   ~ 0
ACC_CS_1
Text Label 7200 3300 0    60   ~ 0
ACC_CLK_1
Text Label 7200 3400 0    60   ~ 0
ACC_MI/MO_1
Text Label 7200 3700 0    60   ~ 0
ACC_CS_2
Text Label 7200 3800 0    60   ~ 0
ACC_CLK_2
Text Label 7200 3900 0    60   ~ 0
ACC_MI/MO_2
Wire Wire Line
	6950 3700 7200 3700
Wire Wire Line
	7200 3800 6950 3800
Wire Wire Line
	6950 3900 7200 3900
Text Label 4750 4100 0    60   ~ 0
ACC_CS_2
Text Label 4750 4000 0    60   ~ 0
ACC_CLK_2
Text Label 4750 3900 0    60   ~ 0
ACC_MI/MO_2
Wire Wire Line
	4750 3900 4500 3900
Wire Wire Line
	4500 4000 4750 4000
Wire Wire Line
	4750 4100 4500 4100
Wire Wire Line
	6900 4850 6900 5050
Wire Wire Line
	7350 4850 7350 5050
Wire Wire Line
	7800 4850 7800 5050
$Comp
L Conn_01x02 J11
U 1 1 5B05DB83
P 6900 4650
F 0 "J11" H 6900 4750 50  0000 C CNN
F 1 "Conn_01x02" H 6900 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 6900 4650 50  0001 C CNN
F 3 "" H 6900 4650 50  0001 C CNN
	1    6900 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J12
U 1 1 5B05DB89
P 7350 4650
F 0 "J12" H 7350 4750 50  0000 C CNN
F 1 "Conn_01x02" H 7350 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 7350 4650 50  0001 C CNN
F 3 "" H 7350 4650 50  0001 C CNN
	1    7350 4650
	0    -1   -1   0   
$EndComp
$Comp
L Conn_01x02 J13
U 1 1 5B05DB8F
P 7800 4650
F 0 "J13" H 7800 4750 50  0000 C CNN
F 1 "Conn_01x02" H 7800 4450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 7800 4650 50  0001 C CNN
F 3 "" H 7800 4650 50  0001 C CNN
	1    7800 4650
	0    -1   -1   0   
$EndComp
$Comp
L GNDREF #PWR014
U 1 1 5B05DB95
P 7000 5050
F 0 "#PWR014" H 7000 4800 50  0001 C CNN
F 1 "GNDREF" V 7000 4700 50  0000 C CNN
F 2 "" H 7000 5050 50  0001 C CNN
F 3 "" H 7000 5050 50  0001 C CNN
	1    7000 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR015
U 1 1 5B05DB9B
P 7450 5050
F 0 "#PWR015" H 7450 4800 50  0001 C CNN
F 1 "GNDREF" V 7450 4700 50  0000 C CNN
F 2 "" H 7450 5050 50  0001 C CNN
F 3 "" H 7450 5050 50  0001 C CNN
	1    7450 5050
	1    0    0    -1  
$EndComp
$Comp
L GNDREF #PWR016
U 1 1 5B05DBA1
P 7900 5050
F 0 "#PWR016" H 7900 4800 50  0001 C CNN
F 1 "GNDREF" V 7900 4700 50  0000 C CNN
F 2 "" H 7900 5050 50  0001 C CNN
F 3 "" H 7900 5050 50  0001 C CNN
	1    7900 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 5050 7000 4850
Wire Wire Line
	7450 5050 7450 4850
Wire Wire Line
	7900 4850 7900 5050
Text Label 4350 5050 3    60   ~ 0
DAC_CS
Text Label 4750 5050 3    60   ~ 0
DAC_CLK
Text Label 5150 5050 3    60   ~ 0
DAC_MISO
Text Label 5550 5050 3    60   ~ 0
ACC_CS_1
Text Label 6000 5050 3    60   ~ 0
ACC_CLK_1
Text Label 6450 5050 3    60   ~ 0
ACC_MI/MO_1
Text Label 6900 5050 3    60   ~ 0
ACC_CS_2
Text Label 7350 5050 3    60   ~ 0
ACC_CLK_2
Text Label 7800 5050 3    60   ~ 0
ACC_MI/MO_2
$EndSCHEMATC
