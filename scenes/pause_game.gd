extends CanvasLayer


func _on_pause_resume_pressed() -> void:
	print("resume pressed")
	self.hide()
	get_tree().paused = false
	

func _on_pause_mainmenu_pressed() -> void:
	print("resume pressed")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	
func _on_pause_quit_pressed() -> void:
	get_tree().quit()
