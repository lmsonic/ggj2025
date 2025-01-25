extends Node2D
const MOVING_PLATFORM = preload("res://scenes/moving_platform.tscn")
@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	var platform :MovingPlatform= MOVING_PLATFORM.instantiate()
	platform.global_position.y = Game.size.y*0.8
	var third := Game.size.x * 0.3
	platform.global_position.x = randf_range(third,Game.size.x-third)
	platform.scale.x = randf_range(1.0,2.0)
	add_child(platform)
	timer.start(randf_range(1.5	,3.0))
