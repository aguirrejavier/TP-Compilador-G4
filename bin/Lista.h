#ifndef LISTA_H
#define LISTA_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NOMBRE 40
#define MAX_TIPODATO 10
#define MAX_VALOR 50
#define MAX_LONGITUD 10
#define TODO_OK 1
#define ERROR 0

typedef struct {
    char nombre[MAX_NOMBRE];
    char tipoDato[MAX_TIPODATO];
    char valor[MAX_VALOR];
    char longitud[MAX_LONGITUD];
} t_lexema;

typedef struct nodo {
    t_lexema dato;
    struct nodo *siguiente;
} t_nodo;

typedef struct {
    t_nodo *cabeza;
} Lista;

// Funciones para manejar la lista
void crearListaLexemas(Lista *lista);
int listaVacia(Lista *lista);
int insertarLexemaEnLista(Lista *lista, t_lexema nuevoDato);
int buscarLexemaEnLista(Lista *lista, t_lexema datoBuscado);
void eliminarLista(Lista *lista);
int eliminarLexemaLista(Lista *lista, const char *nombre);
void mostrarLista(Lista *lista);
int sacarLexemaLista(Lista *lista, t_lexema *lex);

#endif // LISTA_H