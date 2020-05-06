/**
 scopescreen
 Rein Lenting, Renzo van Haren
 april 2020
 **/
import processing.serial.*;

Serial myPort; //Serial object.
int i, j = 0;  
int x_start = 40; //placement of the scope screen.
int x_end = 1040;
int y_start = 1;
int y_end = 512;
int x_len_data = 10;
int values[] = new int [101];


/**************************************************************************************************************
 *
 *
 **************************************************************************************************************/
void scopeScreen() {
  stroke(255);
  fill(0);
  rect(x_start, y_start, x_end - x_start, y_end - y_start);
  stroke(255);
  for (j = x_start; j <= x_end; j = j + 100)
  {
    line(j, 1, j, 512);
  }
  for ( j = 1; j <= y_end; j += 102.5) {
    line(40, j, 1040, j);
  }
}

void displayValues() {
  int val_low = 1023;
  int val_high = 0;
  int total = 0;
  strokeWeight(3);
  stroke(238, 255, 5);
  fill(238, 255, 5);
  values[100] = values[99];
  for (i = 0; i < values.length - 1; i++){
    line(x_start + x_len_data * i, 512 - values[i] / 2, x_start + x_len_data * (i+1), 512 - values[i +1] / 2);
    val_low = values[i] < val_low ? values[i] : val_low;
    val_high = values[i] > val_high ? values[i] : val_high;
    total += values[i];
  }
  strokeWeight(1);
  
  textAlign(LEFT, TOP);
  fill(51);
  rect(x_start, y_end, 150, 20);
  rect(x_start + 160, y_end, 150, 20);
  fill(238, 255, 5);
  text("pk-pk :" + str(float(val_high - val_low) / 1023 * 5) + "V", x_start, y_end);
  text("avrg  :" + str(float(total) / 102300 * 5) + "V", x_start + 160, y_end);
}

void setup() {
  frameRate(10);
  size( 1300 , 720 );
  background(51);

  //on windows it wil always be Serial.list()[0], might be different on other systems
  String portName = Serial.list()[0];
  println(" port used : " + portName);
  myPort = new Serial(this, portName, 115200);
  myPort.clear();
  myPort.readStringUntil(10);
  initButtons();
  scopeButtons();
  scopeScreen();
}

void draw() {
  String data[] = new String[1];
  while (myPort.available() > 4)
  {
    String input = myPort.readStringUntil(10);              // 100 bytes send as data frame
    if (input != null) 
    {
      input = trim(input);
      data = split(input, ":");
      switch(int(data[0])) {
      case 1055:
        scopeScreen();
        displayValues();
        break;
      default:
        if (data.length > 1) {
          values[int(data[0])] = int(data[1]);
        }
        break;
      }
    }
  }
}
