extends CharacterBody2D

var speed: int
var screen_size : Vector2
func _ready():
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	speed = 200

func get_input():
	# Keyboard input
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed  # Set the velocity based on input

func _physics_process(_delta):
	# Player movement
	get_input()
	move_and_slide()  

#Player rotation
	var mouse = get_local_mouse_position()
	var angle = snappedf(mouse.angle(), PI / 2) / (PI / 2)#numeroiden summa on on kulmien määrä 
	angle = wrapi(int(angle), 0, 4) #valitsee animaation hiiren suunnan mukaan. nyt neljä mutta frameja voi tehdä lisää

	$AnimatedSprite2D.animation = "käännös" + str(angle)