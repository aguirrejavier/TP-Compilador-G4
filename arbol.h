
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct nodo{
    struct nodo* hijoIzquierdo;
    struct nodo* hijoDerecho;
    char descripcion[45];
}t_nodo;

typedef t_nodo* t_arbol;

t_nodo* crearHoja( char* lexema);
t_nodo* crearNodo( char* lexema, t_nodo* hijoIzq, t_nodo* hijoDer);
void recorrerInOrder(t_arbol *pa, FILE *pIntermedia);
char* replace_char(char* str, char find, char replace);
void generarArchivoDOT(t_arbol* pa, FILE* stream);
void grabarNodoDOT(t_nodo *nodo, FILE* stream, int* numero);