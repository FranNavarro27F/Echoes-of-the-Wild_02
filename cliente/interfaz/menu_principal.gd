extends Control

func _ready():
	# Buscamos la IP local usando nuestro GestorRed
	var mi_ip = GestorRed.obtener_mi_ip_local()
	
	# Usamos la ruta directa al nodo EtiquetaIP
	$VBoxContainer/EtiquetaIP.text = "Tu IP local es: " + mi_ip

func _on_boton_host_pressed():
	GestorRed.crear_servidor()
	get_tree().change_scene_to_file("res://compartido/mapas/mundo_aetherys.tscn")

func _on_boton_join_pressed():
	# Leemos el texto de la caja usando la ruta directa
	var ip_destino = $VBoxContainer/CajaIP.text
	
	# Si la caja está vacía, usamos la IP de prueba local
	if ip_destino == "":
		ip_destino = "127.0.0.1"
	
	# Pasamos la IP al GestorRed
	GestorRed.unirse_a_servidor(ip_destino)
	
	# Cambiamos a la escena del mundo
	get_tree().change_scene_to_file("res://compartido/mapas/mundo_aetherys.tscn")
