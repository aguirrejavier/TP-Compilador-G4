// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "Lista.h"

#define SYMBOL_TABLE "symbol-table.txt"

int yystopparser=0;
FILE  *yyin;
char *yytext;

Lista tablaSimbolos;
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

%token CTE_INT
%token CTE_FLT
%token CTE_STR
%token ID

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
	declaracion cuerpo {printf(" FIN\n");}
	;
cuerpo:
	sentencia
	| cuerpo sentencia
	;
	  
sentencia:
	leer
	| escribir
	| if
	| while
	| asignacion
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
	expresion OP_SUM termino
	|expresion OP_REST termino
	|termino
	;

termino:
	factor {printf("    Factor es Termino\n");}
    |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
    |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
    ;

factor:
	OP_REST CTE_FLT 
	| OP_REST CTE_INT {agregarLexema(strcat("-",yytext),LEXEMA_NUM);}
    | ID {printf("    ID es Factor \n");}
    | CTE_INT {agregarLexema(yytext,LEXEMA_NUM); printf("    CTE es Factor\n");}
	| CTE_FLT {agregarLexema(yytext,LEXEMA_NUM);}
	| CTE_STR {agregarLexema(yytext,LEXEMA_STR);}
	| PARA expresion PARC {printf("    Expresion entre parentesis es Factor\n");}
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
	condicion
	|PARA condiciones PARC
	|condicion OR condicion
	|condicion AND condicion
	;

condicion:
	expresion
	|comparacion
	|NOT condicion
	|PARA comparacion PARC
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
	ID OP_ASIG condiciones
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
    else{ 
    	yyparse();
    }
	guardarEnArchivo();
	fclose(yyin);
    return 0;
}
int yyerror(void)
{
    printf("Error Sintactico\n");
	exit (1);
}

