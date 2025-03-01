extends Node2D

var picked_up: bool = false
var boost_type: String = ""

@onready var time_created: float = Time.get_ticks_msec() / 1000.0
var pop_up_time: float = 1.0
var dest_scale = 0.5

@onready var inside_player = get_tree().current_scene.find_child("PlayerInside")

func set_type(t: String):
	boost_type = t
	if t == "boost_car_speed_multiplier":
		$SpeedBoostSprite2D.show()
	elif t == "boost_turret_shooting_speed":
		$AttackBoostSprite2D.show()

func _physics_process(delta):
	if time_created < pop_up_time:
		var t = pop_up_time - time_created
		scale = Vector2(
			(t) * dest_scale,
			(t) * dest_scale
		)
		
	if picked_up:
		global_position = inside_player.global_position
