movi.d r0 1 
movi.d r1 0
add.d r1 r1 r0 
addi.d r0 r0 1 
cmpi r0 10 
brnz -4 
movi.d r3 1020
stw r1 r3 2 
halt 
