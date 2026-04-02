extends Node

const PUERTO = 8080
# 127.0.0.1 es la IP universal de "mi propia computadora" para hacer pruebas locales
const IP_SERVIDOR = "127.0.0.1" 

var peer = ENetMultiplayerPeer.new()

func crear_servidor():
	# Abrimos el puerto para escuchar a otros jugadores
	var error = peer.create_server(PUERTO)
	if error != OK:
		print("Error crítico al crear el servidor: ", error)
		return
	
	# Le decimos a Godot que use esta conexión para el multijugador
	multiplayer.multiplayer_peer = peer
	print("Servidor alojado con éxito. Esperando supervivientes...")

func unirse_a_servidor(ip_objetivo):
	# Intentamos llamar a la IP y puerto especificados
	var error = peer.create_client(ip_objetivo, PUERTO)
	if error != OK:
		print("Error al intentar conectar: ", error)
		return
		
	# Le decimos a Godot que use esta conexión
	multiplayer.multiplayer_peer = peer
	print("Conectando a la partida...")

func obtener_mi_ip_local() -> String:
	var todas_las_ips = IP.get_local_addresses()
	for ip in todas_las_ips:
		# Buscamos la IP que empieza con 192 (clásica de módems domésticos)
		# Ignoramos las que tienen ":" porque son direcciones IPv6 (más complejas)
		if ip.begins_with("192.") and not ":" in ip:
			return ip
	return "127.0.0.1" # Si falla, devuelve la local por defecto
