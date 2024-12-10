extends CharacterBody2D

var speed : float = 350  #vihollisen nopeus
var alive: bool 
var rotation_speed = 40 #vihollisen kääntymisnopeus
var item_scene := preload("res://scenes/item.tscn") #täältä tuodaan tiputettavat itemit
var explosion_scene := preload("res://scenes/explosion_2.tscn")#pixeliräjähdys
var DROP_CHANCE : float = 1.0 #itemien dropchance
var health: int = 5

@onready var main = get_node("/root/main") #tuodaan main node jotta voidaan viitata siihen
@onready var player = get_node("/root/main/player") #tuodaan player node jotta voidaan viitata siihen
@onready var player_shield = get_node("/root/main/player/Shield")
@onready var animated_sprite = $AnimatedSprite2D #tuodaan animaatio	
@onready var audio_tuho = $EnemyTuho #tuodaan audio

signal hit_player

func _ready():
	alive = true
	$EnemySound.play()
	randomize_speed()
	
func randomize_speed():
	var min_speed = 400
	var max_speed = 450
	speed = randi_range(min_speed, max_speed)	
	
	
#viholliset liikkuvat aina pelaajan suntaan	
func _physics_process(_delta):
	if alive:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction*speed
		look_at(player.global_position)
		move_and_slide()
	
	if health <= 0 and alive:
			die()
	else:
		pass	
	
		
#vihollinen pysähtyy, animaatio toistetaan ja node poistetaan
func die():
	alive = false
	$EnemySound.stop()
	$AnimatedSprite2D2.visible = false
	audio_tuho.play()
	animated_sprite.play("tuho")
	#$EnemyDeathTimer.start() #tämä määrittää kuoleman viiveen jotta animaatio ehtii toistua
	call_deferred("disable_collision")
	if randf() <= DROP_CHANCE:
		drop_item()
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	main.add_child(explosion)
	explosion.process_mode = Node.PROCESS_MODE_ALWAYS

#tämä hallitsee esineiden tiputtamista	
func drop_item():
	var item = item_scene.instantiate()
	item.position = position #esineen paikka
	item.item_type = randi_range(0,1)
	main.call_deferred("add_child", item)
	item.add_to_group("items") #luodaan ryhmä ja lisätään luodut itemit ryhmään
	
func disable_collision():
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
#func _on_enemy_death_timer_timeout() -> void: #tämä poistaa vihollisen
	#queue_free()

#toistetaan signaali kun vihollinen osuu pelaajaa
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		$EnemyHit.play()
		$EnemyTuho.play()
		hit_player.emit()
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.call_deferred("disable_collision")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		$BulletHit.play()
		$EnemyHitAnimation.play()
		health -= 1
		print(health)
