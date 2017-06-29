// ESP8266 General and OTA
#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>

// BLYNK
#define BLYNK_PRINT Serial    // Comment this out to disable prints and save space
#include <BlynkSimpleEsp8266.h>

//Sensors


// DHT Sensor
#include "DHT.h"

//OneWire for Temp Sens
#include <OneWire.h>
#include <DallasTemperature.h>

//SimpleTimer
#include <SimpleTimer.h>
SimpleTimer timer;

#define ONE_WIRE_BUS D4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);


//#define DHTPIN D2
#define DHTTYPE DHT11

#ifdef DHTPIN
DHT dht(DHTPIN, DHTTYPE);
#endif

#define FANSENS D1
#define FANCNT  D2

const char* ssid = "LV426 Beacon";
const char* password = "3869935899194990";
char auth[] = "ab2f47a18d074345aa20390d27fed878"; //Auth Token for Blynk
bool isFirstConnect = true;

int numberOfDevices = 0;
float maxWaterTemp = 25.0; //maximum allowed Water Temperature

void setup() {
  Serial.begin(115200);
  Serial.println("Booting");
  //WiFi.mode(WIFI_STA);
  Blynk.begin(auth,ssid, password);
  //WiFi.begin(ssid, password);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }

  // Port defaults to 8266
   ArduinoOTA.setPort(8266);

  // Hostname defaults to esp8266-[ChipID]
   ArduinoOTA.setHostname("Axoquarium");

  // No authentication by default
  // ArduinoOTA.setPassword((const char *)"123");

  ArduinoOTA.onStart([]() {
    Serial.println("Start OTA");
    Blynk.disconnect(); //disconnect fro cloud
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
  
  #ifdef DHTPIN
  dht.begin(); //start DHT
  #endif
  sensors.begin(); //start One Wire Temperature
  timer.setInterval(60000L, UpdateTemp); //start simple timer with one minute intervall

  numberOfDevices = sensors.getDeviceCount();
  Serial.print("Found ");
  Serial.print(numberOfDevices, DEC);
  Serial.println(" OneWire Devices");
}

//Function to read Temperature and control Fan
void UpdateTemp()
{
   float temp1 =0;
   float temp2 =0;
   float hum1 = 0;

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
   Blynk.virtualWrite(0,temp1);  
   
   #ifdef DHTPIN
   Blynk.virtualWrite(1,temp2);
   Blynk.virtualWrite(2,hum1);
   
  Serial.print("Ambient Humidity: ");
  Serial.print(hum1);
  Serial.println("%");
  Serial.print("Ambient Temperature: ");
  Serial.print(temp2);
  Serial.println("C");
  #endif
  
  if (temp1>maxWaterTemp) {
	Blynk.notify("Achtung! Wassertemperatur zu hoch");
	
  }
   //rebuild for 4pin Fan
   //if (temp1>21.5) digitalWrite(fanPin, HIGH); //Turn on the Fan
   //if (temp1<21.0) digitalWrite(fanPin,LOW); // Turn off the Fan
  
}

void loop() {
  ArduinoOTA.handle();
  //delay(1000);
  
  Blynk.run();
  timer.run();
  
  }

BLYNK_CONNECTED() {
  if (isFirstConnect) {
    // Request Blynk server to re-send latest values for all pins
    Blynk.syncAll();

    // You can also update individual virtual pins like this:
    //Blynk.syncVirtual(V0, V1, V4);
	Blynk.virtualWrite(V1, maxWaterTemp);
    isFirstConnect = false;
  }
}

BLYNK_WRITE(V1) {
	maxWaterTemp = param.asFloat();
}

