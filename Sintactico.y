// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "bin/Lista.h"
#include "bin/arbol.h"
#include "bin/stack.h"

#define SYMBOL_TABLE "symbol-table.txt"
#define DOT_FILE "arbol.dot"
#define INTERMEDIA_FILE "intermedia.txt"


int yystopparser=0;
FILE  *yyin;
char *yytext;

Lista tablaSimbolos;
FILE  *file_dot;
FILE  *file_intermedia;

ta_nodo* ptr_progr;
ta_nodo* ptr_exp;
ta_nodo* ptr_fact;
ta_nodo* ptr_ter;

ta_nodo* ptr_cuer;
ta_nodo* ptr_sent;
ta_nodo* ptr_asig;
ta_nodo* ptr_conds;
ta_nodo* ptr_cond;

t_pila* pila_exp;

typedef enum {
    LEXEMA_ID,
    LEXEMA_NUM,
    LEXEMA_STR
} TipoLexema;

int yyerror();
int yylex();
void guardarEnArchivo();
void agregarLexema(const char *simboloNombre, TipoLexema tipo);


%}

%union{
    char * sid;
    char * snum;
	char * sfloat;
	char * str;
}

%token DIGITO
%token DIGITOSINCERO
%token LETRA
%token PARA
%token PARC
%token COMA
%token LLAA
%token LLAC
%token PUNTO
%token PYC
%token CORA
%token CORC
%token DOS_PUNTOS

%token <snum>CTE_INT
%token <sfloat>CTE_FLT
%token <str>CTE_STR
%token <sid>ID

/* Operadores */
%right OP_ASIG
%right MENOS_UNARIO
%token MAY
%token MEN
%token MAYI
%token MENI
%token DIST
%left OR
%left AND
%right NOT
%left OP_REST OP_SUM
%left OP_MUL OP_DIV

/* Palabras reservadas */
%token INIT
%token MIENTRAS
%token SI
%token SINO
%token ESCRIBIR
%token LEER
%token V_FLOAT
%token V_INT  
%token V_STRING  
%token BINARY_COUNT
%token SUMAR_ULTIMOS

%%
programa:  	   
	declaracion cuerpo {ptr_progr = crearNodo("programa",NULL,ptr_cuer);recorrerInOrder(&ptr_progr, file_intermedia);printf(" FIN\n");}
	;
cuerpo:
	sentencia {ptr_cuer = ptr_sent;}
	| cuerpo sentencia {ptr_cuer = crearNodo("sentencia",ptr_cuer,ptr_sent);}
	;
	  
sentencia:
	leer
	| escribir
	| if
	| while
	| asignacion {ptr_sent = ptr_asig;}
	| binary_count
	| sumaLosUltimos
	 ;


declaracion:	
	INIT LLAA lineas LLAC
	;
	
lineas: 
    lineas linea
    |linea
	;

linea:
     identificadores DOS_PUNTOS tipodeDato
	;

identificadores:
    ID {agregarLexema(yytext,LEXEMA_ID);}
    |identificadores COMA ID {agregarLexema(yytext,LEXEMA_ID);}
	;
	
tipodeDato:
	V_INT
	| V_FLOAT
	| V_STRING
	;

expresion:
	expresion OP_SUM termino{ptr_exp = crearNodo("+",ptr_exp,ptr_ter);}
	|expresion OP_REST termino{ptr_exp = crearNodo("-",ptr_exp,ptr_ter);}
	|termino {ptr_exp = ptr_ter;}
	;

termino:
	factor {ptr_ter=ptr_fact;printf("    Factor es Termino\n");}
    |termino OP_MUL factor {ptr_ter = crearNodo("*",ptr_ter,ptr_fact);printf("     Termino*Factor es Termino\n");}
    |termino OP_DIV factor {ptr_ter = crearNodo("/",ptr_ter,ptr_fact);printf("     Termino/Factor es Termino\n");}
    ;

factor:
	 ID {ptr_fact = crearHoja($1);printf("    ID es Factor \n");}
    | CTE_INT {agregarLexema(yytext,LEXEMA_NUM);ptr_fact = crearHoja($1); printf("    CTE es Factor\n");}
	| CTE_FLT {agregarLexema(yytext,LEXEMA_NUM);ptr_fact = crearHoja($1);}
	| CTE_STR {agregarLexema(yytext,LEXEMA_STR);ptr_fact = crearHoja($1);}
    ;

leer: 
	LEER PARA ID PARC {printf("Estoy leyendo una ID");}
	|LEER PARA tipo_de_dato PARC {printf("Estoy leyendo un tipo_de_Dato");}
	;
	
escribir:
	ESCRIBIR PARA CTE_STR PARC {printf("Estoy escribiendo");}
	|ESCRIBIR PARA ID PARC {printf("Estoy escribiendo");}
	;

condiciones:
	condicion {ptr_conds = ptr_cond;}
	|PARA condiciones PARC
	|condicion OR condicion
	|condicion AND condicion
	;

condicion:
	expresion {ptr_cond = ptr_exp;}
	|comparacion
	|NOT condicion
	;

comparacion:
	expresion 		MAY 	expresion
	|expresion 		MEN 	expresion
	|expresion 		MAYI 	expresion
	|expresion		MENI	expresion
	|expresion		DIST	expresion
	;

if:
    sin_sino
	|sin_sino SINO LLAA cuerpo LLAC 
	;

sin_sino:
	SI PARA condiciones PARC LLAA cuerpo LLAC
	;

while:
	MIENTRAS PARA condiciones PARC LLAA cuerpo LLAC 
	;

asignacion: 
	ID OP_ASIG condiciones {ptr_asig = crearNodo("=",crearHoja($1),ptr_conds);}
	;

tipo_de_dato:
	CTE_INT
	|CTE_FLT
	|CTE_STR
	;

binary_count:
	ID OP_ASIG BINARY_COUNT PARA lista PARC
	;

lista: 
	CORA elementos CORC 
	;

elementos: 
	elemento_binario COMA elementos
	| elemento_binario
	;

elemento_binario: 
	CTE_INT
	| OP_REST CTE_INT
	| ID
	;

sumaLosUltimos: 
	ID OP_ASIG SUMAR_ULTIMOS PARA CTE_INT PYC lista_nros PARC
	;

lista_nros: 
	CORA elementos_nros CORC
	;

elementos_nros: 
	cte_admitida COMA elementos_nros | cte_admitida
	;

cte_admitida: 
	CTE_INT | CTE_FLT
	;	
%%

void guardarEnArchivo(){

    FILE *file = fopen(SYMBOL_TABLE, "w+");
    t_lexema lexemaRecuperado;

   	if (file == NULL) {
        perror("Error al abrir el archivo");
        exit(1);
    }

    fprintf(file,"%-40s || %-10s || %-50s || %-10s\n","NOMBRE","TIPODATO","VALOR","LONGITUD");
    while( !listaVacia(&tablaSimbolos) )
    {
        sacarLexemaLista(&tablaSimbolos, &lexemaRecuperado);
        fprintf(file, "%-40s || %-10s || %-50s || %-10s\n", lexemaRecuperado.nombre, lexemaRecuperado.tipoDato, lexemaRecuperado.valor, lexemaRecuperado.longitud );
    }
    fclose(file);
}
void agregarLexema(const char *simboloNombre, TipoLexema tipo) {
    t_lexema lex;
    char nombre[100] = "_";
    char valor[100];
    char strLongitud[10] = "";
    int longitud;

    switch (tipo) {
        case LEXEMA_ID:
            strcat(nombre, simboloNombre);
            break;

        case LEXEMA_NUM:
            strcat(nombre, simboloNombre);
            strcpy(valor, simboloNombre);
            break;

        case LEXEMA_STR: {
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
    if (buscarLexemaEnLista(&tablaSimbolos, lex) == 0) {
        strcpy(lex.nombre, nombre);
        strcpy(lex.valor, tipo == LEXEMA_ID ? "" : valor);
        strcpy(lex.longitud, tipo == LEXEMA_STR ? strLongitud : "");
		strcpy(lex.tipoDato, ""); 
        insertarLexemaEnLista(&tablaSimbolos, lex);
    }
}

int main(int argc, char *argv[])
{
	crearListaLexemas(&tablaSimbolos);
    if((yyin = fopen(argv[1], "rt"))==NULL){
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    if ((file_dot = fopen(DOT_FILE, "wt")) == NULL)
    {
	    printf("\nERROR! No se pudo abrir el archivo .dot para armar el arbol\n");
	    return 1;
    } 
    if ((file_intermedia = fopen(INTERMEDIA_FILE, "wt")) == NULL)
    {
	    printf("\nERROR! No se pudo abrir el archivo intermedia\n");
	    return 1;
    }
	pila_exp = crearPila();
    yyparse();
    
	guardarEnArchivo();
	fclose(yyin);
	fclose(file_intermedia);
    generarArchivoDOT(&ptr_progr, file_dot);
    return 0;
}
int yyerror(void)
{
    printf("Error Sintactico\n");
	exit (1);
}

