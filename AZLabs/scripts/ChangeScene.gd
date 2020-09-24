extends Spatial

export(String, FILE, "*.tscn") var new_scene
var can_change = false

var anim = null

func _ready():
	anim = get_node("AnimationPlayer")
	anim.play("rotateText", -1, 0.25)

func _unhandled_key_input(event):
	
	if(can_change and Input.is_action_just_pressed("interact")):
		get_tree().change_scene(new_scene)


func _on_Area_body_entered(body):
	var groups = body.get_groups()
	if(groups.has("player")):
		can_change = true


func _on_Area_body_exited(body):
	var groups = body.get_groups()
	if(groups.has("player")):
		can_change = false
