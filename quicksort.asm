sort: addi sp,sp,-26
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
bge x11,x12,end
add x18,x11,x0   #i
add x19,x12,x0   #j
slli x20,x10,2
add x20,x20,x10
lw x21,0(x20)   #k
while1:
bge x18,x19,end1
while2:
beq x18,x19,end2
slli x20,x19,2
add x20,x20,x10
lw x20,0(x20)  #arr[j]
blt x20,x21,end2:
addi x19,x19,-1
j while2
end2:
if2:
bge x18,x19,endif2
addi x18,x18,1  #i++
slli x22,x18,2
add x22,x10,x22  #*arr[i]
j if2
sw x20,0(x22)   
endif2:
while3:
bge x18,x19,end3
bge x22,x21,end3
addi x18,x18,1
j while3
end3:
if3:
bge x18,x19,endif3
addi x19,x19,-1   #j--
slli x23,x19,2
add x23,x23,x10  #*arr[j]
lw x24,0(x22)
sw x24,0(x23)
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
jalr x0,0(x1)


