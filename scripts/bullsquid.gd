extends Enemy

class_name Bullsquid

@onready var player = get_node("/root/main/Player")

var is_stunned = false

func _ready() -> void:
	horizontal_speed = 40

func _process(delta):
	if is_stunned:
		return
	
	if !ray_cast_2d.is_colliding():
		position.y += delta * vertical_speed
	else:
		if position.y > ray_cast_2d.get_collision_point().y:
			position.y = ray_cast_2d.get_collision_point().y + 1
	
	if player:
		var direction = (player.position - position).normalized()
		var distance_to_player = position.distance_to(player.position)
		
		if distance_to_player < 1000:
			if ray_cast_2d_forward.is_colliding():
				animated_sprite_2d.play("idle") 
			else:
				if direction.x > 0:
					position.x += delta * horizontal_speed
					animated_sprite_2d.scale.x = 1
				elif direction.x < 0:
					position.x -= delta * horizontal_speed
					animated_sprite_2d.scale.x = -1
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")


func stunned():
	if is_stunned:
		return
	is_stunned = true
	animated_sprite_2d.play("stunned")
	await get_tree().create_timer(3).timeout
	is_stunned = false

func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	get_tree().create_timer(5).timeout.connect(queue_free)