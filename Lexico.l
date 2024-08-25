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

DIGITO              [0-9]
DIGITOSINCERO       [1-9]
LETRA               [a-zA-Z]
PARA                "("
PARC                ")"
COMA                ","
LLAA                "{"
LLAC                "}"
PUNTO               "."

CTE_INT             (-?{DIGITOSINCERO}{DIGITO}*)|0
CTE_FLT             -?(({DIGITO}+{PUNTO}{DIGITO}*)|({DIGITO}*{PUNTO}{DIGITO}+))
CTE_STR             \"[^"]*\"
ID                  {LETRA}({LETRA}|{DIGITO})*

/* Operadores */
OP_ASIG             ":""="
MAY                 ">"
MEN                 "<"
MAYI                ">="
MENI                "<="
DIST                "<>"

AND                 "AND"
OR                  "OR"
NOT                 "NOT"

/* Palabras reservadas */
INIT                "init"
MIENTRAS            "while"
SI                  "if"
SINO                "else"
ENDIF               "endif"
ENDWHILE            "endwhile"
ESCRIBIR            "escribir"
LEER                "leer"
V_FLOAT             "Float"
V_INT               "Int"
V_STRING            "String"
BINARY_COUNT        "binaryCount"
SUMAR_ULTIMOS       "sumaLosUltimos"

%%
{INIT}              {return INIT;}
{MIENTRAS}          {return MIENTRAS;}
{SI}                {return SI;}
{SINO}              {return SINO;}
{ENDIF}             {return ENDIF;}
{ENDWHILE}          {return ENDWHILE;}
{ESCRIBIR}          {return ESCRIBIR;}
{LEER}              {return LEER;}
{V_FLOAT}           {return V_FLOAT;}
{V_INT}             {return V_INT;}
{V_STRING}          {return V_STRING;}
{BINARY_COUNT}      {return BINARY_COUNT;}
{SUMAR_ULTIMOS}     {return SUMAR_ULTIMOS;}

{AND}               {return AND;}
{OR}                {return OR;}
{NOT}               {return NOT;}

{OP_ASIG}           {return OP_ASIG;}
{PARA}              {return PARA;}
{PARC}              {return PARC;}
{COMA}              {return COMA;}
{MAY}               {return MAY;}
{MEN}               {return MEN;}
{MAYI}              {return MAYI;}
{MENI}              {return MENI;}
{DIST}              {return DIST;}
{LLAA}              {return LLAA;}
{LLAC}              {return LLAC;}

{CTE_INT}           {return CTE_INT;}
{CTE_FLT}           {return CTE_FLT;}
{CTE_STR}           {return CTE_STR;}
{ID}                {return ID;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.                   { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


