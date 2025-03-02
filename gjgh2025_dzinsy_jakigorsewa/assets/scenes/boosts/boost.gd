extends Node2D

var picked_up: bool = false
var boost_type: String = ""

@onready var time_created: float = Time.get_ticks_msec() / 1000.0
var pop_up_time: float = 1.0
var dest_scale = 0.5

@onready var inside_player = get_tree().current_scene.find_child("PlayerInside")

func set_type(t: String):
	boost_type = t
	if t == "boost_car_accel_multiplier":
		$SpeedBoostSprite2D.show()
	elif t == "boost_turret_shooting_speed":
		$AttackBoostSprite2D.show()
	elif t == "defense_bubble_active":
		$DefenceBubbleSprite2D.show()
	elif t == "auto_repair_times":
		$AutoRepairSprite2D.show()

func _physics_process(delta):
	var ticks = Time.get_ticks_msec() / 1000.0
	if ticks < time_created + pop_up_time:
		var t = ((ticks - time_created) / pop_up_time)**(1.0/3.0)
		scale = Vector2(
			(t) * dest_scale,
			(t) * dest_scale
		)
		
	if picked_up:
		global_position = inside_player.get_node("AnimatedSprite2DContainer").global_position
