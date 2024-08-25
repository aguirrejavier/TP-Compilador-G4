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

%token INIT
%token MIENTRAS
%token SI
%token SINO
%token ENDIF
%token ENDWHILE
%token ESCRIBIR
%token LEER
%token V_FLOAT
%token V_INT
%token V_STRING
%token BINARY_COUNT
%token SUMAR_ULTIMOS
%token AND
%token OR
%token NOT
%token OP_ASIG
%token PARA
%token PARC
%token COMA
%token MAY
%token MEN
%token MAYI
%token MENI
%token DIST
%token LLAA
%token LLAC
%token CTE_INT
%token CTE_FLT
%token CTE_STR
%token ID
%token CORA
%token CORC
%token COM_ABRE
%token COM_CIERRA
%token PYC
%token VALOR_COMENTARIO

%%
programa:  	   
	cuerpo {printf(" FIN\n");} ;
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
	 ;

leer: 
	LEER PARA ID PARC
	|LEER PARA tipo_de_dato PARC
	;
	
escribir:
	ESCRIBIR PARA tipo_de_dato PARC
	;

condiciones:
	condicion OR condicion
	|condicion AND condicion
	|condicion
	;

condicion:
	comparacion
	|NOT PARA comparacion PARC
	|PARA comparacion PARC
	;

comparacion:
	ID 		MAY 	operando
	|ID 	MEN 	operando
	|ID 	MAYI 	operando
	|ID		MENI	operando
	|ID		DIST	operando
	;
	
operando:
	ID
	|expresion
	|tipo_de_dato
	;

declaracion:	
	INIT LLAA lineas LLAC
	;
	
lineas: 
    lineas linea
    |linea
	;

linea:
     identificadores : tipo_de_dato
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
if:
    sin_sino
	|sin_sino SINO cuerpo ENDIF 
	;

sin_sino:
	SI PARA condiciones PARC cuerpo ENDIF
	;

asignacion: 
     ID OP_ASIG tipo_de_dato
	 ;

tipo_de_dato:
	CTE_INT
	|CTE_FLT
	|CTE_STR
	;
	 
while:
	MIENTRAS PARA condiciones PARC cuerpo ENDWHILE
	;
	
comentario: 
	COM_ABRE VALOR_COMENTARIO COM_CIERRA
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

