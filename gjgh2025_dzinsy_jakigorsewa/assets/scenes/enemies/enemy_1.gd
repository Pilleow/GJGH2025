extends CharacterBody2D

@export var max_hp: float = 3.0
@export var shooting_range: float = 4000.0
@export_file("*.tscn") var bullet_path = ""
@onready var bullet = load(bullet_path)
@export var bullet_damage: float = 1.0
@export var bullet_speed: float = 8.0
@export var shooting_cooldown_default: float = 0.4
@export var min_allowed_distance_to_player: float = 200.0

var hp = max_hp
var enemy_speed: float = 200.0
var enemy_move: Vector2 = Vector2.ZERO
var target_spacing_from_point = 0.0
var knockback_move: Vector2 = Vector2.ZERO
var shooting_cooldown: float = shooting_cooldown_default

var time_since_light_up: float = -20.0

var player_visible: bool = false
var check_player_visibility_every_seconds_default = 1.0
var check_player_visibility_every_seconds =  randf_range(0, check_player_visibility_every_seconds_default)

var is_dead: bool = false

var playingShootAnimation: bool = false

@onready var rotate_around_point = get_parent().get_node("RotateAroundPoint")
@onready var player = get_tree().current_scene.find_child("Player")
@onready var carCollider = get_tree().current_scene.find_child("Player").get_node("CarCollision")
@onready var animSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

var stateTimeLeft: float = -1.0
var currentState = "walk"
var stateMachine = {
	"walk": 2.5,
	"shoot": 1.5
}
func _check_and_change_state(delta: float):
	if not player_visible:
		return
	if stateTimeLeft > 0:
		stateTimeLeft -= delta
		return
	if currentState == "walk":
		if global_position.distance_to(carCollider.global_position) < shooting_range:
			shooting_cooldown = shooting_cooldown_default
			currentState = "shoot"
	elif currentState == "shoot":
		if global_position.distance_to(carCollider.global_position) > min_allowed_distance_to_player:
			currentState = "walk"
	stateTimeLeft = stateMachine[currentState]

func _decide_what_to_do_based_on_state(delta: float):
	if currentState == "walk":
		_move()
	elif currentState == "shoot":
		_shoot(delta)
		_move(true)

func _ready():
	animSprite.play("idle")
	add_to_group("Enemies")

func hit_and_knockback(damage: float, knockback_power: float, obj = null):
	if is_dead:
		return
	take_damage(damage)
	if obj == null:
		knockback_move = player.velocity.normalized() * knockback_power 
	else:
		knockback_move = obj.target_vector.normalized() * knockback_power 

func _shoot(delta):
	if not player_visible:
		return
	if shooting_cooldown > 0:
		shooting_cooldown -= delta
		return
	SoundPlayer.play("StrzalEnemy1", randf_range(0.95, 1.05))
	animSprite.play("shooting")
	playingShootAnimation = true
	shooting_cooldown = shooting_cooldown_default
	var tv = (player.global_position - global_position).normalized()
	var b = bullet.instantiate()
	b.global_position = global_position
	b.set_damage(bullet_damage)
	b.set_speed(bullet_speed)
	b.set_target_vector(tv)
	b.global_rotation = global_position.angle_to_point(player.global_position) + PI/2
	get_tree().current_scene.add_child(b)
	
func _become_dead():
	if is_dead:
		return
	player.handle_enemy_died()
	is_dead = true
	animSprite.play("dead")
	var toward_player = (player.global_position - global_position).normalized()  * 1000
	knockback_move = toward_player
	collisionShape.set_deferred("disabled", true)
	hitbox.monitoring = false
	hitbox.monitorable = false

func take_damage(damage: float):
	time_since_light_up = Time.get_ticks_msec()
	hp -= damage
	SoundPlayer.play("RozwalenieEnemy" + str(randi_range(1, 3)))
	if hp <= 0:
		_become_dead()

func _move(disable_voluntary_movement: bool = false):
	var move_to = Vector2.ZERO
	if global_position.distance_to(carCollider.global_position) <= min_allowed_distance_to_player:
		stateTimeLeft = -1
	else:
		move_to = (player.global_position - global_position).normalized()  * enemy_speed
	if not player_visible:
		return
	if not disable_voluntary_movement:
		enemy_move = move_to.normalized()
	else:
		enemy_move = Vector2.ZERO
	velocity = enemy_move * enemy_speed + knockback_move
	if knockback_move:
		knockback_move *= 0.92
	if not playingShootAnimation and not is_dead:
		animSprite.play("idle")
	move_and_slide()

func _check_player_visibility():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position,
		0xFFFFFFFF,
		[self]
	))
	var c = result.get("collider")
	if c and c.name == "Player":
		player_visible = true
	else:
		player_visible = false

func _physics_process(delta):
	if Time.get_ticks_msec() - time_since_light_up < 300:
		var t = (300 - (Time.get_ticks_msec() - time_since_light_up)) / 300
		t *= t
		$AnimatedSprite2D.modulate.g = (1 - t)
		$AnimatedSprite2D.modulate.b = (1 - t)
	if not is_dead and player_visible:
		global_rotation = global_position.angle_to_point(player.global_position) - PI/2
	if is_dead:
		_move(true)
		return
	check_player_visibility_every_seconds -= delta
	if check_player_visibility_every_seconds < 0:
		check_player_visibility_every_seconds = check_player_visibility_every_seconds_default
		_check_player_visibility()
	if playingShootAnimation and not animSprite.is_playing():
		playingShootAnimation = false
	_check_and_change_state(delta)
	_decide_what_to_do_based_on_state(delta)

func _on_hitbox_area_entered(area):
	if is_dead:
		return
	var par = area.get_parent()
	if not par:
		return
	if par.is_in_group("PlayerDamageEntities"):
		hit_and_knockback(par.get_damage_dealt(), 500.0, par)
		par.call_deferred("queue_free")
