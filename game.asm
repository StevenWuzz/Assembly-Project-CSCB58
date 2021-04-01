# Bitmap display starter code 
#
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 ($gp) 
#
.data 
ship: .space 4 
obs1: .space 4
obs2: .space 4
obs3: .space 4
.eqv BASE_ADDRESS 0x10008000 
.text 
	
init: 	
	la $t8, ship
	li $t0, BASE_ADDRESS # $t0 stores the base address for display 
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t3, 0x000000
	li $t4, 0x808080
	addi $t2, $0, 1920
	sw $t2, 0($t8)
	
	li $v0, 42
	li $a0, 0
	li $a1, 960
	syscall
	li $t7, 4
	mult $a0, $t7
	mflo $a0
	
	la $t8, obs1
	add $t2, $0, $a0
	sw $t2, 0($t8)
	
	jal draw_obstacle1
	jal draw_ship
	j main_loop
	j end
	
main_loop:
	jal move_obstacle1
	jal check_input
	j main_loop
	
reset_ship:
	la $t8, ship
	lw $s0, 0($t8)
	add $s2, $s0, $t0
	sw $t3, 0($s2)
	sw $t3, 4($s2)
	sw $t3, 128($s2)
	sw $t3, 132($s2)
	jr $ra	
	
draw_ship:
	la $t8, ship
	lw $s0, 0($t8)
	add $s1, $s0, $t0
	sw $t1, 0($s1)
	sw $t1, 4($s1)
	sw $t1, 128($s1)
	sw $t1, 132($s1)
	jr $ra	
	
draw_obstacle1:
	la $t8, obs1
	lw $s0, 0($t8)
	add $s1, $s0, $t0
	sw $t4, 0($s1)
	sw $t4, 4($s1)
	sw $t4, 128($s1)
	sw $t4, 132($s1)
	jr $ra
	
reset_obstacle1:
	la $t8, obs1
	lw $s0, 0($t8)
	add $s1, $s0, $t0
	sw $t3, 0($s1)
	sw $t3, 4($s1)
	sw $t3, 128($s1)
	sw $t3, 132($s1)
	jr $ra	

move_obstacle1:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal reset_obstacle1
	la $t8, obs1
	lw $s0, 0($t8)
	addi $s1, $s0, -4
	sw $s1, 0($t8)
	jal draw_obstacle1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
			
check_input:
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened
	
return_to_loop:
	jr $ra
	
keypress_happened:
	lw $t2, 4($t9)
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x64, respond_to_d
	beq $t2, 0x70, end
	
respond_to_w:
	la $t8, ship
	lw $s0, 0($t8)
	
	addi $s1, $s0, -128
	blt $s1, $0, return_to_loop
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal reset_ship
	sw $s1, 0($t8)
	jal draw_ship
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j return_to_loop
	
respond_to_a:
	la $t8, ship
	lw $s0, 0($t8)
	
	li $s1, 128
	div $s0, $s1
	mfhi $s3
	beq $s3, 0, return_to_loop
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal reset_ship
	addi $s1, $s0, -4
	sw $s1, 0($t8)
	jal draw_ship
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j return_to_loop

respond_to_s:
	la $t8, ship
	lw $s0, 0($t8)
	
	addi $s1, $s0, 128
	li $s3, 3964
	bgt $s1, $s3, return_to_loop
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal reset_ship
	sw $s1, 0($t8)
	jal draw_ship
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j return_to_loop
	
respond_to_d:
	la $t8, ship
	lw $s0, 0($t8)
	addi $s1, $s0, 4
	sw $s1, 0($t8)
	jal draw_ship
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j return_to_loop		
			
end: 	
	li $v0, 10 # terminate the program gracefully
	syscall
