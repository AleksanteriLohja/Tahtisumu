extends Node2D



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_new_game_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
