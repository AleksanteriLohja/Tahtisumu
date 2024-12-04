extends CharacterBody2D

signal shoot

const NORMAL_SHOT : float = 0.4
const FAST_SHOT : float = 0.1

var can_shoot :  bool
var speed = 600
var acceleration: float = 800 #kiihdytyksen nopeus
var max_speed: float = 700 #kiihdytyksen käyttämä maksimivauhti
var BOOST_SPEED = max_speed*1.5
var friction: float =  500#hidastukseen vaikuttava kitka
var rotation_speed: float = 5.0  # Määritellään rotaation nopeus
var fade_out_speed:float = 0.5 #hidastus äänen feidaus

@onready var Vahinko_sprite: AnimatedSprite2D = $AlusVahinko #vahinko animaatio
@onready var Liike_sprite: AnimatedSprite2D = $MoottoriLiike #moottorin tulianimaatio
@onready var Idle_sprite: AnimatedSprite2D = $MoottoriIdle #moottorin idelanimaatio
@onready var Alus_audioEteen: AudioStreamPlayer = $AlusMoottoriEteen #moottorin ääni eteenpäin
@onready var Alus_audioTaakse: AudioStreamPlayer = $AlusMoottoriTaakse #moottorin ääni taaksepäin
@onready var Ampuminen_audio: AudioStreamPlayer = $AlusAmpuminen #ampumisen ääni
@onready var animated_sprite = $Alus
@onready var gun_sound= $gun_boost

func _ready():#kutsuu reset funktion jossa on kaikki tarvittava pelin aloitukseen
	reset()

func reset():
	animated_sprite.play("idle")
	$gun_boost.stop()
	max_speed = 700
	can_shoot = true
	position = Vector2(4200, 2700) #pelaajan aloitus paikka, koordinaatit x,y
	print("player reset")
	$ShotTimer.wait_time = NORMAL_SHOT	

func get_input(delta):
	# Keyboard input
	var input_dir = Vector2()
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("up"):
		#liikuttaa pelaajaa hiiren suuntaan ja toistaa animaation
		input_dir = (mouse_pos - global_position).normalized()
		Liike_sprite.visible = true
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = 0
		
	if Input.is_action_pressed("down"):
		#liikuttaa pelaajaa kursorista päinvastaiseen suuntaan
		input_dir = (global_position - mouse_pos).normalized()
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = 0
		
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = 0
	
	if Input.is_action_pressed("right"):
		input_dir.x += 1
		if not Alus_audioEteen.is_playing():
			#toistaa äänitehosteen
			Alus_audioEteen.play()
			Alus_audioEteen.volume_db = 0
		
		
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
		Vahinko_sprite.visible = false
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
	animated_sprite.play(("boost"))
	$BoostTimer.start()
	max_speed = BOOST_SPEED
	Alus_audioEteen.pitch_scale = 1.5

	

#palauttaa vauhdin normaaliksi	
func _on_boost_timer_timeout() -> void:
	animated_sprite.play(("idle"))
	max_speed = speed
	Alus_audioEteen.pitch_scale = 1.0

func quick_fire():
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
