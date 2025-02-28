extends CharacterBody2D

var car_angle = 0.0

var car_accel = 0.0
var car_max_accel = 15.0
var car_speed = 0.0
var car_max_speed = 500.0
var car_velocity = Vector2.ZERO
var car_brake_efficiency = 0.05
var car_ground_friction = 0.01

var steering_angle = 0.0
var steering_angle_limit = [-360.0, 360.0]
var wheel_angle_limit = [-90.0, 90.0]

var motor_pitch = 1.0
var motor_pitch_scaled = 100
var motor_max_pitch = 2.5;
var motor_gears = 1

@onready var carCollider: CollisionShape2D = $CarCollision
@onready var carSprite: Sprite2D = $CarSprite

func _steer_set(sang: float):
	if sang < steering_angle_limit[0] or sang > steering_angle_limit[1]:
		return false
	steering_angle = sang / 20
	return true# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



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
	car_speed *= 1 - car_ground_friction
	car_angle += steering_angle
	velocity = Vector2(car_speed * sin(car_angle), car_speed * cos(car_angle))
	
	var lslidecol = get_last_slide_collision()
	if lslidecol != null:
		velocity *= -3
		car_speed *= -1
		car_accel *= -1
	
	move_and_slide()

func _take_input():
	var acceleration = Input.get_axis("up", "down") * car_max_accel
	_accel_set(acceleration)
	var rotation = Input.get_axis( "right","left")
	_steer_set(rotation * -1)
	
func _MotorSound():
	
	motor_pitch = (abs(car_speed))/car_max_speed * motor_max_pitch
	motor_pitch_scaled = (int(abs(car_speed) / 8)) % 60 + 60
	print(motor_pitch_scaled)
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
	_MotorSound()
	_take_input()
	_move(delta)
