extends CharacterBody2D

signal shoot

const NORMAL_SHOT : float = 0.4
const FAST_SHOT : float = 0.1

var can_shoot :  bool
var speed = 500
var acceleration: float = 800 #kiihdytyksen nopeus
var max_speed: float = 500 #kiihdytyksen käyttämä maksimivauhti
var BOOST_SPEED = max_speed*1.5
var friction: float =  500#hidastukseen vaikuttava kitka
var rotation_speed: float = 5.0  # Määritellään rotaation nopeus
var fade_out_speed:float = 0.5 #hidastus äänen feidaus

@onready var Liike_sprite: AnimatedSprite2D = $MoottoriLiike #moottorin tulianimaatio
@onready var Idle_sprite: AnimatedSprite2D = $MoottoriIdle #moottorin idelanimaatio
@onready var Alus_audioEteen: AudioStreamPlayer2D = $AlusMoottoriEteen #moottorin ääni eteenpäin
@onready var Alus_audioTaakse: AudioStreamPlayer2D = $AlusMoottoriTaakse #moottorin ääni taaksepäin
@onready var Ampuminen_audio: AudioStreamPlayer2D = $AlusAmpuminen #ampumisen ääni

func _ready():#kutsuu reset funktion jossa on kaikki tarvittava pelin aloitukseen
	reset()

func reset():
	max_speed = 500
	can_shoot = true
	position = Vector2(3300, 2300) #pelaajan aloitus paikka, koordinaatit x,y
	$ShotTimer.wait_time = NORMAL_SHOT	

func get_input(delta):
	# Keyboard input
	var input_dir = Vector2()
	if Input.is_action_pressed("up"):
		#liikuttaa pelaajaa hiiren suuntaan ja toistaa animaation
		var mouse_pos = get_global_mouse_position()
		input_dir = (mouse_pos - global_position).normalized()
		Liike_sprite.visible = true
		Liike_sprite.play
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
		Alus_audioEteen.volume_db = 0
		
	if Input.is_action_pressed("down"):
		#liikuttaa pelaajaa kursorista päinvastaiseen suuntaan
		var mouse_pos = get_global_mouse_position()
		input_dir = (global_position - mouse_pos).normalized()
		if not Alus_audioTaakse.is_playing():
			#toistaa äänitehosteen
			Alus_audioTaakse.play()
		Alus_audioTaakse.volume_db = 0
		
		#shooting with mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
		var dir = get_global_mouse_position() - position
		shoot.emit(position, dir)
		Ampuminen_audio.play()
		can_shoot = false
		#timer säätää kuinka nopeasti voi ampua
		$ShotTimer.start()
	
	# Kiihdytyksen halinta
	if input_dir != Vector2():
		velocity += input_dir * acceleration * delta
		velocity = velocity.limit_length(max_speed)		
	
	
		
	else:
		# Hidastuksen hallinta
		velocity = velocity.move_toward(Vector2(), friction * delta)
		Liike_sprite.visible = false
		Idle_sprite.play
		if Alus_audioEteen.is_playing():
			Alus_audioEteen.volume_db = lerp(Alus_audioEteen.volume_db,-80.0,fade_out_speed*delta)
		elif Alus_audioTaakse.is_playing():
			Alus_audioTaakse.volume_db = lerp(Alus_audioTaakse.volume_db,-80.0,fade_out_speed*delta)

func _physics_process(delta):
	# Player movement
	get_input(delta)
	move_and_slide()
	
	# Player rotation hallinta hiirellä
	var mouse = get_local_mouse_position()
	look_at(to_global(mouse))

#nostaa pelaajan vauhtia timerin määrittämäksi ajaksi	
func boost():
	$BoostTimer.start()
	max_speed = BOOST_SPEED
	Alus_audioEteen.pitch_scale = 2
	

#palauttaa vauhdin normaaliksi	
func _on_boost_timer_timeout() -> void:
	max_speed = speed
	Alus_audioEteen.pitch_scale = 1.2

func quick_fire():
	$FastFireTimer.start()
	$ShotTimer.wait_time = FAST_SHOT
	
func _on_shot_timer_timeout() -> void:
	can_shoot = true
	
func _on_fast_fire_timer_timeout() -> void:
	$ShotTimer.wait_time = NORMAL_SHOT
