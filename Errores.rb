<<<<<<< HEAD
#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Errores

# Funcion que revisa si el archivo dado existe y si posee la extension requerida.
def comprobar_archivo(archivo)
	unless archivo =~ /\w+\.rtn/ # Chequeamos la extension del archivo de entrada
		abort("Extension del archivo desconocida")
	end

	unless File::exists?(archivo) # Chequeamos la existencia del archivo de entrada
		abort("Archivo no encontrado")
	end
end

# Clase del Error Lexicografico
class LexicographError < Exception
	attr_reader :texto

	def initialize texto, fila, columna
		@texto = texto 	# Lo que se detecto al hacer match con alguna Expresion Regular
		@fila = fila	# Fila en el archivo donde se consiguio dicho Token
		@columna = columna # Columna en el archivo donde se consiguio dicho Token
	end

	def to_s #Salida especial del enunciado
    		"linea #{@fila}, columna #{@columna}: caracter inesperado '#{@texto}'"
 	end
end

# Clase que representa el primer Error Sintactico que se consiga.
class SyntacticError < RuntimeError
	# Constructor de la clase.
	def initialize(token)
		@token = token # Token que mando el error sintactico.
	end

	def to_s
		puts @token
		"linea #{@token.fila}, columna #{@token.columna}: token inesperado: #{@token.texto}"
	end
end

# Clase para representar los Errores de Contexto en el programa.
class ContextError < RuntimeError	
end

# Clase para representar el error de que una variable no fue declarada antes de usarla
class ErrorVariableNoDeclarada < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin
		@nombre = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la variable '#{@nombre}' " +
		"no fue declarada previamente"
	end
end

# Clase para representar el error de que una funcion no fue declarada antes de llamarla
class ErrorFuncionNoDeclarada < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin
		@nombre = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la funcion '#{@nombre}' " +
		"no fue declarada previamente"
	end
end

# Clase para representar el error de que la condicion de un if no es booleana
class ErrorCondicionCondicional < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de la condicion " +
		"es incorrecto: #{@tipo}"	
	end
end

# Clase para representar el error de que la condicion de while no es booleana
class ErrorCondicionIteracion < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de la condicion " +
		"es incorrecto: #{@tipo}"	
	end
end

# Clase para representar el error de que el rango de un for no es number
class ErrorTipoRangoInvalido < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de rango " +
		"es invalido: #{@tipo}"	
	end
end

# Clase para representar el error de que el incremento de un for no es number
class ErrorTipoIncrementoIteracionInvalido < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo del incremento de la iteracion " +
		"es invalido: #{@tipo}"	
	end
end

# Clase para representar el error de que la expresion del repeat no es number
class ErrorTipoExpresionRepeat < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de la expresion del repeat " +
		"es invalido: #{@tipo}"	
	end
end

# Clase para representar el error de que se intenta asignar un tipo distinto al declarado en una variable
class ErrorAsignacion < ContextError
	def initialize inicio, fin, tipoVariable, tipoValor, nombre
		@inicio = inicio
		@fin = fin	
		@tipoValor = tipoValor
		@tipoVariable = tipoVariable
		@nombreVariable = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la variable #{@nombreVariable} " +
		"es de tipo #{@tipoVariable} y se intenta asignar un #{@tipoValor}"	
	end
end

# Clase para representar el error de que se intenta usar una funcion con un tipo de parametro distinto al declarado
class ErrorTipoParametro < ContextError
	def initialize inicio, fin, tipo, tipoIntroducido, posParametro, nombreFuncion
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
		@tipoIntroducido = tipoIntroducido
		@posParametro = posParametro
		@nombreFuncion = nombreFuncion
	end

	def to_s
		"Error en la linea #{@inicio}: el parametro en la posicion #{@posParametro} es de tipo #{@tipoIntroducido} " +
		"y se esperaba de tipo #{@tipo}"		
	end
end

# Clase para representar el error de que se intenta llamar una funcion con una cantidad de parametros distinta a la declarada
class ErrorCantidadParametros < ContextError
	def initialize inicio, fin, cantidadFuncion, cantidadIntroducida, nombre
		@inicio = inicio
		@fin = fin	
		@cantidadFuncion = cantidadFuncion
		@cantidadIntroducida = cantidadIntroducida
		@nombreFuncion = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la funcion #{@nombreFuncion} " +
		"tiene #{@cantidadFuncion} parametros y se llamo con #{@cantidadIntroducida}"		
	end
end

# Clase para representar el error de que se intenta retornar un tipo de valor distinto al declarado
class ErrorTipoValorRetornado < ContextError
	def initialize inicio, fin, tipo, tipoRetornado
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
		@tipoRetornado = tipoRetornado
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: la funcion debe "  +
		"retornar un valor #{@tipo} pero retorna un #{@tipoRetornado}"			
	end
end

# Clase para representar el error de que se omitio la instruccion return
class ErrorValorRetornoAusente < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin	
		@nombreFuncion = nombre
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: la funcion #{@nombreFuncion} carece "  +
		"de valor de retorno"			
	end
end

# Clase para representar el error de que intenta retornar un valor cuando la funcion no retorna algo
class ErrorValorRetornoNoRequerido < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin	
		@nombreFuncion = nombre
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: la funcion #{@nombreFuncion} no debe tener "  +
		"valor de retorno"			
	end
end

# Clase para representar el error de que se intenta utilizar un operador con tipos de operandos invalidos
class ErrorTipoOperadores < ContextError
	def initialize inicio, fin, nombreOperacion, operandoIzq, operandoDer = nil
		@inicio = inicio
		@fin = fin	
		@nombreOperacion = nombreOperacion
		@operandoDer = operandoDer
		@operandoIzq = operandoIzq
	end

	def to_s
		if @operandoDer != nil
			"Error en la fila #{@inicio}: Combinacion de operandos invalida " +
			"para la operacion #{@nombreOperacion}: #{@operandoIzq}  #{@operandoDer}" 
		else
			"Error en la fila #{@inicio}: Operando invalido " +
			"para la operacion #{@nombreOperacion}: #{@operandoIzq}"
		end
	end
end

# Clase para representar los Errores de la tabla de simbolos.
class SymTableError < RuntimeError
end

# Clase para representar el error de reinsertar una variable ya declarada en la tabla de simbolos
class RedefinirError < SymTableError
	def initialize nuevo, declarado, variable
		@nuevo = nuevo	# Token nuevo
		@declarado = declarado	# Token ya declarado
		@variable = variable # Error en tabla de variables (true) o tabla de funciones (false)
	end
	
	def to_s
		if @variable
			"linea #{@nuevo.fila}, columna #{@nuevo.columna}: la variable '#{@nuevo.texto}'" +
			"fue declarada previamente en la linea #{@declarado.fila} y la columna #{@declarado.columna}"
		else
			"linea #{@nuevo.fila}, columna #{@nuevo.columna}: la funcion '#{@nuevo.texto}'" +
			"fue declarada previamente en la linea #{@declarado.fila} y la columna #{@declarado.columna}"
		end
	end
end

# Clase para representar a los errores en tiempo de corrida
class DynamicError < RuntimeError
end

# Clase para representar a los errores de division entre cero en tiempo de corrida
class DivisionCeroError < DynamicError

	def initialize linea, columna
		@linea = linea
	end
	
	def to_s 
		"linea #{@linea}: Division entre cero"
	end

end

# Clase para representar a los errores de overflow en tiempo de corrida
class OverflowError < DynamicError

	def initialize linea, columna
		@linea = linea
	end

	def to_s
		"linea #{@linea}: El resultado no puede ser expresado en 32 bits."
	end

end

# Clase para representar a los errores de correcursividad en tiempo de corrida
class CorrecursividadError < DynamicError

	def initialize linea, columna
		@linea = linea
		@columna = columna
	end
	
	def to_s
		"linea #{@linea}, columna #{@columna}: Se intenta ejecutar una correcursion."
	end
	
end

# Clase para representar a los errores entrada por teclado en tiempo de corrida
class EntradaInvalidaError < DynamicError

	def initialize linea, columna, nombreVariable, tipoVariable, entrada 
		@linea = linea
		@columna = columna
		@nombreVariable = nombreVariable
		@tipoVariable = tipoVariable
		@entrada = entrada
	end

	def to_s
		"linea #{@linea}, columna #{@columna}: la variable #{@nombreVariable} es de tipo #{@tipoVariable} y entro #{@entrada}"
	end

end

# Clase para representar a los errores de variables sin valor de inicializacion
# en tiempo de corrida
class VariableNoInicializadaError < DynamicError

	def initialize linea, columna, variable
		@linea = linea
		@columna = columna
		@variable = variable
	end

	def to_s
		"linea #{@linea}, columna #{@columna}: La variable #{@variable} no fue inicializada."
	end

end
=======
#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Errores

# Funcion que revisa si el archivo dado existe y si posee la extension requerida.
def comprobar_archivo(archivo)
	unless archivo =~ /\w+\.rtn/ # Chequeamos la extension del archivo de entrada
		abort("Extension del archivo desconocida")
	end

	unless File::exists?(archivo) # Chequeamos la existencia del archivo de entrada
		abort("Archivo no encontrado")
	end
end

# Clase del Error Lexicografico
class LexicographError < Exception
	attr_reader :texto

	def initialize texto, fila, columna
		@texto = texto 	# Lo que se detecto al hacer match con alguna Expresion Regular
		@fila = fila	# Fila en el archivo donde se consiguio dicho Token
		@columna = columna # Columna en el archivo donde se consiguio dicho Token
	end

	def to_s #Salida especial del enunciado
    		"linea #{@fila}, columna #{@columna}: caracter inesperado '#{@texto}'"
 	end
end

# Clase que representa el primer Error Sintactico que se consiga.
class SyntacticError < RuntimeError
	# Constructor de la clase.
	def initialize(token)
		@token = token # Token que mando el error sintactico.
	end

	def to_s
		puts @token
		"linea #{@token.fila}, columna #{@token.columna}: token inesperado: #{@token.texto}"
	end
end

# Clase para representar los Errores de Contexto en el programa.
class ContextError < RuntimeError	
end

# Clase para representar el error de que una variable no fue declarada antes de usarla
class ErrorVariableNoDeclarada < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin
		@nombre = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la variable '#{@nombre}' " +
		"no fue declarada previamente"
	end
end

# Clase para representar el error de que una funcion no fue declarada antes de llamarla
class ErrorFuncionNoDeclarada < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin
		@nombre = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la funcion '#{@nombre}' " +
		"no fue declarada previamente"
	end
end

# Clase para representar el error de que la condicion de un if no es booleana
class ErrorCondicionCondicional < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de la condicion " +
		"es incorrecto: #{@tipo}"	
	end
end

# Clase para representar el error de que la condicion de while no es booleana
class ErrorCondicionIteracion < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de la condicion " +
		"es incorrecto: #{@tipo}"	
	end
end

# Clase para representar el error de que el rango de un for no es number
class ErrorTipoRangoInvalido < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de rango " +
		"es invalido: #{@tipo}"	
	end
end

# Clase para representar el error de que el incremento de un for no es number
class ErrorTipoIncrementoIteracionInvalido < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo del incremento de la iteracion " +
		"es invalido: #{@tipo}"	
	end
end

# Clase para representar el error de que la expresion del repeat no es number
class ErrorTipoExpresionRepeat < ContextError
	def initialize inicio, fin, tipo
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: el tipo de la expresion del repeat " +
		"es invalido: #{@tipo}"	
	end
end

# Clase para representar el error de que se intenta asignar un tipo distinto al declarado en una variable
class ErrorAsignacion < ContextError
	def initialize inicio, fin, tipoVariable, tipoValor, nombre
		@inicio = inicio
		@fin = fin	
		@tipoValor = tipoValor
		@tipoVariable = tipoVariable
		@nombreVariable = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la variable #{@nombreVariable} " +
		"es de tipo #{@tipoVariable} y se intenta asignar un #{@tipoValor}"	
	end
end

# Clase para representar el error de que se intenta usar una funcion con un tipo de parametro distinto al declarado
class ErrorTipoParametro < ContextError
	def initialize inicio, fin, tipo, tipoIntroducido, posParametro, nombreFuncion
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
		@tipoIntroducido = tipoIntroducido
		@posParametro = posParametro
		@nombreFuncion = nombreFuncion
	end

	def to_s
		"Error en la linea #{@inicio}: el parametro en la posicion #{@posParametro} es de tipo #{@tipoIntroducido} " +
		"y se esperaba de tipo #{@tipo}"		
	end
end

# Clase para representar el error de que se intenta llamar una funcion con una cantidad de parametros distinta a la declarada
class ErrorCantidadParametros < ContextError
	def initialize inicio, fin, cantidadFuncion, cantidadIntroducida, nombre
		@inicio = inicio
		@fin = fin	
		@cantidadFuncion = cantidadFuncion
		@cantidadIntroducida = cantidadIntroducida
		@nombreFuncion = nombre
	end

	def to_s
		"Error en la linea #{@inicio}: la funcion #{@nombreFuncion} " +
		"tiene #{@cantidadFuncion} parametros y se llamo con #{@cantidadIntroducida}"		
	end
end

# Clase para representar el error de que se intenta retornar un tipo de valor distinto al declarado
class ErrorTipoValorRetornado < ContextError
	def initialize inicio, fin, tipo, tipoRetornado
		@inicio = inicio
		@fin = fin	
		@tipo = tipo
		@tipoRetornado = tipoRetornado
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: la funcion debe "  +
		"retornar un valor #{@tipo} pero retorna un #{@tipoRetornado}"			
	end
end

# Clase para representar el error de que se omitio la instruccion return
class ErrorValorRetornoAusente < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin	
		@nombreFuncion = nombre
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: la funcion #{@nombreFuncion} carece "  +
		"de valor de retorno"			
	end
end

# Clase para representar el error de que intenta retornar un valor cuando la funcion no retorna algo
class ErrorValorRetornoNoRequerido < ContextError
	def initialize inicio, fin, nombre
		@inicio = inicio
		@fin = fin	
		@nombreFuncion = nombre
	end

	def to_s
		"Error entre las filas #{@inicio} y #{@fin}: la funcion #{@nombreFuncion} no debe tener "  +
		"valor de retorno"			
	end
end

# Clase para representar el error de que se intenta utilizar un operador con tipos de operandos invalidos
class ErrorTipoOperadores < ContextError
	def initialize inicio, fin, nombreOperacion, operandoIzq, operandoDer = nil
		@inicio = inicio
		@fin = fin	
		@nombreOperacion = nombreOperacion
		@operandoDer = operandoDer
		@operandoIzq = operandoIzq
	end

	def to_s
		if @operandoDer != nil
			"Error en la fila #{@inicio}: Combinacion de operandos invalida " +
			"para la operacion #{@nombreOperacion}: #{@operandoIzq}  #{@operandoDer}" 
		else
			"Error en la fila #{@inicio}: Operando invalido " +
			"para la operacion #{@nombreOperacion}: #{@operandoIzq}"
		end
	end
end

# Clase para representar los Errores de la tabla de simbolos.
class SymTableError < RuntimeError
end

# Clase para representar el error de reinsertar una variable ya declarada en la tabla de simbolos
class RedefinirError < SymTableError
	def initialize nuevo, declarado, variable
		@nuevo = nuevo	# Token nuevo
		@declarado = declarado	# Token ya declarado
		@variable = variable # Error en tabla de variables (true) o tabla de funciones (false)
	end
	
	def to_s
		if @variable
			"linea #{@nuevo.fila}, columna #{@nuevo.columna}: la variable '#{@nuevo.texto}'" +
			"fue declarada previamente en la linea #{@declarado.fila} y la columna #{@declarado.columna}"
		else
			"linea #{@nuevo.fila}, columna #{@nuevo.columna}: la funcion '#{@nuevo.texto}'" +
			"fue declarada previamente en la linea #{@declarado.fila} y la columna #{@declarado.columna}"
		end
	end
end

# Clase para representar a los errores en tiempo de corrida
class DynamicError < RuntimeError
end

# Clase para representar a los errores de division entre cero en tiempo de corrida
class DivisionCeroError < DynamicError

	def initialize linea, columna
		@linea = linea
	end
	
	def to_s 
		"linea #{@linea}: Division entre cero"
	end

end

# Clase para representar a los errores de overflow en tiempo de corrida
class OverflowError < DynamicError

	def initialize linea, columna
		@linea = linea
	end

	def to_s
		"linea #{@linea}: El resultado no puede ser expresado en 32 bits."
	end

end

# Clase para representar a los errores de correcursividad en tiempo de corrida
class CorrecursividadError < DynamicError

	def initialize linea, columna
		@linea = linea
		@columna = columna
	end
	
	def to_s
		"linea #{@linea}, columna #{@columna}: Se intenta ejecutar una correcursion."
	end
	
end

# Clase para representar a los errores entrada por teclado en tiempo de corrida
class EntradaInvalidaError < DynamicError

	def initialize linea, columna, nombreVariable, tipoVariable, entrada 
		@linea = linea
		@columna = columna
		@nombreVariable = nombreVariable
		@tipoVariable = tipoVariable
		@entrada = entrada
	end

	def to_s
		"linea #{@linea}, columna #{@columna}: la variable #{@nombreVariable} es de tipo #{@tipoVariable} y entro #{@entrada}"
	end

end

# Clase para representar a los errores de variables sin valor de inicializacion
# en tiempo de corrida
class VariableNoInicializadaError < DynamicError

	def initialize linea, columna, variable
		@linea = linea
		@columna = columna
		@variable = variable
	end

	def to_s
		"linea #{@linea}, columna #{@columna}: La variable #{@variable} no fue inicializada."
	end

end
>>>>>>> 776661ccc006e775a4d59ab38bae03804782468d
