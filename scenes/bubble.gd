class_name Bubble extends Area2D

@export var speed := 10
var direction:=Vector2.RIGHT

func _physics_process(delta: float) -> void:
	translate(direction*speed*delta)
