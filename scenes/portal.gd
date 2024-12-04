extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.set_position($destination.global_position)
