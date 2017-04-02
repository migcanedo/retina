#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, AST


######
# CHEQUEAR EL RUN DE ENTRADA QUE COINCIDAN LOS TIPOS
######

require_relative 'SymTable'
require_relative 'Errores'
$nBloques = 1
$nFors = 1
$pilaLlamadas = []

# Clase generica que engloba a las clases participantes en el Arbol Sintactico
class AST
	attr_reader :inicio, :fin

	def set_inicio(i)
		@inicio = i
		self
	end

	def set_fin(f)
		@fin = f
		self
	end
end

# Clase engloba un programa completo, con sus bloques, instrucciones y funciones
class Programa < AST
	# Metodo para inicializar un programa definiendo las funciones y los bloques
	def initialize func, instrucciones
		@funciones = func
		@instrucciones = instrucciones
		@tablaVariables = SymTable.new()
	end
	
	# Metodo que revisa la correctitud de la clase Program
	def check
		@funciones.each do | f |
			f.check(true)
		end
		@funciones.each do | f |
			f.check(false)
		end
		@instrucciones.each do | i |
			i.check(@tablaVariables, true)
		end
	end
	
	# Metodo que simula la corrida del programa
	def run 
		@tablaVariables = SymTable.new()
		@funciones.each do | f |
			f.run(true, [])
		end
		@instrucciones.each do | i |
			i.run(@tablaVariables)
		end
	end
end

# Clase utilizada para definir una nueva funcion dentro del programa
class Funcion < AST
	attr_reader :idFuncion
	# Metodo para inicializar una funcion definiendo su id, sus parametros, el tipo de valor retornado y las instrucciones
	def initialize id, param, tr, inst
		@idFuncion = id
		@parametros = param
		@tipoRetorno = tr
		@instrucciones = inst
		@tablaVariables = SymTable.new()
	end
	
	# Metodo que revisa la correctitud de la clase Funcion
	def check bool
	
		if bool
			parametros = []
			@parametros.each do | p |
				parametros << p.tipo.nombre.texto
				begin
					@tablaVariables.insert(p.variable.nombre, p.tipo.nombre.texto.downcase)
				rescue RedefinirError => e
					$erroresContexto << e
				end
			end

			# Se guarda en la ultima posicion de este arreglo el tipo de vlaro a retorna de la funcion aun asi sea nil.
			if @tipoRetorno != nil
				parametros << @tipoRetorno.nombre.texto.downcase
			else
				parametros << nil
			end
			
			begin
				$tablaFunciones.insert(self, parametros, false) 
			rescue RedefinirError => e
				$erroresContexto << e
			end
		else
			encontradoReturn = false

			@instrucciones.each do | i |
				if @tipoRetorno != nil
					correcto = i.check(@tablaVariables, @tipoRetorno.nombre.texto)
				else
					i.check(@tablaVariables)
				end

				if correcto
					encontradoReturn = true
				end
			end

			if not encontradoReturn and @tipoRetorno != nil
				$erroresContexto << ErrorValorRetornoAusente.new(@inicio, @fin, @idFuncion.nombre.texto)
			elsif encontradoReturn and @tipoRetorno == nil
				$erroresContexto << ErrorValorRetornoNoRequerido.new(@inicio, @fin, @idFuncion.nombre.texto)
			end
		end	
	end

	# Metodo que simula la corrida de una funcion
	def run bool = false, parametros
		if bool 
			@tablaVariables = SymTable.new()
			@parametros.each do | p |
				@tablaVariables.insert(p.variable.nombre, p.tipo.nombre.texto.downcase)
			end
		else
			r = nil
			for i in 0..parametros.length-1
				@tablaVariables.update(@parametros[i].variable.nombre.texto, parametros[i])
			end
			@instrucciones.each do | i |
				r = i.run(@tablaVariables, true)
				if r != nil
					break
				end
			end
			return r			
		end
	end
end

# Clase que representa una instruccion de return dentro de una funcion
class ReturnFuncion < AST
	# Metodo para inicializar la instruccion return en una funcion especificando la expresion a retornar
	def initialize exp
		@expresionRetorno = exp
	end
	
	# Metodo que revisa la correctitud de la clase ReturnFuncion	
	def check tabla, tipoF = ''
		@expresionRetorno.check(tabla, tipoF)
		if @expresionRetorno.tipo.downcase != tipoF.downcase and tipoF != ''
			$erroresContexto << ErrorTipoValorRetornado.new(@inicio, @fin, tipoF.downcase, @expresionRetorno.tipo.downcase)
		end
		true
	end

	# Metodo que simula la corrida de una instruccion de retorno en una funcion
	def run tabla, bool = false
		@expresionRetorno.run(tabla)
	end
end 

# Clase que representa un entorno para un grupo variables e instrucciones
class Bloque < AST
	# Metodo para inicializar un entorno con declaraciones de variables e intrucciones
	def initialize decl, inst
		@declaraciones = decl
		@instrucciones = inst
		@tablaVariables = nil
	end

	# Metodo que revisa la correctitud de la clase Bloque
	def check tabla, tipoF = nil
		@tablaVariables = SymTable.new(tabla)
		if @declaraciones != nil
			@declaraciones.each do | d |
				begin
					@tablaVariables.insert(d.variable.nombre, d.tipo.nombre.texto)
				rescue RedefinirError => e
					$erroresContexto << e
				end
				d.check(@tablaVariables)
			end
		end
		correcto = false
		@instrucciones.each do | i |
			correcto = i.check(@tablaVariables, tipoF)
		end
		if tipoF != nil
			return correcto
		end
	end

	# Metodo que simula la corrida de un bloque de programa
	def run tabla, bool = false
		encontrado = nil
		@tablaVariables = SymTable.new(tabla)

		@declaraciones.each do | d |
			@tablaVariables.insert(d.variable.nombre, d.tipo.nombre.texto)
			d.run(@tablaVariables)
		end

		@instrucciones.each do | i |
			encontrado = i.run(@tablaVariables, bool)
			if i.class.name == "ReturnFuncion"
				break
			end
		end
		if bool 
			return encontrado
		end
	end
end

# Clase que representa los valores que necesita una funcion para poder ejecutarse
class Parametro < AST
	attr_reader :tipo, :variable
	# Metodo para inicializar un parametro indicando el tipo del parametro y el nombre usado para la variable
	def initialize tipo, id
		@tipo = tipo
		@variable = id
	end
end

# Clase que representa la declaracion de una variable dentro del bloque
class Declaracion < AST
	attr_reader :tipo, :variable
	# Metodo para inicializar una declaracion para una variable
	def initialize tipo, id, expresion
		@tipo = tipo
		@variable = id
		@valor = expresion
	end

	# Metodo que revisa la correctitud de la clase Declaracion
	def check tabla, tipoF = nil
		if @valor != nil
			@valor.check(tabla)

			if @tipo.nombre.texto.downcase != @valor.tipo.downcase
				$erroresContexto << ErrorAsignacion.new(@inicio, @fin, @tipo.nombre.texto.downcase, @valor.tipo.downcase, @variable.nombre.texto)
			end
		end
	end

	# Metodo que simula la corrida de una declaracion de variable
	def run tabla 
		if @valor != nil
			tabla.update(@variable.nombre.texto, @valor.run(tabla))
		end 
	end
end

# Clase que representa una asignacion a una variable
class Asignacion < AST
	# Metodo para inicializar la asignacion de un valor para una variable una dada
	def initialize id, valor
		@variable = id
		@valor = valor
	end

	# Metodo que revisa la correctitud de la clase Asignacion
	def check tabla, tipoF = nil
		@valor.check(tabla)
		var = tabla.find(@variable.nombre.texto)
		if var == nil
			$erroresContexto << ErrorVariableNoDeclarada.new(@inicio, @fin, @variable.nombre.texto)
		else
			tipoVariable = var[:tipo].downcase
			if tipoVariable != @valor.tipo.downcase
				$erroresContexto << ErrorAsignacion.new(@inicio, @fin, tipoVariable, @valor.tipo.downcase, @variable.nombre.texto)
			end
			
		end
	end

	# Metodo que simula la corrida de una asignacion de valor a una variable
	def run tabla, bool = false 
		tabla.update(@variable.nombre.texto, @valor.run(tabla))	
	end
end

# Clase que representa un control de flujo
class Condicional < AST
	# Metodo para inicializar un grupo de instrucciones dada una condicion para su ejecucion	
	def initialize cond, inst1, inst2
		@condicion = cond
		@instrucciones = inst1
		@instruccionesElse = inst2
	end

	# Metodo que revisa la correctitud de la clase Condicional
	def check tabla, tipoF = nil
		@condicion.check(tabla)
		if @condicion.tipo.downcase !=  "boolean"
			$erroresContexto << ErrorCondicionCondicional.new(@inicio, @fin, @condicion.tipo.downcase)
		end

		correcto = false
		@instrucciones.each do | i |
			correcto = i.check(tabla, tipoF)
		end 

		if @instruccionesElse != nil
			@instruccionesElse.each do | ie |
				correcto = ie.check(tabla, tipoF)
			end 
		end

		if tipoF != nil
			return correcto
		end
	end

	# Metodo que simula la corrida de un condicional
	def run tabla, bool = false 
		encontrado = nil
		cond = @condicion.run(tabla)
		if cond 
			@instrucciones.each do | i |
				encontrado = i.run(tabla, bool)
				if i.class.name == "ReturnFuncion"
					break
				end
			end
		else	
			if @instruccionesElse != nil
				@instruccionesElse.each do | i |
					encontrado = i.run(tabla, bool)
					if i.class.name == "ReturnFuncion"
						break
					end					
				end
			end
		end
		if bool
			return encontrado
		end
	end
end

# Clase que representa un ciclo indeterminado de instrucciones (while)
class IteracionIndeterminada < AST
	# Metodo para inicializar un ciclo while de instrucciones dada una condicion para su ejecucion
	def initialize cond, inst
		@condicion = cond
		@instrucciones = inst
	end

	# Metodo que revisa la correctitud de la clase IteracionIndeterminada
	def check tabla, tipoF = nil
		@condicion.check(tabla)
		if @condicion.tipo.downcase !=  "boolean"
			$erroresContexto << ErrorCondicionIteracion.new(@inicio, @fin, @condicion.tipo.downcase)
		end

		correcto = false
		@instrucciones.each do | i |
			correcto = i.check(tabla, tipoF)
		end

		if tipoF != nil
			return correcto
		end
	end

	# Metodo que simula la corrida de una iteracion indeterminada
	def run tabla, bool = false
		encontrado = nil
		cond = @condicion.run(tabla)
		while cond do
			@instrucciones.each do | i | 
				encontrado = i.run(tabla, bool)
				if i.class.name == "ReturnFuncion"
					break
				end				
			end
			cond = @condicion.run(tabla)
		end
		if bool
			return encontrado
		end
	end
end

# Clase que representa un ciclo determinado de instrucciones (for)
class IteracionDeterminada < AST
	# Metodo para inicializar un ciclo determinado de instrucciones dada una variable de iteracion, su rango de accion y su taza de incremento
	def initialize id, ini, fin, aum, inst
		@iterador = id
		@inicioRango = ini
		@finRango = fin
		@incremento = aum
		@instrucciones = inst
		@tablaVariables = nil
	end

	# Metodo que revisa la correctitud de la clase IteracionDeterminada
	def check tabla, tipoF = nil
		@tablaVariables = SymTable.new(tabla)
		begin 
			@tablaVariables.insert(@iterador.nombre, "number")
		rescue RedefinirError => e
			$erroresContexto << e
		end

		@inicioRango.check(@tablaVariables)
		if @inicioRango.tipo.downcase != "number"
			$erroresContexto << ErrorTipoRangoInvalido.new(@inicio, @fin, @inicioRango.tipo.downcase)
		end

		@finRango.check(@tablaVariables)
		if @finRango.tipo.downcase != "number"
			$erroresContexto << ErrorTipoRangoInvalido.new(@inicio, @fin, @finRango.tipo.downcase)
		end

		if @incremento != nil
			@incremento.check(@tablaVariables)
			if @incremento.tipo.downcase != "number"
				$erroresContexto << ErrorTipoIncrementoIteracionInvalido.new(@inicio, @fin, @incremento.tipo.downcase)
			end
		end

		correcto = false
		@instrucciones.each do | i |
			correcto = i.check(@tablaVariables, tipoF)
		end

		if tipoF != nil
			return correcto
		end
	end

	# Metodo que simula la corrida de iteracion determinada
	def run tabla, bool = false
		encontrado = nil
		@tablaVariables = SymTable.new(tabla)	
		@tablaVariables.insert(@iterador.nombre, "number")
		@tablaVariables.update(@iterador.nombre.texto, @inicioRango.run(@tablaVariables))
		f = @finRango.run(tabla)
		i = @tablaVariables.find(@iterador.nombre.texto)[:valor]
		while i <= f do
			@instrucciones.each do | i |
				encontrado = i.run(@tablaVariables, bool)
				if i.class.name == "ReturnFuncion"
					break
				end
			end
			if @incremento != nil
				@tablaVariables.update(@iterador.nombre.texto, @incremento.run(@tablaVariables))
				i = @tablaVariables.find(@iterador.nombre.texto)[:valor]
			else
				@tablaVariables.update(@iterador.nombre.texto, i+1)
				i = @tablaVariables.find(@iterador.nombre.texto)[:valor]
			end
		end
		if bool
			return encontrado
		end
	end
end

# Clase que representa un caso especial de iteraciones determinadas(repeat)
class IteracionRepeat < AST
	# Metodo para inicializar un ciclo repeat dadas las instrucciones y la cantidad de veces a repetir el ciclo
	def initialize v, inst
		@veces = v
		@instrucciones = inst
	end

	# Metodo que revisa la correctitud de la clase IteracionRepeat
	def check tabla, tipoF = nil
		@veces.check(tabla)
		if @veces.tipo.downcase != "number"
			$erroresContexto << ErrorTipoExpresionRepeat.new(@inicio, @fin, @veces.tipo.downcase)
		end

		correcto = false
		@instrucciones.each do | i |
			correcto = i.check(tabla, tipoF)
		end
		
		if tipoF != nil
			return correcto
		end

	end

	# Metodo que simula la corrida de una iteracion repeat
	def run tabla, bool = false
		encontrado = nil
		n = @veces.run(tabla)
		for i in 0..n-1
			@instrucciones.each do | i |
				encontrado = i.run(tabla, bool)
				if i.class.name == "ReturnFuncion"
					break
				end
			end
		end
		if bool
			return encontrado
		end
	end
end

# Clase que representa una llamada a una funcion previamente definida en el programa
class LlamadaFuncion < AST
	attr_reader :tipo
	# Metodo para inicializar una llamada a una funcion con identificador idf y los parametros especificados
	def initialize idf, param
		@idFuncion = idf
		@parametros = param
		@tipo = nil
	end

	# Metodo que revisa la correctitud de la clase LlamadaFuncion
	def check tabla, tipoF = nil
		funcion = $tablaFunciones.find(@idFuncion.nombre.texto)
		if funcion == nil
			$erroresContexto << ErrorFuncionNoDeclarada.new(@inicio, @fin, @idFuncion.nombre.texto)
		else
			parametrosFuncion = funcion[:tipo]

			if parametrosFuncion.size-1 != @parametros.size
				$erroresContexto << ErrorCantidadParametros.new(@inicio, @fin, parametrosFuncion.size-1, @parametros.size, @idFuncion.nombre.texto)
			end

			for i in (0..parametrosFuncion.size-2) do 
				@parametros[i].check(tabla)
				if @parametros[i].tipo.downcase != parametrosFuncion[i]

					$erroresContexto << ErrorTipoParametro.new(@inicio, @fin, parametrosFuncion[i], @parametros[i].tipo.downcase, i, @idFuncion.nombre.texto)
				end
			end

			@tipo = parametrosFuncion[parametrosFuncion.size-1]
		end
	end

	# Metodo que simula la corrida de una llamada de funcion
	def run tabla, bool = false
		param = []
		@parametros.each do | p | 
			param << p.run(tabla)
		end
		
		if $pilaLlamadas.include?(@idFuncion.nombre.texto) && $pilaLlamadas.last != @idFuncion.nombre.texto then
			raise CorrecursividadError.new(@inicio, @fin)
		else
			$pilaLlamadas << @idFuncion.nombre.texto
			r = $tablaFunciones.find(@idFuncion.nombre.texto)[:instancia].run(false, param)
			$pilaLlamadas.pop()
			if r != nil
				return r
			end			
		end
	end
end

# Clase para representar la instruccion de salida sin salto
class Salida < AST
	# Metodo para inicializar una instruccion de salida dado un elemento
	def initialize elem
		@elementos = elem
	end

	# Metodo que revisa la correctitud de la clase Salida
	def check tabla, tipoF = nil
		@elementos.each do | e |
			if e.class.name != "String"
				e.check(tabla)
			end
		end
	end

	# Metodo que simula la corrida de una instruccion de salida
	def run tabla, bool = false 
		@elementos.each do | e |
			print e.run(tabla)
			print " "	
		end
		return nil
	end
end

# Clase para representar la instruccion de salida con salto
class SalidaSalto < Salida
	# Metodo que simula la corrida de una instruccion de salida con salto de linea
	def run tabla, bool = false
		@elementos.each do | e |
			print e.run(tabla)	
			print " "	
		end
		puts 
		return nil
	end
end

# Clase que representa la asignacion de un valor a una variable dada una entrada
class Entrada < AST
	# Metodo para inicializar un instruccion de entrada
	def initialize id
		@variable = id
	end	

	# Metodo que revisa la correctitud de la clase Entrada
	def check tabla, tipoF = nil
		@variable.check(tabla)
	end

	# Metodo que simula la corrida de una entrada por teclado
	def run tabla, bool = false
		entrada = STDIN.gets
		tipo = tabla.find(@variable.nombre.texto)[:tipo]
		
		if (entrada == "true" && tipo == "boolean") 
			tabla.update(@variable.nombre.texto, true)
		elsif (entrada == "false" && tipo == "boolean") 
			tabla.update(@variable.nombre.texto, false)	
		elsif tipo == "number" && entrada =~   /\A[0-9]+(\.[0-9]+)/
			tabla.update(@variable.nombre.texto, entrada.to_f)
		elsif tipo == "number" && entrada =~  /\A[0-9]/
			tabla.update(@variable.nombre.texto, entrada.to_i)
		else
			raise EntradaInvalidaError.new(@inicio, @fin, @variable.nombre.texto, tipo, entrada)
		end
		
	end
end

# Clase que representa los numeros dentro del lenguaje
class Numero < AST
	attr_reader :tipo, :nombre
	# Metodo que inicializa un numero con un valor dado
	def initialize v
		@nombre = v
		@tipo = nil
	end

	# Metodo que revisa la correctitud de la clase Numero
	def check tabla, tipoF = nil
		@tipo = "number"
		@inicio = @nombre.fila
	end

	# Metodo que devuelve el valor que posee un numero en el programa
	def run tabla
		if	@nombre.texto =~  /\A[0-9]/ then
			@nombre.texto.to_i
		else
			@nombre.texto.to_f
		end		
	end
end

# Clase que representa los valores booleanos dentro del lenguaje
class Booleano < AST
	attr_reader :tipo, :nombre
	# Metodo para inicializar un valor booleano
	def initialize v
		@nombre = v
		@tipo = nil
	end

	# Metodo que revisa la correctitud de la clase Booleano
	def check tabla, tipoF = nil
		@tipo = "boolean"
		@inicio = @nombre.fila
	end

	# Metodo que devuelve el valor que posee un booleano en el programa
	def run tabla 
		@nombre.texto == "true"
	end
end

# Clase que representa una cadena de caracteres para ser utilizada en una instruccion de salida
class String
	attr_reader :cadena
	# Metodo que define los caracteres que conforman la cadena
	def initialize c
		@cadena = c
	end

	# Metodo que devuelve la cadena de caracteres usada en el programa	
	def run tabla
		@cadena.texto.gsub(/"/, '').gsub(/\\n/, "\n")
	end
end

# Clase que representa los tipo de valores para variables que pueden ser usadas en el lenguaje
class Tipo < AST
	attr_reader :nombre
	# Metodo para inicializar un tipo de variable para un nombre dado (number/boolean)
	def initialize n
		@nombre = n
	end
end

# Clase que representa los ids que pueden tener las variables y las funciones dentro de un programa
class Identificador < AST
	attr_reader :nombre, :tipo
	# Metodo para inicializar un identificador con un nombre dado
	def initialize n
		@nombre = n
		@tipo = "'Expresion Errada'"
	end

	# Metodo que revisa la correctitud de la clase Identificador
	def check tabla, tipoF = nil
		@inicio = @nombre.fila
		variable = tabla.find(@nombre.texto)
		if variable == nil
			$erroresContexto << ErrorVariableNoDeclarada.new(@nombre.fila, @nombre.fila, @nombre.texto)
		else 
			@tipo = variable[:tipo]
		end
	end

	# Metodo que devuelve el valor de la variable
	def run tabla 
		valor = tabla.find(@nombre.texto)[:valor]
		if valor == nil then
			raise VariableNoInicializadaError.new(@nombre.fila, @nombre.columna, @nombre.texto)
		end
		return valor
	end
end

# Clase que engloba a los operadores que requieren de un solo operando para ejecutarse
class OpUnario < AST
	attr_reader :tipo
	# Metodo para inicializar un operador unario dado operando
	def initialize op
		@operando = op 
		@tipo = "'Expresion Errada'"
	end

	# Metodo que revisa la correctitud de la clase OpUnario
	def check tabla, tipoF = nil
		@operando.check(tabla)
		@inicio = @operando.inicio

		if @operando.tipo == 'number' and self.class.name == 'Negativo'
			@tipo = "number"
		elsif @operando.class.name == 'Numero' and self.class.name != 'Negativo'
			$erroresContexto << ErrorTipoOperadores.new(@inicio, @inicio, self.class.name, "number")
		end

		if @operando.tipo == 'boolean' and self.class.name == 'Not'
			@tipo = "boolean"
		elsif @operando.class.name == 'Booleano' and self.class.name != 'Not'
			$erroresContexto << ErrorTipoOperadores.new(@inicio, @inicio, self.class.name, "boolean")
		end
	end
end

# Clase para representar el operador booleano "not"
class Not < OpUnario
	# Metodo que simula la operacion booleana "not"
	def run tabla 
		not(@operando.run(tabla))
	end
end

# Clase para representar el operador numerico "-"
class Negativo < OpUnario
	# Metodo que simula la operacion aritmetica "-"
	def run tabla 
		-(@operando.run(tabla))
	end
end

# Clase que engloba a los operadores que requieren de dos operandos para su ejecucion
class OpBinario < AST
	attr_reader :tipo
	# Metodo para inicializar un operador binario dado sus operandos
	def initialize opl, opr
		@opIzquierda = opl
		@opDerecha = opr
		@tipo = "'Expresion Errada'"
	end

	# Metodo que revisa la correctitud de la clase OpBinario
	def check tabla, tipoF = nil
		@opIzquierda.check(tabla)
		@opDerecha.check(tabla)

		@inicio = @opDerecha.inicio

		if @opIzquierda.tipo == "number" and @opDerecha.tipo == "number" and (self.class.name == 'Suma' or self.class.name == 'Resta' or self.class.name == 'Multiplicacion' or self.class.name == 'Division' or self.class.name == 'Modulo' or self.class.name == 'DivisionEntera' or self.class.name == 'ModuloEntero') 
			@tipo = "number"
		elsif @opIzquierda.tipo == "number" and @opDerecha.tipo == "number" and (self.class.name == 'Igual' or self.class.name == 'Diferente' or self.class.name == 'MayorQue' or self.class.name == 'MenorQue' or self.class.name == 'MayorIgualQue' or self.class.name == 'MenorIgualQue')
			@tipo = "boolean"
		elsif @opIzquierda.tipo == "boolean" and @opDerecha.tipo == "boolean" and  (self.class.name == 'Igual' or self.class.name == 'Diferente' or self.class.name == 'And' or self.class.name == 'Or')
			@tipo = "boolean"
		else
			$erroresContexto << ErrorTipoOperadores.new(@inicio, @inicio, self.class.name, @opIzquierda.tipo, @opDerecha.tipo)
		end
	end
end

# Clase para representar la operacion de adicion de numeros
class Suma < OpBinario
	# Metodo que simula la operacion aritmetica suma
	def run tabla 
		resultado = @opIzquierda.run(tabla) + @opDerecha.run(tabla)
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado
	end
end

# Clase para representar la operacion de sustraccion de numeros
class Resta < OpBinario
	# Metodo que simula la operacion aritmetica resta
	def run tabla 
		resultado = @opIzquierda.run(tabla) - @opDerecha.run(tabla)	
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado
	end
end

# Clase para representar la operacion de multiplicacion de numeros
class Multiplicacion < OpBinario
	# Metodo que simula la operacion aritmetica multiplicacion
	def run tabla 
		resultado = @opIzquierda.run(tabla) * @opDerecha.run(tabla)	
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado		
	end
end

# Clase para representar la operacion de division de numeros
class Division < OpBinario
	# Metodo que simula la operacion aritmetica division
	def run tabla 
		divisor = @opDerecha.run(tabla)
		if divisor == 0 then
			raise DivisionCeroError.new(@inicio, @fin)
		end
		resultado = @opIzquierda.run(tabla) / divisor
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado
	end
end

# Clase para representar la operacion para calcular el resto de una division de numeros
class Modulo < OpBinario
	# Metodo que simula la operacion aritmetica modulo
	def run tabla 
		divisor = @opDerecha.run(tabla)
		if divisor == 0 then
			raise DivisionCeroError.new(@inicio, @fin)
		end
		resultado = @opIzquierda.run(tabla) % divisor
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado		
	end
end

# Clase para representar la operacion de division de numeros con resultado entero
class DivisionEntera < OpBinario
	# Metodo que simula la operacion aritmetica division entera
	def run tabla 
		divisor = @opDerecha.run(tabla)
		if divisor == 0 then
			raise DivisionCeroError.new(@inicio, @fin)
		end
		resultado = @opIzquierda.run(tabla).div(divisor)
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado
	end
end

# Clase para representar la operacion para calcular el resto entero de una division de numeros
class ModuloEntero < OpBinario
	# Metodo que simula la operacion aritmetica modulo entero
	def run tabla 
		divisor = @opDerecha.run(tabla)
		if divisor == 0 then
			raise DivisionCeroError.new(@inicio, @fin)
		end
		resultado = @opIzquierda.run(tabla).floor % divisor.floor
		if resultado > 2**31-1 || resultado < -2**31 then
			raise OverflowError.new(@inicio, @fin)
		end
		return resultado
	end
end

# Clase para representar la operacion booleana de conjuncion
class And < OpBinario
	# Metodo que simula la operacion booleana "and"
	def run tabla 
		@opIzquierda.run(tabla) and @opDerecha.run(tabla)
	end
end

# Clase para representar la operacion booleana de disyuncion
class Or < OpBinario
	# Metodo que simula la operacion booleana "or"
	def run tabla 
		@opIzquierda.run(tabla) or @opDerecha.run(tabla)	
	end
end

# Clase para representar la operacion de comparacion de igualdad
class Igual < OpBinario
	# Metodo que simula la operacion booleana "igual que"
	def run tabla 
		@opIzquierda.run(tabla) == @opDerecha.run(tabla)	
	end
end

# Clase para representar la operacion de comparacion de desigualdad
class Diferente < OpBinario
	# Metodo que simula la operacion booleana "diferente"
	def run tabla 
		@opIzquierda.run(tabla) != @opDerecha.run(tabla)	
	end
end

# Clase para representar la operacion de comparacion de "menor estricto que"
class MenorQue < OpBinario
	# Metodo que simula la operacion booleana "menor que"
	def run tabla 
		@opIzquierda.run(tabla) < @opDerecha.run(tabla)	
	end
end

# Clase para representar la operacion de comparacion de "mayor estricto que"
class MayorQue < OpBinario
	# Metodo que simula la operacion booleana "mayor que"
	def run tabla 
		@opIzquierda.run(tabla) > @opDerecha.run(tabla)	
	end
end

# Clase para representar la operacion de comparacion de "menor o igual que"
class MenorIgualQue < OpBinario
	# Metodo que simula la operacion booleana "menor o igual que"
	def run tabla 
		@opIzquierda.run(tabla) <= @opDerecha.run(tabla)	
	end
end

# Clase para representar la operacion de comparacion de "mayor o igual que"
class MayorIgualQue < OpBinario
	# Metodo que simula la operacion booleana "mayor o igual que"
	def run tabla 
		@opIzquierda.run(tabla) >= @opDerecha.run(tabla)	
	end
end
