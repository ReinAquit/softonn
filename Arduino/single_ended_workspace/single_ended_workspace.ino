// arduino single ended oscilloscope program
// J.F. van der Bent April 2020
// used for the introductionlab first year Embedded systems


//storage variables
boolean flag = 1;
boolean toggle = 0;
int sensorValue = 0;

char p,val=128;
unsigned int data[100];


void ACD_init()
{
  ADMUX = (1 << REFS0); //default Ch-0; Vref = 5V
  ADCSRA |= (1 << ADEN) | (0 << ADSC) | (0 << ADATE); //auto-trigger OFF
  ADCSRB = 0x00;
}


void setup()
{
  
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  ACD_init();         // init AD converter channel A0

cli();//stop interrupts

//set timer1 interrupt at 1kHz
  TCCR1A = 0;// set entire TCCR1A register to 0
  TCCR1B = 0;// same for TCCR1B
  TCNT1  = 0;//initialize counter value to 0
  // set compare match register for 1hz increments
  OCR1A = 16000-1;// = (16MHz/1) - 1 = 1kHz
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS10 bit for 0 prescaler
  TCCR1B |=  (1 << CS10);  
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);

sei();//allow interrupts
  DDRD = DDRD | B11111100;

}



ISR(TIMER1_COMPA_vect)
{
  //loads a sample buffer of 100 at 1 sample every 1ms 
  static char count=0;

    while (ADCSRA & (1 << ADSC)); // wait for conversion to complete (long overdue)
   
     data[count]=(ADCL | (ADCH << 8));
     if (count++==100)
       {
              TIMSK1 =0;      //buffer full stop timer interrupt
              flag = 0;       // let the main know that timer is full
              count = 0;
       }
    if (count % 2 > 0)
      PORTD = PORTD | B00000100;
    else
      PORTD = PORTD & B11111011;
 ADCSRA |= (1 << ADSC);                // start a new conversion will take approximately 21us
}


void loop(){
  byte i;
  
  if (!flag)                        // wait for ISR buffer to fill to 100
  {
    
    for (i=0;i<100;i++)
    {
      Serial.println((String(i) + ":" + String(data[i])));      // send 100 points to processing 
    }
    /*
      do                            // trigger level for new screen
      {
     
        ADCSRA |= (1 << ADSC);    // start a new conversion
        while (ADCSRA & (1 << ADSC)); // wait for conversion to complete (long overdue)
        
      }
       
       while((ADCL | (ADCH << 8))!=312);
      */
         TIMSK1 |= (1 << OCIE1A);     //start timer
      
        flag = 1;                     // wait for next full buffer
      Serial.println("1055" );        // special code for processing -- end of dataframe
    PORTD = p++;
  }
 
  
  DDRD = B11111110;                   // sets Arduino pins 1 to 7 as outputs, pin 0 as input
  DDRD = DDRD | B11111100;            // this is safer as it sets pins 2 to 7 as outputs
                                      // without changing the value of pins 0 & 1, which are RX & TX 

  if (p++>32) p=0;

 if (Serial.available()) 
   { // If data is available to read,
     val = Serial.read(); // read it and store it in val
   }

/*
 
   delay(10); // Wait 10 milliseconds for next reading
*/
}
