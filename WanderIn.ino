// ░██╗░░░░░░░██╗░█████╗░███╗░░██╗██████╗░███████╗██████╗░██╗███╗░░██╗
// ░██║░░██╗░░██║██╔══██╗████╗░██║██╔══██╗██╔════╝██╔══██╗██║████╗░██║
// ░╚██╗████╗██╔╝███████║██╔██╗██║██║░░██║█████╗░░██████╔╝██║██╔██╗██║
// ░░████╔═████║░██╔══██║██║╚████║██║░░██║██╔══╝░░██╔══██╗██║██║╚████║
// ░░╚██╔╝░╚██╔╝░██║░░██║██║░╚███║██████╔╝███████╗██║░░██║██║██║░╚███║
// ░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝

/* -------------------------------------------------------------------------- */
/*                                  Libraries                                 */
/* -------------------------------------------------------------------------- */
#include <Adafruit_GFX.h>     // Graphics library
#include <Adafruit_ILI9341.h> // Display library
#include <TinyGPS.h>          // GPS library
#include <SoftwareSerial.h>   // SoftwareSerial library
// #include <Wire.h>               // Magnetometer libraries
// #include <Adafruit_Sensor.h>    // ...
// #include <Adafruit_HMC5883_U.h> // ...

/* -------------------------------------------------------------------------- */
/*                                   Serial                                   */
/* -------------------------------------------------------------------------- */
// Serial baud rate
#define SERIAL_BAUD 115200

/* -------------------------------------------------------------------------- */
/*                                  Display                                   */
/* -------------------------------------------------------------------------- */
// Display pins
#define TFT_CS 32
#define TFT_DC 14

// TFT initialization
Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC);

/* -------------------------------------------------------------------------- */
/*                                  Buzzer                                    */
/* -------------------------------------------------------------------------- */
// Buzzer pin
#define BUZZER_PIN 12

/* -------------------------------------------------------------------------- */
/*                                  Button                                    */
/* -------------------------------------------------------------------------- */
// Button pin
#define BUTTON_PIN 21

// Button states
enum ButtonState
{
  IDLE,
  PRESSED,
  HELD
};

// Debounce prevention
unsigned long debounceDuration = 50;

// Button timings
const unsigned long holdDuration = 1000;

/* -------------------------------------------------------------------------- */
/*                                    GPS                                     */
/* -------------------------------------------------------------------------- */
// GPS pins and baud rate
#define GPS_RX 16
#define GPS_TX 17
#define GPS_BAUD 9600

// GPS initialization
SoftwareSerial gpsSerial(GPS_RX, GPS_TX);
TinyGPS gps;

/* -------------------------------------------------------------------------- */
/*                                Magnetometer                                */
/* -------------------------------------------------------------------------- */
// // Magnetometer ID
// #define MAGNETOMETER_ID 12345

// // Magnetometer
// Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(MAGNETOMETER_ID);

/* -------------------------------------------------------------------------- */
/*                                  States                                    */
/* -------------------------------------------------------------------------- */
// Possible compass states
enum CompassState
{
  OFF,
  ON_DISCONNECTED,
  ON_CONNECTED_NO_POSTS,
  ON_CONNECTED_POST_NEARBY,
};

// Possible view states
enum ViewState
{
  COMPASS_VIEW,
  POST_VIEW
};

// Initialize current compass state
CompassState currCompassState = CompassState::ON_CONNECTED_POST_NEARBY;

// Initialize current view state
ViewState currViewState = ViewState::COMPASS_VIEW;

/* -------------------------------------------------------------------------- */
/*                                 Config                                     */
/* -------------------------------------------------------------------------- */
const int TEXT_SIZE = 2;

/* -------------------------------------------------------------------------- */
/*                                  Setup                                     */
/* -------------------------------------------------------------------------- */
void setup()
{
  initSerial();
  initButton();
  initBuzzer();
  initDisplay();
  initGPS();
  // initMag();
}

/* -------------------------------------------------------------------------- */
/*                                  Loop                                      */
/* -------------------------------------------------------------------------- */
void loop()
{
  if (currViewState == ViewState::POST_VIEW)
  {
    // TODO
    Serial.println("POST_VIEW");
  }

  // Change states according to how (and if) the button is pressed
  handleButton();

  // TODO - Get heading
  // float theHeading = getHeading();
  float theHeading = 0.0;

  // Read current coordinates
  float theCurrentLatitude = 0.0, theCurrentLongitude = 0.0;
  getCurrentCoordinates(theCurrentLatitude, theCurrentLongitude);

  // TODO - get actual coordinates
  float thePostLatitude = 38.89132224878997;
  float thePostLongitude = -76.72768339351313;

  // Switch statements for different currViewStates
  switch (currCompassState)
  {
  case CompassState::OFF:
  {
    tft.fillScreen(ILI9341_BLACK);
    break;
  }
  case CompassState::ON_DISCONNECTED:
  {
    tft.fillScreen(ILI9341_BLACK);
    printCenteredText("Not connected", 5, ILI9341_WHITE);
    delay(500);
    break;
  }
  case CompassState::ON_CONNECTED_NO_POSTS:
  {
    tft.fillScreen(ILI9341_BLACK);
    if (thePostLatitude == NULL || thePostLongitude == NULL)
    {
      float theBearing = calculateBearing(theCurrentLatitude, theCurrentLatitude, thePostLatitude, thePostLongitude);
      float theDistance = calculateDistance(theCurrentLatitude, theCurrentLatitude, thePostLatitude, thePostLongitude);
      String theMessage1 = "Awaiting";
      String theMessage2 = "new posts";
      for (int i = 1; i <= 4; i++)
      {
        tft.fillScreen(ILI9341_BLACK);
        printCenteredText(theMessage1, 5, ILI9341_WHITE);
        String theDots;
        for (int j = 0; j < i - 1; j++)
        {
          theDots += ".";
        }
        printCenteredText(theMessage2 + theDots, 6, ILI9341_WHITE);
        delay(500);
      }
    }
    else
    {
      currCompassState = ON_CONNECTED_POST_NEARBY;
    }
    break;
  }
  case CompassState::ON_CONNECTED_POST_NEARBY:
  {
    tft.fillScreen(ILI9341_BLACK);
    if (thePostLatitude != NULL && thePostLongitude != NULL)
    {
      float theBearing = calculateBearing(theCurrentLatitude, theCurrentLatitude, thePostLatitude, thePostLongitude);
      float theDistance = calculateDistance(theCurrentLatitude, theCurrentLatitude, thePostLatitude, thePostLongitude);
      updateCompass(theHeading, theBearing, theDistance);
      updateBuzzer(theDistance);
      delay(1000);
    }
    else
    {
      currCompassState = ON_CONNECTED_NO_POSTS;
    }
    break;
  }
  default:
    break;
  }
}

// Initialize serial
void initSerial()
{
  Serial.begin(SERIAL_BAUD);
}

// Initialize button
void initButton()
{
  pinMode(BUTTON_PIN, INPUT);
}

// Initialize buzzer
void initBuzzer()
{
  pinMode(BUZZER_PIN, OUTPUT);
}

// Initialize display
void initDisplay()
{
  tft.begin();
  tft.fillScreen(ILI9341_BLACK);
  tft.setRotation(3);
  tft.setTextSize(TEXT_SIZE);
}

// Initialize the GPS
void initGPS()
{
  gpsSerial.begin(GPS_BAUD);
}

// Initialize the magnetometer
// void initMag()
// {
//   if (!mag.begin())
//   {
//     /* There was a problem detecting the HMC5883 ... check your connections */
//     Serial.println("Ooops, no HMC5883 detected ... Check your wiring!");
//     while (1)
//       ;
//   }
// }

// Handles when button is held or clicked
void handleButton()
{
  static byte theLastButtonState = LOW;

  static unsigned long theLastButtonChangeTime = 0;
  static ButtonState theButtonState = IDLE;

  unsigned long theCurrentTime = millis();
  byte theButtonRead = digitalRead(BUTTON_PIN);

  unsigned long theTimeSinceLastButtonChanged = theCurrentTime - theLastButtonChangeTime;

  // Update button change time and state
  if (theButtonState != theLastButtonState)
  {
    theLastButtonChangeTime = theCurrentTime;
    theLastButtonState = theButtonState;
  }

  // Button released after debounce
  if (theTimeSinceLastButtonChanged > debounceDuration)
  {

    // Button pressed
    if (theButtonRead == LOW && theButtonState == IDLE)
    {
      theButtonState = PRESSED;
      theLastButtonChangeTime = theCurrentTime;
    }

    // When button is held for holdDuration, turn on/off device
    else if (theButtonRead == LOW && theButtonState == PRESSED && theTimeSinceLastButtonChanged >= holdDuration)
    {
      theButtonState = HELD;
      currCompassState = (currCompassState == CompassState::OFF) ? CompassState::ON_DISCONNECTED : CompassState::OFF;
    }

    // When button released
    else if (theButtonRead == HIGH && (theButtonState == PRESSED || theButtonState == HELD))
    {
      if (theButtonState == PRESSED &&
          (currCompassState == CompassState::ON_CONNECTED_NO_POSTS ||
           currCompassState == CompassState::ON_CONNECTED_POST_NEARBY))
      {
        currViewState = (currViewState == ViewState::COMPASS_VIEW) ? ViewState::POST_VIEW : ViewState::COMPASS_VIEW;
      }
      theButtonState = IDLE;
      theLastButtonChangeTime = theCurrentTime;
    }
  }
}

// Get heading
// float getHeading()
// {
//   // Get event from magnetometer
//   sensors_event_t theEvent;
//   mag.getEvent(&theEvent);

//   // Get heading
//   float theHeading = atan2(theEvent.magnetic.y, theEvent.magnetic.x);
//   float theDeclinationAngle = 0.1919; // from https://www.magnetic-declination.com/ (San Diego, CA)
//   theHeading += theDeclinationAngle;

//   // Correct for when signs are reversed
//   if (theHeading < 0)
//   {
//     theHeading += 2 * PI;
//   }

//   // Check for wrap due to addition of declination
//   if (theHeading > 2 * PI)
//   {
//     theHeading -= 2 * PI;
//   }

//   // Return heading as degrees
//   float theHeadingDegrees = theHeading * (180 / PI);
//   return theHeading;
// }

// Get current coordinates
void getCurrentCoordinates(float &theCurrentLatitude, float &theCurrentLongitude)
{
  // Wait until GPS serial is available before reading data
  while (gpsSerial.available())
  {

    // Encode data
    if (gps.encode(gpsSerial.read()))
    {

      // Retrieve coordinates
      gps.f_get_position(&theCurrentLatitude, &theCurrentLongitude);

      // Check to see if coordinates are null or not
      String theLatString = String(theCurrentLatitude, 6);
      String theLngString = String(theCurrentLongitude, 6);
      if (theLatString[0] != '0' && theLngString[0] != '0')
      {
        Serial.println(theLatString);
        Serial.println(theLngString);
      }
    }
  }
}

// Calculate the bearing between two coordinates
float calculateBearing(float aLatitudeA, float aLongitudeA, float aLatitudeB, float aLongitudeB)
{
  aLatitudeA = aLatitudeA * (PI / 180);
  aLongitudeA = aLongitudeA * (PI / 180);
  aLatitudeB = aLatitudeB * (PI / 180);
  aLongitudeB = aLongitudeB * (PI / 180);
  float theDeltaLongitude = aLongitudeB - aLongitudeA;
  float theX = cos(aLatitudeA) * sin(aLatitudeB) - sin(aLatitudeA) * cos(aLatitudeB) * cos(theDeltaLongitude);
  float theY = sin(theDeltaLongitude) * cos(aLatitudeB);
  float theBearing = atan2(theY, theX);
  return (theBearing * (180 / PI)) - 90;
}

// Calculate the distance between two coordinates
float calculateDistance(float aLatitudeA, float aLongitudeA, float aLatitudeB, float aLongitudeB)
{
  const float EARTH_RADIUS = 20925721.785; // in ft

  aLatitudeA = aLatitudeA * (PI / 180);
  aLongitudeA = aLongitudeA * (PI / 180);
  aLatitudeB = aLatitudeB * (PI / 180);
  aLongitudeB = aLongitudeB * (PI / 180);

  float theDeltaLongitude = aLongitudeB - aLongitudeA;
  float theDeltaLatitude = aLatitudeB - aLatitudeA;

  float theDistance = sin(theDeltaLatitude / 2) * sin(theDeltaLatitude / 2) + cos(aLatitudeA) * cos(aLatitudeB) * sin(theDeltaLongitude / 2) * sin(theDeltaLongitude / 2);
  return 2 * asin(sqrt(theDistance)) * EARTH_RADIUS;
}

// Print text centered on the TFT display
void printCenteredText(String aText, int aLineNumber, uint16_t aColor)
{
  int theTextWidth = aText.length() * TEXT_SIZE * 6;
  int theX = (tft.height() / 2) - (theTextWidth / 2);
  int theY = (20 * aLineNumber);
  tft.setCursor(theX, theY);
  tft.setTextColor(aColor);
  tft.println(aText);
}

// Update compass
void updateCompass(float aHeading, float aBearing, float aDistance)
{
  tft.fillScreen(ILI9341_BLACK);
  int theCenterX = (tft.height() / 2);
  int theCenterY = (tft.width() / 2) - 40;
  int theRadius = theCenterX - 10;
  tft.drawCircle(theCenterX, theCenterY, theRadius, ILI9341_WHITE);
  updateCompassLabels(aHeading);
  updateArrow(aHeading, aBearing);
  updateDistanceLabel(aHeading, aBearing, aDistance);
}

// Update buzzer
void updateBuzzer(float aDistance)
{
  // TODO
}

// Update compass labels
void updateCompassLabels(float aHeading)
{
  int theCenterX = (tft.height() / 2);
  int theCenterY = (tft.width() / 2) - 40;
  int theRadius = theCenterY - 10;
  int theLabelDistance = theRadius - 20;
  auto calculateLabel = [&](const char *aLabel, float anAngle)
  {
    int theX = theCenterX + theLabelDistance * sin((aHeading + anAngle) * (PI / 180.0));
    int theY = theCenterY - theLabelDistance * cos((aHeading + anAngle) * (PI / 180.0));
    tft.setCursor(theX - 7, theY - 7);
    tft.print(aLabel);
  };
  tft.setTextColor(ILI9341_WHITE);
  calculateLabel("N", 0.0);
  calculateLabel("NE", 45.0);
  calculateLabel("E", 90.0);
  calculateLabel("SE", 135.0);
  calculateLabel("S", 180.0);
  calculateLabel("SW", 225.0);
  calculateLabel("W", 270.0);
  calculateLabel("NW", 315.0);
}

// Update arrow
void updateArrow(float aHeading, float aBearing)
{
  int theCenterX = (tft.height() / 2);
  int theCenterY = (tft.width() / 2) - 40;
  int theRadius = theCenterY - 45;

  // Dot in the middle
  tft.drawCircle(theCenterX, theCenterY, 2, ILI9341_WHITE);

  // Main arrow line
  int theArrowAngle = aHeading + aBearing;
  int theArrowTipX = theCenterX + theRadius * cos(theArrowAngle * PI / 180);
  int theArrowTipY = theCenterY + theRadius * sin(theArrowAngle * PI / 180);
  tft.drawLine(theCenterX, theCenterY, theArrowTipX, theArrowTipY, ILI9341_WHITE);

  // Arrowhead
  int theArrowheadLength = 10;
  float theArrowheadAngle = atan2(theArrowTipY - theCenterY, theArrowTipX - theCenterX);
  int theArrowheadX1 = theArrowTipX - theArrowheadLength * cos(theArrowheadAngle - PI / 4);
  int theArrowheadY1 = theArrowTipY - theArrowheadLength * sin(theArrowheadAngle - PI / 4);
  int theArrowheadX2 = theArrowTipX - theArrowheadLength * cos(theArrowheadAngle + PI / 4);
  int theArrowheadY2 = theArrowTipY - theArrowheadLength * sin(theArrowheadAngle + PI / 4);
  tft.drawLine(theArrowTipX, theArrowTipY, theArrowheadX1, theArrowheadY1, ILI9341_WHITE);
  tft.drawLine(theArrowTipX, theArrowTipY, theArrowheadX2, theArrowheadY2, ILI9341_WHITE);
  tft.drawLine(theArrowheadX1, theArrowheadY1, theArrowheadX2, theArrowheadY2, ILI9341_WHITE);
}

// Update distance label
void updateDistanceLabel(float aHeading, float aBearing, float aDistance)
{
  int theArrowAngle = aHeading + aBearing;
  long theTruncatedDistance = aDistance;
  String theDistanceStr = theTruncatedDistance + String{" ft"};

  // Arrow is pointing up
  if ((theArrowAngle > 0 && theArrowAngle <= 89) || (theArrowAngle > 270 && theArrowAngle <= 359))
  {
    printCenteredText(theDistanceStr, 4, 0x07E0);
  }

  // Arrow is pointing down
  else
  {
    printCenteredText(theDistanceStr, 7, 0x07E0);
  }
}