extends Area2D

var speed: int = 1000
var direction : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += speed * direction * delta
	
#timer määrittää kuinka kauan kestää ennenkuin luoti häviää itsestään	
func _on_bullet_destroy_timer_timeout() -> void:
	queue_free()
#luotii tuhoutuu kun se osuu bodyyn
func _on_body_entered(body):
	if not body.has_method("die") or not body.get("alive"):
		queue_free()
	elif body.alive:
		body.die()
		queue_free()
	
