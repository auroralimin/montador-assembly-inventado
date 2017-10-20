SECTION DATA
errado1
ADD L1
L2: SPACE
L3: CONST L5
L4: CONST 0
L5: CONST 1

SECTION TEXT
errado2
ADD L
L2: ADD N
CONST 5
jmp L2
jmpn L3
jmpp L2
L: jmpz L3
store L3
input L3
copy L3, L
add L
div L3
div L4
div L5

L2: ADD ok


