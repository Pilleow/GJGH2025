extends CharacterBody2D

@export var max_hp: float = 3.0
@export var shooting_range: float = 2000.0
@export var always_shooting_range: float = 500.0
@export_file("*.tscn") var bullet_path = ""
@onready var bullet = load(bullet_path)
@export var bullet_damage: float = 1.0
@export var bullet_speed: float = 8.0
@export var shooting_cooldown_default: float = 0.4

var hp = max_hp
var enemy_speed: float = 200.0
var enemy_move: Vector2 = Vector2.ZERO
var target_spacing_from_point = 0.0
var knockback_move: Vector2 = Vector2.ZERO
var shooting_cooldown: float = shooting_cooldown_default

@onready var rotate_around_point = get_parent().get_node("RotateAroundPoint")
@onready var player = get_tree().current_scene.find_child("Player")
@onready var carCollider = get_tree().current_scene.find_child("Player").get_node("CarCollider")

var stateTimeLeft: float = -1.0
var currentState = "walk"
var stateMachine = {
	"walk": 2.5,
	"shoot": 1.5
}
func _check_and_change_state(delta: float):
	if stateTimeLeft > 0:
		stateTimeLeft -= delta
		return
	if currentState == "walk":
		if global_position.distance_to(carCollider.global_position) < shooting_range:
			shooting_cooldown = shooting_cooldown_default
			currentState = "shoot"
	elif currentState == "shoot":
		if global_position.distance_to(carCollider.global_position) > always_shooting_range:
			currentState = "walk"
		else:
			currentState = "shoot"
	stateTimeLeft = stateMachine[currentState]

func _decide_what_to_do_based_on_state(delta: float):
	if currentState == "walk":
		_move()
	elif currentState == "shoot":
		_shoot(delta)
		_move(true)

func _ready():
	add_to_group("Enemies")

func hit_and_knockback(damage: float, knockback_power: float):
	hp -= damage
	knockback_move = -player.velocity.normalized() * knockback_power 

func _shoot(delta):
	if shooting_cooldown > 0:
		shooting_cooldown -= delta
		return
	shooting_cooldown = shooting_cooldown_default
	var tv = (player.global_position - global_position).normalized()
	var b = bullet.instantiate()
	b.global_position = global_position
	b.set_damage(bullet_damage)
	b.set_speed(bullet_speed)
	b.set_target_vector(tv)
	get_tree().current_scene.add_child(b)
	
func _become_dead():
	call_deferred("queue_free")

func take_damage(damage: float):
	hp -= damage
	if hp <= 0:
		_become_dead()

func _move(disable_voluntary_movement: bool = false):
	if not disable_voluntary_movement:
		var move_to = (player.global_position - global_position).normalized()  * enemy_speed
		enemy_move = move_to.normalized()
	else:
		enemy_move = Vector2.ZERO
	velocity = enemy_move * enemy_speed - knockback_move
	if knockback_move:
		knockback_move *= 0.9
	move_and_slide()

func _physics_process(delta):
	_check_and_change_state(delta)
	_decide_what_to_do_based_on_state(delta)

func _on_hitbox_area_entered(area):
	var par = area.get_parent()
	if not par:
		return
	if par.is_in_group("PlayerDamageEntities"):
		take_damage(par.get_damage_dealt())
		par.call_deferred("queue_free")
