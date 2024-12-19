extends CanvasLayer

class_name UI

@onready var center_container = $MarginContainer/CenterContainer
@onready var score_label = $MarginContainer/HBoxContainer/ScoreLabel

func set_score(points: int):
	score_label.text = "SCORE: %d" % points

func on_finish():
	center_container.visible = true
