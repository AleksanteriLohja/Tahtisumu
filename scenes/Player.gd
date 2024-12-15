extends CharacterBody2D

signal shoot

const NORMAL_SHOT : float = 0.3
const FAST_SHOT : float = 0.1

var can_shoot :  bool
var speed = 600
var acceleration: float = 2500 #kiihdytyksen nopeus
var max_speed: float = 800 #kiihdytyksen käyttämä maksimivauhti
var BOOST_SPEED = max_speed*1.5
var friction: float =  600#hidastukseen vaikuttava kitka
var rotation_speed: float = 6  # Määritellään rotaation nopeus
var fade_out_speed:float = 0.5 #hidastus äänen feidaus

# Dash variables
var is_dashing: bool = false
var dash_speed: float = 80000
var dash_acceleration = acceleration*2.5
var dash_duration: float = 0.5
var dash_timer: float = 0.0
var can_dash: bool = true
var dash_cooldown: float = 4.0
var dash_cooldown_timer: float = 0.0  # Track remaining cooldown time
var explosion_scene := preload("res://scenes/explosion_3.tscn")#pixeliräjähdys
var explosion_instantiated = false

@onready var main = get_node("/root/main") #tuodaan main node jotta voidaan viitata siihen
@onready var Liike_sprite: AnimatedSprite2D = $MoottoriLiike #moottorin tulianimaatio
@onready var Liike_sprite2: AnimatedSprite2D = $MoottoriLiike2 #moottorin tulianimaatio
@onready var Idle_sprite: AnimatedSprite2D = $MoottoriIdle #moottorin idelanimaatio
@onready var Alus_audioEteen: AudioStreamPlayer = $AlusMoottoriEteen #moottorin ääni eteenpäin
@onready var Alus_audioTaakse: AudioStreamPlayer = $AlusMoottoriTaakse #moottorin ääni taaksepäin
@onready var Ampuminen_audio: AudioStreamPlayer = $AlusAmpuminen #ampumisen ääni
@onready var animated_sprite = $Alus
@onready var gun_sound= $gun_boost
@onready var DashCooldownTimer: Timer = $ShieldTimer
@onready var Shield: Area2D = $Shield  # Reference to the shield node
@onready var DashCDProgressBar: ProgressBar = $"/root/main/Hud/DashCdProgressBar" #dash cd progress bar reference

func _ready():#kutsuu reset funktion jossa on kaikki tarvittava pelin aloitukseen
	reset()
	animated_sprite.play("idle")
	DashCDProgressBar.max_value = dash_cooldown
	DashCDProgressBar.value = dash_cooldown
	$ShotTimer.wait_time = NORMAL_SHOT
	Shield.visible = false  # Ensure shield is initially hidden
	dash_cooldown_timer = 0.0 # Reset cooldown timer

func reset():
	animated_sprite.play("idle")
	max_speed = 700
	can_shoot = true
	can_dash = true
	#position = Vector2(4200, 2700) #pelaajan aloitus paikka, koordinaatit x,y
	DashCDProgressBar.value = dash_cooldown
	dash_cooldown_timer = 0.0 # Reset cooldown timer
	
func get_input(delta):
	# Keyboard input
	var input_dir = Vector2()
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("up"):
		#liikuttaa pelaajaa hiiren suuntaan ja toistaa animaation
		input_dir = (mouse_pos - global_position).normalized()
		Liike_sprite.visible = true
		Liike_sprite2.visible = true
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = -10
		
	if Input.is_action_pressed("down"):
		#liikuttaa pelaajaa kursorista päinvastaiseen suuntaan
		input_dir = (global_position - mouse_pos).normalized()
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = -10
		
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = -10
	
	if Input.is_action_pressed("right"):
		input_dir.x += 1
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = -10
		
		
		#shooting with mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
		var dir = get_global_mouse_position() - position
		shoot.emit(position, dir)
		Ampuminen_audio.play()
		can_shoot = false
		#timer säätää kuinka nopeasti voi ampua
		$ShotTimer.start()
		
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()	
	
	# Kiihdytyksen halinta
	if input_dir != Vector2():
		velocity += input_dir * acceleration * delta
		velocity = velocity.limit_length(max_speed)		
	
	else:
		# Hidastuksen hallinta
		velocity = velocity.move_toward(Vector2(), friction * delta)
		Liike_sprite.visible = false
		Liike_sprite2.visible = false
		if Alus_audioEteen.is_playing():
			Alus_audioEteen.volume_db = lerp(Alus_audioEteen.volume_db,-80.0,fade_out_speed*delta)
		elif Alus_audioTaakse.is_playing():
			Alus_audioTaakse.volume_db = lerp(Alus_audioTaakse.volume_db,-80.0,fade_out_speed*delta)

func _physics_process(delta):
	# Player movement
	get_input(delta)
	move_and_slide()
	
	if $Alus.animation == "tuho" and not explosion_instantiated:
		var explosion = explosion_scene.instantiate()
		explosion.position = position
		main.add_child(explosion)
		explosion.process_mode = Node.PROCESS_MODE_ALWAYS
		explosion_instantiated = true
	
	if $Alus.animation != "tuho":
		explosion_instantiated = false	
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			end_dash()
			
	if not can_dash:
		dash_cooldown_timer -= delta
		DashCDProgressBar.value = dash_cooldown - dash_cooldown_timer
		if dash_cooldown_timer <= 0:	
			can_dash = true
			DashCDProgressBar.value = dash_cooldown  # Reset the progress bar to full
			
	# Player rotation hallinta hiirellä
	var mouse = get_local_mouse_position()
	look_at(to_global(mouse))
	
func start_dash():	
	$DashSound.play()
	is_dashing = true
	dash_timer = dash_duration
	max_speed = dash_speed
	acceleration = dash_acceleration
	can_dash = false
	dash_cooldown_timer = dash_cooldown
	Shield.visible = true  # Activate shield
	DashCDProgressBar.value = 0 #reset cd progress bardw

func end_dash():
	is_dashing = false
	max_speed = speed
	Shield.visible = false  # Deactivate shield
	acceleration = dash_acceleration
	
func _on_shield_timer_timeout() -> void:
	can_dash = true
	DashCDProgressBar.value = dash_cooldown #progress bar reset
	
func _on_shield_body_entered(body: Node2D) -> void:
	if is_dashing:
		#Handle collision with enemies while dashing
		if body.is_in_group("enemies"):
			body.die()
			
#nostaa pelaajan vauhtia timerin määrittämäksi ajaksi	
#func boost():
	#$speed.play()
	#animated_sprite.play(("boost"))
	#$BoostTimer.start()
	#max_speed = BOOST_SPEED
	#Alus_audioEteen.pitch_scale = 1.2

	

#palauttaa vauhdin normaaliksi	
#func _on_boost_timer_timeout() -> void:
	#animated_sprite.play(("idle"))
	#max_speed = speed
	#Alus_audioEteen.pitch_scale = 1.0

func quick_fire():
	$rapidfire.play()
	gun_sound.play()
	$"../Taustamusiikki".stop()
	animated_sprite.play(("gun"))
	$FastFireTimer.start()
	$ShotTimer.wait_time = FAST_SHOT
	
func _on_shot_timer_timeout() -> void:
	can_shoot = true
	
func _on_fast_fire_timer_timeout() -> void:
	gun_sound.stop()
	$"../Taustamusiikki".play()
	animated_sprite.play(("idle"))
	$ShotTimer.wait_time = NORMAL_SHOT
