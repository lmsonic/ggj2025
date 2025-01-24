extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(node:Node2D):
	var player := node as Player
	if player:
		player.die()
