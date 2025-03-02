extends Area2D

@onready var player = get_parent()
@onready var camera: Camera2D = get_parent().get_node("Camera2D")

var squash_damage_max: float = 2.0
var squash_knockback_max: float = 3000.0



func _on_body_entered(body):
	var g = body.get_groups()
	if len(g) == 0:
		return
	var gr = g[0]
	if gr in ["Enemies", "Objects"]:
		if gr == "Enemies":
			body.player_visible = true
		body.hit_and_knockback(
			round(abs(player.car_speed / player.car_max_speed * squash_damage_max)), 
			abs(player.car_speed / player.car_max_speed * squash_knockback_max)
		)
		camera.apply_shake(abs(player.car_speed / player.car_max_speed * 4.0))
