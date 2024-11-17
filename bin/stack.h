#include "arbol.h"
#ifndef STACK_H
#define STACK_H


typedef struct t_nodoStack {
    ta_nodo* dato; 
    struct t_nodoStack* siguiente;
} t_nodoStack;

typedef struct {
    t_nodoStack* cima;
} t_pila;

t_pila* crearPila();
void apilar(t_pila* pila,  ta_nodo* dato);
ta_nodo* desapilar(t_pila* pila);
ta_nodo* verTope(t_pila* pila);
int pilaVacia(t_pila* pila);
void liberarPila(t_pila* pila);

#endif // STACK_H