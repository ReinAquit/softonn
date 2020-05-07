/**
 scopescreen
 Rein Lenting, Renzo van Haren
 april 2020
 **/
import processing.serial.*;

//defines
int x_start = 40; //placement of the scope screen.
int x_end = 1040;
int y_start = 20;
int y_end = 532;
int x_len_data = 10;
int trigger_level = 512;

//global variables
Serial myPort; //Serial object.
int i, j = 0;  
int values[] = new int [101];
int avrg = 0;
int triggerMode = 1;
int calVal = 675;
float calVolt = 3.30;

/**************************************************************************************************************
 *
 *
 **************************************************************************************************************/
void scopeScreen() {
  stroke(255);
  strokeWeight(1);
  fill(0);
  rect(x_start, y_start, x_end - x_start, y_end - y_start);
  stroke(255);
  for (j = x_start; j <= x_end; j = j + 100)
  {
    line(j, y_start, j, y_end);
  }
  for ( j = y_start; j <= y_end; j += 102.5) {
    line(x_start, j, x_end, j);
  }
}

/************
 *
 *
 *
 ************/
void displayValues() {
  int val_low = 1023;
  int val_high = 0;
  int total = 0;
  int pk_pk = 0;
  int avrg_V = 0;
  
  strokeWeight(3);
  stroke(238, 255, 5);
  fill(238, 255, 5);
  values[100] = values[99];
  for (i = 0; i < values.length - 1; i++) {
    line(x_start + x_len_data * i, y_end - values[i] / 2, x_start + x_len_data * (i+1), y_end - values[i +1] / 2);
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
  pk_pk = int(100 * float(val_high - val_low) / calVal * calVolt);
  avrg = total / 100;
  avrg_V = int( 100 * float(avrg) / calVal * calVolt);
  text("peak-peak :" + str(float(pk_pk)/100) + "V", x_start, y_end);
  text("avrg  :" + str(float(avrg_V)/100) + "V", x_start + 160, y_end);
}

void calibrate_values() {
  if (triggerMode == 1)
    calVal = avrg;
}

void setup() {
  frameRate(10);
  size( 1300, 720 );
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
  button b_loop;
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
  b_loop = check_buttons();

  if (b_loop != null) {
    for ( button b : buttons) {
      if (b_loop.command == b.command && b_loop.value != b.value)
        light_out_button(b);
    }
    switch(b_loop.command) {
    case 1:
      triggerMode = b_loop.value;
    case 2:
      myPort.write(Integer.toString(b_loop.command));
      myPort.write(':');
      myPort.write(Integer.toString(b_loop.value));
      myPort.write('\n');
      break;
    case 3:
      trigger_level += b_loop.value;
      println(trigger_level);
      myPort.write(Integer.toString(b_loop.command));
      myPort.write(':');
      myPort.write(Integer.toString(trigger_level));
      myPort.write('\n');
      fill(51);
      noStroke();
      rect(1080, 44 + but_Y_size  + but_spacing, 200, 60);
      textSize(20);
      fill(255);
      textAlign(LEFT, BOTTOM);
      text("trigger level = " + trigger_level, 1080, 45 + but_Y_size * 2 + but_spacing * 2);
      textSize(12);
      break;
    case 4:
      light_out_button(b_loop);
      calibrate_values();
      break;
    default:
      break;
    }
  }
}
