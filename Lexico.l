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
OP_SUM              "+"
OP_MUL              "*"
OP_RES              "-"
OP_DIV              "/"

/* Palabras reservadas */
MIENTRAS            "mientras"
INIT                "init"
SI                  "si"
SINO                "sino"
ESCRIBIR            "escribir"
LEER                "leer"
T_FLOAT             "Float"
T_INT               "Int"
T_STRING            "String"
GET_PENULTIMA_OP    "getPenultimatePosition"
SUMAR_ULTIMOS       "sumaLosUltimos"

%%
{MIENTRAS}          {return MIENTRAS;}
{INIT}              {return INIT;}
{SI}                {return SI;}
{SINO}              {return SINO;}
{ESCRIBIR}          {return ESCRIBIR;}
{LEER}              {return LEER;}
{T_FLOAT}           {return T_FLOAT;}
{T_INT}             {return T_INT;}
{T_STRING}          {return T_STRING;}
{GET_PENULTIMA_OP}  {return GET_PENULTIMA_OP;}
{SUMAR_ULTIMOS}     {return SUMAR_ULTIMOS;}

{CTE}			{printf("\nConstante: %s\n", yytext);return CTE;}
{ID}			{printf("\nIdentificador: %s\n", yytext);return ID;}
{OP_SUM}		{printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_ASIG}		{printf("\nAsignacion: %s\n", yytext);return OP_ASIG;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}
"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


