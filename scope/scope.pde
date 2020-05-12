/**
 scopescreen
 Rein Lenting, Renzo van Haren
 april 2020
 
 shows integer values coming from a serial interface in a graph
 **/
import processing.serial.*; //Serial read/write

//defines
int x_start = 40;     //placement of the scope screen.
int y_start = 20;
int x_end = 1040;     //end point of the scope screen.
int y_end = 532;
int x_len_data = 10;  //length of the X axis for a data point
float calVolt = 3.30; // the voltage to calibrate to
int probe1 = 0;
int probe2 = 1;

//global variables
Serial myPort;                //Serial object.
int i, j = 0;                 //counters
int values[][] = new int [2][101]; //array that stores the probe values 
int avrg = 0;                 //the average of the 100 values
int triggerMode = 1;          //1 == freerun, 2 == triggerMode
int calVal = 675;             //the calibrate value
int trigger_level = 512;      //default trigger level
int DAC_level = 8;
boolean display_probe1 = true;
boolean display_probe2 = false;

/**************************************************************************************************************
 *scopeScreen: displays the black scope screen area
 *args: none
 *returns: none
 **************************************************************************************************************/
void scopeScreen() {
  stroke(255);      //set the style for the display functions
  strokeWeight(1);
  fill(0);
  rect(x_start, y_start, x_end - x_start, y_end - y_start); //create the black rectangle for the background of the scope

  stroke(255); //make the lines white
  for (j = x_start; j <= x_end; j = j + 100)
    line(j, y_start, j, y_end); // vertical lines
  for ( j = y_start; j <= y_end; j += 102.5) 
    line(x_start, j, x_end, j); //horizontal lines
}

/**************************************************************************************************************
 *display_values: displays the values as a graph on the scope screen area and calculates the avarage and peak-peak values
 *args: none
 *returns: none
 *************************************************************************************************************/
void display_values() {
  color c_probe1 = color(238, 255, 5);
  color c_probe2 = color(15, 255, 239);

  if (display_probe2)
    display_probe(probe2, c_probe2);
  if (display_probe1)
    display_probe(probe1, c_probe1);
  
}

/*************************************************************************************************************************************************
 *display_probe: displays the values of a probe as a graph on the scope screen area and calculates the avarage and peak-peak values for that probe
 *args: int probe
 *returns: none
 *************************************************************************************************************************************************/
void display_probe(int probe, color c) {
  int val_low = 1023;  //value set to max
  int val_high = 0;    //value set to min
  int total = 0;       //total of the probe values
  int pk_pk = 0;       //peak to peak value
  int avrg_V = 0;      //average voltage

  strokeWeight(3);     //set the style for the yellow line
  stroke(c);
  fill(c);
  values[probe][100] = values[probe][99]; //ugly way of handling the last data point
  for (i = 0; i < values[probe].length - 1; i++) {
    line(x_start + x_len_data * i, y_end - values[probe][i] / 2, x_start + x_len_data * (i+1), y_end - values[probe][i +1] / 2); //display the yellow line
    val_low = values[probe][i] < val_low ? values[probe][i] : val_low; //check if the value is lower than the previous lowest value and sets it as the new lowest value
    val_high = values[probe][i] > val_high ? values[probe][i] : val_high; //check if the value is higher than the previous highest value and sets it as the new highest value
    total += values[probe][i]; //ad to the total value
  }
  strokeWeight(1); //set the style for the display values
  textAlign(LEFT, TOP);
  fill(51);
  rect(x_start, y_end + but_spacing * probe, 150, 20);       //clear the spots to display the peak-peak and average values
  rect(x_start + 160, y_end + but_spacing * probe, 150, 20);
  fill(c);
  pk_pk = int(100 * float(val_high - val_low) / calVal * calVolt); // calculate the peak to peak value
  avrg = total / 100; //divide the total by the amount of samples - should be done with a define
  avrg_V = int( 100 * float(avrg) / calVal * calVolt); //calibrate the average
  text("peak-peak :" + str(float(pk_pk)/100) + "V", x_start, y_end + but_spacing * probe); //display the values
  text("avrg  :" + str(float(avrg_V)/100) + "V", x_start + 160, y_end + but_spacing * probe);
}

/**************************************************************************************************************
 *calibrate_values: calibrates the calVal to be set to calVolt.
 *args: none
 *returns: none
 *************************************************************************************************************/
void calibrate_values() {
  if (triggerMode == 1) //check if the scope is in free run mode
    calVal = avrg; //set the calVal to the average of the last measurements
}

void send_command(int c, int value) {
  myPort.write(Integer.toString(c)); //write the values to the serial port
  myPort.write(':');
  myPort.write(Integer.toString(value));
  myPort.write('\n');
}
/**************************************************************************************************************
 *setup: initialises a serial connection
 initialises the buttons and puts them on the screen
 initialises the scope screen
 *args: none
 *returns: none
 *************************************************************************************************************/
void setup() {
  //frameRate(10);
  size( 1300, 800 );
  background(51);

  //on windows it wil always be Serial.list()[0], might be different on other systems
  String portName = Serial.list()[0];
  println(" port used : " + portName);
  myPort = new Serial(this, portName, 115200);
  myPort.clear(); //clear all the messages in the serial port in case there are half messages in there
  myPort.readStringUntil(10);
  init_buttons(); //initialise the buttons and display them
  scope_buttons();
  scopeScreen();  //initialise the scope screen
}

/**************************************************************************************************************
 *draw: checks the serial port if data is available
 -if a command is send handle it
 checks the buttons if any of them is pressed
 -if a button is pressed sends data to the serial port
 *args: none
 *returns: none
 *************************************************************************************************************/
void draw() {
  String data[] = new String[1]; //string to store the incomming data
  button b_loop;  //button object

  while (myPort.available() > 10)  //check if at least 4 bytes are available
  {
    String input = myPort.readStringUntil(10);  // 10 = clear line feed bytes send as data frame
    if (input != null)  //double check if the input is not empty
    {
      input = trim(input);  //trim the data and split it up
      data = split(input, ":");
      switch(int(data[0])) {  //place 0 in the string is the data command send by the arduino
      case 1055:
        scopeScreen();
        display_values();
        println(millis());
        break;
      case 1056:
        if (data.length > 101)
          for (i = 0; i < 100; i++)
            values[int(data[1])][i] = int(data[i+2]);
      default:
        break;
      }
    }
  }
  b_loop = check_buttons(); //check if any buttons have been pressed

  if (b_loop != null) {  //a button has been pressed
    for ( button b : buttons) {
      if (b_loop.command == b.command && b_loop.value != b.value) //check if any other buttons with the same command but different value need to be turned of
        light_out_button(b);
    }
    switch(b_loop.command) {
    case 1: //trigger mode
      triggerMode = b_loop.value;
    case 2: //wave function
      send_command(b_loop.command, b_loop.value);
      break;
    case 3: //trigger level
      trigger_level = constrain(b_loop.value + trigger_level, 0, 1023); //constrain the value between 0 and 1023
      send_command(b_loop.command, trigger_level);
      fill(51); //set the style to display the new trigger level
      noStroke();
      rect(1080, 44 + but_Y_size  + but_spacing, 200, 60);
      textSize(20);
      fill(255);
      textAlign(LEFT, BOTTOM);
      text("trigger level = " + trigger_level, 1080, 45 + but_Y_size * 2 + but_spacing * 2);
      textSize(12);
      break;
    case 4: //calibrate
      light_out_button(b_loop); //puts the light out of the calibrate button
      calibrate_values();  //calibrates the value
      break;
    case 5:
      send_command(b_loop.command, b_loop.value);
      light_out_button(b_loop);

      if (b_loop.value == 0)
        display_probe1 = !display_probe1;
      if (b_loop.value == 1)
        display_probe2 = !display_probe2;
    case 6:
      DAC_level = constrain(b_loop.value + DAC_level, 0, 16);
      println(DAC_level * 0.3125);
      send_command(b_loop.command, DAC_level);
    default:
      break;
    }
  }
}
