#include "Arduino.h"

int LED_PIN = 13;

void setup() {
  Serial.begin(57600);
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  Serial.print("Hello, world");
  digitalWrite(LED_PIN, HIGH);
  delay(1000);
  digitalWrite(LED_PIN, LOW);
  delay(1000);
}

int main(){
  init();
  setup();
  for(;;) loop();
  return 0;
}