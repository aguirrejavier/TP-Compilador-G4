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
	pila_exp = crearPilaAsm();
	pila_else = crearPilaAsm();
    recorrerArbol(pa, f_temp,&ts); //POST ORDEN
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

t_arbol* recorrerArbol(t_arbol *pa, FILE *f_temp, Lista *tsimbol){
    if (!*pa) return NULL;
	
	//BAJANDO
	char etiqueta_string[10];
    char* dato; 
	if(strcmp((*pa)->descripcion, "while") == 0){
        fprintf(f_temp, "; Empieza el ciclo while: \n");
		fprintf(f_temp, "#E%d\n", etiqueta);
        sprintf(etiqueta_string, "%d", etiqueta);
		apilarAsm(pila_exp, etiqueta_string);
		(etiqueta)++;
        sprintf(etiqueta_string, "%d", etiqueta);	
		apilarAsm(pila_exp, etiqueta_string);
		(etiqueta)++;
	}
	if(strcmp((*pa)->descripcion, "BYNARY_COUNT") == 0){
        fprintf(f_temp, "; Empieza la funcion especial BYNARY_COUNT : \n");
        agregarLexema("es_binario",LEXEMA_STR, "", tsimbol);
        agregarLexema("@contadorBinario",LEXEMA_ID, "", tsimbol);
	}
    if(strcmp((*pa)->descripcion, "SUMULT") == 0){
        fprintf(f_temp, "; Empieza la funcion especial SUMAULT : \n");
        if ((*pa) != NULL && (*pa)->hijoDerecho != NULL && (*pa)->hijoDerecho->hijoDerecho != NULL) {
            //pa = pa->hijoDerecho->hijoDerecho->hijoDerecho;
            fprintf(f_temp, "FLD %s\n", (*pa)->hijoDerecho->hijoDerecho->hijoDerecho->hijoDerecho->descripcion);
            fprintf(f_temp, "FSTP %s\n", (*pa)->hijoDerecho->hijoDerecho->hijoDerecho->hijoIzquierdo->descripcion);
            return;
        }
	}
	if(strcmp((*pa)->descripcion, "if") == 0){
        fprintf(f_temp, "; Empieza la condicion if: \n");
        sprintf(etiqueta_string, "%d", etiqueta);	
		apilarAsm(pila_exp, etiqueta_string);
		(etiqueta)++;
		if((*pa)->hijoDerecho->hijoDerecho != NULL && strcmp((((*pa)->hijoDerecho)->hijoDerecho) -> descripcion, "else") == 0){
			sprintf(etiqueta_string, "%d", etiqueta);	
            apilarAsm(pila_exp, etiqueta_string);
			(etiqueta)++;
			apilarAsm(pila_else, "1");
		}
		else{
			apilarAsm(pila_else,"0");			
		}
	}
	
	if(strcmp((*pa)->descripcion, "OR") == 0){
        sprintf(etiqueta_string, "%d", etiqueta);	
		apilarAsm(pila_exp, etiqueta_string);
		(etiqueta)++;	
		auxOR = 1;
	}
	
	if(strcmp((*pa)->descripcion, "else") == 0){
		fprintf(f_temp, "JMP #E%d\n",atoi(verTopeAsm(pila_exp))-1);
        dato = desapilarAsm(pila_exp);
		fprintf(f_temp, "#E%s\n", dato);
	}
    recorrerArbol(&(*pa)->hijoIzquierdo, f_temp, tsimbol);
    recorrerArbol(&(*pa)->hijoDerecho, f_temp, tsimbol);
	//SUBIENDO
	//traduccionAssembler
	
    if (strcmp((*pa)->descripcion, "sentencia") != 0 ) {
        traduccionAssembler(pa, f_temp,&etiqueta, tsimbol);
    }
    return pa;

    return NULL;
}
void traduccionAssembler(t_arbol* pa, FILE* f,int* etiqueta,  Lista* tsimbol) {
    if (!*pa) return;
    char cadena[50] = "";
	
	if(strcmp((*pa)->descripcion, "while") == 0){
		fprintf(f, "JMP #E%d\n", atoi(verTopeAsm(pila_exp))-1);
		fprintf(f, "#E%d\n", atoi(verTopeAsm(pila_exp)));				
		desapilarAsm(pila_exp);
		desapilarAsm(pila_exp);
	}
	
	if(strcmp((*pa)->descripcion, "if") == 0){
		fprintf(f, "#E%s\n", (desapilarAsm(pila_exp)));
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
		desapilarAsm(pila_exp);
		fprintf(f, "JMP #E%d\n", atoi(verTopeAsm(pila_exp)));
		fprintf(f, "#E%d\n", atoi(verTopeAsm(pila_exp))+1); 
		auxOR = 0;		
	}

    if (strcmp((*pa)->descripcion, ">") == 0 || strcmp((*pa)->descripcion, ">=") == 0 || 
        strcmp((*pa)->descripcion, "<") == 0 || strcmp((*pa)->descripcion, "<=") == 0 || 
        strcmp((*pa)->descripcion, "<>") == 0 || strcmp((*pa)->descripcion, "==") == 0){
			
		fprintf(f, "FXCH\n");
		fprintf(f, "FCOMPP\n");
		fprintf(f, "FSTSW AX\n");
		fprintf(f, "SAHF\n");
		
        if(auxOR==1){
            invertirCondicion(pa);
        }
		    
		
		if(strcmp((*pa)->descripcion, "<=") == 0){
				fprintf(f, "JA #E%s\n",verTopeAsm(pila_exp));
		}
		if(strcmp((*pa)->descripcion, ">=") == 0){
				fprintf(f, "JB #E%s\n",verTopeAsm(pila_exp));
		}
		if(strcmp((*pa)->descripcion, ">") == 0){
				fprintf(f, "JNA #E%s\n",verTopeAsm(pila_exp));
		}
		if(strcmp((*pa)->descripcion, "<") == 0){
				fprintf(f, "JNB #E%s\n",verTopeAsm(pila_exp));
		}
		if(strcmp((*pa)->descripcion, "==") == 0){
				fprintf(f, "JNE #E%s\n",verTopeAsm(pila_exp));
		}
		if(strcmp((*pa)->descripcion, "<>") == 0){
				fprintf(f, "JE #E%s\n",verTopeAsm(pila_exp));
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
        char* dato = desapilarAsm(pila);
        free(dato);
    }
}