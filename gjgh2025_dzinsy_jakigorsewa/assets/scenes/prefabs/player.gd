extends CharacterBody2D


var car_angle = 0.0
var car_accel = 0.0
var car_max_accel = 15.0
var car_speed = 0.0
var car_max_speed = 500.0
var car_velocity = Vector2.ZERO
var car_brake_efficiency = 0.05

var car_ground_friction = 0.02

var max_hp: float = 10.0
var hp: float = max_hp


var steering_angle = 0.0
var steering_angle_limit = [-360.0, 360.0]
var wheel_angle_limit = [-90.0, 90.0]

@onready var carCollider: CollisionShape2D = $CarCollision
@onready var carSprite: Sprite2D = $CarSprite


func _steer_set(sang: float):
	if sang < steering_angle_limit[0] or sang > steering_angle_limit[1]:
		return false
	steering_angle = move_toward(steering_angle, sang / 20, 0.005)
	return true


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
	prev_angle1 = angle1;
	angle1 = rad_to_deg(car_angle);
	car_angle += 2*steering_angle * car_speed / car_max_speed

	velocity = Vector2(car_speed * sin(car_angle), car_speed * cos(car_angle))
	print(car_speed)
	if(drifting and (Input.is_action_pressed("left") or Input.is_action_pressed("right"))):
		car_speed -= drift_brake_speed *sign(car_speed)
		#* car_speed / car_max_speed;
		if(car_speed >= 0):
			if(push_force <= push_force_max):
				push_force += 20;
			else:
				push_force = push_force_max 
		else:
			if(push_force >= push_force_max):
				push_force -= 20;
			else:
				push_force = (-push_force_max)
			push_force = -push_force_max ;
			
		if(angle1 - prev_angle1 > 0):
			push_velocity = Vector2(push_force* sin(car_angle - PI/2), push_force * cos(car_angle - PI/2));
		else:
			push_velocity = Vector2(push_force* sin(car_angle + PI/2), push_force * cos(car_angle + PI/2));
	else:
		if push_force != 0:
			push_force -= sign(push_force)*75	
		push_velocity = Vector2.ZERO
		
	velocity.x = car_speed * sin(car_angle) + push_velocity.x;
	velocity.y = car_speed * cos(car_angle) + push_velocity.y;
	velocity = velocity.normalized()* abs(car_speed);

	
	var lslidecol = get_last_slide_collision()
	if lslidecol != null:
		velocity *= -3
		car_speed *= -1
		car_accel *= -1
	

func _take_input():
	var acceleration = Input.get_axis("up", "down") * car_max_accel
	_accel_set(acceleration)
	var rotation = Input.get_axis("left", "right")
	_steer_set(rotation)

	
	if(Input.is_action_pressed("Drift")):
		drifting = true;
	else:
		drifting = false;
	
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
	_take_input()
	_move(delta)
	_update_camera_ahead_of_car()
