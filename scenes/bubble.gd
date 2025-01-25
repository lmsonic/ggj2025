class_name Bubble extends Area2D

@export var speed := 10
var direction:=Vector2.RIGHT
var player_index:=0
func _physics_process(delta: float) -> void:
	translate(direction*speed*delta)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player and player_index != player.player_index:
		player.bubbled()
