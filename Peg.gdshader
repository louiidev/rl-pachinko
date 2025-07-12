shader_type canvas_item;

// Uniform to control the fill percentage (0.0 to 1.0)
uniform float fill_percentage : hint_range(0.0, 1.0) = 1.0;


// Optional: color tint for the filled portion
//uniform vec4 fill_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Get the texture color
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate if this pixel should be visible
    // UV.y = 0.0 at top, UV.y = 1.0 at bottom
    // We want to fill from bottom up, so we check if UV.y is greater than the threshold
    float threshold = 1.0 - fill_percentage;

    // Basic hard cutoff
    if (UV.y < threshold) {
        discard; // Don't render this pixel
    }

    // Apply the color tint
    COLOR = tex_color;
}