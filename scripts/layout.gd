@tool

class_name Layout extends Node2D

@export var peg_scene: PackedScene

@export var pegs_per_column: int = 8
@export var num_rows: int = 10  
@export var horizontal_spacing: float = 60.0
@export var vertical_spacing: float = 50.0
@export var start_position: Vector2 = Vector2.ZERO
@export var generate_grid: bool = false : set = _generate_grid
@export var clear_grid: bool = false : set = _clear_grid

func _ready() -> void:
	_clear_existing_pegs()
	spawn_pachinko_pegs(pegs_per_column, num_rows, horizontal_spacing, vertical_spacing, )


# Function to create a pachinko grid layout
# Returns an array of Vector2 positions for the pegs
func create_pachinko_grid(
	pegs_per_column: int,
	num_rows: int,
	horizontal_spacing: float,
	vertical_spacing: float,
	start_position: Vector2 = Vector2.ZERO
) -> Array[Vector2]:
	
	var peg_positions: Array[Vector2] = []
	
	for row in range(num_rows):
		var pegs_in_this_row = pegs_per_column
		
		# Calculate the starting x position for this row
		var row_start_x = start_position.x
		
		# Offset every other row by half the horizontal spacing for staggered pattern
		if row % 2 == 0:
			row_start_x += horizontal_spacing * 0.5
			# Optional: reduce pegs in offset rows by 1 for traditional pachinko look
			# Uncomment the line below if you want this behavior
			pegs_in_this_row -= 1
		
		# Calculate y position for this row
		var y_pos = start_position.y + (row * vertical_spacing)
		
		# Place pegs in this row
		for col in range(pegs_in_this_row):
			var x_pos = row_start_x + (col * horizontal_spacing)
			var peg_pos = Vector2(x_pos, y_pos)
			peg_positions.append(peg_pos)
	
	return peg_positions

# Example usage function that creates actual peg nodes
func spawn_pachinko_pegs(
	pegs_per_column: int,
	num_rows: int,
	horizontal_spacing: float,
	vertical_spacing: float,
	start_position: Vector2 = Vector2.ZERO
):
	# Get the grid positions
	var positions = create_pachinko_grid(
		pegs_per_column, 
		num_rows, 
		horizontal_spacing, 
		vertical_spacing, 
		start_position
	)
	
	# Create peg instances at each position
	for pos in positions:
		var peg_instance = peg_scene.instantiate()
		peg_instance.position = pos
		add_child(peg_instance)


func _clear_existing_pegs():
	for child in get_children():
		child.queue_free()
			

func setup_pegs():
	for peg: Peg in get_children():
		peg.setup()
	
# Setter functions for editor buttons
func _generate_grid(value):
	if value and Engine.is_editor_hint():
		if peg_scene == null:
			print("Error: No peg scene assigned! Please assign a PackedScene to 'Peg Scene' in the inspector.")
			return
		_clear_existing_pegs()
		spawn_pachinko_pegs(pegs_per_column, num_rows, horizontal_spacing, vertical_spacing )

func _clear_grid(value):
	if value and Engine.is_editor_hint():
		_clear_existing_pegs()
