extends CharacterBody2D

var knockback_move: Vector2 = Vector2.ZERO
@onready var player = get_tree().current_scene.find_child("Player")

@export_file("*.tscn") var boxPart1Path = ""
@onready var boxPart1 = load(boxPart1Path)
@export_file("*.tscn") var boxPart2Path = ""
@onready var boxPart2 = load(boxPart2Path)
@export_file("*.tscn") var boxPart3Path = ""
@onready var boxPart3 = load(boxPart3Path)

@export var threshold_damage: float = 2.0

var knockback_slowdown = 0.9
var rotation_change = 0.0

func _ready():
	add_to_group("Objects")

func _spawn_parts_and_destroy():
	for b in [
		boxPart1, boxPart2, boxPart2, boxPart3, boxPart3, boxPart1
	]:
		var b1 = b.instantiate()
		b1.global_position = global_position
		get_tree().current_scene.add_child(b1)
		b1.hit_and_knockback(0, knockback_move.length()/2, PI/2)
		queue_free()

func hit_and_knockback(damage: float, knockback_power: float, random_spread:float = 0.0):
	var v = player.velocity.normalized().rotated(randf_range(-random_spread/2, random_spread/2))
	knockback_move = -v * knockback_power 
	knockback_slowdown = randf_range(0.7, 0.95)
	rotation_change = randf_range(-PI/15, PI/15)
	if damage > threshold_damage:
		_spawn_parts_and_destroy()

func _move():
	velocity = -knockback_move
	rotation += rotation_change
	if knockback_move:
		knockback_move *= knockback_slowdown
		rotation_change *= knockback_slowdown
	move_and_slide()

func _physics_process(delta):
	_move()
