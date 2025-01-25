class_name MovingPlatform extends AnimatableBody2D

@export var direction := Vector2.UP
@export var speed := 50.0

func _physics_process(delta: float) -> void:
	translate(direction*speed*delta)
