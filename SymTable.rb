#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Tabla de Simbolos


require_relative 'Errores'
require_relative 'Lexer'

# Clase que representa una Tabla de Simbolos en el lenguaje.
class SymTable 
	# Metodo Constructor
	def initialize (padre = nil)
		@padre = padre
		@tabla = {}
	end

	# Metodo que se encarga de insertar un token en la tabla de simbolos o arrojar un error si el token ya existe.
	def insert token, tipo, variable = true

		if variable 
			if @tabla.has_key? (token.texto)
				raise RedefinirError.new(token, self.find(token.texto)[:token], variable)
			else
				@tabla[token.texto] = {:token => token, :tipo => tipo, :valor => nil}
			end
		else
			if @tabla.has_key? (token.idFuncion.nombre.texto)
				raise RedefinirError.new(token.idFuncion.nombre, self.find(token.idFuncion.nombre.texto)[:instancia].idFuncion.nombre, variable)	
			else
				@tabla[token.idFuncion.nombre.texto] = {:instancia => token, :tipo => tipo}
			end
		end	
	end

	# Metodo que se encarga de buscar un token en la tabla de simbolos y en sus tablas padres.
	def find nombre
		if @tabla.has_key? (nombre)
			@tabla[nombre]
		elsif @padre == nil
			nil
		else
			@padre.find(nombre)
		end
	end

	# Metodo que se encarga de actualizar el valor de la variable.
	def update nombre, valor
		find(nombre)[:valor] = valor
	end

	# Metodo utilizado para imprimir la tabla de simbolos
	def print_tabla(indentacion)
		s = ""
		if @tabla.empty?
			s += "#{indentacion}none \n"
		else
			@tabla.each do | clave, token, tipo |
				s += "#{indentacion}#{clave}: #{token[:tipo]} \n"
			end
		end
		print s
	end
end
