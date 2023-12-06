#include <stdio.h> 


#include <stdio.h>  // Standard I/O  

#include <stdio.h>  // Standard I/O  
#include <sys/_types.h>

// Define memory-mapped GPIO addresses
#define GPIO2_IN            0x80001800
#define GPIO2_INOUT         0x80001808
#define VGA_ROW_COL         0x80001500  // VGA row/column address
#define VGA_DATA            0x80001504


// Define button masks
#define BTNL_MASK           0x01  // BTNL is the least significant bit
#define BTNR_MASK           0x02  // BTNR is the second least significant bit
//define BTNU_MASK          0x04  // BTNU is the third least significant bit

// Move distance
#define CAR_MOVE_DISTANCE   8


// Lane boundary
#define MAX_LEFT_LANE       ((405 << 10) | 130)
#define MAX_RIGHT_LANE      ((405 << 10) | 475) 
 
// Read and write operations
#define READ_PERIPHERAL(dir) (*(volatile unsigned *)(dir))
#define WRITE_PERIPHERAL(dir, value) { (*(volatile unsigned *)(dir)) = (value); }

// function for delay
void delay_counter(unsigned int Counter_Max) {
    unsigned int counter = 0;

    while (counter < Counter_Max) { 
      counter = counter + 1;
    }
    return;
}


int main(void) {
    unsigned int car_horizontal_pos = 405 << 10| 305; // Initial car position
    unsigned int En_Value = 0x0000; // Enable value to set GPIO module to input mode for buttons
    unsigned int Counter_Max = 10000;
    unsigned int print;
    

    // Initialize GPIO2 to input mode for buttons
    WRITE_PERIPHERAL(GPIO2_INOUT, En_Value);
    En_Value = car_horizontal_pos;
    WRITE_PERIPHERAL(VGA_ROW_COL, En_Value);
    

    while (1) {
        // Check BTNL - if pressed, move car left
        if (READ_PERIPHERAL(GPIO2_IN) & BTNL_MASK) {
            
            if (car_horizontal_pos > MAX_LEFT_LANE) {
                car_horizontal_pos = car_horizontal_pos - CAR_MOVE_DISTANCE;
            }
            else if  (car_horizontal_pos <= MAX_LEFT_LANE) {
                  car_horizontal_pos = MAX_LEFT_LANE;
            }
            En_Value = car_horizontal_pos;          
            WRITE_PERIPHERAL(VGA_ROW_COL, En_Value);
            
        }

        // Check BTNR - if pressed, move car right
        else if (READ_PERIPHERAL(GPIO2_IN) & BTNR_MASK) {
            
            // Assuming 640 is the max screen width
            if (car_horizontal_pos < MAX_RIGHT_LANE) { // 32 is the car width
                car_horizontal_pos = car_horizontal_pos + CAR_MOVE_DISTANCE;
                
            }
            else if(car_horizontal_pos >= MAX_RIGHT_LANE){
             car_horizontal_pos = MAX_RIGHT_LANE;
        }
            En_Value = car_horizontal_pos;
            WRITE_PERIPHERAL(VGA_ROW_COL, En_Value);
            
        }
        /*else if (READ_PERIPHERAL(GPIO2_IN) & BTNR_MASK){
          if (MAX_LEFT_LANE <= car_horizontal_pos <= MAX_RIGHT_LANE){
            car_horizontal_pos = 405 << 10| 305; //initial value
          } 
          En_Value = car_horizontal_pos;
          WRITE_PERIPHERAL(VGA_ROW_COL, En_Value);
        }
        */

        else {
          En_Value = car_horizontal_pos;
          WRITE_PERIPHERAL(VGA_ROW_COL, En_Value);
          
          
        }
        delay_counter(Counter_Max);
  }

return 0;
}
