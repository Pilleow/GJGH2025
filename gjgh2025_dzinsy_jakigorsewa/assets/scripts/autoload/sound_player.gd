extends Node2D

@onready var sounds = {}
var camera = null

func set_camera_to(c: Camera2D):
	camera = c

func _ready():
	for child in get_children():
		sounds[child.name] = child

func play(name: String, pitch_scale:float = 1.0):
	sounds[name].play()
	if pitch_scale != 1.0:
		sounds[name].set_pitch_scale(pitch_scale)

func _physics_process(delta):
	if is_instance_valid(camera):
		global_position = camera.global_position
	elif global_position != Vector2.ZERO:
		global_position = Vector2.ZERO
