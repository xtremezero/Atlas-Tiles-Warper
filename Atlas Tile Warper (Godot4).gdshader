// Shader type and rendering mode
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx, world_vertex_coords;

// Textures and parameters
uniform sampler2D texture_albedo : source_color; 
uniform sampler2D specular : source_color; 
uniform sampler2D texture_metallic : hint_default_black; 
uniform sampler2D texture_roughness : source_color; 
uniform sampler2D texture_emission : source_color; 
uniform sampler2D texture_normal : hint_normal; 
uniform sampler2D texture_AO : hint_default_white; 
uniform sampler2D texture_AO_UV2 : hint_default_white;

uniform float AO_LightAffect; 
uniform float emission_energy; 
uniform float normal_scale : hint_range(-16, 16) = 1.0;

uniform int TilesPerSide = 1; 
uniform float Scale = 1.0; 

// Adjust tangents and binormals in the vertex function for accurate normal mapping.
void vertex() {
    vec3 abs_normal = abs(NORMAL);

    TANGENT = normalize(vec3(1.0, 0.0, 0.0) * abs_normal.y + vec3(0.0, 0.0, -1.0) * abs_normal.x + vec3(1.0, 0.0, 0.0) * abs_normal.z);
    BINORMAL = normalize(vec3(0.0, -1.0, 0.0) * abs_normal.x + vec3(0.0, 0.0, 1.0) * abs_normal.y + vec3(0.0, -1.0, 0.0) * abs_normal.z);
}

// Function to calculate tiled UV coordinates and sample the texture without mipmaps.
vec4 sample_tiled_texture_no_mipmaps(sampler2D tex, vec2 uv) {
    float repeat = Scale;
	float _TilesPerSide = float(TilesPerSide);
    vec2 tile_uv = mod(uv * repeat, vec2(1.0 / _TilesPerSide)) + floor(uv * _TilesPerSide) / _TilesPerSide;
    return textureLod(tex, tile_uv, 0.0); // Force LOD to 0 to disable mipmaps.
}

// Fragment function: Defines the final material properties.
void fragment() {
    // Sample and calculate textures.
    vec4 albedo = sample_tiled_texture_no_mipmaps(texture_albedo, UV);
    vec4 ao_uv2 = textureLod(texture_AO_UV2, UV2, 0.0); // AO UV2 without mipmaps.
    float metallic = sample_tiled_texture_no_mipmaps(texture_metallic, UV).r;
    float roughness = sample_tiled_texture_no_mipmaps(texture_roughness, UV).g;
    float ao = sample_tiled_texture_no_mipmaps(texture_AO, UV).r;
    vec3 normal_map = sample_tiled_texture_no_mipmaps(texture_normal, UV).rgb;
    vec3 emission = sample_tiled_texture_no_mipmaps(texture_emission, UV).rgb;

    // Assign material properties.
    ALBEDO = albedo.rgb * ao_uv2.rgb; 
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = sample_tiled_texture_no_mipmaps(specular, UV).b;
    AO = ao;
    AO_LIGHT_AFFECT = AO_LightAffect; 
    NORMAL_MAP = normal_map;
    NORMAL_MAP_DEPTH = normal_scale; 
    EMISSION = emission * emission_energy; 
}
