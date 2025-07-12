extends Line2D

@onready var triangle = $Polygon2D  # Reference to the triangle

func _ready():
	# Set up your line points first
	add_point(Vector2(0, 0))
	add_point(Vector2(100, 50))
	add_point(Vector2(200, 0))
	
	# Now create the triangle
	create_triangle_arrow()

func create_triangle_arrow():
	if points.size() < 2:
		return
	
	# Get the last point of the line
	var end_point = points[-1]
	var before_end = points[-2]
	
	# Figure out which direction the line is pointing
	var direction = (end_point - before_end).normalized()
	
	# Create a triangle pointing in that direction
	var arrow_points = PackedVector2Array()
	arrow_points.append(end_point)  # Tip of triangle
	arrow_points.append(end_point + Vector2(-15, -8))  # Bottom left
	arrow_points.append(end_point + Vector2(-15, 8))   # Bottom right
	
	# Give the triangle these points
	triangle.polygon = arrow_points
	triangle.color = Color.RED
