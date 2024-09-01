%{
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <float.h>
#include <string.h>
#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);
int validarEntero(const char *str);
int validarFloat(const char *str);
int validarInt16(const char *str);
int validarFloat32(const char *str);
int validarString(char* STR);
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
PYC                 ";"
CORA                "["
CORC                "]"
DOS_PUNTOS          ":"

CTE_FLT             (({DIGITO}+{PUNTO}{DIGITO}*)|({DIGITO}*{PUNTO}{DIGITO}+))
CTE_INT            ({DIGITOSINCERO}{DIGITO}*)|0
CTE_STR             \"[^"]*\" 
ID                  {LETRA}({LETRA}|{DIGITO})*

/* Operadores */
OP_ASIG             ":""="
OP_SUM              "+"
OP_REST             "-"
OP_DIV              "/"
OP_MUL              "*"
MAY                 ">"
MEN                 "<"
MAYI                ">="
MENI                "<="
DIST                "<>"
AND                 "AND"
OR                  "OR"
NOT                 "NOT"
MENOS_UNARIO         "-"

/* Palabras reservadas */
INIT                "init"
MIENTRAS            "while"
SI                  "if"
SINO                "else"
ESCRIBIR            "write"
LEER                "read"
V_FLOAT             "Float"
V_INT               "Int"
V_STRING            "String"
BINARY_COUNT        "binaryCount"
SUMAR_ULTIMOS       "sumaLosUltimos"
VALOR_COMENTARIO    "*-"[^-\%\&\|\;\@\#\^\~\$]*"-*"


%%
{INIT}              {return INIT;}
{MIENTRAS}          {return MIENTRAS;}
{SI}                {return SI;}
{SINO}              {return SINO;}
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
{OP_SUM}            {return OP_SUM;}
{OP_REST}           {printf("\nresta: %s\n",yytext);return OP_REST;}
{OP_DIV}            {return OP_DIV;}
{OP_MUL}            {return OP_MUL;}

{CTE_FLT}           {validarFloat(yytext);return CTE_FLT;}
{CTE_INT}           {validarEntero(yytext);return CTE_INT;}
{CTE_STR}           {validarString(yytext);return CTE_STR;}
{ID}                {printf("\nIdentificador: %s\n",yytext);return ID;}

{OP_ASIG}           {return OP_ASIG;}

{PARA}              {return PARA;}
{PARC}              {return PARC;}
{CORA}              {return CORA;}
{CORC}              {return CORC;}
{COMA}              {return COMA;}
{PYC}               {return PYC;}
{MAY}               {return MAY;}
{MEN}               {return MEN;}
{MAYI}              {return MAYI;}
{MENI}              {return MENI;}
{DIST}              {return DIST;}
{LLAA}              {return LLAA;}
{LLAC}              {return LLAC;}
{DOS_PUNTOS}        {return DOS_PUNTOS;}
{VALOR_COMENTARIO}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.                   { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%



    int validarInt16(const char *str) {
        char *endptr;
        long valorEntero;

        errno = 0;
        valorEntero = strtol(str, &endptr, 10);
        if (errno == 0 && *endptr == '\0' && valorEntero >= SHRT_MIN && valorEntero <= SHRT_MAX) {
            return 1;
        }
        return 0; 
    }

    int validarFloat32(const char *str) {
        char *endptr;
        float valorFlotante;

        errno = 0;
        valorFlotante = strtof(str, &endptr);
        printf("%f",valorFlotante);
        if (errno == 0 && *endptr == '\0' && valorFlotante >= -FLT_MAX && valorFlotante <= FLT_MAX) {
            return 1;
        }
        return 0; 
    }

    int validarString(char* STR)
    {
        if(strlen(STR) > 40)
        {
            printf("ERROR LEXICO : STR excede la capacidad maxima\n");
            exit(1);
        }
        return 1;
    }

    int validarEntero(const char *str)
    {
        if(validarInt16(str))
        {
            return 1;
        }
            printf("ERROR LEXICO : INT excede la capacidad maxima\n");
        exit(1);
    }

    int validarFloat(const char *str)
    {
        if(validarFloat32(str))
        {
            return 1;
        }
            printf("ERROR LEXICO : FLOAT excede la capacidad maxima\n");
        exit(1);
    }