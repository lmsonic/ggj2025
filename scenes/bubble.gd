class_name Bubble extends Area2D

@export var upward_force := 150.0
@export var recoil := 350.0
@export var force := 200.0
@export var speed := 400.0
var direction:=Vector2.RIGHT
var player_index:=0
func _physics_process(delta: float) -> void:
	translate(direction*speed*delta)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player and player_index != player.player_index:
		player.bubbled(self)
		queue_free()
	var bouncy := body as Bouncy
	if bouncy:
		direction = direction.bounce(bouncy.normal())


func _on_timer_timeout() -> void:
	queue_free()
