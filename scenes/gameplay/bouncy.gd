class_name Bouncy extends StaticBody2D

@onready var shape: CollisionShape2D = $CollisionShape2D

func normal() -> Vector2:
	var boundary:WorldBoundaryShape2D= shape.shape
	return boundary.normal
