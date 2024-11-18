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
#include "bin/assembler.h"

#define SYMBOL_TABLE "symbol-table.txt"
#define DOT_FILE "arbol.dot"
#define INTERMEDIA_FILE "intermedia.txt"
#define ASSEMBLER_FILE "Final.asm"

#define MAX_ID_COUNT 100
char *identificadores[MAX_ID_COUNT];
int contador = 0;
int error = 0;
int yystopparser=0;
FILE  *yyin;
char *yytext;

Lista tablaSimbolos;
FILE  *file_dot;
FILE  *file_intermedia;
FILE  *f_asm;

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
ta_nodo* ptr_sumaLosUltimos_aux2;
ta_nodo* ptr_lista_nros;
ta_nodo* ptr_elementos_nros;
ta_nodo* ptr_elementos_nros_aux;
ta_nodo* ptr_elementos_nros_aux2;
ta_nodo* ptr_cte_admitida;
ta_nodo* ptr_leer;
ta_nodo* ptr_escribir;
ta_nodo* ptr_comp;
ta_nodo* ptr_binc;
ta_nodo* ptr_elementos;
ta_nodo* ptr_elementos_false;
ta_nodo* ptr_elementos_true;
ta_nodo* ptr_elemetos_cuerpo;
ta_nodo* ptr_elemento_binario;
ta_nodo* ptr_lista;
ta_nodo* ptr_while;
ta_nodo* ptr_while_aux;

char pivot[50];
int pivote;
int cant;
int auxDatos;
int auxValidacion;
float auxSumaUltimos=0;
int contSumaUltimos;
t_lexema lex;
t_pila* pila_exp;
t_pila* pila_conds;
char* tipoDatoActual = "Int";
void formatearConstante(char *constante, char *resultado, TipoLexema tipo);

int yyerror();
int yylex();
void guardarEnArchivo();
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
%token <str> V_FLOAT
%token <str> V_INT  
%token <str> V_STRING  
%token BINARY_COUNT
%token SUMAR_ULTIMOS

%%
programa:  	   
	declaracion cuerpo {ptr_progr = crearNodo("programa",NULL,ptr_cuer);recorrerInOrder(&ptr_progr, file_intermedia);printf(" FIN\n");guardarEnArchivo();generarArchivoDOT(&ptr_progr, file_dot);generarCodigoAssembler(&ptr_progr, f_asm, tablaSimbolos);}
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
	| while {ptr_sent = ptr_while;}
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
     identificadores DOS_PUNTOS tipodeDato{
		int i;
		for (i = 0; i < contador; i++) {
            error = agregarLexema(identificadores[i], LEXEMA_ID, tipoDatoActual,&tablaSimbolos);
			if (error == -1){
				printf("ERROR SEMANTICO: DEFINICION DE VARIABLE DUPLICADA\n");
				return;
			}
        }
        contador = 0;
	 }
	;

identificadores:
    ID {identificadores[contador] = strdup(yytext);
        contador++;}
    |identificadores COMA ID {identificadores[contador] = strdup(yytext);
        contador++;}
	;
	
tipodeDato:
	V_INT {tipoDatoActual = "Int";}
    | V_FLOAT	{tipoDatoActual = "Float";}
    | V_STRING	{tipoDatoActual = "String";}
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
	 ID {ptr_fact = crearHoja($1);printf("    ID es Factor \n"); strcpy(lex.nombre,$1); auxValidacion = buscarLexemaEnLista(&tablaSimbolos,lex); if(!auxValidacion) {printf("ERROR SEMANTICO: UTILIZACION DE VARIABLE NO DECLARADA\n"); return -1;};if(auxDatos == 0){auxDatos = auxValidacion;}; if(auxDatos != auxValidacion){printf("ERROR SEMANTICO: DISTINTO TIPO EN CONDICIONES.");return -1;}; }
	| CTE_BIN {agregarLexema(yytext,LEXEMA_NUM,"",&tablaSimbolos);ptr_fact = crearHoja($1); printf("    CTE_INT es Factor\n");}
    | CTE_INT {agregarLexema(yytext,LEXEMA_NUM,"",&tablaSimbolos);char resultado[100];formatearConstante($1, resultado,LEXEMA_NUM);ptr_fact = crearHoja(resultado); printf("    CTE_INT es Factor\n"); if(auxDatos == 0){auxDatos = 1;}; if(auxDatos == 2){printf("ERROR SEMANTICO: DISTINTO TIPO EN CONDICIONES.");return -1;}}
	| CTE_FLT {agregarLexema(yytext,LEXEMA_NUM,"",&tablaSimbolos);char resultado[100];formatearConstante($1, resultado,LEXEMA_NUM);ptr_fact = crearHoja(resultado); printf("    CTE_FLT es Factor\n"); if(auxDatos == 0){auxDatos = 1;}; if(auxDatos == 2){printf("ERROR SEMANTICO: DISTINTO TIPO EN CONDICIONES.");return -1;}}
	| CTE_STR {agregarLexema(yytext,LEXEMA_STR,"",&tablaSimbolos);char resultado[100];formatearConstante($1, resultado,LEXEMA_STR);ptr_fact = crearHoja(resultado); printf("    CTE_STR es Factor\n"); if(auxDatos == 0){auxDatos = 2;}; if(auxDatos == 1){printf("ERROR SEMANTICO: DISTINTO TIPO EN CONDICIONES.");return -1;} }
    ;

leer: 
	LEER PARA {auxDatos = 0;} factor PARC {ptr_leer = crearNodo("leer",NULL, ptr_fact); printf("leer\n");}
	;

escribir:
	ESCRIBIR PARA CTE_STR PARC {agregarLexema($3,LEXEMA_STR,"",&tablaSimbolos);char resultado[100];formatearConstante($3, resultado,LEXEMA_STR);printf($3); ptr_escribir = crearNodo("escribir",NULL, crearHoja(resultado));}
	|ESCRIBIR PARA ID PARC {printf($3); ptr_escribir = crearNodo("escribir",NULL, crearHoja($3));}
	;

condiciones:
	condicion {ptr_conds = ptr_cond; apilar(pila_conds, ptr_conds); }
	|PARA condiciones PARC {}
	|condicion {apilar(pila_exp, ptr_cond);} OR condicion {ptr_conds = crearNodo("OR",desapilar(pila_exp), ptr_cond); apilar(pila_conds, ptr_conds);}
	|condicion {apilar(pila_exp, ptr_cond);} AND condicion {ptr_conds = crearNodo("AND",desapilar(pila_exp), ptr_cond);apilar(pila_conds, ptr_conds);}
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
	|sin_sino SINO LLAA cuerpo_ciclo LLAC { ptr_true->hijoDerecho = crearNodo("else",NULL,ptr_cuerciclo); ptr_if = ptr_sinsino;}
	;

sin_sino:
	SI PARA {auxDatos = 0;} condiciones PARC LLAA cuerpo_ciclo LLAC { ptr_sinsino = crearNodo("if",crearNodo("condicion",NULL,desapilar(pila_conds)) , ptr_true = crearNodo("cuerpo",ptr_cuerciclo,NULL));printf("sentencia sin_sino\n"); }
	;
	
while:
	MIENTRAS PARA {auxDatos = 0;}  condiciones{ptr_while_aux=ptr_conds;} PARC LLAA cuerpo_ciclo LLAC {ptr_while = crearNodo("while",ptr_while_aux,ptr_cuerciclo);}
	;

asignacion: 
	ID  OP_ASIG {auxDatos = 0;}  condiciones {printf("\n\n%d\n\n",auxDatos);strcpy(lex.nombre,$1);auxValidacion = buscarLexemaEnLista(&tablaSimbolos,lex); printf("\n\n%d\n\n",auxValidacion);if(auxValidacion != auxDatos){printf("ERROR SEMANTICO: ASIGNACION CON DISTINTO TIPO DE DATO.");return -1;} if(!buscarLexemaEnLista(&tablaSimbolos,lex)) {printf("ERROR SEMANTICO: UTILIZACION DE VARIABLE NO DECLARADA\n"); return -1;}; ptr_asig = crearNodo(":=",crearHoja($1),ptr_conds);}
	;

binary_count:
	ID OP_ASIG { cant = 0;} BINARY_COUNT PARA lista PARC {ptr_binc = crearNodo(":=",crearHoja($1),crearHoja("@contadorBinario")); ptr_binc = crearNodo("BYNARY_COUNT",ptr_lista,ptr_binc);}
	;

lista: 
	CORA elementos CORC {ptr_lista = ptr_elementos;}
	;

elementos: 
	elementos COMA elemento_binario{
		ptr_elemetos_cuerpo = crearNodo("+",crearHoja("@contadorBinario"),crearHoja("1"));
		ptr_elemetos_cuerpo = crearNodo(":=",crearHoja("@contadorBinario"),ptr_elemetos_cuerpo);
		ptr_elemetos_cuerpo = crearNodo("if",crearNodo("==",ptr_elemento_binario,crearHoja("es_binario")),ptr_elemetos_cuerpo);
		ptr_elementos = crearNodo("sentencia",ptr_elementos,ptr_elemetos_cuerpo);
	}
	| elemento_binario { ptr_elementos = crearNodo("==",ptr_elemento_binario,crearHoja("es_binario")); 
						ptr_elementos_true = crearNodo(":=",crearHoja("@contadorBinario"),crearHoja("1"));
						ptr_elementos_false = crearNodo(":=",crearHoja("@contadorBinario"),crearHoja("0"));
						ptr_elementos_false = crearNodo("else",NULL,ptr_elementos_false);
						ptr_elemetos_cuerpo = crearNodo("cuerpo",ptr_elementos_true, ptr_elementos_false);
						ptr_elementos = crearNodo("if",ptr_elementos,ptr_elemetos_cuerpo); 
						}
	;

elemento_binario: 
	  OP_REST CTE_INT {
		char lexemaAux[12];
		sprintf(lexemaAux, "-%s", $2);
		ptr_elemento_binario = crearHoja(lexemaAux);}
	| ID {ptr_elemento_binario = crearHoja($1);}
	| CTE_INT {ptr_elemento_binario = crearHoja($1);}
	;

sumaLosUltimos: 
	ID OP_ASIG SUMAR_ULTIMOS PARA CTE_INT {
		strcpy(pivot,$5);
		pivote = atoi($5);
		ptr_sumaLosUltimos_aux = crearNodo(":=",crearHoja("@PIVOT"),crearHoja(pivot));
		ptr_sumaLosUltimos = crearNodo(":=",crearHoja("@cant"),crearHoja("0"));
		ptr_sumaLosUltimos_aux = crearNodo(";",ptr_sumaLosUltimos_aux,ptr_sumaLosUltimos);
	} 
	PYC lista_nros PARC { 
				char *cadena = (char *)malloc(20 * sizeof(char));
				sprintf(cadena, "%.2f", auxSumaUltimos);
				ptr_sumaLosUltimos = crearNodo(":=",crearHoja($1),crearHoja("@cant"));
				ptr_sumaLosUltimos_aux2 = crearNodo(":=",crearHoja($1),crearHoja(cadena));
				ptr_sumaLosUltimos = crearNodo(";",ptr_sumaLosUltimos,ptr_sumaLosUltimos_aux2 );
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
		ptr_elementos_nros_aux = crearNodo("if",crearNodo(">=",crearHoja("@cont"),crearHoja("@PIVOT")),ptr_elementos_nros_aux);
		ptr_elementos_nros_aux2 = crearNodo("+",crearHoja("@cont"),crearHoja("1"));
		ptr_elementos_nros_aux2 = crearNodo("=",crearHoja("@cont"),ptr_elementos_nros_aux2);
		ptr_elementos_nros_aux = crearNodo("suma_si",ptr_elementos_nros_aux2,ptr_elementos_nros_aux);
		ptr_elementos_nros = crearNodo("suma_si",ptr_elementos_nros,ptr_elementos_nros_aux);
		
	}
	| cte_admitida {
		ptr_elementos_nros = crearNodo("=",crearHoja("@cont"),crearHoja("1"));
		ptr_elementos_nros_aux = crearNodo("+",crearHoja("@cant"),ptr_cte_admitida);
		ptr_elementos_nros_aux = crearNodo("=",crearHoja("@cant"),ptr_elementos_nros_aux);
		ptr_elementos_nros_aux = crearNodo("if",crearNodo(">=",crearHoja("@cont"),crearHoja("@PIVOT")),ptr_elementos_nros_aux);
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
	Lista tablaSimbolosCopia;
	tablaSimbolosCopia.cabeza = NULL;
	copiarLista(&tablaSimbolos, &tablaSimbolosCopia);
   	if (file == NULL) {
        perror("Error al abrir el archivo");
        exit(1);
    }

    fprintf(file,"%-40s || %-10s || %-50s || %-10s\n","NOMBRE","TIPODATO","VALOR","LONGITUD");
    while( !listaVacia(&tablaSimbolosCopia) )
    {
        sacarLexemaLista(&tablaSimbolosCopia, &lexemaRecuperado);
        fprintf(file, "%-40s || %-10s || %-50s || %-10s\n", lexemaRecuperado.nombre, lexemaRecuperado.tipoDato, lexemaRecuperado.valor, lexemaRecuperado.longitud );
    }
    fclose(file);
}
void formatearConstante(char *constante, char *resultado, TipoLexema tipo) {

	char temp[100];  
    int i, j = 1;
    resultado[0] = '_';
    for (i = 0; constante[i] != '\0'; i++) {
        if (constante[i] == '.' || constante[i] == ' ') {
            resultado[j++] = '_'; 
        } else if (constante[i] != '\"') {
            resultado[j++] = constante[i];
        }
    }
    resultado[j] = '\0';
	if (tipo == LEXEMA_STR) {
        sprintf(temp, "%%s%s", resultado);
        strcpy(resultado, temp);
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
	if ((f_asm = fopen(ASSEMBLER_FILE, "wt")) == NULL){
		printf("\nERROR! No se pudo abrir el archivo Final.asm para armar el programa\n");
		return 1;
		}
	pila_exp = crearPila();
	pila_conds = crearPila();
    yyparse();
    
	fclose(yyin);
	fclose(file_intermedia);
    return 0;
}
int yyerror(void)
{
    printf("Error Sintactico\n");
	exit (1);
}

