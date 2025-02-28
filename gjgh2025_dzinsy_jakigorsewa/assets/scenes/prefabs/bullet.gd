extends Node2D

var lifetime: float = 5.0
var target_vector: Vector2 = Vector2(1, 0)
var speed: float = 1.0

func set_speed(sp: float):
	speed = sp

func set_target_vector(v2: Vector2):
	target_vector = v2.normalized()

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		call_deferred("queue_free")
	global_position += target_vector * speed
