extends CharacterBody3D

# --- Variables de Movimiento ---
const VELOCIDAD_CAMINAR = 5.0
const VELOCIDAD_CORRER = 8.0
const FUERZA_SALTO = 4.5

# Obtenemos la gravedad base de Godot
var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	# 1. AUTORIDAD: Solo el dueño de este ID de red puede moverlo
	set_multiplayer_authority(name.to_int())

func _ready():
	# IMPORTANTE: name.to_int() debe ser el ID de red
	if is_multiplayer_authority():
		$Camera3D.current = true  # Solo yo veo a través de MI cámara
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		$Camera3D.current = false # No veo a través de las cámaras de otros


func _physics_process(delta):
	# 3. FILTRO MULTIJUGADOR: Los clones no ejecutan teclas
	if not is_multiplayer_authority():
		return

	# --- FÍSICAS BÁSICAS ---
	# Aplicar gravedad si no estamos tocando el piso
	if not is_on_floor():
		velocity.y -= gravedad * delta

	# Manejar el Salto
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = FUERZA_SALTO

	# --- VELOCIDAD DINÁMICA ---
	# Determinar si caminamos o corremos
	var velocidad_actual = VELOCIDAD_CAMINAR
	if Input.is_action_pressed("correr"):
		velocidad_actual = VELOCIDAD_CORRER

	# --- MOVIMIENTO DIRECCIONAL ---
	# Usamos nuestras nuevas acciones en español
	var direccion_input = Input.get_vector("moverse_izquierda", "moverse_derecha", "moverse_adelante", "moverse_atras")
	var direccion = (transform.basis * Vector3(direccion_input.x, 0, direccion_input.y)).normalized()
	
	if direccion:
		velocity.x = direccion.x * velocidad_actual
		velocity.z = direccion.z * velocidad_actual
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad_actual)
		velocity.z = move_toward(velocity.z, 0, velocidad_actual)

	move_and_slide()

	# --- SISTEMA DE INTERACCIÓN (La tecla E) ---
	if Input.is_action_just_pressed("interactuar"):
		var sensor = $Camera3D/RayCast3D
		if sensor.is_colliding():
			var objeto = sensor.get_collider()
			print("Acción: Interactuando con: ", objeto.name)
			
			if objeto.has_method("interactuar"):
				objeto.interactuar()
		else:
			print("Acción: Intentaste interactuar, pero no hay nada con que interactuar frente a ti.")

	# --- ACCIONES E INTERFAZ ---
	if Input.is_action_just_pressed("atacar"):
		print("Acción: Atacando con espada (Clic Izquierdo)")
		
	if Input.is_action_just_pressed("cubrir"):
		print("Acción: Cubriéndose con escudo (Clic Derecho)")
		
	if Input.is_action_just_pressed("abrir_inventario"):
		print("Acción: Abriendo inventario")
		
	if Input.is_action_just_pressed("abrir_menu"):
		print("Acción: Abriendo menú de pausa")

# Sensibilidad del mouse (puedes ajustarla a tu gusto)
const SENSIBILIDAD = 0.003

func _unhandled_input(event):
	# Solo el dueño del personaje puede mover SU cámara
	if not is_multiplayer_authority():
		return

	# Si el evento es movimiento de mouse
	if event is InputEventMouseMotion:
		# 1. Rotar el CUERPO entero hacia los lados (Eje Y)
		rotate_y(-event.relative.x * SENSIBILIDAD)
		
		# 2. Rotar solo la CÁMARA hacia arriba y abajo (Eje X)
		$Camera3D.rotate_x(-event.relative.y * SENSIBILIDAD)
		
		# 3. Limitar la cámara para que no dé una vuelta de 360 grados vertical
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	# Truco: Si presionas ESC, liberas el mouse para cerrar el juego
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
