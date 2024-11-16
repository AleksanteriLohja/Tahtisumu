extends CharacterBody2D

var speed : float = 300
var alive: bool
@onready var player = get_tree().root.get_node("/root/main/player")
@onready var animated_sprite = $AnimatedSprite2D

signal hit_player

func _ready():
	alive = true
	
	
#viholliset liikkuvat aina pelaajan suntaan	
func _physics_process(delta):
	if alive:
		pass
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction*speed
		move_and_slide()
		
#vihollinen pysähtyy, animaatio toistetaan ja node poistetaan
func die():
	alive = false
	speed = 0.0
	animated_sprite.play("tuho")
	$EnemyDeathTimer.start() #tämä määrittää kuoleman viiveen jotta animaatio ehtii toistua
	
	
func _on_enemy_death_timer_timeout() -> void: #tämä poistaa vihollisen
	queue_free()

#toistetaan signaali kun vihollinen osuu pelaajaan
func _on_area_2d_body_entered(_body):
	hit_player.emit()
