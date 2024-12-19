extends Enemy

class_name Scientist

@onready var player = $"../../Player"

var agr_distance = 100
var attack_distance = 50
var attack_delay = 1.0
var attack_timer = attack_delay
var last_direction: bool

#var initial_position: Vector2
#var idle_state: float = 0.0 # -1 для движения влево, 1 для движения вправо, 0 для остановки
#var idle_state_timer = 0.0
#var idle_state_interval = 6.0

func _ready() -> void:
	horizontal_speed = 30
	#initial_position = position

func _process(delta):	
	if !ray_cast_2d.is_colliding():
		position.y += delta * vertical_speed
	else:
		if position.y > ray_cast_2d.get_collision_point().y:
			position.y = ray_cast_2d.get_collision_point().y + 1
	
	if player:
		var direction = (player.position - position).normalized()
		var distance_to_player = position.distance_to(player.position)
		var current_direction = direction.x > 0
		
		if distance_to_player < agr_distance or attack_timer != attack_delay:
			if ray_cast_2d_forward.is_colliding() and last_direction == current_direction and attack_timer == attack_delay:
				last_direction = current_direction
				animated_sprite_2d.play("idle")
			else:
				if distance_to_player < attack_distance or attack_timer != attack_delay:
					if attack_timer == attack_delay and !player.is_dead:
						animated_sprite_2d.play("attack_1")
					attack_timer -= delta
					if current_direction:
						animated_sprite_2d.scale.x = -1
					else:
						animated_sprite_2d.scale.x = 1
					if attack_timer <= 0:
						if distance_to_player < attack_distance:
							animated_sprite_2d.play("attack_2")
							player.die()
						attack_timer = attack_delay
				else:
					if current_direction:
						#position.x += delta * horizontal_speed
						animated_sprite_2d.scale.x = -1
					else:
						#position.x -= delta * horizontal_speed
						animated_sprite_2d.scale.x = 1
					animated_sprite_2d.play("danger")
		else:
			animated_sprite_2d.play("idle")

#func choose_new_direction() -> void:
	#current_direction = randi() % 3 - 1
	#direction_change_timer = direction_change_interval

func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	queue_free()
