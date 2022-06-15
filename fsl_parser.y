
%{
#define NULL	0
int errors = 0;
int yyerror ( char *s );

#define VM_NODE_TYPE_STRING		'S'
#define VM_NODE_TYPE_INTEGER	'I'

typedef struct vm_var vm_var;
typedef struct vm_immutable vm_immutable;
typedef struct vm_node vm_node ;

struct vm_var {
	char name[32];
	vm_node * value;
	vm_var * next;
};

struct vm_immutable {
	int length;
	int refcount;
	vm_var * next;
	char value[0];
};

struct vm_node {
	int type;
	char * ptr;
};

const vm_node VM_NULL = { VM_NODE_TYPE_INTEGER, 0 };

vm_var * _vars = NULL;			//variable storage
vm_var * _current_var = NULL;
vm_immutable * _immutable = NULL;			//immutable storage
vm_immutable * _current_const = NULL;
vm_node * _stacks[100];
int _stack_index = 0;

void push(vm_node * val) { _stacks[_stack_index++] = val; }
vm_node * pop(void) {
	vm_node * node = _stacks[--_stack_index];
	if(node != NULL) {
		//if(node->type ==  VM_NODE_TYPE_STRING)
		//	((vm_immutable *)node->ptr)->refcount--;		//ref down
	}
}

vm_var * create_variable(char * name, vm_node * value) {
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

vm_immutable * create_constant(int length, char * value) {
	vm_immutable * immutable = malloc(sizeof(vm_immutable) + length);
	immutable->length = length;
	if(value != NULL) strncpy(immutable->value, value, length);
	immutable->refcount = 0;
	immutable->next = NULL;
	return immutable;
}

vm_immutable * add_constant(vm_immutable * var) {
	vm_immutable * iterator = _immutable;
	if(iterator == NULL) _immutable = var;
	else {
		while(iterator->next != NULL) {
			iterator = iterator->next;
		}
		iterator->next = var;
	}
	return var;
}

vm_immutable * select_constant(char * value) {
	vm_immutable * iterator = _immutable;
		while(iterator!= NULL) {
			if(strcmp(iterator->value , value) == 0) {
				return iterator;
			}
			iterator = iterator->next;
		}
	return NULL;
}

vm_node * create_node(int type, char * ptr) {
	vm_node * node = malloc(sizeof(vm_node));
	node->ptr = ptr;
	node->type= type;
	return node;
}

void delete_node(vm_node * node) {
	free(node);
}

void print_node(vm_node * node) {
	vm_immutable * immut;
		int intval;
	if(node == NULL) return;
	switch(node->type) {
		case VM_NODE_TYPE_STRING:
			immut = (vm_immutable *)node->ptr;
			printf("%s\n", immut->value);
			break;
		case VM_NODE_TYPE_INTEGER:
			intval = (int)node->ptr;
			printf("%d\n", intval);
			break;
	}
}

vm_node * add_operation(vm_node * op1, vm_node * op2) {
	char num_buffer1[50];
	char num_buffer2[50];
	char * ptr1;
	char * ptr2;
	if(op1 == NULL) return &VM_NULL;
	if(op2 == NULL) return &VM_NULL;

	//create string value if necessary for operation
	if(op1->type == VM_NODE_TYPE_STRING) { ptr1 = ((vm_immutable *)op1->ptr)->value; }
	else { ptr1 = num_buffer1; snprintf(num_buffer1, 50, "%d", (int)op1->ptr); }
	if(op2->type == VM_NODE_TYPE_STRING) { ptr2= ((vm_immutable *)op2->ptr)->value; }
	else { ptr2 = num_buffer2; snprintf(num_buffer2, 50, "%d", (int)op2->ptr); }

	if(op1->type == VM_NODE_TYPE_STRING || op2->type == VM_NODE_TYPE_STRING) {
		//perform string concatenation
		vm_immutable * immut = create_constant(strlen(ptr1) + strlen(ptr2) + 1, NULL);
		snprintf(immut->value, strlen(ptr1) + strlen(ptr2)+ 1, "%s%s", ptr1, ptr2);
		return create_node(VM_NODE_TYPE_STRING, immut);
	}
	return create_node(VM_NODE_TYPE_INTEGER, (int)op1->ptr + (int)op2->ptr);
}
vm_node * sub_operation(vm_node * op1, vm_node * op2) {
	if(op1 == NULL) return &VM_NULL;
	if(op2 == NULL) return &VM_NULL;

	if(op1->type == VM_NODE_TYPE_STRING || op2->type == VM_NODE_TYPE_STRING) {
		//perform string concatenation
		printf("error : unable to perform substraction\n");
		return &VM_NULL;
	}
	return create_node(VM_NODE_TYPE_INTEGER, (int)op1->ptr - (int)op2->ptr);
}
vm_node * mul_operation(vm_node * op1, vm_node * op2) {
	if(op1 == NULL) return &VM_NULL;
	if(op2 == NULL) return &VM_NULL;

	if(op1->type == VM_NODE_TYPE_STRING || op2->type == VM_NODE_TYPE_STRING) {
		//perform string concatenation
		printf("error : unable to perform multiplication\n");
		return &VM_NULL;
	}
	return create_node(VM_NODE_TYPE_INTEGER, (int)op1->ptr * (int)op2->ptr);
}
vm_node * div_operation(vm_node * op1, vm_node * op2) {
	if(op1 == NULL) return &VM_NULL;
	if(op2 == NULL) return &VM_NULL;

	if(op1->type == VM_NODE_TYPE_STRING || op2->type == VM_NODE_TYPE_STRING) {
		//perform string concatenation
		printf("error : unable to perform division\n");
		return &VM_NULL;
	}
	if(op2->ptr == 0) {
		printf("error : division by zero\n");
		return &VM_NULL;
	}
	return create_node(VM_NODE_TYPE_INTEGER, (int)op1->ptr / (int)op2->ptr);
}

int is_digit(char * tmp) {
	int isDigit = 1;
	int j=0;
	while(j<strlen(tmp) && isDigit == 1){
		if(tmp[j] == '\n') break;
  	if(tmp[j] > 57 || tmp[j] < 48)
    	isDigit = 0;
  	j++;
	}
	return isDigit;
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
%token P_STRING			523

%type<string> P_VAR;		//string
%type<value> P_CONST;			//int
%type<value> P_INPUT;			//int
%type<string> P_STRING;
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
			expr P_EOS { vm_node * node = pop();
				_current_var->value = node;
			}
| P_OUTPUT P_ASSIGNMENT expr P_EOS { print_node(pop()); }
;
expr: expr P_ADD expr { vm_node * x=pop(); vm_node * y=pop(); push(add_operation(y, x));  }
| expr P_MUL expr { vm_node * x=pop(); vm_node * y=pop(); push(mul_operation(y, x)); }
| expr P_SUB expr { vm_node * x=pop(); vm_node * y=pop(); push(sub_operation(y, x)); }
| expr P_DIV expr { vm_node * x=pop(); vm_node * y=pop(); push(div_operation(y, x)); }
| P_INPUT  {
	 	char num_buffer[128];
			//printf("input : ");
			for(int i=0;i<128;i++) {
				num_buffer[i] = getchar();
				if(num_buffer[i] =='\n') { num_buffer[i] = 0; break; }
			}
			if(is_digit(num_buffer)) {
					int a = atoi(num_buffer);
					push(create_node(VM_NODE_TYPE_INTEGER, a));
			} else {
					vm_immutable * immut = select_constant(num_buffer);
					if(immut == NULL) immut = add_constant(create_constant(strlen(num_buffer)+1, num_buffer));
					push(create_node(VM_NODE_TYPE_STRING, immut ));
			}
	}
| P_VAR { vm_var * var = select_variable($1);
			if(var == NULL) push(create_node(VM_NODE_TYPE_INTEGER, 0));
			else {
				push(var->value);
			}
		}
| P_CONST { push(create_node(VM_NODE_TYPE_INTEGER, $1));  }
| P_STRING { vm_immutable * immut = select_constant($1);
		if(immut == NULL) immut = add_constant(create_constant(strlen($1) + 1, $1));
		push(create_node(VM_NODE_TYPE_STRING, immut ));
	 }
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
