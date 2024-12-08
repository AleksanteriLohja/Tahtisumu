extends Area2D

var speed: int = 2000
var direction : Vector2

func _ready() -> void:
	add_to_group("bullet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += speed * direction * delta
	
#timer määrittää kuinka kauan kestää ennenkuin luoti häviää itsestään	
func _on_bullet_destroy_timer_timeout() -> void:
	queue_free()
#luotii tuhoutuu kun se osuu bodyyn
func _on_body_entered(_body):
		queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

		

	#elif body.alive:
		#body.die()
		#queue_free()
	
