SECTION DATA
errado1
ADD L1
L2: SPACE
L3: CONST L5

SECTION TEXT
errado2
ADD L
L2: ADD N
CONST 5
jmp L2
jmpn L3
jmpp L2
jmpz L3

L2: ADD ok


