extends Node2D

var lifetime: float = 5.0
var target_vector: Vector2 = Vector2(1, 0)
var speed: float = 2.0
var damage: float = 1.0

@export var group: String = ""

func _ready():
	add_to_group(group)

func set_damage(v: float):
	damage = v

func get_damage_dealt():
	return damage

func set_speed(sp: float):
	speed = sp

func set_target_vector(v2: Vector2):
	target_vector = v2.normalized()

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		call_deferred("queue_free")
	global_position += target_vector * speed

func _on_area_2d_body_entered(body):
	if body is TileMapLayer:
		queue_free()
