#include <LiquidCrystal_I2C.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Wire.h>
#include <qrcode.h>

//Network
#include <WiFi.h>
#include <ESPmDNS.h>

const char* ssid = "Haruk";
const char* password = "10001000";

// Set web server port number to 80
WiFiServer server(80);

// Variable to store the HTTP request
String header;
String output2State = "off";
const int output2 = 2;

// Current time
unsigned long currentTime = millis();
// Previous time
unsigned long previousTime = 0;
// Define timeout time in milliseconds (example: 2000ms = 2s)
const long timeoutTime = 5000;

const int led = 2;

#define SCREEN_WIDTH 128  // OLED display width, in pixels
#define SCREEN_HEIGHT 64  // OLED display height, in pixels

// set the LCD number of columns and rows
int lcdColumns = 16;
int lcdRows = 2;

LiquidCrystal_I2C lcd(0x3F, lcdColumns, lcdRows);

#define OLED_RESET -1        // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C  ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

#define OLED_SDA 21
#define OLED_SCL 22
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

QRCode qrcode;

String text[] = { "Welcome <3", "Delivering...", "Select your item", "Item delivered!", "Temp. Closed" };

void setup() {
  Serial.begin(115200);

  pinMode(output2, OUTPUT);
  digitalWrite(output2, LOW);

  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;)
      ;  // Don't proceed, loop forever
  }

  display.display();
  delay(1000);  // Pause for 2 seconds

  // Clear the buffer
  display.clearDisplay();

  // initialize LCD
  lcd.init();

  // display.display();
  // Serial.println(display.height());
  // turn on LCD backlight
  lcd.backlight();

  // Clear the buffer
  // display.clearDisplay();

  // Connect to Wi-Fi network with SSID and password
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  // Print local IP address and start web server
  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  server.begin();
  uint8_t qrcodeBytes[qrcode_getBufferSize(2)];
  qrcode_initText(&qrcode, qrcodeBytes, 2, ECC_LOW,("http://" + WiFi.localIP().toString()).c_str());

  display.clearDisplay();
        /*
         * QR-code ต้องมีพื้นที่สีสว่างกว่าตัว block ของ code เลยต้องถม background 
         * ส่วนที่จะแสดง QR-code ให้เป็นสีขาว (หน้าจอจะออกเป็นสีตามเม็ดสีบน oled ซึ่งคือสีฟ้า)
         */
        display.fillRect(0,0,128,64, WHITE);
        for (uint8_t y = 0; y < qrcode.size; y++) {
          for (uint8_t x = 0; x < qrcode.size; x++) {
            if (qrcode_getModule(&qrcode, x, y)) {
              /*
               * วาด Rectangle ขนาด 2x2 ในแต่ละตำแหน่งของ qrcode บนหน้าจอ 
                โดยวางมุมซ้ายบนสุดของ QR-Code ไว้ที่พิกัด (39, 18)
                */
              display.fillRect(x*2 + 39, y*2 + 7, 2, 2, BLACK);
            }
          }
          Serial.print("\n");
        }

  display.display();
}

void loop() {
  WiFiClient client = server.available();  // Listen for incoming clients

  if (client) {  // If a new client connects,
    currentTime = millis();
    previousTime = currentTime;
    Serial.println("New Client.");                                             // print a message out in the serial port
    String currentLine = "";                                                   // make a String to hold incoming data from the client
    while (client.connected() && currentTime - previousTime <= timeoutTime) {  // loop while the client's connected
      currentTime = millis();
      if (client.available()) {  // if there's bytes to read from the client,
        char c = client.read();  // read a byte, then
        Serial.write(c);
        delay(1);  // print it out the serial monitor
        header += c;
        if (c == '\n') {  // if the byte is a newline character
          // if the current line is blank, you got two newline characters in a row.
          // that's the end of the client HTTP request, so send a response:
          if (currentLine.length() == 0) {
            // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
            // and a content-type so the client knows what's coming, then a blank line:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();

            // turns the GPIOs on and off
            if (header.indexOf("GET /2/on") >= 0) {
              Serial.println("GPIO 2 on");
              output2State = "on";
              digitalWrite(output2, HIGH);
            } else if (header.indexOf("GET /2/off") >= 0) {
              Serial.println("GPIO 2 off");
              output2State = "off";
              digitalWrite(output2, LOW);
              // } else if (header.indexOf("GET /27/on") >= 0) {
              //   Serial.println("GPIO 27 on");
              //   output27State = "on";
              //   digitalWrite(output27, HIGH);
              // } else if (header.indexOf("GET /27/off") >= 0) {
              //   Serial.println("GPIO 27 off");
              //   output27State = "off";
              //   digitalWrite(output27, LOW);
            }

            // Display the HTML web page--------------------------------------------------------------------------
            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");
            // CSS to style the on/off buttons
            // Feel free to change the background-color and font-size attributes to fit your preferences
            client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");
            client.println(".button { background-color: #4CAF50; border: none; color: white; padding: 16px 40px;");
            client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            client.println(".button2 {background-color: #555555;}</style></head>");

            // Web Page Heading
            client.println("<body><h1>ESP32 Web Server</h1>");

            // Display current state, and ON/OFF buttons for GPIO 26
            client.println("<p>GPIO 26 - State " + output2State + "</p>");
            // If the output26State is off, it displays the ON button
            if (output2State == "off") {
              client.println("<p><a href=\"/2/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/2/off\"><button class=\"button button2\">OFF</button></a></p>");
            }

            // Display current state, and ON/OFF buttons for GPIO 27
            // client.println("<p>GPIO 27 - State " + output27State + "</p>");
            // // If the output27State is off, it displays the ON button
            // if (output27State=="off") {
            //   client.println("<p><a href=\"/27/on\"><button class=\"button\">ON</button></a></p>");
            // } else {
            //   client.println("<p><a href=\"/27/off\"><button class=\"button button2\">OFF</button></a></p>");
            // }
            client.println("</body></html>");

            // The HTTP response ends with another blank line
            client.println();
            // Break out of the while loop
            break;
          } else {  // if you got a newline, then clear currentLine
            currentLine = "";
          }
        } else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c;      // add it to the end of the currentLine
        }
      }
    }
    // Clear the header variable
    header = "";
    // Close the connection
    client.stop();
    Serial.println("Client disconnected.");
    Serial.println("");
  }

  for (int i; i < 5; i++) {
    showText(text[i]);
  }
}

void showText(String text) {
  lcd.setCursor(0, 0);

  lcd.print(text);


  delay(1000);
  lcd.clear();
}