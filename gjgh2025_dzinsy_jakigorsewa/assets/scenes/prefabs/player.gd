extends CharacterBody2D

var defense_bubble_active = false
var boost_car_speed_multiplier: float = 1.0

var car_angle = 0.0
var car_accel = 0.0
var car_max_accel = 5.0
var car_speed = 0.0
var car_max_speed = 400.0
var car_velocity = Vector2.ZERO
var car_brake_efficiency = 0.05
var car_ground_friction = 0.02

var max_hp: float = 10.0
var hp: float = max_hp

var steering_angle = 0.0
var steering_angle_limit = [-360.0, 360.0]
var wheel_angle_limit = [-90.0, 90.0]

var motor_pitch = 1.0
var motor_pitch_scaled = 100
var motor_max_pitch = 2.5;
var motor_gears = 1

var player_past_speeds = [0.0]
var player_speed_interval_default = 0.1
var player_speed_interval = player_speed_interval_default

@onready var carSquashFront: Area2D = $EnemySquash
@onready var carCollider: CollisionShape2D = $CarCollision
@onready var pl2df: PointLight2D = $PointLight2DFront
@onready var carSprite: Sprite2D = $CarSprite
@onready var defenseBubble = $CarSprite/DefenseBubble
@onready var carHitbox: Area2D = $CarHitbox
@onready var camera: Camera2D = $Camera2D
@onready var hpBar: ProgressBar = $UI/ProgressBar

@export_file("*.tscn") var deadScenePath: String = ""

func _ready():
	show()

func _steer_set(sang: float):
	if sang < steering_angle_limit[0] or sang > steering_angle_limit[1]:
		return false
	steering_angle = move_toward(steering_angle, sang / 50.0, 0.005)
	return true

func _become_dead():
	hide()
	get_tree().change_scene_to_file(deadScenePath)

func take_damage(damage: float):
	if defense_bubble_active:
		defense_bubble_active = false
		damage /= 2.0
		damage = float(int(damage))
		defenseBubble.hide()
	print(damage)
	hp -= damage
	if hp <= 0:
		_become_dead()
	hpBar.value = hp / max_hp * 100.0

func _accel_set(acc: float):
	car_accel = acc

func _brake(force: float):
	car_speed *= 1.0 - force * car_brake_efficiency
	if car_speed < 1:
		car_speed = 0

func _move(timedelta: float):
	car_speed += car_accel
	if abs(car_speed) > car_max_speed:
		car_speed = car_max_speed * sign(car_speed)
	if car_accel == 0:
		car_speed *= 1 - car_ground_friction
	car_angle += steering_angle * car_speed / car_max_speed
	velocity = Vector2(car_speed * sin(car_angle), car_speed * cos(car_angle))
	
	#var lslidecol = get_last_slide_collision()
	#if lslidecol != null:
		#if lslidecol.get_collider() is TileMapLayer:
			#velocity *= -2
			#car_speed *= -0.5
			#car_accel *= -0.5
	
	move_and_slide()
	
func _take_input():
	var acceleration = Input.get_axis("up", "down") * car_max_accel
	if (abs(car_speed)) / car_max_speed - 0.5 > 0:
		acceleration *= 1 - ((abs(car_speed)) / car_max_speed - 0.5)
	_accel_set(acceleration)
	var rotation = Input.get_axis("left", "right")
	_steer_set(rotation)

func _update_camera_ahead_of_car(delta):
	var mult = 0.03
	var mod = -velocity * abs(car_speed) / car_max_speed * mult
	var target_zoom = Vector2(1,1) * 0.75 - Vector2(
		abs(car_speed) / car_max_speed * mult, 
		abs(car_speed) / car_max_speed * mult
	)
	camera.zoom = target_zoom
	camera.global_position = global_position - Vector2(478.8, 0) - mod

	if sign(car_accel) != sign(car_speed):
		car_speed *= 1 - car_ground_friction
	car_angle += steering_angle * car_speed / car_max_speed
	velocity = Vector2(car_speed * sin(car_angle), car_speed * cos(car_angle))
	
	move_and_slide()
	
func _MotorSound():
	motor_pitch = (abs(car_speed))/car_max_speed * motor_max_pitch
	motor_pitch_scaled = (int(abs(car_speed) / 8)) % 60 + 60
	motor_pitch = 2.5 * motor_pitch_scaled / 100;
	
	#if(motor_pitch >=  motor_max_pitch ):
		#if(motor_gears < 5):
			#motor_pitch = 1.0;
			#motor_gears += 1;
	
	$AudioStreamPlayer2D.pitch_scale = motor_pitch
	if($AudioStreamPlayer2D.pitch_scale < 1.0):
		$AudioStreamPlayer2D.pitch_scale = 1.0 
		
	if not $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()

func _physics_process(delta):
	carCollider.rotation = -car_angle
	carSprite.rotation = -car_angle
	carSquashFront.rotation = -car_angle
	carHitbox.rotation = -car_angle
	pl2df.rotation = -car_angle
	carCollider.position = carSprite.position + Vector2(sin(car_angle), cos(car_angle)) * (-48.5)
	_MotorSound()
	_take_input()
	_move(delta)
	_update_camera_ahead_of_car(delta)


func _on_car_hitbox_area_entered(area):
	var par = area.get_parent()
	if not par:
		return
	if par.is_in_group("HurtingEntities"):
		take_damage(par.get_damage_dealt())
		par.call_deferred("queue_free")
