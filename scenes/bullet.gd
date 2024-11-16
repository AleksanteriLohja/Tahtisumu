extends Area2D

var speed: int = 700
var direction : Vector2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += speed * direction * delta
	
#timer määrittää kuinka kauan kestää ennenkuin luoti häviää itsestään	
func _on_bullet_destroy_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body):
	if body.alive:
		body.die()
		queue_free()
	
