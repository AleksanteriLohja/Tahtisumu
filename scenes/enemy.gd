extends CharacterBody2D

var speed : float = 250  #vihollisen nopeus
var alive: bool 
var rotation_speed = 40 #vihollisen kääntymisnopeus
var item_scene := preload("res://scenes/item.tscn") #täältä tuodaan tiputettavat itemit
var DROP_CHANCE : float = 0.1 #itemien dropchance

@onready var main = get_node("/root/main") #tuodaan main node jotta voidaan viitata siihen
@onready var player = get_node("/root/main/player") #tuodaan player node jotta voidaan viitata siihen
@onready var animated_sprite = $AnimatedSprite2D #tuodaan animaatio	
@onready var audio_tuho = $EnemyTuho #tuodaan audio

signal hit_player

func _ready():
	alive = true
	
	
#viholliset liikkuvat aina pelaajan suntaan	
func _physics_process(delta):
	if alive:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction*speed
		look_at(player.global_position)
		move_and_slide()
	else:
		pass	
		
#vihollinen pysähtyy, animaatio toistetaan ja node poistetaan
func die():
	alive = false
	audio_tuho.play()
	animated_sprite.play("tuho")
	#$EnemyDeathTimer.start() #tämä määrittää kuoleman viiveen jotta animaatio ehtii toistua
	call_deferred("disable_collision")
	if randf() <= DROP_CHANCE:
		drop_item()

#tämä hallitsee esineiden tiputtamista	
func drop_item():
	var item = item_scene.instantiate()
	item.position = position #esineen paikka
	item.item_type = randi_range(0,2)
	main.call_deferred("add_child", item)
	item.add_to_group("items") #luodaan ryhmä ja lisätään luodut itemit ryhmään
	
func disable_collision():
	$CollisionEnemy.disabled = true
	$Area2D/CollisionShape2D.disabled = true
#func _on_enemy_death_timer_timeout() -> void: #tämä poistaa vihollisen
	#queue_free()

#toistetaan signaali kun vihollinen osuu pelaajaan
func _on_area_2d_body_entered(_body):
	hit_player.emit()
