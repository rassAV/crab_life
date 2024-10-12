extends Label

func _ready() -> void:
	var label_tween = get_tree().create_tween()
	label_tween.tween_property(self, "position", position + Vector2(0, -10), 1)
	label_tween.tween_callback(queue_free)
