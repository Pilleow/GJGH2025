extends CharacterBody2D

var boost_turret_shooting_speed: float = 1.0

var speed = 650.0
var turret_rotation: float = 0.0
var turret_rotation_max_speed: float = 0.1

var able_to_sit_down: bool = false
var sat_down: bool = false

var able_to_put_boost_in_engine: bool = false
var current_holding_boost = ""
var current_active_boosts = [
	["car_boost", 2.0], 
	["attack_speed", 1.5]
]

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
	current_active_boosts.append([boost, time])
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

func _update_boost_clocks(delta):
	for index in len(current_active_boosts):
		var index_inv = len(current_active_boosts) - index - 1
		current_active_boosts[index_inv][1] -= delta
		if current_active_boosts[index_inv][1] <= 0:
			current_active_boosts.remove_at(index_inv)
			_update_existing_boost_effects()

func _move_person():
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

func _interact_with_environent():
	if able_to_sit_down or sat_down:
		_toggle_sit_down()

func _update_interact_label():
	interactLabel.text = ""
	if able_to_sit_down:
		interactLabel.text = "[X] Steruj działkiem"
	elif able_to_put_boost_in_engine:
		if current_holding_boost == "":
			interactLabel.text = "Potrzebujesz ulepszenia!"
		else:
			interactLabel.text = "[X] DOŁADUJ AUTO!!!"

func _shoot_bullet(speed: float):
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
	if Input.is_action_just_pressed("designer_interact"):
		_interact_with_environent()
	if sat_down:
		if Input.is_action_pressed("designer_shoot_right") and shooting_cooldown < 0:
			_shoot_bullet(20)
			shooting_cooldown = shooting_cooldown_default

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
