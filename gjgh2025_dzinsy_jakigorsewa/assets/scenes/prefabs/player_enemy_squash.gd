extends Area2D

@onready var player = get_parent()
var squash_damage_max: float = 5.0
var squash_knockback_max: float = 5000.0

func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		body.hit_and_knockback(
			abs(player.car_speed / player.car_max_speed * squash_damage_max), 
			abs(player.car_speed / player.car_max_speed * squash_knockback_max)
		)
