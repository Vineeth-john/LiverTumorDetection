
#include<LiquidCrystal.h>
LiquidCrystal lcd(13, 12, 11, 10, 9, 8);
#include<SoftwareSerial.h>
SoftwareSerial iot(2, 3);
void setup() {
  lcd.begin(16, 2);
  iot.begin(9600);
  Serial.begin(9600);
  lcd.setCursor(0 , 0);
  lcd.print("LIVER DISEASE");
  lcd.setCursor(4,1);
  lcd.print("DETECTION");
  delay(2000);
}

void loop() {
  // put your main code here, to run repeatedly:
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("DETECTING..");

  while (iot.available() > 0)
  {
    char c = (char)iot.read();
    if (c == 'B')
    {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("LIVER DISEASE");
      lcd.setCursor(4,1);
      lcd.print("DETECTED");
      iott("*LIVER DISEASE DETECTED#");
      send_sms("7358331932", "LIVER DISEASE DETECTED");
    }
    if (c == 'A')
    {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("HEALTHY LIVER");
      lcd.setCursor(4,1);
      lcd.print("DETECTED");
      iott("*HEALTHY LIVER DETECTED#");
      send_sms("7358331932", "HEALTHY LIVER DETECTED");
    }
  }
  delay(500);
}

void send_sms(String number, String text)
{
  Serial.println("AT");
  delay(1000);
  Serial.println("AT+CMGF=1");
  delay(1000);
  Serial.println("AT+CMGS=\"+91" + String(number) + "\"\r");
  delay(1000);
  Serial.println(text);
  delay(1000);
  Serial.println(char(26));
}
void iott(String data)
{
  for (int i = 0; i < data.length(); i++)
  {
    iot.write(data[i]);
  }
}
