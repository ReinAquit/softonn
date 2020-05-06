class button {
  int x, y;       //top left corner of the button.
  String text;
  boolean clicked = false;
  byte command;  //the number of the button.
  int value;     // a value that the button might have, like a trigger level of frequentie of the function generator.
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


int but_X_size = 80;
int but_Y_size = 30;
int but_spacing = 20;
/*********************************************************************************************************************
 *
 *
 *********************************************************************************************************************/
void initButtons() {
  buttons[0] = new button(1080, 60, "free run", (byte)1, 1);
  buttons = (button[])append(buttons, new button(1080 + but_X_size + but_spacing, 60, "trigger mode", (byte)2, -1));
}

/*********************************************************************************************************************
 *
 *
 *********************************************************************************************************************/
void scopeButtons() {
  textAlign(CENTER, CENTER);
  for (button b : buttons) {
    stroke(58, 252, 184);
    fill(3, 143, 94);
    rect(b.x, b.y, but_X_size, but_Y_size);
    fill(0);
    text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2);
  }
}

void mousePressed() {
  for (button b : buttons) {
    if (mouseX > b.x && mouseX < b.x + but_X_size) {
      if (mouseY > b.y && mouseY < b.y + but_Y_size) {
        textAlign(CENTER, CENTER);
        b.clicked = !b.clicked;
        stroke(255);
        fill(3, 143, 94);
        rect(b.x, b.y, but_X_size, but_Y_size);
        fill(0);
        text(b.text, b.x + but_X_size / 2, b.y + but_Y_size / 2);
        println(b.text);
      }
    }
  }
}
