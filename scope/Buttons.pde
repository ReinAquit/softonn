//defines
int but_X_size = 80;  //pre defined size of a button
int but_Y_size = 30;
int but_spacing = 20; //spacing between buttons 

/***********************************************************************
*button class: stores all the data of a button in a class
***********************************************************************/
class button {
  int x, y;       //top left corner of the button.
  String text;    //the text to be displayed on the button
  boolean clicked = false; //flag clicked
  byte command;  //the command of the button. is a byte because it is send in a string function
  int value;     // a value that the button might have, like a trigger level or frequentie or the function generator.
  
  button(int _x, int _y, String _t, byte _c, int _v) { //init for a button
    x = _x;
    y = _y;
    text = _t;
    command = _c;
    value = _v;
  }
  
  button(int _x, int _y, String _t, byte _c) { //init for if a value isn't needed.
    x = _x;
    y = _y;
    text = _t;
    command = _c;
    value = -1;
  }
}
button buttons[] = new button[1]; //empty array of buttons

/*********************************************************************************************************************
 *init_buttons: initialises the buttons and places them at the end of the buttons array
 *args: none
 *returns: none
 *********************************************************************************************************************/
void init_buttons() {
  int but_row = 1;
  textSize(20);  //set the style for the button text
  text("mode", 1080, 40);
  buttons[0] = new button(1080, 60, "free run", (byte)1, 1); //first button is initialised different due to the way processing works with arrays
  //format for putting more buttons in the array:
  //the button array |   (cast to button array) |processing array function( |the array to append to   |new button object( button syntax ) );
  //buttons          | = (buttons[])            |append(                    |buttons                  |new button(  top_left_x, top_left_y, "text to be displayed", (byte)command, value) );
  //buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60, "trigger mode", (byte)1, 2));
    
  /*
  text("trigger level = " + trigger_level, 1080, 40 + but_Y_size * ++but_row + but_spacing * but_row);
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * but_row + but_spacing * but_row, "- 10", (byte)3, -10));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * but_row + but_spacing * but_row++, "+ 10", (byte)3, 10));
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * but_row + but_spacing * but_row, "- 1", (byte)3, -1));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * but_row + but_spacing * but_row++, "+ 1", (byte)3, 1));
  */
  text("calibrate", 1080, 40 + but_Y_size * ++but_row + but_spacing * but_row);
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * but_row + but_spacing * but_row++, "calibrate", (byte)4, -1));
  
  /*
  text("wave function", 1080, 40 + but_Y_size * ++but_row + but_spacing * but_row);
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * but_row + but_spacing * but_row, "square", (byte)2, 0));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * but_row + but_spacing * but_row++, "sine", (byte)2, 1));
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * but_row + but_spacing * but_row, "sawtooth", (byte)2, 2));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * but_row + but_spacing * but_row++, "DAC", (byte)2, 3));
  
  text("DAC level = ", 1080, 40 + but_Y_size * ++but_row + but_spacing * but_row);
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * but_row + but_spacing * but_row, "- 0.3125", (byte)6, -1));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * but_row + but_spacing * but_row++, "+ 0.3125", (byte)6, 1));
  */
}

/*********************************************************************************************************************
 *scope_buttons: displays the buttons on the screen
 *args: none
 *returns: none
 *********************************************************************************************************************/
void scope_buttons() {
  textAlign(CENTER, CENTER); //set the style for the display functions
  textSize(12);
  for (button b : buttons) { //for each loop to go through the buttons
     light_out_button(b); //display the buttons
  }
}

/************************************************************************************************************************
*light_up_button: puts a white border around a button the show it was clicked on
*args: button b - the button that will be highlighted
*returns: none
************************************************************************************************************************/
void light_up_button(button b) {
  textAlign(CENTER, CENTER); //set the style for the highlighted button
  stroke(255);
  strokeWeight(2);
  fill(3, 143, 94);
  rect(b.x, b.y, but_X_size, but_Y_size); //display the button
  fill(0);
  text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2); //display the text of the button
}

/************************************************************************************************************************
*light_out_button: removes the white border around a button
*args: button b - the button that will be returned to normal
*returns: none
************************************************************************************************************************/
void light_out_button(button b) {
  textAlign(CENTER, CENTER); //set the style for the button
  stroke(58, 252, 184);
  strokeWeight(2);
  fill(3, 143, 94);
  rect(b.x, b.y, but_X_size, but_Y_size); //display the button
  fill(0);
  text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2); //display the text of the button
}

/************************************************************************************************************************
*check_button: checks if any of the buttons have been pressed
                 if multiple buttons have been pressed it wil return the first one in the array that has been pressed
*args: none
*returns: the button that has been pressed
************************************************************************************************************************/
button check_buttons() {
  for ( button b : buttons) { //for each loop to go through all the buttons
    if (b.clicked) { //check if they have been clicked
      b.clicked = false; //remove the clicked flag
      return b;  //return the clicked button
    }
  }
  return null; //if no buttons have been clicked return null
}

/************************************************************************************************************************
*mousePressed: processing API funtion that works like an interrupt every time a mouse button has been pressed
*args: none
*returns: none
************************************************************************************************************************/
void mousePressed() {
  for (button b : buttons) { //for each loop to go through all the buttons
    if (mouseX > b.x && mouseX < b.x + but_X_size) {   //check if the click was inside the button area
      if (mouseY > b.y && mouseY < b.y + but_Y_size) {
        b.clicked = true;    //set clicked flag true
        light_up_button(b);  //highlight the button that was clicked
        println(b.text);     //debug output for wich button was clicked
      }
    }
  }
}
