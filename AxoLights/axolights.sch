EESchema Schematic File Version 2
LIBS:axolights-rescue
LIBS:power
LIBS:device
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
LIBS:axolights-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 2
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L +12V #PWR01
U 1 1 58723DB9
P 1800 3400
F 0 "#PWR01" H 1800 3250 50  0001 C CNN
F 1 "+12V" H 1800 3540 50  0000 C CNN
F 2 "" H 1800 3400 50  0000 C CNN
F 3 "" H 1800 3400 50  0000 C CNN
	1    1800 3400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 58723E42
P 1800 4450
F 0 "#PWR02" H 1800 4200 50  0001 C CNN
F 1 "GND" H 1800 4300 50  0000 C CNN
F 2 "" H 1800 4450 50  0000 C CNN
F 3 "" H 1800 4450 50  0000 C CNN
	1    1800 4450
	1    0    0    -1  
$EndComp
Text GLabel 1650 3700 0    60   Input ~ 0
WW
Wire Wire Line
	1950 3600 1800 3600
Wire Wire Line
	1800 3600 1800 3400
$Comp
L PWR_FLAG #FLG03
U 1 1 58724013
P 1450 1950
F 0 "#FLG03" H 1450 2045 50  0001 C CNN
F 1 "PWR_FLAG" H 1450 2130 50  0000 C CNN
F 2 "" H 1450 1950 50  0000 C CNN
F 3 "" H 1450 1950 50  0000 C CNN
	1    1450 1950
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG04
U 1 1 58724048
P 1900 1950
F 0 "#FLG04" H 1900 2045 50  0001 C CNN
F 1 "PWR_FLAG" H 1900 2130 50  0000 C CNN
F 2 "" H 1900 1950 50  0000 C CNN
F 3 "" H 1900 1950 50  0000 C CNN
	1    1900 1950
	1    0    0    -1  
$EndComp
$Comp
L +12V #PWR05
U 1 1 58724068
P 1450 2350
F 0 "#PWR05" H 1450 2200 50  0001 C CNN
F 1 "+12V" H 1450 2490 50  0000 C CNN
F 2 "" H 1450 2350 50  0000 C CNN
F 3 "" H 1450 2350 50  0000 C CNN
	1    1450 2350
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR06
U 1 1 58724088
P 1900 2350
F 0 "#PWR06" H 1900 2100 50  0001 C CNN
F 1 "GND" H 1900 2200 50  0000 C CNN
F 2 "" H 1900 2350 50  0000 C CNN
F 3 "" H 1900 2350 50  0000 C CNN
	1    1900 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1450 1950 1450 2350
Wire Wire Line
	1900 1950 1900 2350
Text GLabel 1450 3800 0    60   Input ~ 0
NW
Text GLabel 1450 3900 0    60   Input ~ 0
KW
Text GLabel 1450 4000 0    60   Input ~ 0
Rt
Text GLabel 1450 4100 0    60   Input ~ 0
Bl
Wire Wire Line
	1950 3700 1650 3700
Wire Wire Line
	1950 3800 1450 3800
Wire Wire Line
	1450 3900 1950 3900
Wire Wire Line
	1950 4000 1450 4000
Wire Wire Line
	1450 4100 1950 4100
$Sheet
S 5500 2250 1050 700 
U 58A96E93
F0 "AxoLights LEDs" 60
F1 "axolights_leds.sch" 60
F2 "WW" I L 5500 2350 60 
F3 "NW" I L 5500 2450 60 
F4 "KW" I L 5500 2550 60 
F5 "Rt" I L 5500 2650 60 
F6 "Bl" I L 5500 2750 60 
$EndSheet
Text GLabel 1250 2100 0    60   Input ~ 0
+12V
Wire Wire Line
	1250 2100 1450 2100
Connection ~ 1450 2100
Text GLabel 1850 2100 0    60   Input ~ 0
GND
Wire Wire Line
	1850 2100 1900 2100
Connection ~ 1900 2100
$Comp
L +12V #PWR07
U 1 1 58A9CEF9
P 3250 3400
F 0 "#PWR07" H 3250 3250 50  0001 C CNN
F 1 "+12V" H 3250 3540 50  0000 C CNN
F 2 "" H 3250 3400 50  0000 C CNN
F 3 "" H 3250 3400 50  0000 C CNN
	1    3250 3400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR08
U 1 1 58A9CEFF
P 3250 4450
F 0 "#PWR08" H 3250 4200 50  0001 C CNN
F 1 "GND" H 3250 4300 50  0000 C CNN
F 2 "" H 3250 4450 50  0000 C CNN
F 3 "" H 3250 4450 50  0000 C CNN
	1    3250 4450
	1    0    0    -1  
$EndComp
Text GLabel 3100 3700 0    60   Input ~ 0
WW
Wire Wire Line
	3700 3600 3250 3600
Wire Wire Line
	3250 3600 3250 3400
Text GLabel 2900 3800 0    60   Input ~ 0
NW
Text GLabel 2900 3900 0    60   Input ~ 0
KW
Text GLabel 2900 4000 0    60   Input ~ 0
Rt
Text GLabel 2900 4100 0    60   Input ~ 0
Bl
Wire Wire Line
	3700 3700 3100 3700
Wire Wire Line
	3700 3800 2900 3800
Wire Wire Line
	2900 3900 3700 3900
Wire Wire Line
	3700 4000 2900 4000
Wire Wire Line
	2900 4100 3700 4100
Text GLabel 4900 2350 0    60   Input ~ 0
WW
Text GLabel 4700 2450 0    60   Input ~ 0
NW
Text GLabel 4700 2550 0    60   Input ~ 0
KW
Text GLabel 4700 2650 0    60   Input ~ 0
Rt
Text GLabel 4700 2750 0    60   Input ~ 0
Bl
Wire Wire Line
	5500 2350 4900 2350
Wire Wire Line
	5500 2450 4700 2450
Wire Wire Line
	4700 2550 5500 2550
Wire Wire Line
	5500 2650 4700 2650
Wire Wire Line
	4700 2750 5500 2750
$Comp
L CONN_01X08 P1
U 1 1 58B93C67
P 2150 3950
F 0 "P1" H 2150 4400 50  0000 C CNN
F 1 "CONN_01X08" V 2250 3950 50  0000 C CNN
F 2 "Connectors_JST:JST_XH_B08B-XH-A_08x2.50mm_Straight" H 2150 3950 50  0001 C CNN
F 3 "" H 2150 3950 50  0000 C CNN
	1    2150 3950
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X08 P2
U 1 1 58B93CEB
P 3900 3950
F 0 "P2" H 3900 4400 50  0000 C CNN
F 1 "CONN_01X08" V 4000 3950 50  0000 C CNN
F 2 "Connectors_JST:JST_XH_B08B-XH-A_08x2.50mm_Straight" H 3900 3950 50  0001 C CNN
F 3 "" H 3900 3950 50  0000 C CNN
	1    3900 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 4450 3250 4300
Wire Wire Line
	3250 4300 3700 4300
Wire Wire Line
	1800 4450 1800 4300
Wire Wire Line
	1800 4300 1950 4300
Text GLabel 1450 4200 0    60   Input ~ 0
OneWire
Text GLabel 2900 4200 0    60   Input ~ 0
OneWire
Wire Wire Line
	1450 4200 1950 4200
Wire Wire Line
	2900 4200 3700 4200
$EndSCHEMATC
