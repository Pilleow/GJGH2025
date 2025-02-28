extends CharacterBody2D

var car_accel = 0.0
var car_max_accel = 2.0
@export var car_speed = 400.0
var car_max_speed = 400.0
var car_velocity = Vector2.ZERO
var car_brake_efficiency = 0.05
var car_ground_friction = 0.01

var steering_angle = 0.0
var steering_angle_limit = [-360.0, 360.0]
var wheel_angle_limit = [-90.0, 90.0]

@onready var carCollider: CollisionShape2D = $CarCollision
@onready var carSprite: Sprite2D = $CarSprite

func _move(delta):
	var acceleration = Input.get_axis("up", "down")
	if acceleration:
		velocity.y = acceleration * car_speed
	else:
		velocity.y = move_toward(velocity.y, 0, car_speed/10)
	move_and_slide()

func _rotate_car(delta):
	var x_direction = Input.get_axis("left", "right")
	if x_direction:
		velocity.x = x_direction * car_speed
	else:
		velocity.x = move_toward(velocity.x, 0, car_speed/10)
	move_and_slide()
	

func _physics_process(delta):
	_move(delta)
	_rotate_car(delta)
