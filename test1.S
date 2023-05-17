addi x9,x0,1
addi x20,x0,50
addi x22,x0,80
addi x18,x0,420
startcol:addi x9,x9,1
addi x23,x0,0
startnewrow:addi x19,x0,220
startrow:bge x19,x18,endrow

#div x21,x19,x20
add x21,x0,x0
div1:addi x21,x21,1
sub x10,x19,x20
beq x10,x0,div1
add x10,x0,x0

bne x21,x9,white
addi x28,x0,0xff
slli x28,x28,4
addi x28,x28,0xf
sh x28,0(x0)
j endwhite
white:
addi x28,x0,0x000
sh x28,0(x0)
endwhite:
addi x19,x19,1
j startrow
endrow:

#div x24,x23,x22
add x24,x0,x0
div2:addi x24,x24,1
sub x10,x23,x22
beq x10,x0,div2
add x10,x0,x0

bne x24,x0,startcol
addi x23,x23,1
j startnewrow