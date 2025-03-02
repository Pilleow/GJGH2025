extends Node2D

@onready var boost_spawn_1 = $BoostIn1
@onready var boost_spawn_2 = $BoostIn2
@onready var boost_spawn_3 = $BoostIn3
@onready var boost_spawn_4 = $BoostIn4

var location_map = {
	"1": boost_spawn_1,
	"2": boost_spawn_2,
	"3": boost_spawn_3,
	"4": boost_spawn_4
}

@onready var available_locations_to_spawn = [
	boost_spawn_1, boost_spawn_2,
	boost_spawn_3, boost_spawn_4
]

var boost_spawn_1_current_boost = null
var boost_spawn_2_current_boost = null
var boost_spawn_3_current_boost = null
var boost_spawn_4_current_boost = null

@export_file("*.tscn") var sc_boost_object_path = ""
@onready var sc_boost_object = load(sc_boost_object_path)

@onready var playerInside = get_parent().get_node("PlayerInside")
@onready var playerInsideContainer = playerInside.get_parent()

@onready var nextBoostInProgressBar1 = $PlayerInsideUI/NextBoostIn1
@onready var nextBoostInProgressBar2 = $PlayerInsideUI/NextBoostIn2

@onready var available_boosts_to_spawn = [

	"boost_car_accel_multiplier",
	"boost_turret_shooting_speed",
	"defense_bubble_active",
	"auto_repair_times"
]

var time_every_boost_coming_in = 4.0
var next_boost_in_seconds: float = time_every_boost_coming_in

func _ready():
	nextBoostInProgressBar1.max_value = time_every_boost_coming_in
	nextBoostInProgressBar2.max_value = time_every_boost_coming_in

func has_boost_in_location(loc: int):
	if loc == 1:
		return boost_spawn_1_current_boost != null
	if loc == 2:
		return boost_spawn_2_current_boost != null
	if loc == 3:
		return boost_spawn_3_current_boost != null
	if loc == 4:
		return boost_spawn_4_current_boost != null
	return false

func _spawn_new_boost_on_random_location():
	if len(available_boosts_to_spawn) == 0:
		return
	if len(available_locations_to_spawn) == 0:
		return
	var random_boost = available_boosts_to_spawn.pick_random()
	available_boosts_to_spawn.erase(random_boost)
	var random_location = available_locations_to_spawn.pick_random()
	available_locations_to_spawn.erase(random_location)
	var inst = sc_boost_object.instantiate()
	inst.set_type(random_boost)
	inst.position = random_location.get_node("BoostInArea2D").get_node("Sprite2D").position + random_location.position
	add_child(inst)
	
	playerInsideContainer.add_child(inst)
	if random_location.name.ends_with("1"):
		boost_spawn_1_current_boost = inst
	elif random_location.name.ends_with("2"):
		boost_spawn_2_current_boost = inst
	elif random_location.name.ends_with("3"):
		boost_spawn_3_current_boost = inst
	elif random_location.name.ends_with("4"):
		boost_spawn_4_current_boost = inst

func take_boost_from_location(locationNumber: int):
	var chb = null
	var loc = null
	if locationNumber == 1 and boost_spawn_1_current_boost:
		chb = boost_spawn_1_current_boost
		loc = boost_spawn_1
		boost_spawn_1_current_boost = null
	if locationNumber == 2 and boost_spawn_2_current_boost:
		chb = boost_spawn_2_current_boost
		loc = boost_spawn_2
		boost_spawn_2_current_boost = null
	if locationNumber == 3 and boost_spawn_3_current_boost:
		chb = boost_spawn_3_current_boost
		loc = boost_spawn_3
		boost_spawn_3_current_boost = null
	if locationNumber == 4 and boost_spawn_4_current_boost:
		chb = boost_spawn_4_current_boost
		loc = boost_spawn_4
		boost_spawn_4_current_boost = null
	playerInside.current_holding_boost = chb
	chb.picked_up = true
	available_boosts_to_spawn.append(chb.boost_type)
	available_locations_to_spawn.append(loc)

func _process(delta):
	if len(available_locations_to_spawn) > 0 and len(available_boosts_to_spawn) > 0:
		next_boost_in_seconds -= delta
		nextBoostInProgressBar1.value = time_every_boost_coming_in - next_boost_in_seconds
		nextBoostInProgressBar2.value = time_every_boost_coming_in - next_boost_in_seconds
	if next_boost_in_seconds <= 0:
		_spawn_new_boost_on_random_location()
		next_boost_in_seconds = time_every_boost_coming_in
