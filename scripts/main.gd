extends Node

class_name Main

var points = 0

@export var ui: UI
@export var player: Player

func _ready():
	player.ui = ui
	player.points_scored.connect(on_points_scored)

func on_points_scored(points_scored: int):
	points += points_scored
	ui.set_score(points)
