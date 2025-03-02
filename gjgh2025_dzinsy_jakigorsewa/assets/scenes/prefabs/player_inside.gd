extends CharacterBody2D

var boost_turret_shooting_speed: float = 1.0

var speed = 800.0
var turret_rotation: float = 0.0
var turret_rotation_max_speed: float = 0.1

var able_to_sit_down: bool = false
var sat_down: bool = false

var able_to_repair_car: bool = false
var is_repairing: bool = false
var repairing_time_left: float = 0.0
var one_hp_repair_time: float = 0.5

var able_to_pickup_boost_location: int = 0

var able_to_put_boost_in_engine: bool = false
var current_holding_boost = null
var current_active_boosts = [
]  # [type, time left, total time]

@export_file("*.tscn") var boostTimerBarPath = ""
@onready var boostTimerBar = load(boostTimerBarPath)
@export_file("*.tscn") var bulletPath = ""
@onready var bullet: PackedScene = load(bulletPath)
var shooting_cooldown = 0.5
var shooting_cooldown_default = 0.2
var bullet_damage = 2.0

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var turretChair: Node2D = get_parent().get_node("TurretChair")
@onready var interactLabel: Label = $Label
@onready var turretSprite: Sprite2D = null
@onready var animSprite: AnimatedSprite2D = $AnimatedSprite2DContainer/AnimatedSprite2D
@onready var animSpriteContainer: Node2D = $AnimatedSprite2DContainer
@onready var turretChairSprite: Node2D = get_parent().get_node("TurretChair").get_node("AnimatedSprite2D")
@onready var car: CharacterBody2D = null
@onready var boostInContainer: Node2D = get_parent().get_node("BoostInContainer")

func _ready():
	turretSprite = get_tree().current_scene.find_child("CarTurretSprite")
	turretChairSprite.play("empty")
	car = get_tree().current_scene.find_child("Player")

func _move_turret():
	if not turretSprite:
		return
	var y_direction = Input.get_axis("designer_aim_up", "designer_aim_down")
	var x_direction = Input.get_axis("designer_aim_left", "designer_aim_right")
	var target_vector: Vector2 = Vector2(
		-y_direction,
		x_direction
	)
	target_vector += turretSprite.global_position
	turretSprite.look_at(target_vector)
	
	#var x_direction = Input.get_axis("designer_aim_left", "designer_aim_right")
	#turret_rotation += x_direction
	#turretSprite.global_rotation = turret_rotation * turret_rotation_max_speed

func add_boost_to_car(boost: String, time: float):
	current_active_boosts.append([boost, time, time])
	var pb = boostTimerBar.instantiate()
	pb.position = Vector2(754.0 / 2.666, -672.0 / 2.666 + len(current_active_boosts) * 40.0)
	pb.set_type(boost)
	pb.set_time_left(time)
	get_parent().add_child(pb)
	_update_existing_boost_effects()

func _update_existing_boost_effects():
	car.boost_car_speed_multiplier = 1.0
	boost_turret_shooting_speed = 1.0
	
	for eff in current_active_boosts:
		if eff[0] == "boost_car_speed_multiplier":
			car.boost_car_speed_multiplier = 2.0
			# this should only boost the speed when the car player holds down a TURBO button!
		elif eff[0] == "boost_turret_shooting_speed":
			boost_turret_shooting_speed = 2.0
		elif eff[0] == "defense_bubble_active":
			car.defense_bubble_active = true
			car.defenseBubble.show()

func _update_boost_clocks(delta):
	for index in len(current_active_boosts):
		var index_inv = len(current_active_boosts) - index - 1
		current_active_boosts[index_inv][1] -= delta
		if current_active_boosts[index_inv][1] <= 0:
			current_active_boosts.remove_at(index_inv)
			_update_existing_boost_effects()

func _move_person():
	if is_repairing:
		return
	var y_direction = Input.get_axis("designer_up", "designer_down")
	if y_direction:
		velocity.y = move_toward(velocity.y, y_direction * speed, speed/3)
	else:
		velocity.y = move_toward(velocity.y, 0, speed/3)
	var x_direction = Input.get_axis("designer_left", "designer_right")
	if x_direction:
		velocity.x = move_toward(velocity.x, x_direction * speed, speed/3)
	else:
		velocity.x = move_toward(velocity.x, 0, speed/3)
	if abs(x_direction) > 0.01 or abs(y_direction) > 0.01:
		animSprite.play("walking")
		var lkat = Vector2(
			velocity.x + animSprite.global_position.x,
			velocity.y + animSprite.global_position.y
		)
		animSpriteContainer.look_at(lkat)
	else:
		animSprite.play("idle")
		
	move_and_slide()

func _move(delta):
	if sat_down:
		_move_turret()
	else:
		_move_person()

func _toggle_sit_down():
	sat_down = not sat_down
	if sat_down:
		collider.disabled = true
		turretChairSprite.play("sitting")
		hide()
	else:
		collider.disabled = false
		turretChairSprite.play("empty")
		show()

func _put_boost_in_engine():
	var time = {
		"boost_car_speed_multiplier": 5.0,
		"boost_turret_shooting_speed": 6.0,
		"defense_bubble_active": 1.0
	}[current_holding_boost.boost_type]
	add_boost_to_car(current_holding_boost.boost_type, time)
	current_holding_boost.call_deferred("queue_free")
	current_holding_boost = null

func _interact_with_environent():
	if able_to_sit_down or sat_down:
		_toggle_sit_down()
	if able_to_put_boost_in_engine and current_holding_boost:
		_put_boost_in_engine()
	if boostInContainer.has_boost_in_location(able_to_pickup_boost_location):
		boostInContainer.take_boost_from_location(able_to_pickup_boost_location)
	if able_to_repair_car and car.hp < car.max_hp - car.unrecoverable_hp:
		is_repairing = true
		repairing_time_left = one_hp_repair_time
		animSprite.play("repairing")

func _update_interact_label():
	interactLabel.text = ""
	if able_to_sit_down:
		interactLabel.text = "[X] Steruj działkiem"
	elif able_to_put_boost_in_engine:
		if not current_holding_boost:
			interactLabel.text = "Potrzebujesz ulepszenia!"
		else:
			interactLabel.text = "[X] DOŁADUJ AUTKO!!!!"
	elif boostInContainer.has_boost_in_location(able_to_pickup_boost_location):
		if not current_holding_boost:
			interactLabel.text = "[X] Podnieś doładowanie"
	elif able_to_repair_car:
		if car.hp < car.max_hp - car.unrecoverable_hp:
			interactLabel.text = "[X] Napraw autko"
		else:
			interactLabel.text = "Nie da się więcej naprawić"

func _shoot_bullet(speed: float):
	SoundPlayer.play("StrzalPlayer", randf_range(0.8, 1.2))
	var b = bullet.instantiate()
	var dx = sin(turretSprite.global_rotation)
	var dy = -cos(turretSprite.global_rotation)
	var tv = Vector2(
		turretSprite.position.x + dx,
		turretSprite.position.y + dy
	) 
	b.global_position = turretSprite.global_position + Vector2(dx, dy) * 80.0
	b.set_damage(bullet_damage)
	b.set_speed(speed)
	b.set_target_vector(tv)
	get_tree().current_scene.add_child(b)

func _physics_process(delta):
	if shooting_cooldown > 0:
		shooting_cooldown -= delta
	_move(delta)
	_update_interact_label()
	_update_boost_clocks(delta)
	
	if is_repairing:
		if not Input.is_action_pressed("designer_interact"):
			is_repairing = false
		repairing_time_left -= delta
		if repairing_time_left <= 0:
			car.hp += min(0.5, car.max_hp - car.unrecoverable_hp - car.hp)
			car._update_hp_bar()
			if car.hp < car.max_hp - car.unrecoverable_hp:
				repairing_time_left = one_hp_repair_time
			else:
				is_repairing = false
	
	if Input.is_action_just_pressed("designer_interact"):
		_interact_with_environent()
	if sat_down:
		if Input.is_action_pressed("designer_shoot_right") and shooting_cooldown < 0:
			_shoot_bullet(20)
			shooting_cooldown = shooting_cooldown_default / boost_turret_shooting_speed

func _on_sit_down_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_sit_down = true

func _on_sit_down_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_sit_down = false

func _on_engine_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_put_boost_in_engine = true

func _on_engine_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_put_boost_in_engine = false

func _on_boost1_in_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 1

func _on_boost1_in_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 0

func _on_boost2_in_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 2

func _on_boost2_in_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 0

func _on_boost3_in_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 3

func _on_boost3_in_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 0

func _on_boost4_in_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 4

func _on_boost4_in_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_pickup_boost_location = 0

func _on_repair_area_2d_body_entered(body):
	if body.name == "PlayerInside":
		able_to_repair_car = true

func _on_repair_area_2d_body_exited(body):
	if body.name == "PlayerInside":
		able_to_repair_car = false
