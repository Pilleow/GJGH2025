extends CharacterBody2D

var knockback_move: Vector2 = Vector2.ZERO
@onready var player = get_tree().current_scene.find_child("Player")

@export_file("*.tscn") var part1Path = ""
@onready var part1 = load(part1Path)
@export_file("*.tscn") var part2Path = ""
@onready var part2 = load(part2Path)
@export_file("*.tscn") var part3Path = ""
@onready var part3 = load(part3Path)
@export_file("*.tscn") var part4Path = ""
@onready var part4 = load(part4Path)
@export_file("*.tscn") var part5Path = ""
@onready var part5 = load(part5Path)
@export_file("*.tscn") var partSpecialPath = ""
@onready var partSpecial = load(partSpecialPath)

@export var threshold_damage: float = 1.0

var knockback_slowdown = 0.9
var rotation_change = 0.0

func _ready():
	add_to_group("Objects")

func _spawn_parts_and_destroy():
	var i_total = 6
	var parts = []
	if partSpecialPath != "" and randf() < 0.25:
		parts = [partSpecial]
		i_total = 1
	else:
		if part1Path != "":
			parts.append(part1)
		if part2Path != "":
			parts.append(part2)
		if part3Path != "":
			parts.append(part3)
		if part4Path != "":
			parts.append(part4)
		if part5Path != "":
			parts.append(part5)
	for i in i_total:
		var b = parts[randi_range(0, len(parts) - 1)]
		var b1 = b.instantiate()
		b1.global_position = global_position
		get_tree().current_scene.add_child(b1)
		b1.hit_and_knockback(0, knockback_move.length()/2, PI/2)
		queue_free()

func hit_and_knockback(damage: float, knockback_power: float, random_spread:float = 0.0):
	var v = player.velocity.normalized().rotated(randf_range(-random_spread/2, random_spread/2))
	knockback_move = -v * knockback_power 
	knockback_slowdown = randf_range(0.6, 0.9)
	rotation_change = randf_range(-PI/13, PI/13)
	if damage > threshold_damage:
		SoundPlayer.play("RozwalenieObiekt")
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
