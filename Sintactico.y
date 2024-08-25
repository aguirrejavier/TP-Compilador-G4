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

%%
sentencia:  	   
	asignacion {printf(" FIN\n");} ;

asignacion: 
	ID OP_AS expresion
	  ;
	  
expresion:
	termino
	|expresion OP_SUM termino
	|expresion OP_RES termino
	 ;

termino:
       factor {printf("    Factor es Termino\n");}
       |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
       |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
       ;

factor: 
      ID {printf("    ID es Factor \n");}
      | CTE {printf("    CTE es Factor\n");}
	| PARA expresion PARC {printf("    Expresion entre parentesis es Factor\n");}
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
	|CTE
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

