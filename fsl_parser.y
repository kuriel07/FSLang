
%{
#define NULL	0
int errors = 0;
int yyerror ( char *s );

typedef struct vm_var vm_var;

struct vm_var {
	char name[32];
	int value;
	vm_var * next;
};

vm_var * _vars = NULL;
vm_var * _current_var = NULL;
int _stacks[100];
int _stack_index = 0;

void push(int val) { _stacks[_stack_index++] = val; }
int pop(void) { return _stacks[--_stack_index];  }

vm_var * create_variable(char * name, int value) {
	vm_var * var = malloc(sizeof(vm_var));
	strncpy(var->name, name, 32);
	var->value = value;
	var->next = NULL;
	return var;
}

vm_var * add_variable(vm_var * var) {
	vm_var * iterator = _vars;
	if(iterator == NULL) _vars = var;
	else {
		while(iterator->next != NULL) {
			iterator = iterator->next;
		}
		iterator->next = var;
	}
	return var;
}

vm_var * select_variable(char * name) {
	vm_var * iterator = _vars;
		while(iterator!= NULL) {
			if(strcmp(iterator->name , name) == 0) {
				return iterator;
			}
			iterator = iterator->next;
		}
	return NULL;
}


/*************************************************************************
Compiler for the FSL language
***************************************************************************/
/*=========================================================================
C Libraries, Symbol Table, Code Generator & other C code
=========================================================================*/
#include <stdio.h> /* For I/O */
#include <stdlib.h> /* For malloc here and in symbol table */
#include <string.h> /* For strcmp in symbol table */
#include <stdarg.h>


#define YYDEBUG 1 /* For Debugging */


%}


%union semrec
{
	char string[4096];
	int value;
}

/*=========================================================================
TOKENS
=========================================================================*/
%start program

%token P_INPUT			512
%token  P_OUTPUT		513
%token  P_VAR				514
%token  P_CONST			515

%token  P_ADD				516
%token  P_SUB				517
%token  P_MUL				518
%token  P_DIV				519

%token  P_ASSIGNMENT		520
%token  P_EOS					521

%type<string> P_VAR;		//string
%type<value> P_CONST;			//int
%type<value> P_INPUT;			//int

/*=========================================================================
GRAMMAR RULES for the Simple language
=========================================================================*/
%%
/*********************************************** SEMANTIC RULES SHALL BE WRITTEN HERE (LANGUAGE DEPENDENT) ***********************************************/
program: /*  */
| program stmt
| stmt
;
stmt: P_VAR P_ASSIGNMENT
		{ vm_var * var = select_variable($1);
				if(var == NULL) _current_var = add_variable(create_variable($1, 0));
				else _current_var = var;
		 }
			expr P_EOS { _current_var->value = pop(); }
| P_OUTPUT P_ASSIGNMENT expr P_EOS { printf("output : %d\n", pop()); }
;
expr: expr P_ADD expr { int x=pop(); int y=pop(); push(y+x);  }
| expr P_MUL expr { int x=pop(); int y=pop(); push(y*x); }
| expr P_SUB expr { int x=pop(); int y=pop(); push(y-x); }
| expr P_DIV expr { int x=pop(); int y=pop(); push(y/x); }
| P_INPUT  { int a; printf("input number : "); scanf("%d", &a); push(a); }
| P_VAR { vm_var * var = select_variable($1);
			if(var == NULL) push(0);
			else {
				push(var->value);
			}
		}
| P_CONST { push($1); }
;
%%

/*=========================================================================
MAIN
=========================================================================*/
void main( int argc, char *argv[] )
{
	int i;
	extern FILE * yyin;
	yyin = fopen(argv[1], "r");
	yyinit();
	yyparse();
}

/*=========================================================================
YYERROR
=========================================================================*/
int yyerror ( char *s ) /* Called by yyparse on error */
{
	errors++;
	return 0;
}
/**************************** End Grammar File ***************************/
