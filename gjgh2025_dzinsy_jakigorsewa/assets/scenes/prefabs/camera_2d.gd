extends Camera2D

var shake_strength = 0.0  # Initial strength of the shake
var shake_decay = 2.0      # How fast the shake stops

func apply_shake(intensity):
	shake_strength = intensity

func _physics_process(delta):
	if shake_strength > 0:
		offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)  # Smoothly decrease shake strength
	else:
		offset = Vector2.ZERO  # Reset when shake is done
