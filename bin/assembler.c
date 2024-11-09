#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "arbol.h"
#include "Lista.h"

void generarCodigoAssembler(t_arbol *pa, FILE *f_asm, Lista ts){
	char Linea[300];
	FILE *f_temp = fopen("Temp.asm", "wt");
	//inOrderAssembler(pa, f_temp);
	fclose(f_temp);
	f_temp = fopen("Temp.asm", "rt");

	fprintf(f_asm, "include macros2.asm\ninclude number.asm\n.MODEL LARGE	; Modelo de Memoria\n.386	        ; Tipo de Procesador\n.STACK 200h		; Bytes en el Stack\n\n.DATA \n\n");

	generarDataAsm(f_asm,ts);

	fprintf(f_asm, "\n\n.CODE\n\nSTART:\nmov AX,@DATA    ; Inicializa el segmento de datos\nmov DS,AX\nmov es,ax ;\n\n");

	while(fgets(Linea, sizeof(Linea), f_temp))
	{
		fprintf(f_asm, Linea);
	}

	fclose(f_temp);
	remove("Temp.asm");

	fprintf(f_asm, "\n\n\nmov ax,4c00h	; Indica que debe finalizar la ejecución\nint 21h\n\nEnd START\n");
	fclose(f_asm);
}
void generarDataAsm(FILE* f, Lista tsimbol){
	 
	 t_nodo *nodoActual = tsimbol.cabeza;

    while (nodoActual != NULL) {
        t_lexema lex = nodoActual->dato;

        if ((!strncmp(lex.nombre, "_", 1)) && strcmp(lex.longitud, "") == 0 && strchr(lex.valor, '.') == NULL) {
            strcat(lex.valor, ".00");
            fprintf(f, "%-40s%-30s%-30s\n", lex.nombre, "dd", lex.valor);
        }
        else if (!strncmp(lex.nombre, "_", 1)) {
				if(strcmp(lex.longitud, "") != 0)
				{
					replace_char(lex.nombre,'.','_');
					replace_char(lex.nombre,' ','_');
					fprintf(f, "%-40s%-30s\"%s\",'$', %s dup (?)\n", lex.nombre, "db", lex.valor, lex.longitud);
				}
				else{
					replace_char(lex.nombre,'.','_');
					fprintf(f, "%-40s%-30s%-30s\n", lex.nombre, "dd", lex.valor);
				}
                	
        }
        else if (strncmp(lex.nombre, "", 1)) {
            fprintf(f, "%-40s%-30s%-30s\n", lex.nombre, "dd", "?");
        }
        nodoActual = nodoActual->siguiente;
    }
}