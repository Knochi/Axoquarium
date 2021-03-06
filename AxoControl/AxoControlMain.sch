EESchema Schematic File Version 2
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
LIBS:ESP8266
LIBS:myLib
LIBS:AxoControlMain-cache
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
L ESP-12E U1
U 1 1 595B81B3
P 3200 2150
F 0 "U1" H 3200 2050 50  0000 C CNN
F 1 "ESP-12E" H 3200 2250 50  0000 C CNN
F 2 "ESP8266:ESP-12E_SMD" H 3200 2150 50  0001 C CNN
F 3 "" H 3200 2150 50  0001 C CNN
	1    3200 2150
	1    0    0    -1  
$EndComp
$Sheet
S 7450 3800 1450 1050
U 595B87C5
F0 "Power" 60
F1 "AxoControlMain_Power.sch" 60
F2 "Vin" I L 7450 3900 60 
F3 "3V3" O R 8900 3900 60 
$EndSheet
Text HLabel 1650 2550 0    60   Input ~ 0
3V3
Wire Wire Line
	1650 2550 2300 2550
$EndSCHEMATC
