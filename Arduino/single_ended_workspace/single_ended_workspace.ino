// arduino single ended oscilloscope & andfunction generator program
// used for the introductionlab first year Embedded systems
// 2020 April
// Rein Lenting & Renzo van Haren

//Define the signal output pin
#define PWM_SINUS_OUTPUT_BIT    PIND2   //PWM pin digital 2
#define PROBES 1
#define BUFSIZE 100
#define HALF_BUFSIZE 50
//storage variables
boolean flag = 1;
boolean resetCounter = false;
int bufferFlag = 0;
boolean toggle = 0; //!
unsigned int data[4][100];
String val;
int triggerVal = 512;
bool triggered = false;
char triggerMode = 1;
volatile static char triggerCount = 0;
int waveForm = 1;
bool probeOn[] = {true, true};
String probeData = "1056:0:";
//Degine the types of signals in a lookup table

int signals[4][20] =
{
  { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0
  },  //block
  { 128, 168, 203, 232, 250, 255, 250, 232, 203, 168,
    128,  88,  53,  24,   6,   0,   6,  24,  53,  88
  }, //sinus 128sin(0.1*x*pi)+128
  { 13,  26,  39,  52,  64,  77,  90, 103, 116, 128,
    141, 154, 167, 180, 192, 205, 218, 231, 244, 255
  }, //sawtooth
  { 128,  128,  128,  128,  128,  128,  128, 128, 128, 128,
    128, 128, 128, 128, 128, 128, 128, 128, 128, 128
  } //DAC values
};
//   0    1    2    3    4    5    6    7    8    9


/*********************************************************************************************************
  ADC: Initialize ACD converter
  args: none
  returns: none
**********************************************************************************************************/
void ACD_init()
{
  ADMUX = (1 << REFS0); //default Ch-0; Vref = 5V
  ADCSRA |= (1 << ADEN) | (0 << ADSC) | (0 << ADATE); //auto-trigger OFF
  ADCSRB = 0x00;
}


/*********************************************************************************************************
  setup: Main setup of the program
  args: none
  returns: none
*********************************************************************************************************/
void setup()
{
  //Begin serial comunications
  Serial.begin(115200);

  //Setting pins 13, 2, 3 & 4 as output
  pinMode(13, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);

  // init ADC converter channel A0
  ACD_init();

  cli();//stop interrupts

  //set timer1 interrupt at 1kHz
  TCCR1A = 0;// set entire TCCR1A register to 0
  TCCR1B = 0;// same for TCCR1B
  TCNT1  = 0;//initialize counter value to 0
  // set compare match register for 1hz increments
  OCR1A = 16000 - 1; // = (16MHz/1) - 1 = 1kHz
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS10 bit for 0 prescaler
  TCCR1B |=  (1 << CS10);
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);

  //Setup timer 2 at 25.6kHz
  /*
    16.000.000/8 = 2.000.000 -- prescaler of 8
    2.000.000/25.600 = 78.125
    0.125*25.600 = 3.200
    (3.200/2.000.000)*100 = 0.16%
    Dus 0.16% Fout marge per seconde
  */

  TCCR2A = 0;// set entire TCCR2A register to 0
  TCCR2B = 0;// same for TCCR2B
  TCNT2  = 0;//initialize counter value to 0

  OCR2A = 160 - 1; //Time compare register
  // turn on CTC mode
  TCCR2A |= (1 << WGM21);
  // Set CS21 bit for 8 prescaler
  TCCR2B |=  (1 << CS21);
  // enable timer compare interrupt
  TIMSK2 |= (1 << OCIE2A);

  sei();//allow interrupts

  DDRD |= 1 << (PWM_SINUS_OUTPUT_BIT); // Set output port PIND2 (Arduino board pin 2)
}


//code voor Franc interrupt timer 2 met lookup table
/*********************************************************************************************************
  ISR: Interupt routine timer 2 compare register A
  args: TIMER2_COMPA_vect
  returns: none
**********************************************************************************************************/
//1uF & 10k Ohm
ISR(TIMER2_COMPA_vect)
{
  static long long DACCount = 0;

  if (signals[waveForm][(DACCount >> 8) % 20] > int(DACCount & 255)) // vergelijk de counter met de waarde van de lookup table
  {
    PORTD |= B00000100; //Toggle pin 2 to genarate PWM
  }
  else
  {
    PORTD &= B11111011; //Toggle pin 2 to genarate PWM
  }
  DACCount += 16;

}



/*********************************************************************************************************
  ISR: Interupt routine timer 1 compare register A
  args: TIMER1_COMPA_vect
  returns: none
**********************************************************************************************************/
ISR(TIMER1_COMPA_vect)
{
  //loads a sample buffer of 100 at 1 sample every 1ms
  static char count = 0;

  if (probeOn[0]) {
    ADMUX = (1 << REFS0);                 ////reset ADC multiplexer
    ADCSRA |= (1 << ADSC);                // start a new conversion will take approximately 21us
    while (ADCSRA & (1 << ADSC));         //wait for conversion to complete (long overdue)
    data[bufferFlag][count] = int(ADCL | (ADCH << 8));
  }

  //Load data in array
  //if(probeOn[1]){
  //ADMUX |= B00000001;                   //set ADC multiplexer
  //ADCSRA |= (1 << ADSC);                // start a new conversion will take approximately 21us
  //while (ADCSRA & (1 << ADSC));
  //data[bufferFlag + 1][count] = int(ADCL | (ADCH << 8));
  //}

  //Checking is the trigger mode is in trigger mode
  if (triggerMode == 2) {
    if (data[bufferFlag][count] >= triggerVal && triggered == false) {    //When the data value is higher than the trigger value then thrigger once
      triggered = true;                                       //Triggerd
      triggerCount = count;                                   //set trigger count
    }

    //Resetting counter back to 0 when it hits 100
    if (count++ == BUFSIZE || resetCounter) {
      count = 0;
      resetCounter = false;
    }

    //Check is the buffer count is 50 point above trigger count
    if ((triggered == true) && (count == (triggerCount + HALF_BUFSIZE) % BUFSIZE)) {
      TIMSK1 = 0;     //buffer full stop timer interrupt
      flag = 0;       //let the main know that timer is full
      count = 0;      //Counter back to 0
      digitalWrite(13, LOW); //Writing low to pin 13 (LED)
    }

  }
  //Chekcing if triggermode is free running
  else if (triggerMode == 1) {
    if (count++ == BUFSIZE)
    {
      TIMSK1 = 0;     //buffer full stop timer interrupt
      flag = 0;       //let the main know that timer is full
      count = 0;      //Counter back to 0
    }
  }
}


/*********************************************************************************************************
  Loop: Main program loop
  args: none
  returns: none
**********************************************************************************************************/
void loop()
{
  byte i, j; //Index, byte becouse it is used in a string function


  if (!flag)                        // wait for ISR buffer to fill to 100
  {

    if (triggerMode == 1) {
      TIMSK1 |= (1 << OCIE1A);     //start timer
      bufferFlag = (bufferFlag == 2) ? 0 : 2;
    }

    flag = 1;                     // wait for next full buffer
    for (j = 0; j < PROBES; j++) {
      probeData[5] = '0' + j;
      //Loop trough the buffer
      for (i = 0; i < BUFSIZE; i++)
      {
        if (triggerMode == 2) //Checking if trigger mode is in trigger mode
        {
          probeData += data[bufferFlag + j] [(i + triggerCount + 50) % 100];     // send 100 points to processing/ scope
          probeData += ":";
          data[bufferFlag + j][(i + triggerCount + 50) % 100] = 0; //Setting all the values back to 0
        }
        if (triggerMode == 1) //Checking if trigger mode in free running
        {
          probeData += data[2 - bufferFlag + j][i];
          probeData += ":";
        }
      }
      Serial.println(probeData);
      probeData.remove(7, probeData.length());
      probeData.trim();
    }
    triggerCount = 0;             //Reset trigger count
    Serial.println("1055");      // special code for processing -- end of dataframe
  }


  //Checking if data is availeble to read
  if (Serial.available())
  {

    //init vars for recieving data
    String sub_val;
    int value;

    //read the recieved string and store it in val
    val = Serial.readString();

    //Remove all the spaces
    val.trim();

    //snip the data on ":"
    sub_val = val.substring(val.indexOf(':') + 1);

    //change the var sub_var to int and move it in to value
    value = sub_val.toInt();

    //switch case for handeling commands, commands are always at spot val "0"
    switch (val[0]) {
      case '1': //trigger on
        cli();
        if (value == 1) {
          triggerMode = 1;
          TIMSK1 |= (1 << OCIE1A);     //start timer
          digitalWrite(13, LOW);
        }       //Free running mode
        else if (value == 2) {
          triggerMode = 2;
          TIMSK1 |= (1 << OCIE1A);     //start timer
          triggered = false;           //Not so triggerd
          resetCounter = true;

          digitalWrite(13, HIGH);     //Set LED high to display trigger active
        }
        sei();
        break;
      case '2': //Switching wave form code
        waveForm = value;
        
        break;
      case '3': //switching tigger mode
        triggerVal = value;
        
        break;
      case '5':
        probeOn[value] = !probeOn[value];
        
      case '6':
        for (i = 0; i < 20; i++)
          signals[3][i] = (value << 4);
          
      default:
        break;      //I want to break free
    }
  }
}
