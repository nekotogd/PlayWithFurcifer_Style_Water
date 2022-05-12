shader_type canvas_item;

uniform sampler2D noise1;
uniform sampler2D noise2;

uniform vec4 water_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 foam_color : hint_color = vec4(1.0);
uniform float foam_brightness = 1.0;
uniform float water_brightness = 1.0;
uniform float noise1_scale = 1.0;
uniform float noise2_scale = 1.0;
uniform float noise1_speed = 0.1;
uniform float noise2_speed = -0.1;
uniform float cut_level = 1.8;
uniform float cut_blend = 0.0;

// Refraction properties
uniform float refraction_scale1 = 1.0;
uniform float refraction_scale2 = 1.0;
uniform float refraction_speed1 = 0.1;
uniform float refraction_speed2 = 0.15;
uniform float refraction_distortion = 0.1;
uniform float refraction_strength = 0.06;

void fragment(){
	// Sample Both Noise Values
	// One Going towards the top-left, the other towards the bottom-right
	// (This is for specular highlights)
	float n1 = texture(noise1, UV * noise1_scale + TIME * noise1_speed).r;
	float n2 = texture(noise2, UV * noise2_scale + TIME * noise2_speed).r;
	
	// Blend the values together, using an average works too
	float sum = n1 + n2;
	float coherence = 1.0 - smoothstep(cut_level, cut_level + cut_blend, sum);
	
	// Build the noise for refraction
	float rf_noise = texture(noise1, UV * refraction_scale1 + TIME * refraction_speed1).r;
	rf_noise = texture(noise2, UV * refraction_scale2 + TIME * refraction_speed2 + rf_noise * refraction_distortion).r;
	
	// Mess with screen UVs using our refraction noise
	vec2 uv = SCREEN_UV;
	uv += rf_noise * refraction_strength;
	// Recenter UVs after distortion
	uv -= refraction_strength * 0.5;
	
	// Get our distorted screen color
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	
	// Mask between specular highlights and water distortion
	vec3 final_color = mix(screen_color, screen_color * water_color.rgb, water_color.a);
	final_color += (water_brightness - 1.0);
	final_color = mix(final_color, foam_color.rgb * foam_brightness, coherence); // Optional foam color
	
	// Actually output it to the screen
	COLOR.rgb = final_color;
}
