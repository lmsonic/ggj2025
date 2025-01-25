extends Area2D

@export var need_bubble:=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(node:Node2D) -> void:
	var player := node as Player
	if player:
		if not need_bubble or player.is_in_bubble():
			player.die()
