extends Node2D

@onready var main = get_node("/root/main")

signal hit_p

var enemy_scene := preload("res://scenes/enemy.tscn")
var spawn_points :=[]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)


func _on_timer_timeout() -> void:
	#tarkistaa montako vihollista on jo luotu
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size()<get_parent().max_enemies:
	#pick random spawnpoint
		var spawn = spawn_points[randi() % spawn_points.size()]
	#spawn enemy
		var enemy = enemy_scene.instantiate()
		enemy.position = spawn.position
		enemy.hit_player.connect(hit)
		main.add_child(enemy)
		#spawnatut viholliset laitetaan ryhmään (funktio luo ryhmän itsestään jos sellaista ei ole)
		enemy.add_to_group("enemies")
	
#toistetaan signaali kun vihollinen osuu pelaajaan	
func hit():
	hit_p.emit()
