extends Node2D

@onready var boost_spawn_1 = $BoostIn1
var boost_spawn_1_taken: bool = false
@onready var boost_spawn_2 = $BoostIn2
var boost_spawn_2_taken: bool = false
@onready var boost_spawn_3 = $BoostIn3
var boost_spawn_3_taken: bool = false
@onready var boost_spawn_4 = $BoostIn4
var boost_spawn_4_taken: bool = false

@onready var available_locations_to_spawn = [1, 2, 3, 4]

@export_file("*.tscn") var sc_boost_car_speed_multiplier_path = ""
@onready var sc_boost_car_speed_multiplier = load(sc_boost_car_speed_multiplier_path)
@export_file("*.tscn") var sc_boost_turret_shooting_speed_path = ""
@onready var sc_boost_turret_shooting_speed = load(sc_boost_turret_shooting_speed_path)

@onready var available_boosts_to_spawn = [
	"boost_car_speed_multiplier", 
	"boost_turret_shooting_speed"
]

var time_every_boost_coming_in = 5.0
var next_boost_in_seconds: float = time_every_boost_coming_in

func _spawn_new_boost_on_random_location():
	if len(available_boosts_to_spawn) == 0:
		print("NO BOOSTS AVAILABLE TO SPAWN")
		return
	if len(available_locations_to_spawn) == 0:
		print("NO LOCATIONS AVAILABLE TO SPAWN")
		return
	var random_boost = available_boosts_to_spawn.pick_random()
	var random_location = available_locations_to_spawn.pick_random()
	

func _process(delta):
	if (
		not boost_spawn_1_taken or not boost_spawn_2_taken 
		or not boost_spawn_3_taken or not boost_spawn_4_taken
	):
		next_boost_in_seconds -= delta
	if next_boost_in_seconds <= 0:
		_spawn_new_boost_on_random_location()
		next_boost_in_seconds = time_every_boost_coming_in
		
