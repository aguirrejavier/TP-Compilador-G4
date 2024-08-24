%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]

CTE                 {DIGITO}+
ID                  {LETRA}({LETRA}|{DIGITO})*
PA                  "("
PC                  ")"

/* Operadores */
OP_ASIG             ":""="


/* Operadores logicos*/
OP_AND              "AND"
OP_OR               "OR"
OP_NOT              "NOT"

/* Palabras reservadas */
MIENTRAS            "mientras"
INIT                "init"
SI                  "si"
SINO                "sino"
ESCRIBIR            "escribir"
LEER                "leer"
V_FLOAT             "Float"
V_INT               "Int"
V_STRING            "String"
GET_PENULTIMA_OP    "getPenultimatePosition"
SUMAR_ULTIMOS       "sumaLosUltimos"

%%
{MIENTRAS}          {return MIENTRAS;}
{INIT}              {return INIT;}
{SI}                {return SI;}
{SINO}              {return SINO;}
{ESCRIBIR}          {return ESCRIBIR;}
{LEER}              {return LEER;}
{V_FLOAT}           {return V_FLOAT;}
{V_INT}             {return V_INT;}
{V_STRING}          {return V_STRING;}
{GET_PENULTIMA_OP}  {return GET_PENULTIMA_OP;}
{SUMAR_ULTIMOS}     {return SUMAR_ULTIMOS;}

{OP_AND}            {return OP_AND;}
{OP_OR}             {return OP_OR;}
{OP_NOT}            {return OP_NOT;}

{OP_ASIG}           {return OP_ASIG;}
{PA}                {return PA;}
{PC}                {return PC;}

{CTE}               {return CTE;}
{ID}                {return ID;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


