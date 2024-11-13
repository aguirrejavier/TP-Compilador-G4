#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stack.h"

t_pila* crearPila() {
    t_pila* nuevaPila = (t_pila*)malloc(sizeof(t_pila));
    if (nuevaPila == NULL) {
        fprintf(stderr, "Error al asignar memoria para la pila.\n");
        exit(EXIT_FAILURE);
    }
    nuevaPila->cima = NULL;
    return nuevaPila;
}

void apilar(t_pila* pila, const char* dato) {
    t_nodoStack* nuevoNodo = (t_nodoStack*)malloc(sizeof(t_nodoStack));
    if (nuevoNodo == NULL) {
        fprintf(stderr, "Error al asignar memoria para el nodo.\n");
        exit(EXIT_FAILURE);
    }
    nuevoNodo->dato = strdup(dato); // Copia la cadena para almacenar en la pila
    nuevoNodo->siguiente = pila->cima;
    pila->cima = nuevoNodo;
}

char* desapilar(t_pila* pila) {
    if (pilaVacia(pila)) {
        fprintf(stderr, "Error: Intento de desapilar una pila vacía.\n");
        exit(EXIT_FAILURE);
    }
    t_nodoStack* nodoAEliminar = pila->cima;
    char* dato = nodoAEliminar->dato; // Obtiene la cadena del nodo
    pila->cima = nodoAEliminar->siguiente;
    free(nodoAEliminar);
    return dato;
}

int pilaVacia(t_pila* pila) {
    return pila->cima == NULL;
}

void liberarPila(t_pila* pila) {
    t_nodoStack* nodoActual = pila->cima;
    while (nodoActual != NULL) {
        t_nodoStack* nodoAEliminar = nodoActual;
        nodoActual = nodoActual->siguiente;
        free(nodoAEliminar->dato);
        free(nodoAEliminar);
    }
    pila->cima = NULL;
}

char* verTope(t_pila* pila) {
    if (pilaVacia(pila)) {
        fprintf(stderr, "Error: Intento de ver el tope de una pila vacía.\n");
        exit(EXIT_FAILURE);
    }
    return pila->cima->dato;
}