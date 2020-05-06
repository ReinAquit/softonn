/**
Scopescreen
j.f. van der Bent
april 2020
revision log:
21 april added trigger output
 */


import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int count,i,j = 0;
int adval,oldval,calval=0;
boolean flag = false;
int trig=128;
int[] numbers = new int[102];


void setup() 
{
  size(1040, 710);
  background(255);
  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  print(" port used : " + portName);
  myPort = new Serial(this, portName, 115200);
}

void keyPressed() {

if (key == 'c') 
  {
    text("Calibrate -- connect A0 to 3.3Volt ", 50, 630);
   calval = adval;
   
  }
if (key == '+') 
  {
     trig = trig+1;   
    if (trig >255) trig = 255;    
    myPort.write(trig);
  }
if (key == '-') 
  {
    trig = trig-1;   
    if (trig <0) trig = 0;
    myPort.write(trig);
        
  }
}

void draw()
{

  while (myPort.available() > 0)
  {
    
      String input = myPort.readStringUntil(10);              // 100 bytes send as data frame
      if (input != null) 
      {
  
 
        input = trim(input);
      
        int intConv = int(input);
               if (i==1)
        {
          stroke(128);
          background(255);
          line(2,512-trig*2,30,512-trig*2);
          line(40,1,1014,1);
          for(j=40;j<1014;j=j+100)
          {
            line(j,1,j,512);
          }
     
          line(40,102,1014,102);
          line(40,205,1014,205);
          line(40,307,1014,307);
          line(40,410,1014,410);
          line(1014,1,1014,512);      
          line(40,1,40,512);
                 
          
          line(40,512,1014,512);
          fill(0);  
          text("Last value of A0 is " + input + " --> " + str((3.30/calval)*intConv - (3.30/calval)*intConv%0.1) + "V", 50, 530);
          text("trigger level (0 = freerunning) =  " + str((5.0/256)*trig - (5.0/256)*trig%0.1),50,540);
        }
           if (intConv == 1055)                               // end of data code send by Arduino
        {
          count = 0;
          i=0;
         fill(255);
         flag = true; 
        
        }
        adval = intConv;
        intConv= intConv/2;
        stroke(0); 
        if (flag && count>30) line (count,512-oldval,count+10,512-intConv);
      //  numbers[i] = intConv;                              // save old value to wipe next screen
        count=count+10;
       
        i++;
    
       
        oldval = intConv;
    }
   
 }
   
   
   
}
