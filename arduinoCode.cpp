#include <DHT.h>

#define DHTPIN 3
#define DHTTYPE DHT11      // Change to DHT22 if using one

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  dht.begin();
}

void loop() {

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();


  if (isnan(humidity) || isnan(temperature)) {
    Serial.print("ERROR");
    return;
  }


  Serial.print(temperature, 1);
  Serial.print(",");
  Serial.println(humidity, 1);

  delay(2000);
}
