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
ta_nodo* ptr_sinsino;
ta_nodo* ptr_if;
ta_nodo* ptr_cuerciclo;
ta_nodo* ptr_true;
ta_nodo* ptr_false;
ta_nodo* ptr_sumaLosUltimos;
ta_nodo* ptr_sumaLosUltimos_aux;
ta_nodo* ptr_lista_nros;
ta_nodo* ptr_elementos_nros;
ta_nodo* ptr_elementos_nros_aux;
ta_nodo* ptr_elementos_nros_aux2;
ta_nodo* ptr_cte_admitida;
ta_nodo* ptr_leer;
ta_nodo* ptr_escribir;
ta_nodo* ptr_comp;
ta_nodo* ptr_binc;

char pivot[50];
int pivote;
int cant;
float auxSumaUltimos=0;
int contSumaUltimos;

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

%token <snum>CTE_BIN
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
	| cuerpo sentencia {ptr_cuer = crearNodo("sentencia",ptr_cuer,ptr_sent);printf("cuerpo: cuerpo sentencia\n");}
	;

cuerpo_ciclo:
	sentencia {ptr_cuerciclo = ptr_sent;}
	| cuerpo_ciclo sentencia {ptr_cuerciclo = crearNodo("sentencia",ptr_cuerciclo,ptr_sent);printf("cuerpo: cuerpo sentencia\n");}
	;
	  
sentencia:
	leer {ptr_sent = ptr_leer;printf("leer\n");}
	| escribir {ptr_sent = ptr_escribir;}
	| if {ptr_sent = ptr_if;printf("sentencia sentencia = if\n");}
	| while
	| asignacion {ptr_sent = ptr_asig;}
	| binary_count {ptr_sent = ptr_binc;}
	| sumaLosUltimos {ptr_sent = ptr_sumaLosUltimos;}
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
	expresion OP_SUM termino{ptr_exp = crearNodo("+",ptr_exp,ptr_ter);printf("     Expresion+Termino es Expresion\n");}
	|expresion OP_REST termino{ptr_exp = crearNodo("-",ptr_exp,ptr_ter);printf("     Expresion-Termino es Expresion\n");}
	|termino {ptr_exp = ptr_ter;printf("    Termino es Expresion\n");}
	;

termino:
	factor {ptr_ter=ptr_fact;printf("    Factor es Termino\n");}
    |termino OP_MUL factor {ptr_ter = crearNodo("*",ptr_ter,ptr_fact);printf("     Termino*Factor es Termino\n");}
    |termino OP_DIV factor {ptr_ter = crearNodo("/",ptr_ter,ptr_fact);printf("     Termino/Factor es Termino\n");}
    ;

factor:
	 ID {ptr_fact = crearHoja($1);printf("    ID es Factor \n");}
	| CTE_BIM {agregarLexema(yytext,LEXEMA_NUM);ptr_fact = crearHoja($1); printf("    CTE_INT es Factor\n");}
    	| CTE_INT {agregarLexema(yytext,LEXEMA_NUM);ptr_fact = crearHoja($1); printf("    CTE_INT es Factor\n");}
	| CTE_FLT {agregarLexema(yytext,LEXEMA_NUM);ptr_fact = crearHoja($1); printf("    CTE_FLT es Factor\n");}
	| CTE_STR {agregarLexema(yytext,LEXEMA_STR);ptr_fact = crearHoja($1); printf("    CTE_STR es Factor\n");}
    ;

leer: 
	LEER PARA factor PARC {ptr_leer = crearNodo("leer",NULL, ptr_fact); printf("leer");}
	;

escribir:
	ESCRIBIR PARA CTE_STR PARC {printf($3); ptr_escribir = crearNodo("escribir",NULL, crearHoja($3));}
	|ESCRIBIR PARA ID PARC {printf($3); ptr_escribir = crearNodo("escribir",NULL, crearHoja($3));}
	;

condiciones:
	condicion {ptr_conds = ptr_cond;}
	|PARA condiciones PARC
	|condicion {apilar(pila_exp, ptr_cond);} OR condicion {ptr_conds = crearNodo("OR",desapilar(pila_exp), ptr_cond);}
	|condicion {apilar(pila_exp, ptr_cond);} AND condicion {ptr_conds = crearNodo("AND",desapilar(pila_exp), ptr_cond);}
	;

condicion:
	expresion {ptr_cond = ptr_exp;}
	|comparacion {ptr_cond = ptr_comp;}
	|NOT condicion {ptr_cond = crearNodo("NOT",NULL, ptr_cond);}
	;

comparacion:
	expresion   {apilar(pila_exp, ptr_exp);}	MAY 	expresion {ptr_comp = crearNodo(">", desapilar(pila_exp), ptr_exp);}
	|expresion 	{apilar(pila_exp, ptr_exp);}	MEN 	expresion {ptr_comp = crearNodo("<", desapilar(pila_exp), ptr_exp);}
	|expresion 	{apilar(pila_exp, ptr_exp);}	MAYI 	expresion {ptr_comp = crearNodo(">=", desapilar(pila_exp), ptr_exp);}
	|expresion	{apilar(pila_exp, ptr_exp);}	MENI	expresion {ptr_comp = crearNodo("<=", desapilar(pila_exp), ptr_exp);}
	|expresion	{apilar(pila_exp, ptr_exp);}	DIST	expresion {ptr_comp = crearNodo("<>", desapilar(pila_exp), ptr_exp);}
	;

if:
    sin_sino {ptr_if = ptr_sinsino; printf("sentencia if\n");}
	|sin_sino SINO LLAA cuerpo_ciclo LLAC { ptr_true->hijoDerecho = ptr_cuerciclo; ptr_if = ptr_sinsino;}
	;

sin_sino:
	SI PARA condiciones PARC LLAA cuerpo_ciclo LLAC { ptr_sinsino = crearNodo("if",crearNodo("condicion",NULL,ptr_conds) , ptr_true = crearNodo("cuerpo",ptr_cuerciclo,NULL));printf("sentencia sin_sino\n"); }
	;
	


while:
	MIENTRAS PARA condiciones PARC LLAA cuerpo_ciclo LLAC 
	;

asignacion: 
	ID OP_ASIG condiciones {ptr_asig = crearNodo("=",crearHoja($1),ptr_conds);}
	;

binary_count:
	ID OP_ASIG { cant = 0;} BINARY_COUNT PARA lista PARC {ptr_binc = crearNodo("=",crearHoja($1),crearHoja("cant"));ptr_binc = crearNodo("BINARY_COUNT",NULL,ptr_binc);printf("HOLACUNATO?%d",cant);}
	;

lista: 
	CORA elementos CORC 
	;

elementos: 
	elemento_binario COMA  elementos
	| elemento_binario
	;

elemento_binario: 
	CTE_BIN { cant++;printf("INCREMENTOCOSO");}
	| OP_REST CTE_INT
	| ID
	| CTE_INT 
	;

sumaLosUltimos: 
	ID OP_ASIG SUMAR_ULTIMOS PARA CTE_INT {
		strcpy(pivot,$5);
		pivote= atoi($5);
		printf("PIVOT: %s \n", pivot);
		printf("PIVOT FLOAT: %d \n", pivote);
		ptr_sumaLosUltimos_aux = crearNodo("=",crearHoja("PIVOT"),crearHoja(pivot));
	} 
	PYC lista_nros PARC { 
		char *cadena = (char *)malloc(20 * sizeof(char));
		sprintf(cadena, "%.2f", auxSumaUltimos);
		ptr_sumaLosUltimos = crearNodo("=",crearHoja($1),crearHoja(cadena));
		ptr_sumaLosUltimos = crearNodo(";",ptr_lista_nros,ptr_sumaLosUltimos);
		ptr_sumaLosUltimos = crearNodo("SUMULT",ptr_sumaLosUltimos_aux,ptr_sumaLosUltimos);
		}
	;

lista_nros: 
	CORA elementos_nros CORC {ptr_lista_nros = ptr_elementos_nros;}
	;

elementos_nros: 
	elementos_nros COMA cte_admitida 
	{
		contSumaUltimos = contSumaUltimos + 1;
		float aux=0;
		char* endPtr;
		ta_nodo nodoAux = *ptr_cte_admitida;
		aux = strtof(nodoAux.descripcion, &endPtr);
		if(contSumaUltimos >= pivote) { auxSumaUltimos = auxSumaUltimos + aux; }
		ptr_elementos_nros_aux = crearNodo("+",crearHoja("@cant"),ptr_cte_admitida);
		ptr_elementos_nros_aux = crearNodo("=",crearHoja("@cant"),ptr_elementos_nros_aux);
		ptr_elementos_nros_aux = crearNodo("IF",crearNodo(">=",crearHoja("@cont"),crearHoja(pivot)),ptr_elementos_nros_aux);
		ptr_elementos_nros_aux2 = crearNodo("+",crearHoja("@cont"),crearHoja("1"));
		ptr_elementos_nros_aux2 = crearNodo("=",crearHoja("@cont"),ptr_elementos_nros_aux2);
		ptr_elementos_nros_aux = crearNodo("suma_si",ptr_elementos_nros_aux2,ptr_elementos_nros_aux);
		ptr_elementos_nros = crearNodo("suma_si",ptr_elementos_nros,ptr_elementos_nros_aux);
		
	}
	| cte_admitida {
		ptr_elementos_nros = crearNodo("=",crearHoja("@cont"),crearHoja("1"));
		ptr_elementos_nros_aux = crearNodo("+",crearHoja("@cant"),ptr_cte_admitida);
		ptr_elementos_nros_aux = crearNodo("=",crearHoja("@cant"),ptr_elementos_nros_aux);
		ptr_elementos_nros_aux = crearNodo("IF",crearNodo(">=",crearHoja("@cont"),crearHoja(pivot)),ptr_elementos_nros_aux);
		ptr_elementos_nros = crearNodo("suma_si",ptr_elementos_nros,ptr_elementos_nros_aux);
		contSumaUltimos = 1;
	}
	;

cte_admitida: 
	 CTE_FLT {ptr_cte_admitida = crearHoja($1);}
	| CTE_INT  {ptr_cte_admitida = crearHoja($1);}
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

