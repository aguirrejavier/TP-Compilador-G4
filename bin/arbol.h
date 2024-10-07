#ifndef ARBOL_H
#define ARBOL_H

typedef struct a_nodo{
    struct a_nodo* hijoIzquierdo;
    struct a_nodo* hijoDerecho;
    char descripcion[45];
}ta_nodo;

typedef ta_nodo* t_arbol;

ta_nodo* crearHoja( char* lexema);
ta_nodo* crearNodo( char* lexema, ta_nodo* hijoIzq, ta_nodo* hijoDer);
void recorrerInOrder(t_arbol *pa, FILE *pIntermedia);
char* replace_char(char* str, char find, char replace);
void generarArchivoDOT(t_arbol* pa, FILE* stream);
void grabarNodoDOT(ta_nodo *nodo, FILE* stream, int* numero);
#endif // ARBOL_H