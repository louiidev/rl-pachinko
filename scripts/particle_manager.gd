extends Node

@onready var hit_particle: PackedScene = preload("res://particles/HitParticle.tscn")
@onready var _smoke_particle: PackedScene = preload("res://particles/Smoke.tscn")



var child_container: Node2D


func clear_particles(_scene):
	for child: GPUParticles2D in child_container.get_children():
		child.emitting = false
		child.finished.emit()
		child.visible = false

func _ready() -> void:
	child_container = Node2D.new()
	var scene:= get_tree().root
	scene.call_deferred("add_child", child_container)
	Game.change_scene_request.connect(clear_particles)

func spawn_smoke_particle(global_position: Vector2):
	var particle: GPUParticles2D = _smoke_particle.instantiate()
	child_container.add_child(particle)
	particle.global_position = global_position
	particle.emitting = true
	particle.one_shot = true
	

	particle.finished.connect(particle.queue_free)
	particle.restart()

func spawn_hit_particle(global_position: Vector2, direction: Vector2, color: Color):
	var particle: GPUParticles2D = hit_particle.instantiate()
	child_container.add_child(particle)
	particle.global_position = global_position
	particle.emitting = true
	particle.one_shot = true
	
	#particle.explosiveness = 1.0
	particle.lifetime = 0.3
	var mat: ParticleProcessMaterial = particle.process_material
	mat.color = color
	mat.direction = Vector3(direction.x, direction.y, 0.0)
	particle.finished.connect(particle.queue_free)
	particle.restart()
