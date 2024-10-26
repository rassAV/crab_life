extends Enemy

class_name Snark

func _ready() -> void:
	horizontal_speed = 60

func _process(delta):
	position.x -= delta * horizontal_speed
	
	if !ray_cast_2d.is_colliding():
		position.y += delta * vertical_speed
	else:
		if position.y > ray_cast_2d.get_collision_point().y:
			position.y = ray_cast_2d.get_collision_point().y + 1
	
	if ray_cast_2d_forward.is_colliding():
		horizontal_speed = -horizontal_speed
		scale.x = -scale.x  

func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	get_tree().create_timer(5).timeout.connect(queue_free)
