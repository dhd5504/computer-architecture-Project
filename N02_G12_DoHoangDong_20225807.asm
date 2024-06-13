#Dia chi bat dau cua bo nho man hinh
.eqv MONITOR_SCREEN 0x10010000 

#Dia chi bat dau MMIO
.eqv KEY_CODE 0xFFFF0004
.eqv KEY_READY 0xFFFF0000 
#Danh sach mau
.eqv YELLOW 0x00FFFF00
.eqv BLACK 0x00000000
#---------------------------------
.eqv MASK_CAUSE_KEYBOARD 0x0000034 

.text
	li $k0, KEY_CODE
	li $k1, KEY_READY
	li $t0,MONITOR_SCREEN
main:
	# circle:  tam I(a,b) ;bk r
	addi $s1,$0,256 # a 
	addi $s2,$0,256 # b
	addi $s3,$0,15 # r
	
	li $t8,YELLOW # Draw_color
	jal Draw_circle	# ve hinh tron ban dau
	nop
		
	li $a0,100  # 100ms
	li $a1,100
Moving:
	add $a0,$a1,$0 # cap nhap gia tri $a0 sau moi lan ngat
	li $v0, 32 # sleep $a0 ms
	syscall
	
	lw $t1,0($k1) # read
	beq $t1,$0,Continue 
	nop
	
	MakeIntR: 	# Kich hoat ngat mem khi nhan duoc phim
	teqi $t1, 1
	
	Continue:
	beq $t9, 1, Up
	nop
	beq $t9, 2, Down
	nop
	beq $t9, 3, Left
	nop
	beq $t9, 4, Right
	nop
	j Moving
	nop
	
	Up:	
	li $t8,BLACK   
	jal Draw_circle	# delete OLD_Circlev # I , r
	nop
	sub $s2,$s2,1 # y -= 1
	li $t8,YELLOW
	jal Draw_circle  # draw new circle
	nop
	bne $s2,16,Up1
	nop
	# To_Down
	addi $t9,$0,2
	Up1:
	j Moving
	nop
	
	Down:
	li $t8,BLACK
	jal Draw_circle
	nop
	add $s2,$s2,1 # y += 1
	li $t8,YELLOW
	jal Draw_circle
	nop
	bne $s2,495,L2
	nop
	# To_Up
	addi $t9,$0,1
	L2:
	j Moving
	nop
	
	Left:
	li $t8,BLACK
	jal Draw_circle
	nop
	sub $s1,$s1,1 #x -= 1
	li $t8,YELLOW
	jal Draw_circle
	nop
	bne $s1,16,L3 # check
	nop
	# To_Down
	addi $t9,$0,4
	L3:
	j Moving
	nop	
	
	Right:
	li $t8,BLACK
	jal Draw_circle
	nop
	add $s1,$s1,1 # x += 1
	li $t8,YELLOW
	jal Draw_circle
	nop
	bne $s1,495,L4
	nop
	# To_Down
	addi $t9,$0,3
	L4:
	j Moving
	nop
	
Draw_circle:
	# stack
	addi $sp,$sp,-4
	sw $ra,0($sp)
	#draw two circle: r and r + 1
	jal Mid_point
	nop
	addi $s3,$s3,1 # r + 1
	jal Mid_point
	nop
	addi $s3,$s3,-1 # r
	# r_stack
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	nop

Mid_point: #thuat toan Midpoint

	# stack
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	add $t1,$0,$0  # x = 0
	add $t2,$0,$s3 # y = r
	addi $t3,$0,1 
	sub $t3,$t3,$s3 # f = 1 - r
	jal Put8pixel # draw 8 point 
	nop
	While:  
	slt $t4 ,$t1, $t2 # $t4 = 1 if x < y
	beq $t4,$0,EndWhile
	nop
	bgez $t3,Else  # if f >= 0
	nop
	sll $t5,$t1,1
	addi $t5,$t5,3 
	add $t3,$t5,$t3 # f += x*2 + 3
	j L1
	nop
	
	Else:  	
	addi $t2,$t2,-1 # y--
	sub $t5,$t1,$t2 
	sll $t5,$t5,1
	addi $t5,$t5,5
	add $t3,$t3,$t5 # f += (x-y)*2 + 5

	L1:	
	addi $t1,$t1,1
	jal Put8pixel
	nop
	j While
	nop
	EndWhile:	
	# r_stack
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	nop
	
Put8pixel : # 8 diem doi xung
	# stack
	addi $sp,$sp,-4
	sw $ra,0($sp)
	#point 1
	add $t6,$t1,$s1 # x + a
	add $t7,$t2,$s2 # y + b
	jal Draw # draw point
	nop
	#point 2
	sub $t6,$0,$t1
	add $t6,$t6,$s1 # -x + a
	add $t7,$t2,$s2 # y + b
	jal Draw
	nop	
	#point 3
	add $t6,$t1,$s1 # x + a
	sub $t7,$0,$t2 
	add $t7,$t7,$s2 # -y + b
	jal Draw
	nop	
	#point 4
	sub $t6,$0,$t1
	add $t6,$t6,$s1 # -x + a
	sub $t7,$0,$t2 
	add $t7,$t7,$s2 # -y + b
	jal Draw
	nop
	#point 5
	add $t6,$t2,$s1 # y + a
	add $t7,$t1,$s2 # x + b
	jal Draw
	nop
	#point 6
	sub $t6,$0,$t2
	add $t6,$t6,$s1 # -y + a
	add $t7,$t1,$s2 # x + b
	jal Draw
	nop	
	#point 7
	add $t6,$t2,$s1 # y + a
	sub $t7,$0,$t1
	add $t7,$t7,$s2 # -x + b
	jal Draw
	nop
	#point 8
	sub $t6,$0,$t2
	add $t6,$t6,$s1 # -y + a
	sub $t7,$0,$t1
	add $t7,$t7,$s2 # -x + b
	jal Draw
	nop
	# end - r_stack
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	nop
	
Draw:
	# draw input $s1: line $s2 row
	addi $s7,$0,2048
	mult $s7,$t7
	mflo $t7
	sll $t6,$t6,2
	add $s7,$t7,$t6
	add $s7,$t0,$s7 # addr draw
	sw $t8,0($s7) # draw point
	 # end draw
	 jr $ra
	 nop

.ktext 0x80000180
get_cause: 
    	mfc0 $t1, $13
    	
Is_keyboar_interrupt: 
    	li $t2, MASK_CAUSE_KEYBOARD
    	and $at, $t1, $t2
    	beq $at, $t2, Keyboard_Intr
other_cause:
	nop
	j end_process
Keyboard_Intr:
	nop
	lb $t3, 0($k0) #luu ki tu duoc an vao $t3
	#Doi chieu phim duoc an voi cac ki tu w,s,a,d,z,x
	beq $t3, 119, up_direction	# w
	beq $t3, 115, down_direction	# s
	beq $t3, 97, left_direction	# a
	beq $t3, 100, right_direction	# d
	beq $t3, 122, Speed	# z
	beq $t3, 120, Slow	# x
	add $t9,$0,$0
	j end_process
	nop
#--------------------------------------------------
# Gan cac ki tu voi tung so tuong ung de de xu ly
# w --> 1
# s --> 2
# a --> 3
# d --> 4
# ki tu # --> 0
#--------------------------------------------------
	up_direction:
	addi $t9, $zero, 1
	j end_process
	nop
	
	down_direction:
	addi $t9, $zero, 2
	j end_process
	nop
	
	left_direction:
	addi $t9, $zero, 3
	j end_process
	nop
	
	right_direction:
	addi $t9, $zero, 4
	j end_process
	nop
	
	Speed:
	beq $a1,20,end_process
	nop
	addi $a1,$a1,-20
	j end_process
	nop
	
	Slow:
	beq $a1,200,end_process
	nop
	addi $a1,$a1,20
	j end_process
	nop
	
	
end_process:
	mtc0 $zero, $13 	# reset nguyen nhan ngat
next_pc:
	mfc0 $at, $14 		# $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4	# $at = $at + 4 (next instruction)
	mtc0 $at, $14 		# Coproc0.$14 = Coproc0.epc <= $at
return: 
	eret # tro ve 
else:
	jr $ra
	
# co bn diem anh? 192
# ve duong tron bang thuat toan nao? hoc tt
# luu tru du lieu o dau? bang stack
# tang toc nhu the nao? giam thoi gian tre // hoc lai  thoi gian tre
