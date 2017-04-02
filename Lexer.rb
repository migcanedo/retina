#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Lexer

require_relative 'Tokens'
require_relative 'Errores'

# Clase que representa al Lexer.
class Lexer
	# Constructor de la clase Lexer
	def initialize entrada
		@entrada = entrada # String que contiene el contenido del archivo
		@linea = 1 # Valor inicial de la fila
		@columna = 1 # Valor inicial de columna
		@tokens = [] # Lista de tokens
		@errores = [] # Lista de errores
		
	end

	# Metodo que consume la entrada del lexer y retorna el siguente token que haga match. 
	# En caso de no existir ningun match, reportara una exception.
	def obtener_token

		# Se consumen los espacios en blanco y los comentrios.
		@entrada =~ /\A(\s|\t|\n|\#.*)*/
		@entrada = $'
		$&.each_char do |chr|
			if chr == "\n" # Si es salto de linea, se suma 1 a la linea y se resetea la columna.
				@linea += 1
				@columna = 1
			else
				@columna += 1
			end
		end

		# Si la entrada queda completamente vacia, se retorna nil.
		if @entrada.empty?
			return nil
		end

		# Inicializamos un Error Lexicografico, en caso de no existir ningun match en la entrada.
		nuevoToken = LexicographError.new(@entrada[0], @linea, @columna)

		# Revisamos si la entrada hace match con algun token.
		$tokens.each do |token, regex|
			if @entrada =~ regex
				tk = Object::const_get("Tk#{token}")
				nuevoToken = tk.new($&, @linea, @columna)
				break
			end
		end

		# Aumentamos la columna con la longitud del match, o del error, y lo quitamos de la entrada.
		@columna += nuevoToken.texto.length
		@entrada = @entrada[nuevoToken.texto.length..@entrada.length-1]

		# Se reporta el error en caso de no existir mathc, o se retorna el token en caso de q si exista un match.
		if nuevoToken.is_a? LexicographError
			@errores << nuevoToken
			raise nuevoToken
		else
			@tokens << nuevoToken
			return nuevoToken
		end
	end

	# To String para hacer imprimible al Lexer. Si tiene errores, se imprimen sus errores; pero en caso contrario,
	# se imprimen los tokens reconocidos.
	def to_s
		(if @errores.empty? then @tokens else @errores end).map { |token| token.to_s }.join "\n"
	end
end