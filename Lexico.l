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
VALOR_COMENTARIO    "[^\-\%\&\|\;\@\#\^\~\$]*"
PARA                "("
PARC                ")"
COMA                ","
LLAA                "{"
LLAC                "}"
PUNTO               "."
PYC                 ";"
CORA                "["
CORC                "]"
COM_ABRE            "*-"         
COM_CIERRA          "-*"

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
OP_SUM              "+"
OP_REST             "-"
OP_DIV              "/"
OP_MUL              "*"
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
{VALOR_COMENTARIO}  {return VALOR_COMENTARIO;}
{BINARY_COUNT}      {return BINARY_COUNT;}
{SUMAR_ULTIMOS}     {return SUMAR_ULTIMOS;}

{AND}               {return AND;}
{OR}                {return OR;}
{NOT}               {return NOT;}

{OP_ASIG}           {return OP_ASIG;}
{OP_SUM}            {return OP_SUM;}
{OP_REST}           {return OP_REST;}
{OP_DIV}            {return OP_DIV;}
{OP_MUL}            {return OP_MUL;}
{PARA}              {return PARA;}
{PARC}              {return PARC;}
{CORA}              {return CORA;}
{CORC}              {return CORC;}
{COM_ABRE}          {return COM_ABRE;}
{COM_CIERRA}        {return COM_CIERRA;}
{COMA}              {return COMA;}
{PYC}               {return PYC;}
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


