:: Script para windows
flex Lexico.l
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c "bin\Lista.c" "bin\arbol.c" "bin\stack.c" -o compilador.exe

compilador.exe prueba.txt

dot -Tpng arbol.dot -o salida.png

@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
