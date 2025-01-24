extends Node

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params:Dictionary) -> void:
	pass

# `start()` is called after pre_start and after the graphic transition ends.
func start() -> void:
	print("gameplay.gd: start() called")


func _process(delta:float) -> void:
	pass
