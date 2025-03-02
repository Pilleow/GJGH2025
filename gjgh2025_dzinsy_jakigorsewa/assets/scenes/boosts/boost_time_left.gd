extends Node2D

var time_left: float = 0.0
var init_time_left: float = 0.0

@onready var pBar = $ProgressBar

func set_time_left(v: float):
	time_left = v
	init_time_left = v

func _process(delta):
	time_left -= delta
	var t = time_left / init_time_left
	pBar.value = t * 100.0
	if time_left <= 0:
		call_deferred('queue_free')

func set_type(t: String):
	if t == "boost_car_accel_multiplier":
		$SpeedBoostSprite2D.show()
	elif t == "boost_turret_shooting_speed":
		$AttackBoostSprite2D.show()
	elif t == "defense_bubble_active":
		$DefenceBubbleSprite2D.show()
	elif t == "auto_repair_times":
		$AutoRepairSprite2D.show()
