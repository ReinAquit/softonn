//defines
int but_X_size = 80;
int but_Y_size = 30;
int but_spacing = 20;

class button {
  int x, y;       //top left corner of the button.
  String text;    //the text to be displayed on the button
  boolean clicked = false;
  byte command;  //the number of the button.
  int value;     // a value that the button might have, like a trigger level or frequentie or the function generator.
  button(int _x, int _y, String _t, byte _c, int _v) {
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
button buttons[] = new button[1];

/*********************************************************************************************************************
 *
 *
 *********************************************************************************************************************/
void initButtons() {
  textSize(20);
  text("mode", 1080, 40);
  buttons[0] = new button(1080, 60, "free run", (byte)1, 1);
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60, "trigger mode", (byte)1, 2));
  //buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * 2 + but_spacing * 2, "square", (byte)2, 1));
  //buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * 2 + but_spacing * 2, "sine", (byte)2, 2));
  //buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * 3 + but_spacing * 3, "sawtooth", (byte)2, 3));
  text("trigger level = " + trigger_level, 1080, 40 + but_Y_size * 2 + but_spacing * 2);
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * 2 + but_spacing * 2, "- 10", (byte)3, -10));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * 2 + but_spacing * 2, "+ 10", (byte)3, 10));
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * 3 + but_spacing * 3, "- 1", (byte)3, -1));
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60 + but_Y_size * 3 + but_spacing * 3, "+ 1", (byte)3, 1));
  text("calibrate", 1080, 40 + but_Y_size * 5 + but_spacing * 5);
  buttons = (button[])append(buttons, new button(1080, 60 + but_Y_size * 5 + but_spacing * 5, "calibrate", (byte)4, -1));
}

/*********************************************************************************************************************
 *
 *
 *********************************************************************************************************************/
void scopeButtons() {
  textAlign(CENTER, CENTER);
  textSize(12);
  for (button b : buttons) {
    strokeWeight(2);
    stroke(58, 252, 184);
    fill(3, 143, 94);
    rect(b.x, b.y, but_X_size, but_Y_size);
    fill(0);
    text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2);
  }
}

/*
*
 */
void light_up_button(button b) {
  textAlign(CENTER, CENTER);
  stroke(255);
  strokeWeight(2);
  fill(3, 143, 94);
  rect(b.x, b.y, but_X_size, but_Y_size);
  fill(0);
  text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2);
}

void light_out_button(button b) {
  textAlign(CENTER, CENTER);
  stroke(58, 252, 184);
  strokeWeight(2);
  fill(3, 143, 94);
  rect(b.x, b.y, but_X_size, but_Y_size);
  fill(0);
  text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2);
}

button check_buttons() {

  for ( button b : buttons) {
    if (b.clicked) {
      b.clicked = false;
      return b;
    }
  }
  return null;
}

/****************************
 *
 *
 */
void mousePressed() {
  for (button b : buttons) {
    if (mouseX > b.x && mouseX < b.x + but_X_size) {
      if (mouseY > b.y && mouseY < b.y + but_Y_size) {
        textAlign(CENTER, CENTER);
        b.clicked = true;
        light_up_button(b);
        println(b.text);
      }
    }
  }
}
