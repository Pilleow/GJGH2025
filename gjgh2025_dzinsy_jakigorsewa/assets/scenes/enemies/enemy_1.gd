extends CharacterBody2D

var enemy_speed: float = 200.0
var enemy_move: Vector2 = Vector2.ZERO
var target_spacing_from_point = 0.0

var knockback_move: Vector2 = Vector2.ZERO

@export var health: float = 3.0

@onready var rotate_around_point = get_parent().get_node("RotateAroundPoint")
@onready var player = get_tree().current_scene.find_child("Player")

func _ready():
	add_to_group("Enemies")

func hit_and_knockback(damage: float, knockback_power: float):
	health -= damage
	knockback_move = -player.velocity.normalized() * knockback_power 

func _set_target_move_to(to: Vector2):
	rotate_around_point.global_position -= to * enemy_speed

func _set_enemy_move():
	pass
	#var n: Vector2 = rotate_around_point.global_position - global_position
	#n = n.normalized() * (n.length() / target_spacing_from_point)
	#print(n)
	#var s = n.rotated(PI/2) * enemy_speed
	#enemy_move = n + s
	#enemy_move = enemy_move.normalized() * enemy_speed
	enemy_move = (rotate_around_point.global_position - global_position).normalized()

func _move():
	velocity = enemy_move * enemy_speed - knockback_move
	if knockback_move:
		knockback_move *= 0.9
	move_and_slide()

func _physics_process(delta):
	_set_enemy_move()
	var move_to = (rotate_around_point.global_position - player.global_position).normalized()
	_set_target_move_to(move_to)
	_move()
