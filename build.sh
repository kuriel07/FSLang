#!/bin/sh

bison fsl_parser.y
flex fsl_lexer.lex

echo "generating fsl compiler"
gcc fsl_parser.tab.c lex.yy.c -o fsl

echo "execute sample.fsl"
./fsl sample.fsl

