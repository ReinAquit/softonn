// arduino single ended oscilloscope program
// J.F. van der Bent April 2020
// used for the introductionlab first year Embedded systems

#define PWM_SINUS_OUTPUT_BIT    PIND2   // PWM pin

//storage variables
boolean flag = 1;
boolean toggle = 0;
int sensorValue = 0;
char p;
unsigned int data[100];
String val;
int triggerVal = 512;
bool triggered = false;
char triggerMode = 1;
volatile static char triggerCount = 0;
int waveForm = 1;
uint8_t signals[3][20] =
{
  { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0
  },  //block
  { 128, 168, 203, 232, 250, 255, 250, 232, 203, 168,
    128,  88,  53,  24,   6,   0,   6,  24,  53,  88
  }, //sinus 128sin(0.1*x*pi)+128
  { 13,  26,  39,  52,  64,  77,  90, 103, 116, 128,
    141, 154, 167, 180, 192, 205, 218, 231, 244, 255
  } //sawtooth
};
//   0    1    2    3    4    5    6    7    8    9

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
  pinMode(13, OUTPUT);
  ACD_init();         // init AD converter channel A0

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


  //Setup timer 2 at 256kHz
  /*
    16.000.000/256.000 = 62.5
    0.5*256.000 = 128.000
    (128.000/16.000.000)*100 = 0.8%
    Dus 0.8% Fout marge per seconde
  */

  //code voor Franc interrupt timer 2 instellen
  /*
    TCCR2A = 0;// set entire TCCR2A register to 0
    TCCR2B = 0;// same for TCCR2B
    TCNT2  = 0;//initialize counter value to 0

    OCR2A = 63 - 1; //Time compare register
    // turn on CTC mode
    TCCR2A |= (1 << WGM20);
    // Set CS20 bit for 0 prescaler
    TCCR2B |=  (1 << CS21);
    // enable timer compare interrupt
    TIMSK2 |= (1 << OCIE2A);
  */
  sei();//allow interrupts
  DDRD |= 1 << (PWM_SINUS_OUTPUT_BIT); // Set output port PINB3 (Arduino board pin 11)
}

//code voor Franc interrupt timer 2 met lookup table
/*
  ISR(TIMER2_COMPA_vect)
  {
  static long long DACCount = 0;
  PORTB |= B00100000;
  if(signals[waveForm][(DACCount >> 8) % 20] > uint8_t(DACCount & 255)) // vergelijk de counter met de waarde van de lookup table
  {
    PORTD |= B00001100; //Toggle pin 2 & 3 to genarate PWM
  }
  else
  {
    PORTD &= B11110011; //Toggle pin 2 & 3 to genarate PWM
  }
  DACCount++;

  PORTB &= ~B00100000;
  }
*/

ISR(TIMER1_COMPA_vect)
{
  //loads a sample buffer of 100 at 1 sample every 1ms
  static char count = 0;

  ADCSRA |= (1 << ADSC);                // start a new conversion will take approximately 21us
  while (ADCSRA & (1 << ADSC)); // wait for conversion to complete (long overdue)

  data[count] = int(ADCL | (ADCH << 8));

  if (triggerMode == 2) {
    if (data[count] >= triggerVal && triggered == false) {
      triggered = true;
      triggerCount = count;
    }
    
    if (count++ == 100)
      count = 0;
      
    if (triggered == true && (count % 50) == (triggerCount % 50)) {
      TIMSK1 = 0;     //buffer full stop timer interrupt
      flag = 0;       // let the main know that timer is full
      count = 0;
      digitalWrite(13, LOW);
    }

  }
  else if (triggerMode == 1) {
    if (count++ == 100)
    {
      TIMSK1 = 0;     //buffer full stop timer interrupt
      flag = 0;       // let the main know that timer is full
      count = 0;
    }
  }

  if (count % 20 > 9)
    PORTD |= 1 << (PWM_SINUS_OUTPUT_BIT);
  else
    PORTD &= ~(1 << (PWM_SINUS_OUTPUT_BIT));
}


void loop() {
  byte i;
  if (!flag)                        // wait for ISR buffer to fill to 100
  {

    for (i = 0; i < 100; i++)
    {
      if (triggerMode == 2) {
        Serial.println((String((i + 50) % 100) + ":" + String(data[(i + triggerCount) % 100])));      // send 100 points to processing
        data[(i + triggerCount) % 100] = 0;
      }
      if (triggerMode == 1) {

        TIMSK1 |= (1 << OCIE1A);     //start timer
        Serial.println((String(i) + ":" + String(data[i])));
      }

    }

    triggerCount = 0;
    flag = 1;                     // wait for next full buffer
    Serial.println("1055" );        // special code for processing -- end of dataframe
  }

  if (Serial.available())
  { // If data is available to read,

    String sub_val;
    int value;
    val = Serial.readString(); // read it and store it in val
    val.trim();
    sub_val = val.substring(val.indexOf(':') + 1);
    value = sub_val.toInt();
    switch (val[0]) {
      case '1':

        if (value == 1) {
          triggerMode = 1;
          TIMSK1 |= (1 << OCIE1A);     //start timer
          digitalWrite(13, LOW);
        }
        else if (value == 2) {
          triggerMode = 2;
          TIMSK1 |= (1 << OCIE1A);     //start timer
          triggered = false;

          triggerCount = 0;
          digitalWrite(13, HIGH);
        }

        break;
      case '2':
        waveForm = value;
        break;
      case '3':
        triggerVal = value;
        break;
      case '4':
        break;
    }

    sei();//allow interrupts
  }
}
