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

#include <OneWire.h>
#include <DallasTemperature.h>

#include <SimpleTimer.h>
SimpleTimer timer;

#define ONE_WIRE_BUS 2
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

void UpdateTemp()
{
   float temp =0;
   sensors.requestTemperatures();
   temp = sensors.getTempCByIndex(0);
   Serial.print("Temperature: "); Serial.println(temp);
   Blynk.virtualWrite(0,temp);  
   
}


// You should get Auth Token in the Blynk App.
// Go to the Project Settings (nut icon).
char auth[] = "ab2f47a18d074345aa20390d27fed878";

void setup()
{
  Serial.begin(9600);
  Blynk.begin(auth, "LV426 Beacon", "3869935899194990");
  sensors.begin();
  timer.setInterval(10000L, UpdateTemp);
}

void loop()
{
  Blynk.run();
  timer.run();
}



BLYNK_WRITE(V1)
{
  BLYNK_LOG("Got a value: %s", param.asStr());
  // You can also use:
  // int i = param.asInt() or
  // double d = param.asDouble()
}


