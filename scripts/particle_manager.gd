extends Node

@onready var hit_particle: PackedScene = preload("res://particles/HitParticle.tscn")






func spawn_hit_particle(global_position: Vector2, direction: Vector2, color: Color):
	var scene:= get_tree().root
	var particle: GPUParticles2D = hit_particle.instantiate()
	scene.add_child(particle)
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
