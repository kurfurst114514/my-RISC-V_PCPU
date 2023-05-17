lui x10,0x10000
addi x31,x0,0x7f
slli x31,x31,8
add x10,x10,x31
addi x10,x10,0xd0
add x11,x0,x0
addi x12,x0,3   #high
addi x13,x0,4  #argu1
sw x13,0(x10)
addi x13,x0,3  #argu2
sw x13,4(x10)
addi x13,x0,2   #argu3
sw x13,8(x10)
addi x13,x0,1   #argu4
sw x13,12(x10)
jal x1,sort
loop:
lw x0,0(x10)
lw x0,4(x10)
lw x0,8(x10)
lw x0,12(x10)
j loop

sort: addi sp,sp,-34
   #arr x10
   #low x11
    #high  x12
sw x18,0(sp)
sw x19,4(sp)
sw x20,8(sp)
sw x21,12(sp)
sw x22,16(sp)
sw x23,20(sp)
sw x24,22(sp)
sw x1,26(sp)
sw x25,30(sp)
bge x11,x12,end
add x18,x11,x0   #i
add x19,x12,x0   #j
slli x20,x18,2
add x20,x20,x10
lw x21,0(x20)   #k
while1:
bge x18,x19,end1
while2:
bge x18,x19,end2
slli x20,x19,2
add x20,x20,x10
lw x20,0(x20)  #arr[j]
blt x20,x21,end2
addi x19,x19,-1
j while2
end2:
if2:
bge x18,x19,endif2
slli x22,x18,2
add x22,x10,x22  #*arr[i]
sw x20,0(x22) 
addi x18,x18,1  #i++
endif2:
while3:
bge x18,x19,end3
lw x25,0(x22)
bge x25,x21,end3
addi x18,x18,1
j while3
end3:
if3:
bge x18,x19,endif3
slli x23,x19,2
add x23,x23,x10  #*arr[j]
lw x24,0(x22)
sw x24,0(x23)
addi x19,x19,-1   #j--
j if3
endif3:
j while1
end1:
sw x21,0(x22)
addi x12,x18,-1
jal x1,sort
addi x11,x18,1
jal x1,sort
end:
lw x18,0(sp)
lw x19,4(sp)
lw x20,8(sp)
lw x21,12(sp)
lw x22,16(sp)
lw x23,20(sp)
lw x24,22(sp)
lw x1,26(sp)
lw x25,30(sp)
jalr x0,x1,0


