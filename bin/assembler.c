#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "assembler.h"
#include "arbol.h"
#include "Lista.h"
#include "stackAsm.h"
int contAux = 0;
t_pila* pila_exp;
void cargarOperando(FILE* f, char* operando);
void realizarOperacion(FILE* f, t_pila* pila_exp, const char* operacion);
void vaciar_pila(t_pila* pila);

void generarCodigoAssembler(t_arbol *pa, FILE *f_asm, Lista ts){
	char Linea[300];
	FILE *f_temp = fopen("Temp.asm", "wt");
	pila_exp = crearPila();
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

	fprintf(f_asm, "\n\n\nmov ax,4c00h	; Indica que debe finalizar la ejecuci贸n\nint 21h\n\nEnd START\n");
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
    recorrerArbol(&(*pa)->hijoDerecho, f_temp);

    if (strcmp((*pa)->descripcion, "sentencia") != 0 ) {
        traduccionAssembler(pa, f_temp);
    }
    return pa;

    return NULL;
}
void traduccionAssembler(t_arbol* pa, FILE* f) {
    if (!*pa) return;
    char cadena[50] = "";
	
	//COMENTARIO GENERAL
	// *TODO funciones especiales
	// *puede que por el trabajo en pila tengamos que hacer intercambios de registros
	// *esta logica seria suficiente para manejar todo lo que venga de la intermedia
	if((*pa)->hijoIzquierdo == NULL && (*pa)->hijoDerecho == NULL && strncmp((*pa)->descripcion, "%s", 2) != 0){
        
        apilar(pila_exp, (*pa)->descripcion);
        //fprintf(f, "FLD %s\n", (*pa)->descripcion); 
    }
		

    if(strcmp((*pa)->descripcion, "escribir") == 0){
        fprintf(f, "mov dx, OFFSET %s\n",((*pa)->hijoDerecho)->descripcion + 2);
        fprintf(f, "mov ah, 9\n");
        fprintf(f, "int 21h\n");
        fprintf(f, "newLine 1\n");
    }
	//FLD variable/cte
	//FSTP mensaje
	//mov dx, offset mensaje  ; Cargar la direcci贸n de la cadena a imprimir
	//mov ah, 09h             ; Funci贸n 09h de DOS para mostrar cadenas
	//int 21h                 ; Llamar a la interrupci贸n 21h de DOS
	if(strcmp((*pa)->descripcion, "leer") == 0)
		fprintf(f, "FLD %s\n", (*pa)->hijoDerecho->descripcion); 
	
	if(strcmp((*pa)->descripcion, "while") == 0){}
	//agrega un if preguntando si el tope de pila es 1 o 0, deberia tener un JZ a la etiqueta donde comienza (hago un POP de PILAETIQUETA)
	if(strcmp((*pa)->descripcion, "if") == 0){}
	//no haria nada
	if(strcmp((*pa)->descripcion, "condicion") == 0){}
	//usaria este nodo dummy para apilar en PILAETIQUETA el valor que tenga en AUXETIQUETA 
	if(strcmp((*pa)->descripcion, "cuerpo") == 0){}
    //en esta se hace toda la logica del if o del while, usando un JNE con 1 y 0 contra el tope de pila , tambien podriamos usar un JZ en estos casos (salto si no es 0) 
	//desapilo PILAETIQUETA
	//en el if no lo uso para nada
	//en el while la utilizo para volver al inicio del ciclo

    if (strcmp((*pa)->descripcion, "AND") == 0 || strcmp((*pa)->descripcion, "OR") == 0 ){}
    //suma los dos primeros registros de la pila
    //para AND verifica si es igual a 2
	//para OR verifica si es mayor o igual a 1
    //en tope de pila quedaria un unico valor que corresponde al resultado (1 TRUE-0 FALSE)

    if (strcmp((*pa)->descripcion, ">") == 0 || strcmp((*pa)->descripcion, ">=") == 0 || 
        strcmp((*pa)->descripcion, "<") == 0 || strcmp((*pa)->descripcion, "<=") == 0 || 
        strcmp((*pa)->descripcion, "<>") == 0 || strcmp((*pa)->descripcion, "==") == 0){
	//ETIQUETA COMP i
    //compara los dos primeros registros de la pila (FCMP)
    //en el caso del TRUE deja en el tope de la pila 1    
	//en el caso del FALSE deja en el tope de la pila 0
	//ademas deberia agregarse una etiqueta encima para que pueda volver en el caso del while (pongo esa etiqueta en AUXETIQUETA)
	//	fprintf(f, "FCOMP");
	//	 if (strcmp((*pa)->descripcion, ">") == 0 )
	//			fprintf(f, "JNA");
	//			fprintf(f, "FLD 1");
	//			fprintf(f, "");

    }

     if (strcmp((*pa)->descripcion, "+") == 0) {
        realizarOperacion(f, pila_exp, "FADD");
    } else if (strcmp((*pa)->descripcion, "-") == 0) {
        realizarOperacion(f, pila_exp, "FSUB");
    } else if (strcmp((*pa)->descripcion, "*") == 0) {
        realizarOperacion(f, pila_exp, "FMUL");
    } else if (strcmp((*pa)->descripcion, "/") == 0) {
        realizarOperacion(f, pila_exp, "FDIV");
    } else if (strcmp((*pa)->descripcion, ":=") == 0) {
        if (strncmp(((*pa)->hijoDerecho)->descripcion, "%s", 2) == 0) {
            fprintf(f, "lea eax, %s\n", ((*pa)->hijoDerecho)->descripcion + 2);
            fprintf(f, "mov %s, eax\n", ((*pa)->hijoIzquierdo)->descripcion);
        } else {
            char* opIgual = desapilar(pila_exp);
            if (strcmp(opIgual, "TRUE") == 0) {
                opIgual = desapilar(pila_exp);
            } else {
                cargarOperando(f, opIgual);
            }
            fprintf(f, "FSTP %s\n", ((*pa)->hijoIzquierdo)->descripcion);
        }
        vaciar_pila(pila_exp);
    }
        //operaciones sobre los dos primeros registros de la pila  y asignacion sobre el tope de pila
        //en todas las operaciones queda el resultado en tope de pila
        //en el caso de la asignacion queda la pila vacia
        //(pensando que previamente lo estaba)
    
}
void cargarOperando(FILE* f, char* operando) {
    if (strcmp(operando, "TRUE") != 0) {
        fprintf(f, "FLD %s\n", operando);
    }
}

void realizarOperacion(FILE* f, t_pila* pila_exp, const char* operacion) {
    char* opDer = desapilar(pila_exp);
    char* opIzq = desapilar(pila_exp);

    cargarOperando(f, opIzq);
    cargarOperando(f, opDer);

    fprintf(f, "%s\n", operacion);
    apilar(pila_exp, "TRUE");
}

void vaciar_pila(t_pila* pila){
    while (!pilaVacia(pila)) {
        char* dato = desapilar(pila);
        free(dato);
    }
}