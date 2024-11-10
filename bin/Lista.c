#include "Lista.h"

void crearListaLexemas(Lista *lista) {
    lista->cabeza = NULL;
    lista->size = 0;
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
    lista->size++;
    return TODO_OK;
}    
int buscarLexemaEnLista(Lista *lista, t_lexema datoBuscado){
    t_nodo *actual = lista->cabeza;
    while (actual) {
        if (strcmp(actual->dato.nombre, datoBuscado.nombre) == 0){
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
    lista->size--;
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
t_lexema copiarLexema(t_lexema original) {
    t_lexema copia;
    strcpy(copia.nombre, original.nombre);
    strcpy(copia.tipoDato, original.tipoDato);
    strcpy(copia.valor, original.valor);
    strcpy(copia.longitud, original.longitud);
    return copia;
}

void copiarLista(Lista *origen, Lista *destino) {
    t_nodo *nodoActual = origen->cabeza;
    t_nodo *nodoNuevo = NULL;
    t_nodo *nodoAnterior = NULL;

    destino->cabeza = NULL;

    while (nodoActual != NULL) {
        nodoNuevo = (t_nodo*)malloc(sizeof(t_nodo));
        if (nodoNuevo == NULL) {
            printf("Error al asignar memoria para el nuevo nodo.\n");
            return;
        }
        nodoNuevo->dato = copiarLexema(nodoActual->dato);
        nodoNuevo->siguiente = NULL;

        if (destino->cabeza == NULL) {
            destino->cabeza = nodoNuevo; 
        } else {
            nodoAnterior->siguiente = nodoNuevo; 
        }

        nodoAnterior = nodoNuevo;
        nodoActual = nodoActual->siguiente;
    }
}
void agregarLexema(const char *simboloNombre, TipoLexema tipo, char *tipoDato, Lista *tablaSimbolos) {
    t_lexema lex;
    char nombre[100] = "";
    char valor[100];
    char strLongitud[10] = "";
    int longitud;

    switch (tipo) {
        case LEXEMA_ID:
            strcat(nombre, simboloNombre);
            break;

        case LEXEMA_NUM:
			strcat(nombre, "_");
            strcat(nombre, simboloNombre);
            strcpy(valor, simboloNombre);
            break;

        case LEXEMA_STR: {
			strcat(nombre, "_");
            int i = 0, j = 0, ocurrencias = 0;
            while (ocurrencias < 2 && simboloNombre[i] != '\0') {
                if (simboloNombre[i] != '"') {
                    valor[j++] = simboloNombre[i];
                } else {
                    ocurrencias++;
                }
                i++;
            }
            valor[j] = '\0';
            strcat(nombre, valor);
            longitud = strlen(valor);
            sprintf(strLongitud, "%d", longitud);
			
            break;
        }
    }
	strcpy(lex.nombre, nombre);
    if (buscarLexemaEnLista(tablaSimbolos, lex) == 0) {
        strcpy(lex.nombre, nombre);
        strcpy(lex.valor, tipo == LEXEMA_ID ? "" : valor);
        strcpy(lex.longitud, tipo == LEXEMA_STR ? strLongitud : "");
		strcpy(lex.tipoDato, tipoDato); 
        insertarLexemaEnLista(tablaSimbolos, lex);
    }
}