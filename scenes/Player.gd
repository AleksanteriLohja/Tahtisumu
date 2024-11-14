extends CharacterBody2D

var speed: int

func _ready():
	speed = 500

func get_input():
	# Keyboard input
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed  # Set the velocity based on input

func _physics_process(_delta):
	# Player movement
	get_input()
	move_and_slide()  

#Player rotation, tässä oli alunperin toisenlainen koodi mutta tää toimii paremmin
	var mouse = get_local_mouse_position()
	look_at(to_global(mouse))
