// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();


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
%left OP_REST OP_SUM
%left OP_DIV OP_MUL
%token MAY
%token MEN
%token MAYI
%token MENI
%token DIST
%token AND
%token OR
%token NOT

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
%token VALOR_COMENTARIO

%%
programa:  	   
	cuerpo {printf(" FIN\n");}
	|declaracion cuerpo
	;
cuerpo:
	sentencia
	| cuerpo sentencia
	;
	  
sentencia:
	declaracion	
	| leer
	| escribir
	| if
	| while
	| asignacion
	| binary_count
	| sumaLosUltimos
	| vacio
	 ;

vacio:
	;

declaracion:	
	INIT LLAA lineas LLAC
	;
	
lineas: 
    lineas linea
    |linea
	;

linea:
     identificadores DOS_PUNTOS tipo_de_dato
	;

identificadores:
    identificador
    |identificadores COMA identificador
	;
	
identificador:
	V_INT
	| V_FLOAT
	| V_STRING
	;

expresion:
	termino
	|expresion OP_SUM termino
	|expresion OP_REST termino
	;

termino:
	factor {printf("    Factor es Termino\n");}
    |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
    |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
    ;

factor: 
	OP_REST factor  
    |ID {printf("    ID es Factor \n");}
    | CTE_INT {printf("    CTE es Factor\n");}
	| CTE_FLT 
	| CTE_STR
	| PARA expresion PARC {printf("    Expresion entre parentesis es Factor\n");}
    ;

leer: 
	LEER PARA ID PARC {printf("Estoy leyendo una ID");}
	|LEER PARA tipo_de_dato PARC {printf("Estoy leyendo un tipo_de_Dato");}
	;
	
escribir:
	ESCRIBIR PARA tipo_de_dato PARC {printf("Estoy escribiendo");}
	;
condiciones:
	condicion  
	|condicion OR condicion
	|condicion AND condicion
	;

condicion:
	comparacion
	|NOT PARA comparacion PARC
	|PARA comparacion PARC
	;

comparacion:
	operando 		MAY 	operando
	|operando 		MEN 	operando
	|operando 		MAYI 	operando
	|operando		MENI	operando
	|operando		DIST	operando
	;

operando:
	expresion
	|ID
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
	ID OP_ASIG expresion 
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
	CTE_INT COMA elementos | ID COMA elementos | ID | CTE_INT	
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


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
    	yyparse();
    }
	fclose(yyin);
    return 0;
}
int yyerror(void)
{
    printf("Error Sintactico\n");
	exit (1);
}

