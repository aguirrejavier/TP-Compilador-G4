#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "arbol.h"
#include "Lista.h"
#include "stackAsm.h"
int etiqueta = 0;
int auxOR = 0;
t_pila* pila_else;
t_pila* pila_exp;

void cargarOperando(FILE* f, char* operando);
void realizarOperacion(FILE* f, t_pila* pila_exp, const char* operacion);
void vaciar_pila(t_pila* pila);



void invertirCondicion(t_arbol *pa){
		if(strcmp((*pa)->descripcion, ">") == 0)
			strcpy((*pa)->descripcion,"<=");
		
		if(strcmp((*pa)->descripcion, "<") == 0)
			strcpy((*pa)->descripcion,">=");
		
		if(strcmp((*pa)->descripcion, ">=") == 0)
			strcpy((*pa)->descripcion,"<");
		
		if(strcmp((*pa)->descripcion, "<=") == 0)
			strcpy((*pa)->descripcion,">");
		
		if(strcmp((*pa)->descripcion, "==") == 0)
			strcpy((*pa)->descripcion,"<>");
		
		if(strcmp((*pa)->descripcion, "<>") == 0)
			strcpy((*pa)->descripcion,"==");
}

void generarCodigoAssembler(t_arbol *pa, FILE *f_asm, Lista ts){
	char Linea[300];
	FILE *f_temp = fopen("Temp.asm", "wt");
	pila_exp = crearPila();
	pila_else = crearPila();
    recorrerArbol(pa, f_temp); //POST ORDEN
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

	fprintf(f_asm, "\n\n\nmov ax,4c00h	; Indica que debe finalizar la ejecuci?n\nint 21h\n\nEnd START\n");
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
	
	//BAJANDO
	
	if(strcmp((*pa)->descripcion, "while") == 0){
		fprintf(f_temp, "#E%d\n", etiqueta);		
		apilar(pila_exp, etiqueta);
		(etiqueta)++;
		apilar(pila_exp, etiqueta);
		(etiqueta)++;
	}
	
	if(strcmp((*pa)->descripcion, "if") == 0){
		apilar(pila_exp, etiqueta);
		(etiqueta)++;
			if((*pa)->hijoDerecho->hijoDerecho != NULL && strcmp((((*pa)->hijoDerecho)->hijoDerecho) -> descripcion, "else") == 0){
			apilar(pila_exp, etiqueta);
			(etiqueta)++;
			apilar(pila_else, 1);
		}
		else{
			apilar(pila_else,0);			
		}
	}
	
	if(strcmp((*pa)->descripcion, "OR") == 0){
		apilar(pila_exp, etiqueta);
		(etiqueta)++;	
		auxOR = 1;
	}
	
	if(strcmp((*pa)->descripcion, "else") == 0){
		fprintf(f_temp, "JMP #E%d\n",verTope(pila_exp)-1);
		fprintf(f_temp, "#E%d\n", (desapilar(pila_exp)));
	}
    recorrerArbol(&(*pa)->hijoIzquierdo, f_temp);
    recorrerArbol(&(*pa)->hijoDerecho, f_temp);
	//SUBIENDO
	//traduccionAssembler
	
    if (strcmp((*pa)->descripcion, "sentencia") != 0 ) {
        traduccionAssembler(pa, f_temp,&etiqueta);
    }
    return pa;

    return NULL;
}
void traduccionAssembler(t_arbol* pa, FILE* f,int* etiqueta) {
    if (!*pa) return;
    char cadena[50] = "";
	
	if(strcmp((*pa)->descripcion, "while") == 0){
		fprintf(f, "JMP #E%d\n", verTope(pila_exp)-1);
		fprintf(f, "#E%d\n", verTope(pila_exp));				
		desapilar(pila_exp);
		desapilar(pila_exp);
	}
	
	if(strcmp((*pa)->descripcion, "if") == 0){
		fprintf(f, "#E%d", (desapilar(pila_exp)));
	}

	if((*pa)->hijoIzquierdo == NULL && (*pa)->hijoDerecho == NULL && strncmp((*pa)->descripcion, "%s", 2) != 0){
        fprintf(f, "FLD %s\n", (*pa)->descripcion); 
    }
		
    if(strcmp((*pa)->descripcion, "escribir") == 0){
        fprintf(f, "displayString %s\n",((*pa)->hijoDerecho)->descripcion+2);
    }

	if(strcmp((*pa)->descripcion, "leer") == 0)
		fprintf(f, "FLD %s\n", (*pa)->hijoDerecho->descripcion); 
	
	if(strcmp((*pa)->descripcion, "OR") == 0){
		desapilar(pila_exp);
		fprintf(f, "JMP #E%d\n", verTope(pila_exp));
		fprintf(f, "#E%d\n", verTope(pila_exp)+1); 
		auxOR = 0;		
	}

    if (strcmp((*pa)->descripcion, ">") == 0 || strcmp((*pa)->descripcion, ">=") == 0 || 
        strcmp((*pa)->descripcion, "<") == 0 || strcmp((*pa)->descripcion, "<=") == 0 || 
        strcmp((*pa)->descripcion, "<>") == 0 || strcmp((*pa)->descripcion, "==") == 0){
			
		fprintf(f, "FXCH\n");
		fprintf(f, "FCOMPP\n");
		fprintf(f, "FSTSW AX\n");
		fprintf(f, "SAHF\n");
		
		//funcion
		invertirCondicion((*pa));
		
		if(strcmp((*pa)->descripcion, "<=") == 0){
				fprintf(f, "JA #E%d\n",verTope(pila_exp));
		}
		if(strcmp((*pa)->descripcion, ">=") == 0){
				fprintf(f, "JB #E%d\n",verTope(pila_exp));
		}

    }

     if (strcmp((*pa)->descripcion, "+") == 0) {
        fprintf(f, "FADDP\n");
    } else if (strcmp((*pa)->descripcion, "-") == 0) {
        fprintf(f, "FSUBP\n");
    } else if (strcmp((*pa)->descripcion, "*") == 0) {
        fprintf(f, "FMULP\n");
    } else if (strcmp((*pa)->descripcion, "/") == 0) {
        fprintf(f, "FXCH\n");		
        fprintf(f, "FDIVP\n");
    } else if (strcmp((*pa)->descripcion, ":=") == 0) {
		fprintf(f, "FSTP %s\n",(*pa)->hijoIzquierdo->descripcion);
        }
    }

    
void cargarOperando(FILE* f, char* operando) {
    if (strcmp(operando, "TRUE") != 0) {
        fprintf(f, "FLD %s\n", operando);
    }
}

void vaciar_pila(t_pila* pila){
    while (!pilaVacia(pila)) {
        char* dato = desapilar(pila);
        free(dato);
    }
}