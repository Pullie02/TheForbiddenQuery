extends Area2D


func _on_body_entered(body):
	Dialogic.start("wakeup")
	queue_free()
