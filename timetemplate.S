# timetemplate.S
# Written 2015 by F Lundevall
# Ported 2024/06 by W Szczerek (from MIPS to RISC-V)
# Copyright abandonded - this file is in the public domain.

#############################################################
# Choose the macro syntax for RARS or DTEK-V board.         #
# The syntax for RARS is probably due to its MIPS heritage. #
#############################################################
###################
# Macros for RARS #
###################
#.macro	PUSH (%reg)
#	addi	sp,sp,-4
#	sw	%reg,0(sp) 
#.end_macro

#.macro	POP (%reg)
#	lw	%reg,0(sp)
#	addi	sp,sp,4
#.end_macro
###################
# Macros for DTEK #
###################
#.macro	PUSH reg
#	addi sp,sp,-4
#	sw \reg,0(sp) 
#.endm

#.macro	POP reg
#	lw	\reg,0(sp)
#	addi	sp,sp,4
#.endm
#############################################################

	.data
	.align 2
mytime:	.word 	0x5959
timstr:	.asciz 	"text more text lots of text\0"
	.text
	.globl timetemplate, tick, time2string, delay, tick, display_string

# Function for displaying a string with a newline at the end	
display_string:	
	li a7,4
	ecall
	li a0, 10
	li a7,11
	ecall
	jr ra
	
timetemplate:
	la	a0, timstr
	jal     display_string
	
	# wait a little
	li	a0, 1000	# ms
	jal	delay
	
	# call tick
	la 	a0, mytime
	jal	tick
	
	# call your function time2string
	la	a0, timstr
	la	t0, mytime
	lw	a1, 0(t0)
	jal	time2string
	
	# go back and do it all again
	j	timetemplate

	
# tick: update time pointed to by $a0
tick:	lw	t0, 0(a0)	# get time
	addi	t0, t0, 1	# increase
	andi	t1, t0, 0xf	# check lowest digit
	sltiu	t2, t1, 0xa	# if digit < a, okay
	bnez	t2, tiend
	addi	t0, t0, 0x6	# adjust lowest digit
	
	andi	t1, t0, 0xf0	# check next digit
	sltiu	t2, t1, 0x60	# if digit < 6, okay
	bnez	t2, tiend
	addi	t0, t0, 0xa0	# adjust digit
	
	li	t3, 0xF
	slli	t3, t3, 0x8
	and	t1, t0, t3	# check minute digit
	addi	t3, x0, 0xA
	slli	t3, t3, 0x8
	slt	t2, t1, t3	# if digit < a, okay
	bnez	t2, tiend
	addi	t0, t0, 0x600	# adjust digit - this one's okay, it's lower than 0x7FF 
	
	li	t3, 0xF
	slli	t3, t3, 0xC
	and	t1, t0, t3	# check last digit
	addi	t3, x0, 0x6
	slli	t3, t3, 0xC
	slt	t2, t1, t3	# if digit < 6, okay
	bnez	t2, tiend
	
	li	t3, 0xA
	slli	t3, t3, 0xC
	add	t0, t0, t3	# adjust last digit
tiend:	sw	t0,0(a0)	# save updated result
	jr	ra		# return

#########################################################
# Place for your functions: time2string, hex2asc, delay.#
#########################################################


hex2asc:
	li	a0, 4		# test number (from 0 to 15)
	
	addi    sp,sp,-4
	sw      ra,0(sp)
	
	jal	hexasc		# call hexasc
	
	li	a7, 11	        # write a0 to stdout
	ecall

	lw      ra,0(sp)
	addi    sp,sp,4
	jr      ra	
	
 hexasc:
  
  	li   t0, 10	
  	blt  a0, t0, digit 
  	     
    	addi a0, a0, 0x37       
   	jr   ra
  
 digit:
  	addi a0, a0, 0x30     # 0x30 => 0-9
  	      jr   ra


	
delay:
       blez a0, endDelay  # if (ms <= 0) return;
	
while: # # while (ms > 0) {
       addi a0,a0,-1   #   ms = ms - 1;
       li   t0, 0      #   i = 0;       
       li   t1, 100   #   setting the constant
	
for: # (; i < 4711; i++) {
       addi t0, t0, 1 # i++
       blt  t0, t1, for   # if i >= 4711 → break inner 
       bgtz a0, while # if
       
endDelay:
       ret
       
       
time2string:
	addi sp, sp, -4
        sw ra, 0(sp)
        
        addi sp, sp, -4
        sw s0, 0(sp)
        
        addi sp, sp, -4
        sw s1, 0(sp)
        
        

	mv s0, a1        # s0 = time-info
        mv s1, a0        # s1 = destination pointer
        mv t6, s1 

    # extract double digit min
       srli t1, s0, 12
       andi t1, t1, 0xF
       mv a0, t1
       jal hexasc
       sb a0, 0(s1)
       addi s1, s1, 1
	
  # extract single digit min
       srli t1, s0, 8
       andi t1, t1, 0xF
       mv a0, t1
       jal hexasc
       sb a0, 0(s1)
       addi s1, s1, 1
       
   #colon    
       li a0, 0x3A     
       sb a0, 0(s1)
       addi s1, s1, 1
  
  # extract double digit sec
       srli t1, s0, 4
       andi t1, t1, 0xF
       mv a0, t1
       jal hexasc
       sb a0, 0(s1)
       addi s1, s1, 1
       
  # extract single digit sec
      andi t1, s0, 0xF    
      mv a0, t1
      jal hexasc
      sb a0, 0(s1)
      #addi s1, s1, -5 #Jump to begining of string
      
      
  # hour-check
      mv t5, t6
      li t1, '0'
      lb t2, 0(t6)
      
      bne t2, t1, null_colon
      
      addi t6, t6, 1
      li t1, '0'
      lb t2, 0(t6)
      bne t2, t1, null_colon
      
      addi t6, t6, 2
      li t1, '0'
      lb t2, 0(t6)
      bne t2, t1, null_colon
      
      addi t6, t6, 1
      li t1, '0'
      lb t2, 0(t6)
      bne t2, t1, null_colon
      
      #  HOUR
      mv t6, t5
      li t1, 'H'
      sb t1, 0(t6)
      
      addi t6, t6, 1
      li t1, 'O'
      sb t1, 0(t6)
      
      addi t6, t6, 1
      li t1, 'U'
      sb t1, 0(t6)
      
      addi t6, t6, 1
      li t1, 'R'
      sb t1, 0(t6)
      
      addi t6, t6, 1
     
     li a0, 0
     sb a0, 0(t6)
     j end
       

#THIS ONE WORKS FOR normal time
null_colon:
	addi t5, t5, 5
	li a0, 0
	sb a0, 0(t5)
	j end
	           
      
#This one works for "HOUR"

     
end:     
     lw s1, 0(sp)
     addi sp, sp, 4
     
     lw s0, 0(sp)
     addi sp, sp, 4
     
     lw ra, 0(sp)
     addi sp, sp, 4

     jr ra

