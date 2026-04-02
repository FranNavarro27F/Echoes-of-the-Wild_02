extends Node3D

# Cargamos la escena del jugador en memoria
const JUGADOR_ESCENA = preload("res://compartido/entidades/jugador.tscn")

func _ready():
	print("Mundo cargado en: ", multiplayer.get_unique_id())
	if not multiplayer.is_server():
		print("Soy un cliente y estoy listo")
		return
	# ... resto del código del servidor ...
	
	# 2. Conectamos la señal: "Cuando alguien se conecte, ejecuta la función añadir_jugador"
	multiplayer.peer_connected.connect(añadir_jugador)
	
	# 3. Creamos al jugador del propio Host (tú mismo)
	añadir_jugador(1)

func añadir_jugador(id):
	# Creamos una copia del jugador
	var nuevo_jugador = JUGADOR_ESCENA.instantiate()
	
	# LE ASIGNAMOS SU NOMBRE SEGÚN SU ID (Esto es vital para la sincronización)
	nuevo_jugador.name = str(id)
	
	# Lo metemos dentro del contenedor que creamos
	$ContenedorJugadores.add_child(nuevo_jugador)
	print("Jugador con ID ", id, " ha entrado a Aetherys")
