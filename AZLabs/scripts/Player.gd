extends KinematicBody

# variáveis de movimento
export var speed : float = 20
export var acceleration : float = 20
export var air_acceleration : float = 5
export var gravity : float = 0.98
export var max_terminal_velocity : float = 54
export var jump_power : float = 20

# variáveis de câmera
export(float, 0.1, 1) var mouse_sensitivity : float = 0.3
export(float, -90, 0) var min_pitch : float = -90
export(float, 0, 90) var max_pitch : float = 90

var velocity : Vector3
var y_velocity : float

onready var camera_pivot = $CameraPivot
onready var camera =  $CameraPivot/CameraBoom/Camera

# variáveis de animação
var jumping = false
var current_attack = 0;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(not Input.get_mouse_mode())
		
func _input(event):
	if (event is InputEventMouseMotion):
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_pitch, max_pitch)

func _physics_process(delta):
	handle_movement(delta)
		

func handle_movement(delta):
	var direction = Vector3()
	var dir_aux =  Vector2(0,0)
	if (Input.is_action_pressed("move_forward")):
		direction -= transform.basis.z
		dir_aux.y = -1
		
	if (Input.is_action_pressed("move_backward")):
		direction += transform.basis.z
		dir_aux.y = 1

	if (Input.is_action_pressed("move_left")):
		direction -= transform.basis.x
		dir_aux.x = 1
	
	if (Input.is_action_pressed("move_right")):
		direction += transform.basis.x
		dir_aux.x = -1
	
	direction = direction.normalized()
	
	var accel = acceleration if is_on_floor() else air_acceleration	
	velocity =  velocity.linear_interpolate(direction * speed, accel * delta)
	
	if(is_on_floor()):
		y_velocity = -0.01
		jumping = false
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)
		
	
	if (Input.is_action_just_pressed("jump") and is_on_floor()):		
		y_velocity = jump_power
		jumping = true
	
	velocity.y = y_velocity
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if(Input.is_action_just_pressed("attack")):
		$AnimationTree["parameters/Attacks/current"] = current_attack
		$AnimationTree["parameters/Attack/active"] = true
		if(current_attack > 1):
			current_attack = 0
		else:
			current_attack += 1
		
	if(dir_aux == Vector2(0,0)):
		$AnimationTree["parameters/MovementTime/scale"] = 1
	else:
		$AnimationTree["parameters/MovementTime/scale"] = 2.5
	$AnimationTree["parameters/Movement/blend_position"] = dir_aux
	if(jumping):
		$AnimationTree["parameters/Jump/blend_amount"] = 1
	else:
		$AnimationTree["parameters/Jump/blend_amount"] = 0
	
