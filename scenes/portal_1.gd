extends Area2D

@onready var player = get_node("/root/main/player")
@onready var player_collision = player.get_node("/root/main/player/CollisionShape2D")
@onready var teleport_sound = $"../AudioStreamPlayer2D"


func ready():
	$PortalHum.play()

func teleport_player(target_position: Vector2):
	player_collision.set_deferred("disabled", true)
	player.visible = false #pelaaja on näkymätön teleportin ajan
	if teleport_sound.is_playing():
		teleport_sound.stop()
	teleport_sound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", target_position,1.0)
	tween.tween_callback(func():
		player.visible = true
		player_collision.set_deferred("disabled", false)
		)

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		teleport_player($destination_portal_1.global_position)	
