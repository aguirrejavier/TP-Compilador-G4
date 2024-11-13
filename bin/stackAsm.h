#ifndef STACK_H
#define STACK_H

typedef struct t_nodoStack {
    char* dato; 
    struct t_nodoStack* siguiente;
} t_nodoStack;

typedef struct {
    t_nodoStack* cima;
} t_pila;

t_pila* crearPila();
void apilar(t_pila* pila, const char* dato);
char* desapilar(t_pila* pila);
int pilaVacia(t_pila* pila);
void liberarPila(t_pila* pila);
char* verTope(t_pila* pila) ;

#endif // STACK_H