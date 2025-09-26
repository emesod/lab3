/* main.c

   This file written 2024 by Artur Podobas and Pedro Antunes

   For copyright and licensing, see file COPYING */

#include<stdint.h>
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

/* Below is the function that will be called when an interrupt is triggered. */
void handle_interrupt(unsigned cause) 
{}

/* Add your code here for initializing interrupts. */
void labinit(void)
{}

void set_leds(int led_mask){
  volatile int* ledress = (volatile int*) 0x04000000;
  *ledress = led_mask & 0x3FF;
}

static const uint8_t digit_table[10] = {
0b1000000,
0b1111001,
0b0100100,
0b0110000,
0b0011001,
0b0010010,
0b00000010,
0b1111000,
0b0000000,
0b0011000
};

void set_displays(int display_number, int value){
  int first_display = 0x04000050;
  volatile uint8_t* current_disp = (volatile uint8_t*) (first_display + 0x10 * display_number);
  *current_disp = digit_table[value];

}

int get_sw( void ){
  volatile int* toggle_status = (volatile int*) 0x04000010;
  return *toggle_status & 0x3FF;
}

int get_btn(void){
  volatile int* button_status = (volatile int*) 0x040000d0;
  return *button_status;
}
/* Your code goes into main as well as any needed functions. */
int main() {
  // Call labinit()
  labinit();
  int bina = 0;

  // Enter a forever loop
  while (1) {
    time2string( textstring, mytime ); // Converts mytime to string
    display_string( textstring ); //Print out the string 'textstring'
    delay( 125000 );          // Delays 1 sec (adjust this value)
    tick( &mytime );     // Ticks the clock once
    set_displays(bina ,bina);
    bina++;
    if(bina==16){
      break;
    }
  }
}


