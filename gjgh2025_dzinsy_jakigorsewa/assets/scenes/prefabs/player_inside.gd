extends CharacterBody2D

const SPEED = 250.0

func _physics_process(delta):
	var y_direction = Input.get_axis("designer_up", "designer_down")
	if y_direction:
		velocity.y = move_toward(velocity.y, y_direction * SPEED, SPEED/2)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED/2)

	var x_direction = Input.get_axis("designer_left", "designer_right")
	if x_direction:
		velocity.x = move_toward(velocity.x, x_direction * SPEED, SPEED/2)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/2)

	move_and_slide()
