extends Area2D

class_name Enemy

@export var horizontal_speed = 30
@export var vertical_speed = 100

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var ray_cast_2d_forward = $RayCast2Dforward as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func die():
	horizontal_speed = 0
	vertical_speed = 0
	animated_sprite_2d.play("death")

#func _on_visible_on_screen_notifier_2d_screen_exited():
	#hide()
#
#func _on_visible_on_screen_notifier_2d_screen_entered():
	#show()
