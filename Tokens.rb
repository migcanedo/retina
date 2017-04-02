<<<<<<< HEAD
#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Tokens

# Clase que representa un Token (lexema)
class Token
	attr_reader :texto, :fila, :columna

	# Constructor de la Clase Token
	def initialize texto, fila, columna
		@texto = texto	# Lo que se detecto al hacer match con alguna Expresion Regular.
		@fila = fila	# Fila en el archivo donde se consiguio dicho Token.
		@columna = columna # Columna en el archivo donde se consiguio dicho Token.
	end

	def to_s
		"linea #{@fila}, columna #{@columna}: #{self.class.name} '#{@texto}'"
	end
end

# Expresiones regulares para identificar los tokens
tk = {
 'Tipo' => /\A(boolean|number)\b/,
 'Number' => /\A[0-9]+(\.[0-9]+)?/,
 'Boolean' => /\A(true|false)\b/,
 'Flecha' => /\A\->/,
 'PuntoYComa' => /\A;/,
 'Coma' => /\A,/,
 'AbreParentesis' => /\A\(/,
 'CierraParentesis' => /\A\)/,
 'Igual' => /\A==/,
 'Diferente' => /\A\/=/,
 'MenorIgualQue' => /\A<=/,
 'MayorIgualQue' => /\A>=/,
 'MenorQue' => /\A</,
 'MayorQue' => /\A>/,
 'Asignacion' => /\A=/,
 'Suma' => /\A\+/,
 'Resta' => /\A\-/,
 'Multiplicacion' => /\A\*/,
 'Division' => /\A\//,
 'Modulo' => /\A%/,
 'Id' => /\A[a-z][a-zA-Z0-9_]*/,
 'String' => /\A\"([^\"\\\n]|(\\[\\\"n]))*\"/
}

# Arreglo con las palabras resevadas del Lenguaje.
palabras_reservadas = %w(program by not and or mod div read write writeln with do end if then else while for from to repeat times begin func return)
pr = Hash::new

# Agregamos las palabras reservadas al una Tabla de Hash de tal forma q su clave sea ella misma capitalizada y su valor sea su regex.
palabras_reservadas.each do |w| 
	pr[w.capitalize] = /\A#{w}\b/ 
end

# Unimos las tablas  de hash con los tokens y las palabras resrvadas para asi tenerlos en una sola.
$tokens = pr.merge(tk)

# Ahora creamos dinamicamente una clase para cada token, de forma que hereden sus caracteristicas de la clase Token.
$tokens.each do |token, regex|
	nueva_clase = Class::new(Token) do #Creacion dinamica de clases
		@regex = regex # Expresion regular 

		# Constructor de las clases
		def initialize(texto, fila, columna)
			@texto = texto 	
			@fila = fila	
			@columna = columna 
		end
	end
	Object::const_set("Tk#{token}", nueva_clase) # Le damos nombre a la clase
=======
#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Tokens

# Clase que representa un Token (lexema)
class Token
	attr_reader :texto, :fila, :columna

	# Constructor de la Clase Token
	def initialize texto, fila, columna
		@texto = texto	# Lo que se detecto al hacer match con alguna Expresion Regular
		@fila = fila	# Fila en el archivo donde se consiguio dicho Token
		@columna = columna # Columna en el archivo donde se consiguio dicho Token
	end

	def to_s
		"linea #{@fila}, columna #{@columna}: #{self.class.name} '#{@texto}'"
	end
end

# Expresiones regulares para identificar los tokens
tk = {
 'Tipo' => /\A(boolean|number)\b/,
 'Number' => /\A[0-9]+(\.[0-9]+)?/,
 'Boolean' => /\A(true|false)\b/,
 'Flecha' => /\A\->/,
 'PuntoYComa' => /\A;/,
 'Coma' => /\A,/,
 'AbreParentesis' => /\A\(/,
 'CierraParentesis' => /\A\)/,
 'Igual' => /\A==/,
 'Diferente' => /\A\/=/,
 'MenorIgualQue' => /\A<=/,
 'MayorIgualQue' => /\A>=/,
 'MenorQue' => /\A</,
 'MayorQue' => /\A>/,
 'Asignacion' => /\A=/,
 'Suma' => /\A\+/,
 'Resta' => /\A\-/,
 'Multiplicacion' => /\A\*/,
 'Division' => /\A\//,
 'Modulo' => /\A%/,
 'Id' => /\A[a-z][a-zA-Z0-9_]*/,
 'String' => /\A\"([^\"\\\n]|(\\[\\\"n]))*\"/
}

# Arreglo con las palabras resevadas del Lenguaje.
palabras_reservadas = %w(program by not and or mod div read write writeln with do end if then else while for from to repeat times begin func return)
pr = Hash::new

# Agregamos las palabras reservadas al una Tabla de Hash de tal forma q su clave sea ella misma capitalizada y su valor sea su regex.
palabras_reservadas.each do |w| 
	pr[w.capitalize] = /\A#{w}\b/ 
end

# Unimos las tablas  de hash con los tokens y las palabras resrvadas para asi tenerlos en una sola.
$tokens = pr.merge(tk)

# Ahora creamos dinamicamente una clase para cada token, de forma que hereden sus caracteristicas de la clase Token.
$tokens.each do |token, regex|
	nueva_clase = Class::new(Token) do #Creacion dinamica de clases
		@regex = regex # Expresion regular 

		# Constructor de las clases
		def initialize(texto, fila, columna)
			@texto = texto 	
			@fila = fila	
			@columna = columna 
		end
	end
	Object::const_set("Tk#{token}", nueva_clase) # Le damos nombre a la clase
>>>>>>> 776661ccc006e775a4d59ab38bae03804782468d
end