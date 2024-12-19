extends Control

const POINTS_LABEL_SCENE = preload("res://scenes/points_label.tscn")
@onready var headcrab = $Sprite2D
var timer = 1.5

func _process(delta: float) -> void:
	timer -= delta
	if timer < 0:
		timer = 1.5
		spawn_points_label()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func spawn_points_label():
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = headcrab.position + Vector2(-10, -15)
	points_label.text = "Z"
	get_tree().root.add_child(points_label)
