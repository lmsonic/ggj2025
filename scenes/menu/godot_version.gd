extends Label


func _ready() -> void:
	text = "Godot %s" % Engine.get_version_info().string
