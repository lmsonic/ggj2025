extends Label


func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version") # you need to enable "Advanced Settings" to make this property visible
