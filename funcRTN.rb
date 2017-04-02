<<<<<<< HEAD
#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Funciones de Retina

require_relative 'SymTable'

# Creamos la Tabla de Simbolos para las funciones.
$tablaFunciones = SymTable.new()

# Inicializamos las variables globales necesarias .
$matrix = [] #Representacion del BitMap.
for i in 0..1000 
	m = []
	for j in 0..1000
		m << 0
	end
	$matrix << m
end
$eye = [500,500] # Posicion del cursor de retina.
$head = 180 	 # Direccion del cursor de retina.
$status = true	 # Indica si se marcan o no los movimientos del cursor.
# Marcamos el centro del BitMap.
$matrix[500][500] = 1 

# Clase que representa a la Funcion Home de Retina que coloca el curso en el
# punto inicial (0,0).
class FuncionHome
	attr_reader :idFuncion
	def initialize
		
		@idFuncion = Identificador.new(TkId.new("home", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion.
	def run tabla
		$eye = [500,500]
	end
end

# Clase que representa a la Funcion OpenEye de Retina que indica que se marcaran los 
# movimientos del cursor a partir de esta instruccion.
class FuncionOpenEye
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("openeye", 0, 0))
	end

	# Metodo que simula la ejecucion de la funcion.
	def run tabla
		$status = true
	end
end

# Clase que representa a la Funcion CloseEye de Retina que indica que no se marcaran los
# movimientos del cursor a partir de esta instruccion.
class FuncionCloseEye
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("closeeye", 0, 0))
	end

	# Metodo que simula la ejecucion de la funcion.	
	def run tabla
		$status = false
	end
end

# Clase que representa a la Funcion Forward de Retina que avanza el cursor una cantidad
# de pasos dada por el parametro.
class FuncionForward
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("forward", 0, 0))
	end

	# Metodo que simula la ejecucion de la funcion.
	def run tabla, param
		xi = $eye[0]
		yi = $eye[1]
		for i in 1..param[0]
			x = xi + (i*Math::cos($head*Math::PI/180)).round
			y = yi + (i*Math::sin($head*Math::PI/180)).round
			$matrix[x][y] = 1 if $status && x >= 0 && x < 1001 && y >= 0 && y < 1001
		end
		$eye = [x,y]
	end
end

# Clase que representa a la Funcion Backward de Retina que retrocede el cursor una
# cantidad de pasos dada por el parametro.
class FuncionBackward
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("backward", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion.
	def run tabla, param
		xi = $eye[0]
		yi = $eye[1]
		for i in 1..param[0]
			x = xi - (i*Math::cos($head*Math::PI/180)).round
			y = yi - (i*Math::sin($head*Math::PI/180)).round
			$matrix[x][y] = 1 if $status && x >= 0 && x < 1001 && y >= 0 && y < 1001
		end
		$eye = [x,y]
	end
end

# Clase que representa a la Funcion Rotatel de Retina que rota el cursor en sentido
# antihorario tantos grados como indique el parametro.
class FuncionRotatel
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("rotatel", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion.	
	def run tabla, param
		$head = ($head + param[0])%360
	end
end

# Clase que representa a la Funcion Rotater de Retina que rota el cursor en sentido
# horario tantos grados como indique el parametro.
class FuncionRotater
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("rotater", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion.
	def run tabla, param
		$head = ($head - param[0])%360
	end
end

# Clase que representa a la Funcion SetPosition de Retina que coloca el cursor a la
# posicion indicada por los parametros.
class FuncionSetPosition
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("setposition", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion.
	def run tabla, param
		$eye = [param[0], param[1]]
		$matrix[param[0]][param[1]] = 1 if $status
	end
end

# Guardamos todas estas funciones en la tabla global de funciones.
$tablaFunciones.insert(FuncionHome.new(), [nil], false)
$tablaFunciones.insert(FuncionOpenEye.new(), [nil], false)
$tablaFunciones.insert(FuncionCloseEye.new(), [nil], false)
$tablaFunciones.insert(FuncionForward.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionBackward.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionRotatel.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionRotater.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionSetPosition.new(), ["number", "number", nil], false)



=======
#! /usr/bin/ruby
# Universidad Simon Bolivar
# Trimestre Enero-Marzo 2017
# Traductores e Interpretadores [CI3725]
# Rafael Cisneros, 13-11156
# Miguel Canedo, 13-10214
# Proyecto, Funciones de Retina

require_relative 'SymTable'

# Creamos la Tabla de Simbolos para las funciones
$tablaFunciones = SymTable.new()

# Inicializamos las variables globales necesarias 
$matrix = [] #Representacion del BitMap
for i in 0..1000 
	m = []
	for j in 0..1000
		m << 0
	end
	$matrix << m
end
$eye = [500,500] # Posicion del cursor de retina
$head = 180 	 # Direccion del cursor de retina
$status = true	 # Indica si se marcan o no los movimientos del cursor
# Marcamos el centro del BitMap
$matrix[500][500] = 1 

# Clase que representa a la Funcion Home de Retina que coloca el curso en el
# punto inicial (0,0)
class FuncionHome
	attr_reader :idFuncion
	def initialize
		
		@idFuncion = Identificador.new(TkId.new("home", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion
	def run tabla
		$eye = [500,500]
	end
end

# Clase que representa a la Funcion OpenEye de Retina que indica que se marcaran los 
# movimientos del cursor a partir de esta instruccion
class FuncionOpenEye
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("openeye", 0, 0))
	end

	# Metodo que simula la ejecucion de la funcion	
	def run tabla
		$status = true
	end
end

# Clase que representa a la Funcion CloseEye de Retina que indica que no se marcaran los
# movimientos del cursor a partir de esta instruccion
class FuncionCloseEye
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("closeeye", 0, 0))
	end

	# Metodo que simula la ejecucion de la funcion	
	def run tabla
		$status = false
	end
end

# Clase que representa a la Funcion Forward de Retina que avanza el cursor una cantidad
# de pasos dada por el parametro
class FuncionForward
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("forward", 0, 0))
	end

	# Metodo que simula la ejecucion de la funcion	
	def run tabla, param
		xi = $eye[0]
		yi = $eye[1]
		for i in 1..param[0]
			x = xi + (i*Math::cos($head*Math::PI/180)).round
			y = yi + (i*Math::sin($head*Math::PI/180)).round
			$matrix[x][y] = 1 if $status && x >= 0 && x < 1001 && y >= 0 && y < 1001
		end
		$eye = [x,y]
	end
end

# Clase que representa a la Funcion Backward de Retina que retrocede el cursor una
# cantidad de pasos dada por el parametro
class FuncionBackward
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("backward", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion	
	def run tabla, param
		xi = $eye[0]
		yi = $eye[1]
		for i in 1..param[0]
			x = xi - (i*Math::cos($head*Math::PI/180)).round
			y = yi - (i*Math::sin($head*Math::PI/180)).round
			$matrix[x][y] = 1 if $status && x >= 0 && x < 1001 && y >= 0 && y < 1001
		end
		$eye = [x,y]
	end
end

# Clase que representa a la Funcion Rotatel de Retina que rota el cursor en sentido
# antihorario tantos grados como indique el parametro
class FuncionRotatel
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("rotatel", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion	
	def run tabla, param
		$head = ($head + param[0])%360
	end
end

# Clase que representa a la Funcion Rotater de Retina que rota el cursor en sentido
# horario tantos grados como indique el parametro
class FuncionRotater
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("rotater", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion	
	def run tabla, param
		$head = ($head - param[0])%360
	end
end

# Clase que representa a la Funcion SetPosition de Retina que coloca el cursor a la
# posicion indicada por los parametros
class FuncionSetPosition
	attr_reader :idFuncion
	def initialize
		@idFuncion = Identificador.new(TkId.new("setposition", 0, 0))
	end
	
	# Metodo que simula la ejecucion de la funcion	
	def run tabla, param
		$eye = [param[0], param[1]]
		$matrix[param[0]][param[1]] = 1 if $status
	end
end

# Guardamos todas estas funciones en la tabla global de funciones
$tablaFunciones.insert(FuncionHome.new(), [nil], false)
$tablaFunciones.insert(FuncionOpenEye.new(), [nil], false)
$tablaFunciones.insert(FuncionCloseEye.new(), [nil], false)
$tablaFunciones.insert(FuncionForward.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionBackward.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionRotatel.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionRotater.new(), ["number", nil], false)
$tablaFunciones.insert(FuncionSetPosition.new(), ["number", "number", nil], false)



>>>>>>> 776661ccc006e775a4d59ab38bae03804782468d
