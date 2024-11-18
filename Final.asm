include macros2.asm
include number.asm
.MODEL LARGE    ; Modelo de Memoria
.386            ; Tipo de Procesador
.STACK 200h     ; Bytes en el Stack

.DATA 

a                                       dd                            ?                             
b                                       dd                            ?                             
c                                       dd                            ?                             
x                                       dd                            ?                             
y                                       dd                            ?                             
variable1                               dd                            ?                             
variable2                               dd                            ?                             
i                                       dd                            ?                             
j                                       dd                            ?                             
p1                                      dd                            ?                             
p2                                      dd                            ?                             
p3                                      dd                            ?                             
mensaje                                 dd                            ?                             
condicion                               dd                            ?                             
_5                                      dd                            5.00                          
_10                                     dd                            10.00                         
_a_a_b                                  db                            "a a b",'$', 5 dup (?)
_42                                     dd                            42.00                         
_3                                      dd                            3.00                          
_x_es_mayor_que_y_o_a                   db                            "x es mayor que y o a",'$', 20 dup (?)
_0                                      dd                            0.00                          
_b_es_positivo                          db                            "b es positivo",'$', 13 dup (?)
_1                                      dd                            1.00                          
_Ciclo_terminado__b_ahora_es            db                            "Ciclo terminado. b ahora es",'$', 27 dup (?)
_Esto_es_un_mensaje_de_prueba_          db                            "Esto es un mensaje de prueba.",'$', 29 dup (?)
_123_456                                dd                            123.456                       
__789                                   dd                            .789                          
_0_123                                  dd                            0.123                         
_Inicio                                 db                            "Inicio",'$', 6 dup (?)
_Proceso                                db                            "Proceso",'$', 7 dup (?)
_Final                                  db                            "Final",'$', 5 dup (?)
_a_es_mayor_que_b                       db                            "a es mayor que b",'$', 16 dup (?)
_a_es_menor_o_igual_que_b               db                            "a es menor o igual que b",'$', 24 dup (?)
_c_no_es_menor_que_b                    db                            "c no es menor que b",'$', 19 dup (?)
_Nuevo_inicio                           db                            "Nuevo inicio",'$', 12 dup (?)


.CODE

START:
mov AX,DGROUP    ; Inicializa el segmento de datos
mov DS,AX
mov es,ax ;

FLD a
FLD _5
FSTP a
FLD b
FLD _10
FSTP b
FLD c
FLD a
FLD b
FADDP
FSTP c
; Empieza la condicion if: 
FLD a
FLD b
FXCH
FCOMPP
FSTSW AX
SAHF
JA E0
FLD c
FLD b
FXCH
FCOMPP
FSTSW AX
SAHF
JB E0
displayString _a_a_b
E0:
FLD x
FLD _42
FLD c
FXCH
FDIVP
FSTP x
FLD y
FLD x
FLD _3
FMULP
FLD _5
FADDP
FSTP y
; Empieza la condicion if: 
FLD x
FLD y
FXCH
FCOMPP
FSTSW AX
SAHF
JNA E2
FLD a
FLD b
FXCH
FCOMPP
FSTSW AX
SAHF
JNB E2
JMP E1
E2:
displayString _x_es_mayor_que_y_o_a
E1:
; Empieza el ciclo while: 
E3:
FLD b
FLD _0
FXCH
FCOMPP
FSTSW AX
SAHF
JNA E4
displayString _b_es_positivo
FLD b
FLD b
FLD _1
FSUBP
FSTP b
JMP E3
E4:
displayString _Ciclo_terminado__b_ahora_es
FLD mensaje
FSTP mensaje
FLD mensaje
displayString mensaje
FLD a
FLD _123_456
FSTP a
FLD b
FLD __789
FSTP b
FLD c
FLD _0_123
FSTP c
FLD p1
FSTP p1
FLD p2
FSTP p2
FLD p3
FSTP p3
; Empieza la condicion if: 
FLD a
FLD b
FXCH
FCOMPP
FSTSW AX
SAHF
JNA E6
displayString _a_es_mayor_que_b
JMP E5
E6:
displayString _a_es_menor_o_igual_que_b
E5:
; Empieza la condicion if: 
FLD c
FLD b
FXCH
FCOMPP
FSTSW AX
SAHF
JNB E7
displayString _c_no_es_menor_que_b
E7:
FLD p1
FSTP p1
FLD p1
displayString p1
FLD variable2
FLD variable2
FLD variable2
displayString variable2



mov ax,4c00h    ; Indica que debe finalizar la ejecuci?n
int 21h

End START
