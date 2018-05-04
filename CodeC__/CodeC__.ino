int pushButton = PUSH1;
int pushButton2 = PUSH2;
int incomingByte = 0;  
int brightness = 0;    
int fadeAmount = 5; 

// the setup routine runs once when you press reset:
void setup() {
  Serial.begin(19200);
  pinMode(pushButton, INPUT_PULLUP);
  pinMode(pushButton2, INPUT_PULLUP);
  pinMode(RED_LED, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    if(incomingByte == 1) { 
      analogWrite(RED_LED, brightness);    
      brightness = brightness + fadeAmount;
        if (brightness == 0 || brightness == 255) fadeAmount = -fadeAmount ;    
    }
  }
  else analogWrite(RED_LED, 0);   
  int buttonState = digitalRead(pushButton);
  int buttonState2 = digitalRead(pushButton2);
  if (!buttonState) Serial.println("L");
  else if (!buttonState2) Serial.println("R");
  else Serial.println("N");
  delay(1); 
}



