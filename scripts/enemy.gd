extends Area2D

class_name Enemy

@export var horizontal_speed = 30
@export var vertical_speed = 200

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func _process(delta):
	position.x -= delta * horizontal_speed
	
	if !ray_cast_2d.is_colliding():
		position.y += delta * vertical_speed

func die():
	horizontal_speed = 0
	vertical_speed = 0
	animated_sprite_2d.play("death")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
	set_process(true)
