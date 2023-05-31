#include <Adafruit_GFX.h>     // Graphics library
#include <Adafruit_ILI9341.h> // Display library
#include <SoftwareSerial.h>   // SoftwareSerial library

// Display pins
#define TFT_CS 32
#define TFT_DC 14

// Buzzer pin
#define BUZZER_PIN 12

// Button pin
#define BUTTON_PIN 21

// States
enum State
{
  OFF,
  ON_DISCONNECTED,
  ON_CONNECTED_NO_POSTS,
  ON_CONNECTED_POST_NEARBY,
  ON_CONNECTED_POST_FOUND
};

// Initial state
State state = State::OFF; // Change for debug

// Display
Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC);

// Configurable variables
const int TEXT_SIZE = 2;

// Setup
void setup()
{
  initSerial();
  initButton();
  initBuzzer();
  initDisplay();
}

// Loop
void loop()
{
  // TODO - get actual rotation
  long double theCompassRotation = 0;

  // TODO - get actual coordinates
  long double theLatitudeA = 38.88984594484824;
  long double theLongitudeA = -76.728515625;
  long double theLatitudeB = 38.89132224878997;
  long double theLongitudeB = -76.72768339351313;

  // long double theLatitudeA = NULL;
  // long double theLongitudeA = NULL;
  // long double theLatitudeB = NULL;
  // long double theLongitudeB = NULL;

  // Return if button have been pressed to turn off wearable
  if (state != State::OFF && buttonPressed())
  {
    state = State::OFF;
    return;
  }

  // Switch statements for different states
  switch (state)
  {
  case State::OFF:
  {
    tft.fillScreen(ILI9341_BLACK) if (buttonPressed())
    {
      state = State::ON_DISCONNECTED;
    }
    break;
  }
  case State::ON_DISCONNECTED:
  {
    if (buttonPressed())
    {
      state = State::OFF;
      break;
    }
    tft.fillScreen(ILI9341_BLACK);
    printCenteredText("Not connected", 5, ILI9341_WHITE);
    while (state == State::ON_DISCONNECTED)
    {
      // TODO - if connected, connect
      continue;
    }
    break;
  }
  case State::ON_CONNECTED_NO_POSTS:
  {
    if (theLatitudeB == NULL || theLongitudeB == NULL)
    {
      long double theBearing = calculateBearing(theLatitudeA, theLongitudeA, theLatitudeB, theLongitudeB);
      long double theDistance = calculateDistance(theLatitudeA, theLongitudeA, theLatitudeB, theLongitudeB);
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
      state = ON_CONNECTED_POST_NEARBY;
    }
    break;
  }
  case State::ON_CONNECTED_POST_NEARBY:
  {
    if (theLatitudeB != NULL && theLongitudeB != NULL)
    {
      long double theBearing = calculateBearing(theLatitudeA, theLongitudeA, theLatitudeB, theLongitudeB);
      long double theDistance = calculateDistance(theLatitudeA, theLongitudeA, theLatitudeB, theLongitudeB);
      updateCompass(theCompassRotation, theBearing, theDistance);
      updateBuzzer(theDistance);
      delay(1000);
    }
    else
    {
      state = ON_CONNECTED_NO_POSTS;
    }
    break;
  }
  case State::ON_CONNECTED_POST_FOUND:
  {
    // TODO
    break;
  }
  default:
    break;
  }
}

// Initialize Serial
void initSerial()
{
  Serial.begin(9600);
}

void initButton()
{
  pinMode(BUTTON_PIN, INPUT_PULLUP);
}

// Initialize the buzzer
void initBuzzer()
{
  pinMode(BUZZER_PIN, OUTPUT);
}

// Initialize the display
void initDisplay()
{
  tft.begin();
  tft.fillScreen(ILI9341_BLACK);
  tft.setRotation(3);
  tft.setTextSize(TEXT_SIZE);
}

// Checks if button have been pressed
bool buttonPressed()
{
  int theButtonState = digitalRead(BUTTON_PIN);
  bool buttonPressed = theButtonState == LOW;
  delay(100); // to prevent debounce
  return buttonPressed;
}

// Calculate the bearing between two coordinates
long double calculateBearing(long double aLatitudeA, long double aLongitudeA, long double aLatitudeB, long double aLongitudeB)
{
  aLatitudeA = aLatitudeA * (PI / 180);
  aLongitudeA = aLongitudeA * (PI / 180);
  aLatitudeB = aLatitudeB * (PI / 180);
  aLongitudeB = aLongitudeB * (PI / 180);
  long double theDeltaLongitude = aLongitudeB - aLongitudeA;
  long double theX = cos(aLatitudeA) * sin(aLatitudeB) - sin(aLatitudeA) * cos(aLatitudeB) * cos(theDeltaLongitude);
  long double theY = sin(theDeltaLongitude) * cos(aLatitudeB);
  long double theBearing = atan2(theY, theX);
  return (theBearing * (180 / PI)) - 90;
}

// Calculate the distance between two coordinates
long double calculateDistance(long double aLatitudeA, long double aLongitudeA, long double aLatitudeB, long double aLongitudeB)
{
  const long double EARTH_RADIUS = 20925721.785; // in ft

  aLatitudeA = aLatitudeA * (PI / 180);
  aLongitudeA = aLongitudeA * (PI / 180);
  aLatitudeB = aLatitudeB * (PI / 180);
  aLongitudeB = aLongitudeB * (PI / 180);

  long double theDeltaLongitude = aLongitudeB - aLongitudeA;
  long double theDeltaLatitude = aLatitudeB - aLatitudeA;

  long double theDistance = sin(theDeltaLatitude / 2) * sin(theDeltaLatitude / 2) + cos(aLatitudeA) * cos(aLatitudeB) * sin(theDeltaLongitude / 2) * sin(theDeltaLongitude / 2);
  return 2 * asin(sqrt(theDistance)) * EARTH_RADIUS;
}

// Print text centered on the TFT display
void printCenteredText(String aText, int aLineNumber, int aColor)
{
  int theTextWidth = aText.length() * TEXT_SIZE * 6;
  int theX = (tft.height() / 2) - (theTextWidth / 2);
  int theY = (20 * aLineNumber);
  tft.setCursor(theX, theY);
  tft.setTextColor(aColor);
  tft.println(aText);
}

// Update compass
void updateCompass(long double aCompassRotation, long double aBearing, long double aDistance)
{
  tft.fillScreen(ILI9341_BLACK);
  int theCenterX = (tft.height() / 2);
  int theCenterY = (tft.width() / 2) - 40;
  int theRadius = theCenterX - 10;
  tft.drawCircle(theCenterX, theCenterY, theRadius, ILI9341_WHITE);
  updateCompassLabels(aCompassRotation);
  updateArrow(aCompassRotation, aBearing);
  updateDistanceLabel(aCompassRotation, aBearing, aDistance);
}

// Update buzzer
void updateBuzzer(long double aDistance)
{
  // TODO
}

// Update compass labels
void updateCompassLabels(long double aCompassRotation)
{
  int theCenterX = (tft.height() / 2);
  int theCenterY = (tft.width() / 2) - 40;
  int theRadius = theCenterY - 10;
  int theLabelDistance = theRadius - 20;
  auto calculateLabel = [&](const char *aLabel, long double anAngle)
  {
    int theX = theCenterX + theLabelDistance * sin((aCompassRotation + anAngle) * (PI / 180.0));
    int theY = theCenterY - theLabelDistance * cos((aCompassRotation + anAngle) * (PI / 180.0));
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
void updateArrow(long double aCompassRotation, long double aBearing)
{
  int theCenterX = (tft.height() / 2);
  int theCenterY = (tft.width() / 2) - 40;
  int theRadius = theCenterY - 45;

  // Dot in the middle
  tft.drawCircle(theCenterX, theCenterY, 2, ILI9341_WHITE);

  // Main arrow line
  int theArrowAngle = aCompassRotation + aBearing;
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
void updateDistanceLabel(long double aCompassRotation, long double aBearing, long double aDistance)
{
  int theArrowAngle = aCompassRotation + aBearing;
  long theTruncatedDistance = aDistance;
  String theDistanceStr = theTruncatedDistance + String{" ft"};

  // Arrow is pointing up
  if ((theArrowAngle > 0 && theArrowAngle <= 90) || (theArrowAngle > 270 && theArrowAngle <= 359))
  {
    printCenteredText(theDistanceStr, 4, 0x07E0);
  }

  // Arrow is pointing down
  else
  {
    printCenteredText(theDistanceStr, 7, 0x07E0);
  }
}