extends Area2D

@onready var player = get_parent()
@onready var camera: Camera2D = get_parent().get_node("Camera2D")

var squash_damage_max: float = 5.0
var squash_knockback_max: float = 5000.0

var shake_strength = 0.0  # Initial strength of the shake
var shake_decay = 5.0      # How fast the shake stops

func _apply_shake(intensity):
	shake_strength = intensity

func _physics_process(delta):
	if shake_strength > 0:
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)  # Smoothly decrease shake strength
	else:
		camera.offset = Vector2.ZERO  # Reset when shake is done

func _on_body_entered(body):
	var g = body.get_groups()
	if len(g) == 0:
		return
	var gr = g[0]
	if gr in ["Enemies", "Objects"]:
		if gr == "Enemies" and body.is_dead:
			return
		body.hit_and_knockback(
			abs(player.car_speed / player.car_max_speed * squash_damage_max), 
			abs(player.car_speed / player.car_max_speed * squash_knockback_max)
		)
		_apply_shake(abs(player.car_speed / player.car_max_speed * 4.0))
