// ESP8266 General and OTA
#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>

// BLYNK
//#define BLYNK_DEBUG
//#define BLYNK_PRINT Serial    // Comment this out to disable prints and save space
//#include <BlynkSimpleEsp8266.h>
//#include <WidgetRTC.h>

//--- Sensors ---
// DHT Sensor
//#include "DHT.h"

//OneWire for Temp Sens
#include <OneWire.h>
#include <DallasTemperature.h>

//Time
#include <TimeLib.h> //fetch time from NTP server 


// Central European Time (Frankfurt, Paris)
static const char ntpServerName[] = "2.pool.ntp.org";
//const int timeZone = 1; // CET (standard time)
const int timeZone = 2; // CETS (summer time)

WiFiUDP Udp;

unsigned int localPort = 8888;

//declarations for NTP Time functions
time_t getNtpTime();
void sendNTPpacket(IPAddress &address);


#define ONE_WIRE_BUS D4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);


//#define DHTPIN D2 //uncomment to enable DHT sensor
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


//WiFi Setup
const char* ssid = "LV426";
const char* password = "19263854466404343353";
//char auth[] = "ab2f47a18d074345aa20390d27fed878"; //Auth Token for Blynk
bool isFirstConnect = true;

//Web Server
WiFiServer server(80);
String header;

// Current time
unsigned long currentTime = millis();
// Previous time
unsigned long previousTime = 0; 
// Define timeout time in milliseconds (example: 2000ms = 2s)
const long timeoutTime = 2000;


//globals
int numberOfDevices = 0;
float maxWaterTemp = 20.5; //maximum allowed Water Temperature
bool fanIsOn = false;

float temp1 =0;
float temp2 =0;
float hum1 = 0;
unsigned int fanSpeed=0;

// intensities of Lamps NW, CW, WW, red,blue
int intensity[5]  =    {000,000,000,600,000};
int targetIntensity[5]={200,0,800,600,0}; //set by default
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
long startTime_s = 9*3600; //9am
time_t startTime_t;
long stopTime_s= 20*3600+5*60; //8pm
time_t stopTime_t;
bool newSSTime = false;
bool timedOn= false;
bool timedOff= false;
bool isSynced = false;

unsigned int timerPrevious=0;


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
  
  WiFi.begin(ssid, password);
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
    
    //Blynk.disconnect(); //disconnect from cloud
    //Serial.println("BLYNK disconnect");
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
    //Blynk.connect();
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
  
  /* print to BLYNK Serial
  Serial.println(F("Searching for Temp Sensors"));
  Serial.print(F("Found "));
  Serial.print(numberOfDevices, DEC);
  Serial.println(F(" OneWire Device(s)"));
  Serial.flush();
  */

  Serial.print("Found ");
  Serial.print(numberOfDevices, DEC);
  Serial.println(" OneWire Devices");
  
  //-- NTP --
  //start UDP
  Udp.begin(localPort);
  setSyncProvider(getNtpTime);
  setSyncInterval(10*60); //10minutes

  // Start Server
  server.begin();
}

//Function to read Temperature and control Fan
void UpdateTemp()
{
  

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
  
 
 #ifdef DHTPIN
  Serial.print("Ambient Humidity: ");
  Serial.print(hum1);
  Serial.println("%");
  Serial.print("Ambient Temperature: ");
  Serial.print(temp2);
  Serial.println("C");
 #endif
  
  if ((temp1>maxWaterTemp)&& !fanIsOn) {
    //Blynk.notify("Achtung! Wassertemperatur zu hoch");
    tagPrintln("Lüfter wird eingeschaltet");
    analogWrite(FAN_PWM_PIN,900);  //Turn on the Fan
    fanIsOn=true;
    //Blynk.virtualWrite(V6, 900);
  }
  else if ((temp1<maxWaterTemp-0.5) && fanIsOn) {
    analogWrite(FAN_PWM_PIN,10);  //Turn off the Fan
    tagPrintln("Lüfter ausgeschaltet");
    //Blynk.virtualWrite(V6, 10); // Turn off the Fan
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
  WiFiClient client = server.available(); // wait for client

  //Update temps every minute
  if (millis() - timerPrevious >= 60000)
  {
    UpdateTemp();
    timerPrevious = millis();    
  }

  if (client) {
    Serial.println("New Client");
    String currentLine = "";
    currentTime = millis();
    previousTime = currentTime;
    while (client.connected() && currentTime - previousTime <= timeoutTime) { // loop while the client's connected
      currentTime = millis();         
      if (client.available()) {             // if there's bytes to read from the client,
        char c = client.read();             // read a byte, then
        Serial.write(c);                    // print it out the serial monitor
        header += c;
        if (c == '\n') {                    // if the byte is a newline character
          // if the current line is blank, you got two newline characters in a row.
          // that's the end of the client HTTP request, so send a response:
          if (currentLine.length() == 0) {

            // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
            // and a content-type so the client knows what's coming, then a blank line:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();

            // Display the HTML web page
            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");

            // CSS to style the on/off buttons 
            // Feel free to change the background-color and font-size attributes to fit your preferences
            /*client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");
            client.println(".button { background-color: #195B6A; border: none; color: white; padding: 16px 40px;");
            client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            
            client.println(".button2 {background-color: #77878A;}</style>");
            */
            client.println("</head>");
            

            // Web Page Heading
            client.println("<body><h1>AxoControl</h1>");
            
            client.println("<p>Current water temperature: " +String(temp1) + "</p>");
            client.println("<p>Maximum water temperature: " +String(maxWaterTemp) + "</p>");
          
            
            client.println("</body></html>");
            
            // The HTTP response ends with another blank line
            client.println();
            // Break out of the while loop
            break;
          } else { // if you got a newline, then clear currentLine
            currentLine = "";
          }
        } 
        else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c;      // add it to the end of the currentLine
        }
      }
    }//while
  }//client
  
  //timer.run();
// intensities of Lamps NW,CW,WW,red,blue

  if (newIntensity) {
    setLEDs(targetIntensity);
    newIntensity=false;
    copy5(intensity,targetIntensity);
    tagPrint(F("LEDs set to: "));
    for (int i=0;i<5;i++){
      Serial.print(targetIntensity[i]);
      Serial.print(", ");
    }
    Serial.println();
  }

  if (newSSTime && dbgLvl) {
    now_s = hour() *60 *60 + minute() *60 + second();
    String currentTime = String(hour()) + ":" + minute() + ":" + second();
    tagPrint(F("Start Time is set to: "));
    Serial.println(startTime_s);
    tagPrint(F("Stop Time is set to: "));
    Serial.println(stopTime_s);
    if (timeStatus()<2) tagPrintln("Time is not in sync!");
    else {
      tagPrint("RTC Time is: ");  
      Serial.println(currentTime);
    }
    newSSTime=false;
  }

  if ((timeStatus()>1) && (startTime_s < stopTime_s)) { // if RTC is synced and starttime is less than stoptime
    now_s = hour() *60 *60 + minute() *60 + second();
	
    if ((now_s>=stopTime_s)&& !timedOff) {//if stopTime has passed by an was switched on --> switch off
     
      //Blynk.virtualWrite(V5,0);
      tagPrintln(F("Good night"));
      switchLEDs(false);
      delay(500);
      timedOff=true;
      timedOn=false; //allow timed on
    }
    else if ((now_s>=startTime_s)&& (now_s<stopTime_s) && !timedOn) {// else if between start and stop --> switch ON
	  
      //Blynk.virtualWrite(V5,1);
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
    Serial.println(F(" seconds have passed by today"));
    tagPrintln("Date: " + String(day()) + "." + String(month()) + "." + String(year()));
    isSynced=true;
  }
  delay(200);
} //loop

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
  return 0;
}

void tagPrint(String printStr) {
  String currentTime;
  
  if(timeStatus()>1) currentTime = String(hour()) + ":" + minute() + ":" + second();
  else currentTime = "??:??:??";
  Serial.print(currentTime);
  Serial.print(">>");
  Serial.print(printStr);
}

void tagPrintln(String printStr) {
  String currentTime;
  
  if(timeStatus()>1) currentTime = String(hour()) + ":" + minute() + ":" + second();
  else currentTime = "??:??:??";
  
  Serial.print(currentTime);
  Serial.print(">>");
  Serial.println(printStr);
}

/*-------- NTP code ----------*/

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

time_t getNtpTime()
{
  IPAddress ntpServerIP; // NTP server's ip address

  while (Udp.parsePacket() > 0) ; // discard any previously received packets
  Serial.println("Transmit NTP Request");
  // get a random server from the pool
  WiFi.hostByName(ntpServerName, ntpServerIP);
  Serial.print(ntpServerName);
  Serial.print(": ");
  Serial.println(ntpServerIP);
  sendNTPpacket(ntpServerIP);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = Udp.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      Serial.println("Receive NTP Response");
      Udp.read(packetBuffer, NTP_PACKET_SIZE);  // read packet into the buffer
      unsigned long secsSince1900;
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  Serial.println("No NTP Response :-(");
  return 0; // return 0 if unable to get the time
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12] = 49;
  packetBuffer[13] = 0x4E;
  packetBuffer[14] = 49;
  packetBuffer[15] = 52;
  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  Udp.beginPacket(address, 123); //NTP requests are to port 123
  Udp.write(packetBuffer, NTP_PACKET_SIZE);
  Udp.endPacket();
}
