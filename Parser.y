#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Parser

class Parser
	# Los tokens pertenecientes al lenguaje.
	token 'boolean' 'number' 'true' 'false' '->' ';' ',' '(' ')' '==' '\=' '<=' '>=' '>' '<' '=' 
		'+' '-' '*' '/' '%' 'program' 'by' 'not' 'or' 'and' 'not' 'mod' 'div' 'read' 'write' 
		'writeln' 'with' 'do' 'end' 'if' 'then' 'else' 'while' 'for' 'from' 'to' 'repeat' 
		'times' 'begin' 'func' 'return' UMINUS

	# Precedencia de los operadores.
	prechigh
		right UMINUS 'not'
		left '*' '/' 'div' 'mod' '%'
		left '+' '-'
		left '==' '\=' '>' '<' '<=' '>='
		left 'and'
		left 'or'
		right 'then' 'else'
	preclow



	convert
		'boolean' 'TkTipo'
		'number' 'TkTipo'
		'num' 'TkNumber'
		'true' 'TkBoolean'
		'false' 'TkBoolean'
		'->' 'TkFlecha'
		';' 'TkPuntoYComa'
		',' 'TkComa'
		'(' 'TkAbreParentesis'
		')' 'TkCierraParentesis'
		'=' 'TkAsignacion'
		'==' 'TkIgual'
		'\=' 'TkDiferente'
		'<=' 'TkMenorIgualQue'
		'>=' 'TkMayorIgualQue'
		'>' 'TkMayorQue'
		'<' 'TkMenorQue'
		'=' 'TkAsignacion'
		'+' 'TkSuma'
		'-' 'TkResta'
		'*' 'TkMultiplicacion'
		'/' 'TkDivision'
		'%' 'TkModulo'
		'program' 'TkProgram'
		'by' 'TkBy'
		'not' 'TkNot'
		'and' 'TkAnd'
		'or' 'TkOr'
		'not' 'TkNot'
		'mod' 'TkMod'
		'div' 'TkDiv'
		'read' 'TkRead'
		'write' 'TkWrite'
		'writeln' 'TkWriteln'
		'with' 'TkWith'
		'do' 'TkDo'
		'end' 'TkEnd'
		'if' 'TkIf'
		'then' 'TkThen'
		'else' 'TkElse'
		'while' 'TkWhile'
		'for' 'TkFor'
		'from' 'TkFrom'
		'to' 'TkTo'
		'repeat' 'TkRepeat'
		'times' 'TkTimes'
		'begin' 'TkBegin'
		'func''TkFunc'
		'return' 'TkReturn'
		'id' 'TkId'
		'str' 'TkString'
end

# Regla Inicial
start Programa

# Declaracion de la Gramatica de Retina.
rule

	Programa: 'program' Instrucciones 'end' ';'						{result = Programa.new([], val[1]).set_inicio(val[0].fila).set_fin(val[2].fila)		}
		| Funciones 'program' Instrucciones 'end' ';'					{result = Programa.new(val[0], val[2]).set_inicio(val[1].fila).set_fin(val[3].fila)	}
		;

	Funciones: Funcion ';'								{result = [val[0]]				}
		| Funcion ';' Funciones							{result = [val[0]] + val[2]			}
		;

	Funcion: 'func' 'id' '(' Parametros ')' 'begin' InstruccionesF 'end'		{result = Funcion.new(Identificador.new(val[1]), val[3], nil, val[6]).set_inicio(val[0].fila).set_fin(val[7].fila)	}
		| 'func' 'id' '(' ')' 'begin' InstruccionesF 'end'			{result = Funcion.new(Identificador.new(val[1]), [], nil, val[5]).set_inicio(val[0].fila).set_fin(val[6].fila)		}
		| 'func' 'id' '(' Parametros ')' '->' Tipo 'begin' InstruccionesF 'end'	{result = Funcion.new(Identificador.new(val[1]), val[3], val[6], val[8]).set_inicio(val[0].fila).set_fin(val[9].fila)	}
		| 'func' 'id' '(' ')' '->' Tipo 'begin' InstruccionesF 'end'		{result = Funcion.new(Identificador.new(val[1]), [], val[5], val[7]).set_inicio(val[0].fila).set_fin(val[8].fila)	}
		;

	InstruccionF: 'return' Expresion 						{result = ReturnFuncion.new(val[1]).set_inicio(val[0].fila).set_fin(val[0].fila)		}
		| CondicionalF								{result = val[0]				}
		| IteracionF								{result = val[0]				}
		| BloqueF								{result = val[0]				}
		| 'id' '='  Expresion 							{result = Asignacion.new(Identificador.new(val[0]), val[2]).set_inicio(val[0].fila).set_fin(val[0].fila)				   }
		| 'id' '(' Expresiones ')' 						{result = LlamadaFuncion.new(Identificador.new(val[0]), val[2]).set_inicio(val[0].fila).set_fin(val[0].fila)			    	   }
		| 'id' '(' ')'								{result = LlamadaFuncion.new(Identificador.new(val[0]), []).set_inicio(val[0].fila).set_fin(val[0].fila)			    	   }
		| 'write' ElementosSalida						{result = Salida.new(val[1]).set_inicio(val[0].fila).set_fin(val[0].fila)		   }
		| 'writeln' ElementosSalida						{result = SalidaSalto.new(val[1]).set_inicio(val[0].fila).set_fin(val[0].fila)		   }
		| 'read' 'id'								{result = Entrada.new(Identificador.new(val[1])).set_inicio(val[0].fila).set_fin(val[0].fila)	}
		;

	InstruccionesF: InstruccionF ';' 						{result = [val[0]]						}
		| InstruccionF ';' InstruccionesF					{result = [val[0]] + val[2]					}
		;

	Parametros: Parametro 								{result = [val[0]]				}
		| Parametros ',' Parametro 						{result = val[0] + [val[2]]			}
		;

	Parametro: Tipo 'id'								{result = Parametro.new(val[0], Identificador.new(val[1])).set_inicio(val[1].fila).set_fin(val[1].fila)		}
		;

	Bloque: 'with' Declaraciones 'do' Instrucciones 'end'				{result = Bloque.new(val[1], val[3]).set_inicio(val[0].fila).set_fin(val[4].fila)	}
		| 'with' 'do' Instrucciones 'end'					{result = Bloque.new([], val[2]).set_inicio(val[0].fila).set_fin(val[3].fila)		}
		| 'with' Declaraciones 'do' 'end'					{result = Bloque.new(val[1], []).set_inicio(val[0].fila).set_fin(val[3].fila)		}
		| 'with' 'do' 'end'							{result = Bloque.new([], []).set_inicio(val[0].fila).set_fin(val[2].fila)}	
		;

	BloqueF: 'with' Declaraciones 'do' InstruccionesF 'end'				{result = Bloque.new(val[1], val[3]).set_inicio(val[0].fila).set_fin(val[4].fila)	}
		| 'with' 'do' InstruccionesF 'end'					{result = Bloque.new([], val[2]).set_inicio(val[0].fila).set_fin(val[3].fila)		}
		| 'with' Declaraciones 'do' 'end'					{result = Bloque.new(val[1], []).set_inicio(val[0].fila).set_fin(val[3].fila)		}
		| 'with' 'do' 'end'							{result = Bloque.new([], []).set_inicio(val[0].fila).set_fin(val[2].fila)}	
		;


	Declaraciones: Declaracion ';'							{result = [val[0]]					}
		| Declaracion ';' Declaraciones						{result = [val[0]] + val[2]				}
		;

	Declaracion: Tipo 'id'								{result = Declaracion.new(val[0], Identificador.new(val[1]), nil).set_inicio(val[1].fila).set_fin(val[1].fila)		}
		| Tipo 'id' '=' Expresion 						{result = Declaracion.new(val[0], Identificador.new(val[1]), val[3]).set_inicio(val[1].fila).set_fin(val[1].fila)		}
		;

	Tipo: 'number'									{result = Tipo.new(val[0])				   }
		| 'boolean'								{result = Tipo.new(val[0])				   }
		;

	Condicional: 'if' Expresion 'then' Instrucciones 'end'				{result = Condicional.new(val[1], val[3], []).set_inicio(val[0].fila).set_fin(val[4].fila)   	}
		| 'if' Expresion 'then' Instrucciones 'else' Instrucciones 'end'	{result = Condicional.new(val[1], val[3], val[5]).set_inicio(val[0].fila).set_fin(val[6].fila)  }
		| 'if' Expresion 'then' 'end'						{result = Condicional.new(val[1], [], []).set_inicio(val[0].fila).set_fin(val[3].fila)  	}
		| 'if' Expresion 'then' Instrucciones 'else' 'end'			{result = Condicional.new(val[1], val[3], []).set_inicio(val[0].fila).set_fin(val[5].fila)  	}
		| 'if' Expresion 'then' 'else' Instrucciones 'end'			{result = Condicional.new(val[1], [], val[4]).set_inicio(val[0].fila).set_fin(val[5].fila)  	}
		;
	
	CondicionalF: 'if' Expresion 'then' InstruccionesF 'end'			{result = Condicional.new(val[1], val[3], []).set_inicio(val[0].fila).set_fin(val[4].fila)   	}
		| 'if' Expresion 'then' InstruccionesF 'else' InstruccionesF 'end'	{result = Condicional.new(val[1], val[3], val[5]).set_inicio(val[0].fila).set_fin(val[6].fila)  }
		| 'if' Expresion 'then' 'end'						{result = Condicional.new(val[1], [], []).set_inicio(val[0].fila).set_fin(val[3].fila)  	}
		| 'if' Expresion 'then' InstruccionesF 'else' 'end'			{result = Condicional.new(val[1], val[3], []).set_inicio(val[0].fila).set_fin(val[5].fila)  	}
		| 'if' Expresion 'then' 'else' InstruccionesF 'end'			{result = Condicional.new(val[1], [], val[4]).set_inicio(val[0].fila).set_fin(val[5].fila)  	}
		;

	Iteracion: 'while' Expresion 'do' Instrucciones 'end' 				{result = IteracionIndeterminada.new(val[1], val[3]).set_inicio(val[0].fila).set_fin(val[4].fila) }
		| 'while' Expresion 'do' 'end' 						{result = IteracionIndeterminada.new(val[1], []).set_inicio(val[0].fila).set_fin(val[3].fila) 	}
		| 'for' 'id' 'from' Expresion 'to' Expresion 'by' Expresion 'do' Instrucciones 'end'    {result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], val[7], val[9]).set_inicio(val[0].fila).set_fin(val[10].fila)   }
		| 'for' 'id' 'from' Expresion 'to' Expresion 'by' Expresion 'do' 'end'    {result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], val[7], []).set_inicio(val[0].fila).set_fin(val[9].fila)   }
		| 'for' 'id' 'from' Expresion 'to' Expresion 'do' Instrucciones 'end'	 {result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], nil, val[7]).set_inicio(val[0].fila).set_fin(val[8].fila)   }
		| 'for' 'id' 'from' Expresion 'to' Expresion 'do' 'end'	 		{result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], nil, []).set_inicio(val[0].fila).set_fin(val[7].fila)   }
		| 'repeat' Expresion 'times' Instrucciones 'end'			{result = IteracionRepeat.new(val[1], val[3]).set_inicio(val[0].fila).set_fin(val[4].fila)	}
		| 'repeat' Expresion 'times' 'end'					{result = IteracionRepeat.new(val[1], []).set_inicio(val[0].fila).set_fin(val[3].fila)	}
		;

	IteracionF: 'while' Expresion 'do' InstruccionesF 'end' 			{result = IteracionIndeterminada.new(val[1], val[3]).set_inicio(val[0].fila).set_fin(val[4].fila) }
		| 'while' Expresion 'do' 'end' 						{result = IteracionIndeterminada.new(val[1], []).set_inicio(val[0].fila).set_fin(val[3].fila) 	}
		| 'for' 'id' 'from' Expresion 'to' Expresion 'by' Expresion 'do' InstruccionesF 'end'    {result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], val[7], val[9]).set_inicio(val[0].fila).set_fin(val[10].fila)   }
		| 'for' 'id' 'from' Expresion 'to' Expresion 'by' Expresion 'do' 'end'    {result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], val[7], []).set_inicio(val[0].fila).set_fin(val[9].fila)   }
		| 'for' 'id' 'from' Expresion 'to' Expresion 'do' InstruccionesF 'end'	 {result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], nil, val[7]).set_inicio(val[0].fila).set_fin(val[8].fila)   }
		| 'for' 'id' 'from' Expresion 'to' Expresion 'do' 'end'	 		{result = IteracionDeterminada.new(Identificador.new(val[1]), val[3], val[5], nil, []).set_inicio(val[0].fila).set_fin(val[7].fila)   }
		| 'repeat' Expresion 'times' InstruccionesF 'end'			{result = IteracionRepeat.new(val[1], val[3]).set_inicio(val[0].fila).set_fin(val[4].fila)   }
		| 'repeat' Expresion 'times' 'end'					{result = IteracionRepeat.new(val[1], []).set_inicio(val[0].fila).set_fin(val[3].fila)	}
		;

	Instrucciones: Instruccion ';'							{result = [val[0]]				   	}
		| Instruccion ';' Instrucciones						{result = [val[0]] + val[2]				}
		;

	Instruccion: 'id' '='  Expresion 						{result = Asignacion.new(Identificador.new(val[0]), val[2]).set_inicio(val[0].fila).set_fin(val[0].fila)				   }
		| Condicional								{result = val[0]									   }
		| Iteracion 								{result = val[0] 									   }
		| Bloque								{result = val[0]							            	   }
		| 'id' '(' Expresiones ')' 						{result = LlamadaFuncion.new(Identificador.new(val[0]), val[2]).set_inicio(val[0].fila).set_fin(val[0].fila)			    	   }
		| 'id' '(' ')'								{result = LlamadaFuncion.new(Identificador.new(val[0]), []).set_inicio(val[0].fila).set_fin(val[0].fila)			    	   }
		| 'write' ElementosSalida						{result = Salida.new(val[1]).set_inicio(val[0].fila).set_fin(val[0].fila)		   }
		| 'writeln' ElementosSalida						{result = SalidaSalto.new(val[1]).set_inicio(val[0].fila).set_fin(val[0].fila)		   }
		| 'read' 'id'								{result = Entrada.new(Identificador.new(val[1])).set_inicio(val[0].fila).set_fin(val[0].fila)	 }
		;

	ElementosSalida: ElementoSalida 						{result = [val[0]]				}
		| ElementosSalida ',' ElementoSalida 					{result = val[0] + [val[2]] 			}
		;

	ElementoSalida: 'str'								{result = String.new(val[0])			}
		| Expresion 								{result = val[0]				}
		;

	Expresiones: Expresion   							{result = [val[0]]				}
		| Expresiones ',' Expresion 						{result = val[0] + [val[2]]			}
		;

	Expresion: 'num' 							{result = Numero.new(val[0])				}
		| 'true'							{result = Booleano.new(val[0])				}
		| 'false'							{result = Booleano.new(val[0])				}
		| 'id'								{result = Identificador.new(val[0])			}
		| '-' Expresion = UMINUS					{result = Negativo.new(val[1])				}
		| Expresion '+' Expresion 					{result = Suma.new(val[0], val[2])			}
		| Expresion '-' Expresion 					{result = Resta.new(val[0], val[2])			}
		| Expresion '*' Expresion 					{result = Multiplicacion.new(val[0], val[2])		}	
		| Expresion '/' Expresion 					{result = Division.new(val[0], val[2])			}	
		| Expresion '%' Expresion 					{result = Modulo.new(val[0], val[2])			}
		| Expresion '>' Expresion 					{result = MayorQue.new(val[0], val[2])			}
		| Expresion '<' Expresion 					{result = MenorQue.new(val[0], val[2])			}
		| Expresion '>=' Expresion 					{result = MayorIgualQue.new(val[0], val[2])		}
		| Expresion '<=' Expresion 					{result = MenorIgualQue.new(val[0], val[2])		}
		| Expresion '==' Expresion 					{result = Igual.new(val[0], val[2])			}
		| Expresion '\=' Expresion 					{result = Diferente.new(val[0], val[2])			}
		| Expresion 'div' Expresion 					{result = DivisionEntera.new(val[0], val[2])		}
		| Expresion 'mod' Expresion 					{result = ModuloEntero.new(val[0], val[2])		}  	
		| Expresion 'and' Expresion 					{result = And.new(val[0], val[2])			}
		| Expresion 'or' Expresion 					{result = Or.new(val[0], val[2])			}
		| 'not' Expresion 						{result = Not.new(val[1])				}
		| '(' Expresion ')'						{result = val[1] 					}
		| 'id' '(' Expresiones ')' 					{result = LlamadaFuncion.new(Identificador.new(val[0]), val[2])	}
		| 'id' '(' ')'							{result = LlamadaFuncion.new(Identificador.new(val[0]), [])	}
		;

---- header

require_relative 'Ast'
require_relative 'Lexer'
require_relative 'Errores'

---- inner
# Funcion que requiere el Parser para reportar un error sintactico.
def on_error(id, token, stack)
	raise SyntacticError.new(token)
end
  
# Funcion que requiere el Parser para obtener los tokens de la entrada.
def next_token
	token = @lexer.obtener_token
	return [false,false] unless token
	return [token.class,token]
end
   
# Funcion que requiere el Parser para construir el AST.
def parse(lexer)
	@yydebug = true
	@lexer = lexer
	@tokens = []
	ast = do_parse
	return ast
end
