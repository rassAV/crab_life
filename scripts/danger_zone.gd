extends Area2D

class_name DangerZone

@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play("default")
