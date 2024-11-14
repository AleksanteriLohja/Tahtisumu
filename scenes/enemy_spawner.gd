extends Node2D

#TÄMÄ ON VIELÄ KESKEN!!!!!!

var enemy_scene := preload("res://scenes/enemy.tscn")
var spawn_points :=[]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)


func _on_timer_timeout() -> void:
	#pick random spawnpoint
	var spawn = spawn_points[randi() % spawn_points.size()]
#spawn enemy
	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_position
