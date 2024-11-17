#ifndef STACK_H
#define STACK_H

typedef struct t_nodoStack {
    char* dato; 
    struct t_nodoStack* siguiente;
} t_nodoStack;

typedef struct {
    t_nodoStack* cima;
} t_pila;

t_pila* crearPilaAsm();
void apilarAsm(t_pila* pila, const char* dato);
char* desapilarAsm(t_pila* pila);
int pilaVaciaAsm(t_pila* pila);
void liberarPilaAsm(t_pila* pila);
char* verTopeAsm(t_pila* pila);

#endif // STACK_H