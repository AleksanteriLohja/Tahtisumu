extends Area2D

@onready var main = get_node("/root/main") #tuodaan main node jotta voidaan viitata siihen
@onready var lives_label = get_node("/root/main/Hud/LivesLabel") #tuodaan main node jotta voidaan viitata siihen

var item_type : int # 0:health 1:gun

var health_item = preload("res://assets/grafiikka/items/health.png")
var bullets_item = preload("res://assets/grafiikka/items/bullets.png")
var boost_item = preload("res://assets/grafiikka/items/boost.png")
var textures = [health_item, bullets_item, boost_item]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = textures[item_type]
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_body_entered(body: Node2D) -> void:
	#health
	if item_type == 0:
		main.lives += 1
		lives_label.text = "X " + str(main.lives)
		print("Health")
	#bullets
	elif item_type == 1:
		body.quick_fire()
		print("bullets")
		#boost
	elif item_type == 2:
		body.boost()
		print("boost")
	#delete item
	queue_free()	