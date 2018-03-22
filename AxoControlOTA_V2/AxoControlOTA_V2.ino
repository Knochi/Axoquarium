


// ESP8266 General and OTA
#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>

// BLYNK
//#define BLYNK_DEBUG
#define BLYNK_PRINT Serial    // Comment this out to disable prints and save space
#include <BlynkSimpleEsp8266.h>
#include <WidgetRTC.h>
//Sensors


// DHT Sensor
//#include "DHT.h"

//OneWire for Temp Sens
#include <OneWire.h>
#include <DallasTemperature.h>

//Timer
//#include <SimpleTimer.h>
#include <TimeLib.h>
// SimpleTimer timer;
BlynkTimer timer;

#define ONE_WIRE_BUS D4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);


//#define DHTPIN D2
#define DHTTYPE DHT11

#ifdef DHTPIN
DHT dht(DHTPIN, DHTTYPE);
#endif

// -- Pin settings -- 
#define FANSENS D1
#define FAN_PWM_PIN  D2


#define CW_PIN    D6
#define NW_PIN    D5
#define WW_PIN    D0
#define RED_PIN   D7
#define BLUE_PIN  D8

// BLYNK Objects
WidgetRTC rtc;
WidgetTerminal terminal(V11);

//WiFi Setup
const char* ssid = "LV426";
const char* password = "19263854466404343353";
char auth[] = "ab2f47a18d074345aa20390d27fed878"; //Auth Token for Blynk
bool isFirstConnect = true;

//globals
int numberOfDevices = 0;
float maxWaterTemp = 25.0; //maximum allowed Water Temperature
bool fanIsOn = false;

// intensities of Lamps NW,CW,WW,red,blue
int intensity[5]={810,500,720,600,600};
int targetIntensity[5]={0,0,0,0,0};
int nxtIntensity[5]={0,0,0,0,0};
byte dimmingPlan[5][64];
bool newIntensity = true;
bool isOn=false;
bool isLog=false;

const uint16_t pwmtable_10[64] PROGMEM =
{
    0, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9, 10,
    11, 12, 13, 15, 17, 19, 21, 23, 26, 29, 32, 36, 40, 44, 49, 55,
    61, 68, 76, 85, 94, 105, 117, 131, 146, 162, 181, 202, 225, 250,
    279, 311, 346, 386, 430, 479, 534, 595, 663, 739, 824, 918, 1023
};

// timekeeping globals
long startTime_s = 0;
time_t startTime_t;
long stopTime_s= 0;
time_t stopTime_t;
bool newSSTime = false;
bool timedOn= false;
bool timedOff= false;
bool isSynced = false;
byte dbgLvl = 1;

unsigned int rpmCounter=0;

void setup() {
  
  Serial.begin(115200);
  Serial.println("Booting");
  //WiFi.mode(WIFI_STA);
 
 // -- FAN --
  pinMode(FANSENS,INPUT_PULLUP); //tacho signal
  analogWriteFreq(2000); //try 2kHz
  analogWrite(FAN_PWM_PIN, 10); //turn off fan
  delay(500);
  
  //-- BLYNK --
  Blynk.begin(auth,ssid, password);
  //WiFi.begin(ssid, password);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }

  // -- Arduino OTA --
  // Port defaults to 8266
   ArduinoOTA.setPort(8266);

  // Hostname defaults to esp8266-[ChipID]
   ArduinoOTA.setHostname("Axoquarium");

  // No authentication by default
  // ArduinoOTA.setPassword((const char *)"123");

  ArduinoOTA.onStart([]() {
    Serial.println("Start OTA");
    switchLEDs(false); //Turn LEDs Off
    analogWrite(FAN_PWM_PIN,10); //turn Fan Off
    
    Blynk.disconnect(); //disconnect from cloud
    Serial.println("BLYNK disconnect");
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
    Blynk.connect();
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  
  ArduinoOTA.begin();
  
  Serial.println("Ready");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  
 
  
  // Temp Sensors
  #ifdef DHTPIN
  dht.begin(); //start DHT
  #endif
  sensors.begin(); //start One Wire Temperature

  numberOfDevices = sensors.getDeviceCount();
  
  terminal.println(F("Searching for Temp Sensors"));
  terminal.print(F("Found "));
  terminal.print(numberOfDevices, DEC);
  terminal.println(F(" OneWire Device(s)"));
  terminal.flush();
  
  Serial.print("Found ");
  Serial.print(numberOfDevices, DEC);
  Serial.println(" OneWire Devices");
  
  //-- RTC --
  setSyncInterval(10*60); //10minutes

  //-- Timer --
  timer.setInterval(60000L, UpdateTemp); //start simple timer with one minute intervall
}

//Function to read Temperature and control Fan
void UpdateTemp()
{
   float temp1 =0;
   float temp2 =0;
   float hum1 = 0;
   unsigned int fanSpeed=0;

   rpmCounter=0;

  

   //if Temp Sensors found
   if (numberOfDevices) {
     sensors.requestTemperatures();
     temp1 = sensors.getTempCByIndex(0);
   }
   else {
     temp1 = -127;
   }
   
   #ifdef DHTPIN
   temp2 = dht.readTemperature();
   hum1 = dht.readHumidity();
   
   if (isnan(hum1) || isnan(temp2)) {
    Serial.println("Failed to read from DHT Sensor");
    return;
   } 
   #endif
   
  Serial.print("Water Temperature: "); Serial.println(temp1);
  Blynk.virtualWrite(20,temp1);  //send Temp to server/clients
 
 #ifdef DHTPIN
  Blynk.virtualWrite(21,temp2);
  Blynk.virtualWrite(22,hum1);
 
  Serial.print("Ambient Humidity: ");
  Serial.print(hum1);
  Serial.println("%");
  Serial.print("Ambient Temperature: ");
  Serial.print(temp2);
  Serial.println("C");
 #endif
  
  if ((temp1>maxWaterTemp)&& !fanIsOn) {
  	Blynk.notify("Achtung! Wassertemperatur zu hoch");
    tagPrintln("Lüfter wird eingeschaltet");
    analogWrite(FAN_PWM_PIN,900);  //Turn on the Fan
    fanIsOn=true;
    Blynk.virtualWrite(V6, 900);
  }
  else if ((temp1<maxWaterTemp-0.5) && fanIsOn) {
    analogWrite(FAN_PWM_PIN,10);  //Turn off the Fan
    tagPrintln("Lüfter ausgeschaltet");
    Blynk.virtualWrite(V6, 10); // Turn off the Fan
    fanIsOn=false;
  }
   
 //count pulses for 1 second
 /*
 attachInterrupt(FANSENS,countRPM,RISING);
 delay(1000);
 detachInterrupt(FANSENS);
 
 if (rpmCounter) fanSpeed = (rpmCounter/2)*60; //2 pulses per revolution
 else fanSpeed = 0;
 rpmCounter = 0;
 
 
 Blynk.virtualWrite(23,fanSpeed); //report fanSpeed to server
 */
 
  //Blynk.syncVirtual(V6); //read the Control?
   
}

void loop() {
  long now_s = 0;
  ArduinoOTA.handle();
  //delay(1000);
  
  Blynk.run();
  timer.run();
// intensities of Lamps NW,CW,WW,red,blue

  if (newIntensity) {
    setLEDs(targetIntensity);
    newIntensity=false;
    copy5(intensity,targetIntensity);
    tagPrint(F("LEDs set to: "));
    for (int i=0;i<5;i++){
    terminal.print(targetIntensity[i]);
    terminal.print(", ");
    }
    terminal.println();
    terminal.flush();
  }

  if (newSSTime && dbgLvl) {
    now_s = hour() *60 *60 + minute() *60 + second();
    String currentTime = String(hour()) + ":" + minute() + ":" + second();
    tagPrint(F("Start Time is set to: "));
    terminal.println(startTime_s);
    tagPrint(F("Stop Time is set to: "));
    terminal.println(stopTime_s);
    if (timeStatus()<2) tagPrintln("Time is not in sync!");
    else {
      tagPrint("RTC Time is: ");  
      terminal.println(currentTime);
    }
    terminal.flush();
    newSSTime=false;
  }

  if ((timeStatus()>1) && (startTime_s < stopTime_s)) { // if RTC is synced and starttime is less than stoptime
    now_s = hour() *60 *60 + minute() *60 + second();
	
    if ((now_s>=stopTime_s)&& !timedOff) {//if stopTime has passed by an was switched on --> switch off
     
      Blynk.virtualWrite(V5,0);
      tagPrintln(F("Good night"));
      switchLEDs(false);
      delay(500);
      timedOff=true;
      timedOn=false; //allow timed on
    }
    else if ((now_s>=startTime_s)&& (now_s<stopTime_s) && !timedOn) {// else if between start and stop --> switch ON
	  
      Blynk.virtualWrite(V5,1);
      tagPrintln(F("Good morning"));
      switchLEDs(true);
      delay(500);
      timedOn=true;
      timedOff=false; //allow timed off
      
    }
  }

  if (!isSynced && (timeStatus()>1)) {
    now_s = hour() *60 *60 + minute() *60 + second();
    tagPrintln("Time Synced");
    tagPrint(String(now_s));
    terminal.println(F(" seconds have passed by today"));
    tagPrintln("Date: " + String(day()) + "." + String(month()) + "." + String(year()));
    isSynced=true;
  }
  delay(200);
} //loop


BLYNK_CONNECTED() {

  terminal.println(F("Blynk v" BLYNK_VERSION ": Device started"));
  terminal.println(F("------------------------------------"));
  terminal.println(F("Time Sync started"));
  
  terminal.flush();
  
  if (isFirstConnect) {
    // Request Blynk server to re-send latest values for all pins
  Blynk.syncAll();

    // You can also update individual virtual pins like this:
  //Blynk.syncVirtual(V0, V1, V4);
	Blynk.virtualWrite(V1, maxWaterTemp);
    isFirstConnect = false;
  }
  rtc.begin(); //sync time on connection
}

BLYNK_WRITE(V10) {
	maxWaterTemp = param.asFloat();
}

BLYNK_WRITE(V0) { //NW
  targetIntensity[0] = param.asInt();
  newIntensity = true;
}

BLYNK_WRITE(V1) { //CW
  targetIntensity[1] = param.asInt();
  newIntensity = true;
}
BLYNK_WRITE(V2) { //WW
  targetIntensity[2] = param.asInt();
  newIntensity = true;
}
BLYNK_WRITE(V3) { //RED
  //if (isLog) targetIntensity[3] = pwmtable_10[map(param.asInt(),0,100,0,64)]; //map to 0..64 and take value from LUT
  //else targetIntensity[3] = map(param.asInt(),0,100,0,1024);
  targetIntensity[3] = param.asInt();
  newIntensity = true;
}
BLYNK_WRITE(V4) { //BLUE
  targetIntensity[4] = param.asInt();
  newIntensity = true;
}

BLYNK_WRITE(V5) { //Manual LED PowerOnOff
  if (param.asInt()){ // ON
    switchLEDs(true);
  }
  
  else //OFF
  {
   switchLEDs(false);
  }
}



BLYNK_WRITE(V6) { //fanControl
  if (param.asInt()){
    analogWrite(FAN_PWM_PIN,param.asInt());
  }
}

BLYNK_WRITE(V7){ //Time setting
TimeInputParam t(param);

  if (t.hasStartTime())
  {
   startTime_s = param[0].asLong();
   newSSTime = true;
  }
  if (t.hasStopTime())
   stopTime_s = param[1].asLong();
   newSSTime = true;
  {
    
  }
  
}

BLYNK_WRITE(V8){ //Logarithmic LED dimming ON/OFF
 if (param.asInt()){ // ON
    isLog=true;
  }
  
  else //OFF
  {
   isLog=false;
  }
}

void copy5(int target[], int original[]) {
  for (int i=0;i<5;i++)
  target[i]=original[i];
}

void countRPM(void){
  rpmCounter++;
}

void switchLEDs(bool switchOn){

  if (switchOn) { //ON
   tagPrintln("Switching Lights on");
   setLEDs(targetIntensity);
  }
  else { //OFF
   tagPrintln("Switching Lights off");
   //copy5(intensity,targetIntensity); //save old setting in intensity
   analogWrite(NW_PIN,0);
   analogWrite(CW_PIN,0);
   analogWrite(WW_PIN,0);
   analogWrite(RED_PIN,0);
   analogWrite(BLUE_PIN,0);
  }
  
}

void setupLEDDimm(){
  byte LEDStat[5][3]; //start, end and steps for each LED

 for (int i=0;i<5;i++){
  LEDStat[i][0]=PWM2Step(intensity[i]);
  LEDStat[i][1]=PWM2Step(targetIntensity[i]);
  LEDStat[i][2]=LEDStat[i][1]-LEDStat[i][0];
 }
 // set up a plan for each LED over 64 steps
 for (byte i=0;i<5;i++){
  for (byte j=0;j<64;i++){
    dimmingPlan[i][j]=0;   
  }
 }
}


void setLEDs (int intensityArr[]){
   analogWrite(NW_PIN,intensityArr[0]);
   analogWrite(CW_PIN,intensityArr[1]);
   analogWrite(WW_PIN,intensityArr[2]);
   analogWrite(RED_PIN,intensityArr[3]);
   analogWrite(BLUE_PIN,intensityArr[4]);
}

byte PWM2Step(unsigned int PWM){
  for (int i=0;i<64;i++){
    if (PWM>=pwmtable_10[i]) return i; 
  }
}

void tagPrint(String printStr) {
  String currentTime;
  
  if(timeStatus()>1) currentTime = String(hour()) + ":" + minute() + ":" + second();
  else currentTime = "??:??:??";
  terminal.print(currentTime);
  terminal.print(">>");
  terminal.print(printStr);
}

void tagPrintln(String printStr) {
  String currentTime;
  
  if(timeStatus()>1) currentTime = String(hour()) + ":" + minute() + ":" + second();
  else currentTime = "??:??:??";
  
  terminal.print(currentTime);
  terminal.print(">>");
  terminal.println(printStr);
  terminal.flush();
}

