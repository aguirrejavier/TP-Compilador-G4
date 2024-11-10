#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "arbol.h"
#include "Lista.h"
int contAux = 0;
void generarCodigoAssembler(t_arbol *pa, FILE *f_asm, Lista ts){
	char Linea[300];
	FILE *f_temp = fopen("Temp.asm", "wt");
	
    recorrerArbol(pa, f_temp);
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
int esHoja(t_arbol* pa){
    if(!*pa)
        return 0;
 
    return (!(*pa)->hijoIzquierdo) && (!(*pa)->hijoDerecho);
}

t_arbol* recorrerArbol(t_arbol *pa, FILE *f_temp){
    if (!*pa) return NULL;

    recorrerArbol(&(*pa)->hijoIzquierdo, f_temp);

    if (esHoja(&(*pa)->hijoIzquierdo) && (esHoja(&(*pa)->hijoDerecho) || (*pa)->hijoDerecho == NULL)) {
        if (strcmp((*pa)->descripcion, "sentencia") != 0 ) {
            traduccionAssembler(pa, f_temp);
        }
        return pa;
    }

    recorrerArbol(&(*pa)->hijoDerecho, f_temp);

    return NULL;
}
void traduccionAssembler(t_arbol* pa, FILE* f) {
    if (!*pa) return;
    char cadena[50] = "";

    if (strcmp((*pa)->descripcion, "+") == 0 || strcmp((*pa)->descripcion, "-") == 0 || 
        strcmp((*pa)->descripcion, "*") == 0 || strcmp((*pa)->descripcion, "/") == 0 || 
        strcmp((*pa)->descripcion, ":=") == 0) {

        if (strcmp((*pa)->descripcion, ":=") != 0) {
            fprintf(f, "FLD %s\n", ((*pa)->hijoIzquierdo)->descripcion);
        }
        fprintf(f, "FLD %s\n", ((*pa)->hijoDerecho)->descripcion);
    
        if (strcmp((*pa)->descripcion, "+") == 0)
            fprintf(f, "FADD\n");
        else if (strcmp((*pa)->descripcion, "-") == 0)
            fprintf(f, "FSUB\n");
        else if (strcmp((*pa)->descripcion, "*") == 0)
            fprintf(f, "FMUL\n");
        else if (strcmp((*pa)->descripcion, "/") == 0)
            fprintf(f, "FDIV\n");

        if (strcmp((*pa)->descripcion, ":=") == 0) {
            fprintf(f, "FSTP %s\n", (*pa)->hijoIzquierdo->descripcion); 
        } else {
            sprintf(cadena, "@Aux%d", ++contAux);
            fprintf(f, "FSTP %s\n", cadena);
            strcpy((*pa)->descripcion, cadena);
        }

        free((*pa)->hijoIzquierdo);
        (*pa)->hijoIzquierdo = NULL;
        free((*pa)->hijoDerecho);
        (*pa)->hijoDerecho = NULL;

        fprintf(f, "FFREE\n");
    }
}