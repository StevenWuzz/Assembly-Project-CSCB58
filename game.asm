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
bar: .space 4
damage: .word 0
score: .word 0
waiting_time: .word 0
count: .word 0
threshold: .word 0
.eqv BASE_ADDRESS 0x10008000 
.text 
	
init: 	
	li $t0, BASE_ADDRESS 	# $t0 stores the base address for display 
	li $t1, 0xff0000 	# $t1 stores the red colour code
	li $t3, 0x000000	# $t3 stores the black colour code
	li $t4, 0x808080	# $t4 stores the grey colour code
	li $t6, 0x00ffff00	# $t6 stores the yellow colour code
	li $t5, 0x00ffffff      # $t5 stores the white colour code
	
	la $t8, ship 		# load the address of the ship object
	li $t2, 1920		# set y coordinate to be at the middle of the screen, 
				# and x coordinate to be at the most left of the screen
				 
	sw $t2, 0($t8)		# set the position above as the initial location of the ship
	jal draw_ship		# draw the ship
	
	la $t8, bar		# load the address of the health bar
	li $t2, 180		# set the offset for the position of the bar
	sw $t2, 0($t8)		# store that offset into the address of the bar
	jal draw_health_bar	# draw the health bar 
	
	la $t8, score		# load the address of score variable
	sw $0, 0($t8)		# initialize the score to 0
	
	la $t8, count		# load the address of count variable 
	sw $0, 0($t8)		# initialize the count to 0
	
	la $t8, threshold	# load the address of threshold variable
	li $s0, 10		# initialize the threshold to 10
	sw $s0, 0($t8)
	
	la $t8, waiting_time	# load the address of waiting_time variable
	li $t9, 70		# initialize the waiting time to 0.07 seconds 
	sw $t9, 0($t8) 
	
	jal obstacle_random_position1	# generate a random position for the first obstacle
	la $t8, obs1			# load the address of the first obstacle
	sw $a0, 0($t8)			# set the random position as the initial location of the first obstacle
	jal draw_obstacle1		# draw the first obstacle
	
	jal obstacle_random_position2 	# generate a random position for the second obstacle
	la $t8, obs2			# load the address of the second obstacle
	sw $a0, 0($t8)			# set the random position as the initial location of the second obstacle
	jal draw_obstacle2		# draw the second obstacle
	
	jal obstacle_random_position3	# generate a random position for the third obstacle
	la $t8, obs3			# load the address of the third obstacle
	sw $a0, 0($t8)			# set the random position as the initial location of the third obstacle
	jal draw_obstacle3		# draw the third obstacle
	
	j main_loop			# directly jump to the main loop
	j end	
	
obstacle_random_position1:
	li $v0, 42			# generate a random number
	li $a0, 0
	li $a1, 7			# set the upper bound to be 7
	syscall
	
	addi $a0, $a0, 3		# add the generated random number by 3 to create some space at the top for the health ba
	
	li $s1, 128			# position = 120 + 128 * random number
	mult $s1, $a0
	mflo $a0
	addi $a0, $a0, 120
	
	jr $ra				# go back to the original calling location
	
obstacle_random_position2:
	li $v0, 42			# generate a random number				
	li $a0, 0			
	li $a1, 10			# set the upper bound to be 10
	syscall
	
	addi $a0, $a0, 10		# add the generated random number by 10 to get into the middle range 
	
	li $s1, 128			# position = 120 + 128 * random number
	mult $s1, $a0
	mflo $a0
	addi $a0, $a0, 120
	
	jr $ra				# go back to the original calling location
	
obstacle_random_position3:
	li $v0, 42			# generate a random number
	li $a0, 0
	li $a1, 10			# set the upper bound to be 10
	syscall
	
	addi $a0, $a0, 20		# add the generated random number by 20 to get into the last range 
	
	li $s1, 128			# position = 120 + 128 * random number
	mult $s1, $a0
	mflo $a0
	addi $a0, $a0, 120
	
	jr $ra				# go back to the original calling location
	
main_loop:
	jal check_input			# check for the keyboard input
	
	jal check_collision_obstacle1	# check for collisions between the fist obstacle and the ship
	jal move_obstacle1		# move the first obstacle one step to the left
	jal check_collision_obstacle2	# check for collisions between the second obstacle and the ship
	jal move_obstacle2		# move the second obstalce one step to the left
	jal check_collision_obstacle3	# check for collisions between the third obstacle and the ship
	jal move_obstacle3		# move the third obstacle one step to the left
	
	la $t8, count			# load the address of count variable
	lw $t9, 0($t8)			# load the value of count 
	
	la $t8, threshold		# load the address of threshold variable
	lw $s5, 0($t8)			# load the value of threshold
	bge $t9, $s5, decrease_waiting_time	# if the count is at least as big as the threshold, then decrease the waiting time

	li $v0, 32 			# otherwise, just sleep the program for "waiting_time" miliseconds
	la $s3, waiting_time
	lw $s4, 0($s3)
	add $a0, $0, $s4
	syscall
	
	j main_loop			# jump back to the main loop to keep on looping 
	
decrease_waiting_time:
	li $v0, 32 			
	la $s6, waiting_time		# load the address of the waiting_time variable
	lw $s7, 0($s6)			# load the value of waiting_time
	
	li $s5, 5			
	sub $t9, $s7, $s5		# decrease the waiting time by 5 
	sw $t9, 0($s6)			# store the reduced value to waiting_time variable
	add $a0, $0, $t9		# now sleep the program with the new waiting_time variable
	
	la $t9, threshold		# load the address of the threshold variable
	lw $t8, 0($t9)			# load the value of the threshold
	addi $t8, $t8, 10		# increase the threshold by 10 
	sw $t8, 0($t9)			# store the increased threshold value back to threshold variable
	
	la $t8, count			# load the address of count variable
	sw $0, 0($t8)			# reset the count back to 0
	
	syscall
	
	j main_loop			# jump back tot the main loop to keep on looping

reset_ship:
	la $t8, ship			# load the address of the ship
	lw $s0, 0($t8)			# load the offset from the address of the ship
	add $s2, $s0, $t0		# add the current position to the base address and store it in $s2
	sw $t3, 0($s2)			# remove the ship by painting the current position as black 
	sw $t3, 4($s2)			
	sw $t3, 128($s2)
	sw $t3, 132($s2)
	jr $ra				# go back to the caller 
	
draw_ship:
	la $t8, ship			# load the address of the ship
	lw $s0, 0($t8)			# store the desired offset for the position of the ship
	add $s1, $s0, $t0		# add the offset to the base address to get the actual position of the ship
	sw $t1, 0($s1)			# draw the ship at that position
	sw $t1, 4($s1)
	sw $t1, 128($s1)
	sw $t1, 132($s1)
	jr $ra				# go back to the caller
	
draw_obstacle1:
	la $t8, obs1			# load the address of the first obstacle
	lw $s0, 0($t8)			# store the desired offset for the position of the first obstacle
	add $s2, $s0, $t0		# add the offset to the base address to get the actual position of the first obstacle
	sw $t4, 0($s2)			# draw the first obstacle at that position
	sw $t4, 4($s2)
	sw $t4, 128($s2)
	sw $t4, 132($s2)
	jr $ra				# go back to the caller
	
draw_obstacle2:
	la $t8, obs2			# load the address of the second obstacle
	lw $s0, 0($t8)			# store the desired offset for the position of the second obstacle
	add $s2, $s0, $t0		# add the offset to the base address to get the actual position of the second obstacle
	sw $t4, 0($s2)			# draw the second obstacle at that position
	sw $t4, 4($s2)			
	sw $t4, 128($s2)
	sw $t4, 132($s2)
	jr $ra				# go back to the caller
	
draw_obstacle3:
	la $t8, obs3			# load the address of the third obstacle
	lw $s0, 0($t8)			# store the desired offset for the position of the third obstacle
	add $s2, $s0, $t0		# add the offset to the base address to get the actual position of the third obstacle
	sw $t4, 0($s2)			# draw the third obstacle at that position
	sw $t4, 4($s2)
	sw $t4, 128($s2)
	sw $t4, 132($s2)
	jr $ra				# go back to the caller
	
draw_health_bar:
	la $t8, bar			# load the address of the health bar
	lw $s0, 0($t8)			# load the offset from the address of the health bar
	add $s2, $s0, $t0		# add the offset to the base address to get the actual position of the health bar
	sw $t1, 0($s2)			# draw the health bar which consists of 5 bars
	sw $t1, 4($s2)
	sw $t1, 8($s2)
	sw $t1, 12($s2)
	sw $t1, 16($s2)
	jr $ra				# go back to the caller	
	
reset_health_bar:
	la $t8, bar			# load the address of the health bar
	lw $s0, 0($t8)			# load the offset value from the address of the health bar
	add $s2, $s0, $t0		# add the offset to the base address to get the actual position of the health bar
	
	sw $t3, 0($s2)			# turn each bar into black color
	sw $t3, 4($s2)
	sw $t3, 8($s2)
	sw $t3, 12($s2)
	sw $t3, 16($s2)
	
	la $t7, damage			# load the address of the damage
	sw $0, 0($t7)			# reset the damage's count back to 0
	
	jr $ra				# go back to the caller
	
reset_obstacle1:
	la $t8, obs1			# load the address of the first obstacle
	lw $s0, 0($t8)			# store the desired offset for the position of the third obstacle
	add $s1, $s0, $t0		# add the offset to the base address to get the actual position of the third obstacle
	sw $t3, 0($s1)			# reset the current position of the first obstacle by turning it to black
	sw $t3, 4($s1)
	sw $t3, 128($s1)
	sw $t3, 132($s1)
	jr $ra				# go back to the caller
	
reset_obstacle2:
	la $t8, obs2			# load the address of the second obstacle
	lw $s0, 0($t8)			# store the desired offset for the position of the second obstacle
	add $s1, $s0, $t0		# add the offset to the base address to get the actual position of the second obstacle
	sw $t3, 0($s1)			# reset the current position of the second obstacle by turning it to black
	sw $t3, 4($s1)
	sw $t3, 128($s1)
	sw $t3, 132($s1)
	jr $ra				# go back to the caller
	
reset_obstacle3:
	la $t8, obs3			# load the address of the third obstacle
	lw $s0, 0($t8)			# store the desired offset for the position of the third obstacle
	add $s1, $s0, $t0		# add the offset to the base address to get the actual position of the third obstacle
	sw $t3, 0($s1)			# reset the current position of the third obstacle by turning it to black
	sw $t3, 4($s1)
	sw $t3, 128($s1)
	sw $t3, 132($s1)
	jr $ra				# go back to the caller

move_obstacle1:
	addi $sp, $sp, -4		# make space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	jal reset_obstacle1		# call the function to turn the current position of the first obstacle into black
	la $t8, obs1			# load the address of the first obstacle
	lw $s0, 0($t8)			# store the desired offset 
	
	li $s1, 128			# checking for the left boundary of the screen
	div $s0, $s1
	mfhi $s3
	beq $s3, 0, generate_new_obstacle1	# if the first obstacle is out of the left boundary, then generate a new obstacle 
	j move_obstacle1_left			# finally, call the function to move the current position of the first obstacle to the left
	
move_obstacle2:
	addi $sp, $sp, -4		# make a new space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	jal reset_obstacle2		# call the function to turn the current position of the second obstacle into black
	la $t8, obs2			# load the address of the second obstacle
	lw $s0, 0($t8)			# store the desired offset 
	
	li $s1, 128			# checking for the left boundary of the screen
	div $s0, $s1
	mfhi $s3
	beq $s3, 0, generate_new_obstacle2	# if the second obstacle is out of the left boundary, then generate a new obstacle 
	j move_obstacle2_left			# finally, call the function to move the current position of the second obstacle to the left
	
move_obstacle3:
	addi $sp, $sp, -4		# make a new space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	jal reset_obstacle3		# call the function to turn the current position of the third obstacle into black
	la $t8, obs3			# load the address of the third obstacle
	lw $s0, 0($t8)			# store the desired offset
		
	li $s1, 128			# checking for the left boundary of the screen
	div $s0, $s1
	mfhi $s3
	beq $s3, 0, generate_new_obstacle3	# if the third obstacle is out of the left boundary, then generate a new obstacle 
	j move_obstacle3_left			# finally, call the function to move the current position of the third obstacle to the left
	
move_obstacle1_left:	
	addi $s1, $s0, -4		# move the current position of the first obstacle to the left
	sw $s1, 0($t8)			# store that new position of the first obstacle
	jal draw_obstacle1		# draw the new first obstacle at that new position
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back	
	jr $ra				# go back to the caller
	
move_obstacle2_left:	
	addi $s1, $s0, -4		# move the current position of the second obstacle to the left
	sw $s1, 0($t8)			# store that new position of the second obstacle
	jal draw_obstacle2		# draw the new second obstacle at that new position
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back	
	jr $ra				# go back to the caller
	
move_obstacle3_left:	
	addi $s1, $s0, -4		# move the current position of the third obstacle to the left
	sw $s1, 0($t8)			# store that new position of the third obstacle
	jal draw_obstacle3		# draw the new third obstacle at that new position
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back	
	jr $ra				# go back to the caller
	
generate_new_obstacle1:
	jal obstacle_random_position1	# call the function to generate random position for the first obstacle
	add $s0, $0, $a0		# transfer that random position to $s0
	addi $s0, $s0, 4		# set back the first obstacle to the right by one position
	
	la $s3, score			# load the address of the score
	lw $s4, 0($s3)			# load the current score 
	addi $s4, $s4, 1		# increase the score by 1 point
	sw $s4, 0($s3)			# store the increased score back to the score variable
	
	la $s3, count			# load the address of the count
	lw $s4, 0($s3)			# load the current count
	addi $s4, $s4, 1		# increase the count by 1 
	sw $s4, 0($s3)			# store the increased count back to the count variable
	
	j move_obstacle1_left		# now move the first obstacle to the left

generate_new_obstacle2:
	jal obstacle_random_position2	# call the function to generate random position for the second obstacle
	add $s0, $0, $a0		# transfer that random position to $s0
	addi $s0, $s0, 4		# set back the second obstacle to the right by one position
	
	la $s3, score			# load the address of the score
	lw $s4, 0($s3)			# load the current score 
	addi $s4, $s4, 1		# increase the score by 1 point
	sw $s4, 0($s3)			# store the increased score back to the score variable
	
	la $s3, count			# load the address of the count
	lw $s4, 0($s3)			# load the current count
	addi $s4, $s4, 1		# increase the count by 1 
	sw $s4, 0($s3)			# store the increased count back to the count variable
	
	j move_obstacle2_left		# now move the second obstacle to the left
	
generate_new_obstacle3:
	jal obstacle_random_position3	# call the function to generate random position for the third obstacle
	add $s0, $0, $a0		# transfer that random position to $s0
	addi $s0, $s0, 4		# set back the third obstacle to the right by one position
	
	la $s3, score			# load the address of the score
	lw $s4, 0($s3)			# load the current score 
	addi $s4, $s4, 1		# increase the score by 1 point
	sw $s4, 0($s3)			# store the increased score back to the score variable
	
	la $s3, count			# load the address of the count
	lw $s4, 0($s3)			# load the current count
	addi $s4, $s4, 1		# increase the count by 1 
	sw $s4, 0($s3)			# store the increased count back to the count variable
	
	j move_obstacle3_left		# now move the third obstacle to the left
			
check_input:
	li $t9, 0xffff0000 		# check for an input to the keyboard
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened	# if there is an input, execute keypress_happened
	
return_to_loop:
	jr $ra
	
keypress_happened:
	lw $t2, 4($t9)		
	beq $t2, 0x77, respond_to_w	#if the input was w, then execute respond_to_w
	beq $t2, 0x61, respond_to_a	#if the input was a, then execute respond_to_a
	beq $t2, 0x73, respond_to_s	#if the input was s, then execute respond_to_s
	beq $t2, 0x64, respond_to_d	#if the input was d, then execute respond_to_d
	beq $t2, 0x70, restart		#if the input was p, then execute restart to restart the game

restart:
	jal reset_ship			# call the function to reset the current position of the ship
	jal reset_obstacle1		# call the function to reset the current position of the first obstacle
	jal reset_obstacle2		# call the function to reset the current position of the second obstacle
	jal reset_obstacle3		# call the function to reset the current position of the third obstacle
	jal reset_health_bar		# call the function to reset the health bar
	
	la $t7, score			# load the address of the score
	sw $0, 0($t7)			# reset the score back to 0
	
	la $t7, count			# load the address of the count
	sw $0, 0($t7)			# reset the count back to 0
	
	li $v0, 32 			# sleep the game for 0.6 seconds
	li $a0, 600
	syscall
	
	j init				# jump back to the initial state of the game
	
respond_to_w:
	la $t8, ship			# load the address of the ship
	lw $s0, 0($t8)			# load the offset stored in the address of the ship
	
	addi $s1, $s0, -128		# attempt to move the ship upward
	blt $s1, $0, return_to_loop	# if the ship goes beyond the upper boundary of the screen, then execute return_to_loop instead
	
	addi $sp, $sp, -4		# otherwise, make a new space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	
	jal reset_ship			# call the function to reset the position of the ship
	sw $s1, 0($t8)			# store the offset for moving the ship upward into the address of the ship
	jal draw_ship			# move the ship upward
	
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back
	j return_to_loop		# jump to return_to_loop
	
respond_to_a:
	la $t8, ship			# load the address of the ship
	lw $s0, 0($t8)			# load the offset stored in the address of the ship
	
	li $s1, 128			# attempt to move the ship to the left
	div $s0, $s1
	mfhi $s3
	beq $s3, 0, return_to_loop	# if the ship goes beyond the left boundary of the screen, then execute return_to_loop instead
	
	addi $sp, $sp, -4		# otherwise, make a new space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	
	jal reset_ship			# call the function to reset the current position of the ship
	addi $s1, $s0, -4		# store the offset to move the ship to the right in $s1
	sw $s1, 0($t8)			# store the offset into the address of the ship
	jal draw_ship			# call the function to draw the new position of the ship
	
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back
	j return_to_loop		# jump to return_to_loop

respond_to_s:
	la $t8, ship			# load the address of the ship
	lw $s0, 0($t8)			# load the offset stored in the address of the ship
	
	addi $s1, $s0, 124		# attempt to move the ship downward
	li $s3, 3964
	bgt $s1, $s3, return_to_loop	# if the ship goes beyond the bottom boundary of the screen, then execute return_to_loop instead
	
	addi $sp, $sp, -4		# otherwise, make a new space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	
	jal reset_ship			# call the function to reset the current position of the ship
	sw $s1, 0($t8)			# store the offset to move the ship downward in the address of the ship
	jal draw_ship			# call the function to draw the new position of the ship
	
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back	
	
respond_to_d:
	la $t8, ship			# load the address of the ship
	lw $s0, 0($t8)			# load the offset stored in the address of the ship
	
	li $s1, 128			# attempt to move the ship to the right
	addi $s4, $s0, 8
	div $s4, $s1
	mfhi $s3
	beq $s3, 0, return_to_loop	# if the ship goes beyond the right boundary of the screen, then execute return_to_loop instead
	
	addi $sp, $sp, -4		# otherwise, make a new space in the stack
	sw $ra, 0($sp)			# push $ra to the stack
	
	jal reset_ship			# call the function to reset the current position of the ship
	addi $s1, $s0, 4		# store the offset to move the ship to the right in $s1
	sw $s1, 0($t8)			# transfer the offset to move the ship to the right to the address of the ship
	jal draw_ship			# call the function to draw the new position of the ship
	
	lw $ra, 0($sp)			# pop $ra off the stack
	addi $sp, $sp, 4		# claim the space back
	j return_to_loop		# jump to return_to_loop
	
check_collision_obstacle1:
	la $t8, ship			# load the address of the ship
	la $t7, obs1			# load the address of the first obstacle
	lw $s0, 0($t8)			# load the offset stored in the address of the ship
	lw $s7, 0($t7)			# load the offset stored in the address of the first obstacle
	
	beq $s0, $s7, indicate_collision1	# check if the ship's top-left position overlaps with the first obstacle's top-left position
	addi $s6, $s7, 4			
	beq $s0, $s6, indicate_collision1	# check if the ship's top-left position overlaps with the first obstacle's top-right position
	addi $s6, $s7, 128
	beq $s0, $s6, indicate_collision1	# check if the ship's top-left position overlaps with the first obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s0, $s6, indicate_collision1	# check if the ship's top-left position overlaps with the first obstacle's bottom-right position
	
	addi $s5, $s0, 4			
	beq $s5, $s7, indicate_collision1	# check if the ship's top-right position overlaps with the first obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision1	# check if the ship's top-right position overlaps with the first obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision1	# check if the ship's top-right position overlaps with the first obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision1	# check if the ship's top-right position overlaps with the first obstacle's bottom-right position
	
	
	addi $s5, $s0, 128			
	beq $s5, $s7, indicate_collision1	# check if the ship's bottom-left position overlaps with the first obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision1	# check if the ship's bottom-left position overlaps with the first obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision1	# check if the ship's bottom-left position overlaps with the first obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision1	# check if the ship's bottom-left position overlaps with the first obstacle's bottom-right position
	
	addi $s5, $s0, 132			
	beq $s5, $s7, indicate_collision1	# check if the ship's bottom-right position overlaps with the first obstacle's top-left position
	addi $s6, $s7, 4			
	beq $s5, $s6, indicate_collision1	# check if the ship's bottom-right position overlaps with the first obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision1	# check if the ship's bottom-right position overlaps with the first obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision1	# check if the ship's bottom-right position overlaps with the first obstacle's bottom-right position
	
	jr $ra					# go back to the caller
	
check_collision_obstacle2:
	la $t8, ship				# load the address of the ship
	la $t7, obs2				# load the address of the second obstacle
	lw $s0, 0($t8)				# load the offset stored in the address of the ship
	lw $s7, 0($t7)				# load the offset stored in the address of the second obstacle
	
	beq $s0, $s7, indicate_collision2	# check if the ship's top-left position overlaps with the second obstacle's top-left position
	addi $s6, $s7, 4
	beq $s0, $s6, indicate_collision2	# check if the ship's top-left position overlaps with the first obstacle's top-right position
	addi $s6, $s7, 128
	beq $s0, $s6, indicate_collision2	# check if the ship's top-left position overlaps with the first obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s0, $s6, indicate_collision2	# check if the ship's top-left position overlaps with the first obstacle's bottom-right position
	
	addi $s5, $s0, 4
	beq $s5, $s7, indicate_collision2	# check if the ship's top-right position overlaps with the second obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision2	# check if the ship's top-right position overlaps with the second obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision2	# check if the ship's top-right position overlaps with the second obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision2	# check if the ship's top-right position overlaps with the second obstacle's bottom-right position
	
	addi $s5, $s0, 128
	beq $s5, $s7, indicate_collision2	# check if the ship's bottom-left position overlaps with the second obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision2	# check if the ship's bottom-left position overlaps with the second obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision2	# check if the ship's bottom-left position overlaps with the second obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision2	# check if the ship's bottom-left position overlaps with the second obstacle's bottom-right position
	
	addi $s5, $s0, 132			
	beq $s5, $s7, indicate_collision2	# check if the ship's bottom-right position overlaps with the second obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision2	# check if the ship's bottom-right position overlaps with the second obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision2	# check if the ship's bottom-right position overlaps with the second obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision2	# check if the ship's bottom-right position overlaps with the second obstacle's bottom-right position
	
	jr $ra					# go back to the caller
	
check_collision_obstacle3:
	la $t8, ship				# load address of the ship
	la $t7, obs3				# load address of the third obstacle
	lw $s0, 0($t8)				# load the offset stored in the address of the ship
	lw $s7, 0($t7)				# load the offset stored in the address of the second obstacle 
	
	beq $s0, $s7, indicate_collision3	# check if the ship's top-left position overlaps with the third obstacle's top-left position
	addi $s6, $s7, 4
	beq $s0, $s6, indicate_collision3	# check if the ship's top-left position overlaps with the third obstacle's top-right position
	addi $s6, $s7, 128
	beq $s0, $s6, indicate_collision3	# check if the ship's top-left position overlaps with the third obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s0, $s6, indicate_collision3	# check if the ship's top-left position overlaps with the third obstacle's bottom-right position
	
	addi $s5, $s0, 4
	beq $s5, $s7, indicate_collision3	# check if the ship's top-right position overlaps with the third obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision3	# check if the ship's top-right position overlaps with the third obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision3	# check if the ship's top-right position overlaps with the third obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision3	# check if the ship's top-right position overlaps with the third obstacle's bottom-right position
	
	addi $s5, $s0, 128
	beq $s5, $s7, indicate_collision3	# check if the ship's bottom-left position overlaps with the third obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision3	# check if the ship's bottom-left position overlaps with the third obstacle's top-right position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision3	# check if the ship's bottom-left position overlaps with the third obstacle's bottom-left position
	addi $s6, $s7, 132
	beq $s5, $s6, indicate_collision3	# check if the ship's bottom-left position overlaps with the third obstacle's bottom-left position
	
	addi $s5, $s0, 132
	beq $s5, $s7, indicate_collision3	# check if the ship's bottom-right position overlaps with the third obstacle's top-left position
	addi $s6, $s7, 4
	beq $s5, $s6, indicate_collision3	# check if the ship's bottom-right position overlaps with the third obstacle's top-right position
	addi $s6, $s7, 124
	beq $s5, $s6, indicate_collision3	# check if the ship's bottom-right position overlaps with the third obstacle's bottom-left position
	addi $s6, $s7, 128
	beq $s5, $s6, indicate_collision3	# check if the ship's bottom-right position overlaps with the third obstacle's bottom-right position				
	
	jr $ra					# go back to the caller  

indicate_collision1:
	addi $sp, $sp, -4			# make a new space in the stack
	sw $ra, 0($sp)				# push $ra into the stack
	
	jal reset_obstacle1			# call the function to reset the current position of the first obstacle 
	jal reset_ship				# call the function to reset the current position of the ship
	jal draw_collision			# call the function to draw the ship with different color to indicate collision
	jal reduce_health
	
	li $v0, 32 				# sleep the program for 0.9 seconds
	li $a0, 900
	syscall
	
	jal draw_ship				# call the function to draw the ship again with the original color
	
	jal obstacle_random_position1		# call the function to generate new random position for the first obstacle after the collision 
	la $t7, obs1				# load the address of the first obstacle 
	sw $a0, 0($t7)				# store the new random position into the address of the first obstacle
	jal draw_obstacle1			# call the function to draw a new first obstacle 
	
	lw $ra, 0($sp)				# pop $ra off the stack
	addi $sp, $sp, 4			# claim the space back
	
	jr $ra					# jump to the caller	
	
indicate_collision2:
	addi $sp, $sp, -4			# make a new space in the stack
	sw $ra, 0($sp)				# push $ra into the stack 
	
	jal reset_obstacle2			# call the function to reset the current position of the second obstacle
	jal reset_ship				# call the function to reset the current position of the ship
	jal draw_collision			# call the function to draw the ship with different color to indicate collision
	jal reduce_health
	
	li $v0, 32 				# sleep the program for 0.9 seconds
	li $a0, 900
	syscall
	
	jal draw_ship				# call the function to draw the ship again with the original color
	
	jal obstacle_random_position2		# call the function to generate new random position for the second obstacle after the collision
	la $t7, obs2				# load the address of the first obstacle 
	sw $a0, 0($t7)				# store the new random position into the address of the second obstacle
	jal draw_obstacle2			# call the function to draw a new second obstacle
	
	lw $ra, 0($sp)				# pop $ra off the stack
	addi $sp, $sp, 4			# claim the space back
	
	jr $ra					# go back to the caller
	
indicate_collision3:
	addi $sp, $sp, -4			# make a new space in the stack
	sw $ra, 0($sp)				# push $ra into the stack
		
	jal reset_obstacle3			# call the function to reset the current position of the third obstacle
	jal reset_ship				# call the fucntion to reset the current position of the ship
	jal draw_collision			# call the function to draw the ship with different color to indicate collision
	jal reduce_health
	
	li $v0, 32 				# sleep the program for 0.9 seconds
	li $a0, 900
	syscall
	
	jal draw_ship				# call the function to draw the ship again with the original color
	
	jal obstacle_random_position3		# call the function to generate new random position for the third obstacle after the collision
	la $t7, obs3				# load the address of the third obstacle
	sw $a0, 0($t7)				# store the new random position into the address of the third obstacle 
	jal draw_obstacle3			# call the function to draw a new third obstacle	
	
	lw $ra, 0($sp)				# pop $ra off the stack
	addi $sp, $sp, 4			# claim the space back
	
	jr $ra					# go back to the caller

draw_collision:
	add $s3, $s0, $t0			# add the desired offset to the base address to get the current position of the ship
	sw $t6, 0($s3)				# draw the ship with different color to indicate collision
	sw $t6, 4($s3)
	sw $t6, 128($s3)
	sw $t6, 132($s3)
	
	jr $ra					# go back to the caller
	
reduce_health:
	la $t8, bar				# load  the address of the bar 
	lw $s0, 0($t8)				# load the offset from the address of the ship
	add $s1, $s0, $t0			# add the offset to the base address to get the actual position of the health bar
	
	la $t7, damage				# load the address of the damage
	lw $s3, 0($t7)				# load the value of the damage
	addi $s3, $s3, 1			# increment the damage's count
	sw $s3, 0($t7)				# store the new damage's count back to variable damage
	
	sw $t3, 0($s1)				# turn the left-most pixel of the health bar into black
	li $s2, 5				
	beq $s3, $s2, game_over

	addi $s0, $s0, 4			# the health bar now starts at the next available pixel
	sw $s0, 0($t8)				# store the next available pixel's offset into the address of the ship
	
	jr $ra					# go back to the caller
	
game_over:
	jal reset_ship				# call the function to reset the position of the ship 
	jal reset_health_bar			# call the function to reset the position of the health bar
	jal reset_obstacle1			# call the function to reset the position of the first obstacle
	jal reset_obstacle2			# call the function to reset the position of the second obstacle
	jal reset_obstacle3			# call the function to reset the position of the third obstacle
	
	la $t7, score				# load the address of the score
	sw $0, 0($t7)				# reset the score count back to 0
	
	la $t7, count				# load the address of the count
	sw $0, 0($t7)				# reset the count back to 0
	
	jal draw_and_remove_RIP			# call the function to display "game over" screen
	
	j init 					# jump back to the initial state of the game
	
draw_and_remove_RIP:
	li $s0, 1832				# draw the letter 'R' 
	addi $s1, $s0, 128
	addi $s2, $s0, 4
	addi $s3, $s0, 256
	addi $s4, $s0, 384
	
	add $s0, $s0, $t0
	sw $t5, 0($s0)
	add $s1, $s1, $t0
	sw $t5, 0($s1)
	add $s2, $s2, $t0
	sw $t5, 0($s2)
	add $s3, $s3, $t0
	sw $t5, 0($s3)
	add $s4, $s4, $t0
	sw $t5, 0($s4)
	
	
	li $s0, 1844				# draw the letter 'I'
	addi $s1, $s0, 128
	addi $s2, $s0, 256
	addi $s3, $s0, 384
	
	add $s0, $s0, $t0
	sw $t5, 0($s0)
	add $s1, $s1, $t0
	sw $t5, 0($s1)
	add $s2, $s2, $t0
	sw $t5, 0($s2)
	add $s3, $s3, $t0
	sw $t5, 0($s3)
	
	
	li $s0, 1852				# draw the letter 'P'
	addi $s1, $s0, 128
	addi $s2, $s0, 256
	addi $s3, $s0, 384
	addi $s4, $s0, 4
	addi $s5, $s0, 8
	addi $s6, $s0, 136
	addi $s7, $s0, 264
	addi $t9, $s0, 260
	addi $t8, $s0, 256
	
	add $s0, $s0, $t0
	sw $t5, 0($s0)
	add $s1, $s1, $t0
	sw $t5, 0($s1)
	add $s2, $s2, $t0
	sw $t5, 0($s2)
	add $s3, $s3, $t0
	sw $t5, 0($s3)
	add $s4, $s4, $t0
	sw $t5, 0($s4)
	add $s5, $s5, $t0
	sw $t5, 0($s5)
	add $s6, $s6, $t0
	sw $t5, 0($s6)
	add $s7, $s7, $t0
	sw $t5, 0($s7)
	add $t9, $t9, $t0
	sw $t5, 0($t9)
	add $t8, $t8, $t0
	sw $t5, 0($t8)
	
	li $v0, 32 				# sleep the game for 0.9 seconds
	li $a0, 900
	syscall
	
	li $s0, 1832				# erase the letter 'R'
	addi $s1, $s0, 128
	addi $s2, $s0, 4
	addi $s3, $s0, 256
	addi $s4, $s0, 384
	
	add $s0, $s0, $t0
	sw $t3, 0($s0)
	add $s1, $s1, $t0
	sw $t3, 0($s1)
	add $s2, $s2, $t0
	sw $t3, 0($s2)
	add $s3, $s3, $t0
	sw $t3, 0($s3)
	add $s4, $s4, $t0
	sw $t3, 0($s4)
	
	li $s0, 1844				# erase the letter 'I'
	addi $s1, $s0, 128
	addi $s2, $s0, 256
	addi $s3, $s0, 384
	
	add $s0, $s0, $t0
	sw $t3, 0($s0)
	add $s1, $s1, $t0
	sw $t3, 0($s1)
	add $s2, $s2, $t0
	sw $t3, 0($s2)
	add $s3, $s3, $t0
	sw $t3, 0($s3)
	
	
	li $s0, 1852				# erase the letter 'P'
	addi $s1, $s0, 128
	addi $s2, $s0, 256
	addi $s3, $s0, 384
	addi $s4, $s0, 4
	addi $s5, $s0, 8
	addi $s6, $s0, 136
	addi $s7, $s0, 264
	addi $t9, $s0, 260
	addi $t8, $s0, 256
	
	add $s0, $s0, $t0
	sw $t3, 0($s0)
	add $s1, $s1, $t0
	sw $t3, 0($s1)
	add $s2, $s2, $t0
	sw $t3, 0($s2)
	add $s3, $s3, $t0
	sw $t3, 0($s3)
	add $s4, $s4, $t0
	sw $t3, 0($s4)
	add $s5, $s5, $t0
	sw $t3, 0($s5)
	add $s6, $s6, $t0
	sw $t3, 0($s6)
	add $s7, $s7, $t0
	sw $t3, 0($s7)
	add $t9, $t9, $t0
	sw $t3, 0($t9)
	add $t8, $t8, $t0
	sw $t3, 0($t8)
	
	jr $ra					# go back to the caller
	
end: 	
	li $v0, 10 # terminate the program gracefully
	syscall
