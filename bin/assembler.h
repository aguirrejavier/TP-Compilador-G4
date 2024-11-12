#include "arbol.h"
#include "Lista.h"

void generarCodigoAssembler(t_arbol *pa, FILE *f_asm, Lista ts);
void generarDataAsm(FILE* f, Lista tsimbol);
t_arbol* recorrerArbol(t_arbol *pa, FILE *f_temp);
int esHoja(t_arbol* pa);
void traduccionAssembler(t_arbol* pa, FILE* f);