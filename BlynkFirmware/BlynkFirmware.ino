

/**************************************************************
 * Blynk is a platform with iOS and Android apps to control
 * Arduino, Raspberry Pi and the likes over the Internet.
 * You can easily build graphic interfaces for all your
 * projects by simply dragging and dropping widgets.
 *
 *   Downloads, docs, tutorials: http://www.blynk.cc
 *   Blynk community:            http://community.blynk.cc
 *   Social networks:            http://www.fb.com/blynkapp
 *                               http://twitter.com/blynk_app
 *
 * Blynk library is licensed under MIT license
 * This example code is in public domain.
 *
 **************************************************************
 * This example runs directly on ESP8266 chip.
 *
 * You need to install this for ESP8266 development:
 *   https://github.com/esp8266/Arduino
 *
 * Please be sure to select the right ESP8266 module
 * in the Tools -> Board menu!
 *
 * Change WiFi ssid, pass, and Blynk auth token to run :)
 *
 **************************************************************/

#define BLYNK_PRINT Serial    // Comment this out to disable prints and save space
#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>
//#include <ESP8266HTTPUpdateServer.h>
//#include <ESP8266WebServer.h>
//#include <ESP8266mDNS.h>

#include <OneWire.h>
#include <DallasTemperature.h>

#include <SimpleTimer.h>
SimpleTimer timer;

#define ONE_WIRE_BUS 2
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

//const char host[]="Axoquarium";


//ESP8266WebServer httpServer(80);
//ESP8266HTTPUpdateServer httpUpdater;


int fanPin = 13;

void UpdateTemp()
{
   float temp1 =0;
   float temp2 =0;
   
   sensors.requestTemperatures();
   temp1 = sensors.getTempCByIndex(0);
   Serial.print("Temperature: "); Serial.println(temp1);
   Blynk.virtualWrite(0,temp1);  
   if (temp1>21.5) digitalWrite(fanPin, HIGH); //Turn on the Fan
   if (temp1<21.0) digitalWrite(fanPin,LOW); // Turn off the Fan
   
}


// You should get Auth Token in the Blynk App.
// Go to the Project Settings (nut icon).
char auth[] = "ab2f47a18d074345aa20390d27fed878";

void setup()
{
//  MDNS.begin(host);

  //httpUpdater.setup(&httpServer);
  //httpServer.begin();

  //MDNS.addService("http","tcp",80);
  
  Serial.begin(9600);
  Blynk.begin(auth, "LV426 Beacon", "3869935899194990");
  sensors.begin();
  timer.setInterval(60000L, UpdateTemp);

 // Serial.printf("HTTPUpdateServer ready! Open http://%s.local/update in your browser\n", host);
}

void loop()
{
  Blynk.run();
  timer.run();
  //httpServer.handleClient();
}



BLYNK_WRITE(V1)
{
  BLYNK_LOG("Got a value: %s", param.asStr());
  // You can also use:
  // int i = param.asInt() or
  // double d = param.asDouble()
}


