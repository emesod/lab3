/* main.c

   This file written 2024 by Artur Podobas and Pedro Antunes

   For copyright and licensing, see file COPYING */

#include <stdint.h>
/* Below functions are external and found in other files. */
extern void print(const char*);
extern void print_dec(unsigned int);
extern void display_string(char*);
extern void time2string(char*,int);
extern void tick(int*);
extern void delay(int);
extern int nextprime( int );

int mytime = 0x0000;
char textstring[] = "text, more text, and even more text!";

int timeoutcount = 0;
int prime = 1234567;

/* Below is the function that will be called when an interrupt is triggered. */
void handle_interrupt(unsigned cause) {

}

/* Add your code here for initializing interrupts. */
void labinit(void){
  int timer_base = 0x04000020;
  int cycles = 3000000;  //30 Mhz * 0.1
  
  volatile unsigned short* period_l = (volatile unsigned short*)(timer_base + 0x08);
  volatile unsigned short* period_h = (volatile unsigned short*)(timer_base + 0x0C);
  *period_l = cycles & 0xFFFF;
  *period_h = (cycles >> 16) & 0xFFFF;

  volatile int* control = (volatile int*) (timer_base + 0x4);
  volatile int* status = (volatile int*) timer_base;

  *status = 0; 
  *control = 6; 
  
  





}

void set_leds(int led_mask){
  volatile int* ledress = (volatile int*) 0x04000000;
  *ledress = led_mask & 0x3FF;
}





static const uint8_t digit_table[10] = {
0b1000000, //0
0b1111001, //1
0b0100100, //2
0b0110000, //3
0b0011001, //4
0b0010010, //5
0b0000010, //6
0b1111000, //7
0b0000000, //8
0b0011000, //9
};



void set_displays(int display_number, int value){
  int first_display = 0x04000050;
  volatile uint8_t* current_disp = (volatile uint8_t*) (first_display + 0x10 * display_number);
  *current_disp = digit_table[value];

}

int get_sw( void ){
  volatile int* toggle_status = (volatile int*) 0x04000010;
  return *toggle_status & 0b1111111111;
}

int get_btn(void){
  volatile int* button_status = (volatile int*) 0x040000d0;
  return *button_status;
}


void set_time(int seconds_passed){
  int seconds = seconds_passed % 60;

  int first_val = seconds % 10; //Get the seconds out
  int second_val = seconds / 10; //Get the 10 seconds out
  
  int minutes_as_seconds = seconds_passed / 60;
  int minutes = minutes_as_seconds % 60;

  int third_val = minutes % 10;
  int fourth_val = minutes / 10;

  
  int hours_as_seconds = seconds_passed / 3600;
  int hours = hours_as_seconds % 24;

  int fifth_val = hours % 10;
  int sixth_val = hours / 10;

  set_displays(0, first_val);
  set_displays(1, second_val);
  set_displays(2, third_val);
  set_displays(3, fourth_val);
  set_displays(4, fifth_val);
  set_displays(5, sixth_val);


}


void switch_to_display(int *seconds_passed, int switches) {
  
  int selector = (switches >> 8) & 0b011;
  int value = switches & 0b111111;

  int seconds = *seconds_passed % 60;
  int minutes = (*seconds_passed / 60) % 60;
  int hours = (*seconds_passed / 3600) % 24;

  if (selector == 1) {        // 01 = seconds
    if (value < 60)
    {
      seconds = value;
    }
    } else if (selector == 2) 
    {
      if (value < 60) 
      {
        minutes = value;
      }
    } else if (selector == 3) 
    { 
        if (value < 24) 
        {
          hours = value;
        }
    }

    *seconds_passed = hours * 3600 + minutes * 60 + seconds;
}


/* Your code goes into main as well as any needed functions. */

int main ( void ) {
    labinit();
    while (1) {
    print (”Prime: ”);
    prime = nextprime( prime );
    print_dec( prime );
    print(”\n”);
    }
}
  



