extends Sprite2D

@onready var player = get_parent()

func _ready():
	show()

func _process(delta):
	region_rect.position += player.velocity * delta * 0.75
