#include "arbol.h"

t_nodo* crearHoja( char* lexema){
    t_nodo* nodo = (t_nodo*) malloc (sizeof(t_nodo));
    if(!nodo){
        printf("No se pudo reservar memoria para el nodo.\n");
        return NULL;
    }
    nodo->hijoIzquierdo = NULL;
    nodo->hijoDerecho = NULL;
    strcpy(nodo->descripcion, lexema);
    return nodo;
}

t_nodo* crearNodo(char* lexema, t_nodo* hijoIzq, t_nodo* hijoDer){
    t_nodo* padre = crearHoja(lexema);
    if(!padre) return NULL;
    padre->hijoIzquierdo = hijoIzq;
    padre->hijoDerecho = hijoDer;
    return padre;
}

void recorrerInOrder(t_arbol *pa, FILE *codidoIntermedioFILE)
{
    if(!(*pa)) return;
    recorrerInOrder(&(*pa)->hijoIzquierdo, codidoIntermedioFILE);
	printf(" %s  ", (*pa)->descripcion);
    fprintf(codidoIntermedioFILE, " %s  ", (*pa)->descripcion);  
    recorrerInOrder(&(*pa)->hijoDerecho, codidoIntermedioFILE);
}


void grabarNodoDOT(t_nodo *nodo, FILE* stream, int* numero)
{
    int nodoId = (*numero);
    fprintf(stream, "id%d [label = \"%s\"];\n", nodoId, replace_char((*nodo).descripcion,'"','\''));

    if ((*nodo).hijoIzquierdo)
    {
        int izqId = ++(*numero);
        grabarNodoDOT((*nodo).hijoIzquierdo, stream, numero);
        fprintf(stream, "id%d -> id%d ;\n", nodoId , izqId);
    }

    if ((*nodo).hijoDerecho)
    {
        int derId = ++(*numero);
        grabarNodoDOT((*nodo).hijoDerecho, stream, numero);
        fprintf(stream, "id%d -> id%d ;\n", nodoId , derId);
    }
}

void generarArchivoDOT(t_arbol* pa, FILE* stream)
{
    fprintf(stream, "digraph BST {\n");
    fprintf(stream, "    node [fontname=\"Arial\"];\n");

    if(!(*pa))
        fprintf(stream, "\n");
    else if (!(*pa)->hijoDerecho && !(*pa)->hijoIzquierdo)
        fprintf(stream, "    \"%s\";\n", (*pa)->hijoDerecho);
    else{
        int numero = 1;
        grabarNodoDOT((*pa), stream, &numero);
    }

    fprintf(stream, "}\n");
}

char* replace_char(char* str, char find, char replace){
    char *current_pos = strchr(str,find);
    while (current_pos) {
        *current_pos = replace;
        current_pos = strchr(current_pos,find);
    }
    return str;
}