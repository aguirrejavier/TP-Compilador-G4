#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Lista.h"

void crearListaLexemas(Lista *lista) {
    lista->cabeza = NULL;
}
int listaVacia(Lista *lista) {
    return lista->cabeza == NULL;
}
int insertarLexemaEnLista(Lista *lista, t_lexema nuevoDato){
    t_nodo *nuevoNodo = (t_nodo *)malloc(sizeof(t_nodo));
    if (nuevoNodo == NULL) {
        printf("Error al asignar memoria para el nuevo nodo.\n");
        return ERROR;
    }

    nuevoNodo->dato = nuevoDato;
    nuevoNodo->siguiente = NULL;

    if (lista->cabeza == NULL) {
        lista->cabeza = nuevoNodo;
    } else {
        t_nodo *actual = lista->cabeza;
        while (actual->siguiente != NULL) {
            actual = actual->siguiente;
        }
        actual->siguiente = nuevoNodo;
    }
    return TODO_OK;
}    
int buscarLexemaEnLista(Lista *lista, t_lexema datoBuscado){
    t_nodo *actual = lista->cabeza;
    while (actual) {
        if (strcmp(actual->dato.nombre, datoBuscado.nombre) == 0 &&
            strcmp(actual->dato.tipoDato, datoBuscado.tipoDato) == 0) {
            return 1;
        }
        actual = actual->siguiente;
    }
    return 0;
}

void mostrarLista(Lista *lista) {
    t_nodo *actual = lista->cabeza;
    while (actual) {
        printf("Nombre: %s, Tipo: %s, Valor: %s, Longitud: %s\n",
                actual->dato.nombre, actual->dato.tipoDato,
                actual->dato.valor, actual->dato.longitud);
        actual = actual->siguiente;
    }
}
void eliminarLista(Lista *lista){
    t_nodo *actual = lista->cabeza;
    while (actual) {
        t_nodo *siguiente = actual->siguiente;
        free(actual);
        actual = siguiente;
    }
    lista->cabeza = NULL;
}

int eliminarLexemaLista(Lista *lista, const char *nombre) {
    if (lista->cabeza == NULL) {
        return ERROR;
    }

    t_nodo *actual = lista->cabeza;
    t_nodo *anterior = NULL;

    while (actual != NULL) {
        if (strcmp(actual->dato.nombre, nombre) == 0) {
            if (anterior == NULL) {
                lista->cabeza = actual->siguiente;
            } else {
                anterior->siguiente = actual->siguiente;
            }

            free(actual);
            return TODO_OK;
        }
        anterior = actual;
        actual = actual->siguiente;
    }

    return 0;
}
int sacarLexemaLista(Lista *lista, t_lexema *lex) {
    if (listaVacia(lista)) {
        return 0;
    }

    t_nodo *aux = lista->cabeza;

    strcpy(lex->nombre, aux->dato.nombre);
    strcpy(lex->tipoDato, aux->dato.tipoDato);
    strcpy(lex->valor, aux->dato.valor);
    strcpy(lex->longitud, aux->dato.longitud);

    lista->cabeza = aux->siguiente;

    free(aux);

    return TODO_OK; 
}