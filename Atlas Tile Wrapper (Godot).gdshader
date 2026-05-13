shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx, world_vertex_coords;

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform sampler2D specular : hint_default_white;
uniform float AO_LightAffect = 1.0;
uniform sampler2D texture_metallic : hint_default_black;
uniform sampler2D texture_roughness : hint_default_white;
uniform sampler2D texture_emission : hint_default_black;
uniform float emission_energy = 1.0;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;
uniform sampler2D texture_AO : hint_default_white;
uniform sampler2D texture_AO_UV2 : hint_default_white;

uniform bool Triplanar = true;
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness = 1.0;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform int tiles_per_side = 1;
uniform float Scale = 1.0;

void vertex() {
    TANGENT = vec3(0.0, 0.0, -1.0) * abs(NORMAL.x);
    TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.y);
    TANGENT += vec3(1.0, 0.0, 0.0) * abs(NORMAL.z);
    TANGENT = normalize(TANGENT);
    
    BINORMAL = vec3(0.0, -1.0, 0.0) * abs(NORMAL.x);
    BINORMAL += vec3(0.0, 0.0, 1.0) * abs(NORMAL.y);
    BINORMAL += vec3(0.0, -1.0, 0.0) * abs(NORMAL.z);
    BINORMAL = normalize(BINORMAL);
    
    uv1_power_normal = pow(abs(NORMAL), vec3(uv1_blend_sharpness));
    uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
    uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
    uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

// Function for filter_nearest textures
vec4 sample_nearest(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, vec2 UVcoord) {
    float repeat = Scale;
    vec4 samp = vec4(0.0);
    float tps = float(tiles_per_side);
    vec2 tile_size = vec2(1.0 / tps);
    vec2 uv_offset = floor(UVcoord * tps) / tps;
    
    if (!Triplanar) {
        vec2 base_uv = UVcoord * repeat;
        samp += textureGrad(p_sampler, mod(base_uv, tile_size) + uv_offset, dFdx(base_uv), dFdy(base_uv));
    } else {
        vec2 uv_z = (UVcoord * repeat) + p_triplanar_pos.xy;
        samp += textureGrad(p_sampler, mod(uv_z, tile_size) + uv_offset, dFdx(uv_z), dFdy(uv_z)) * p_weights.z;
        vec2 uv_y = (UVcoord * repeat) + p_triplanar_pos.xz;
        samp += textureGrad(p_sampler, mod(uv_y, tile_size) + uv_offset, dFdx(uv_y), dFdy(uv_y)) * p_weights.y;
        vec2 uv_x = (UVcoord * repeat) + (p_triplanar_pos.zy * vec2(-1.0, 1.0));
        samp += textureGrad(p_sampler, mod(uv_x, tile_size) + uv_offset, dFdx(uv_x), dFdy(uv_x)) * p_weights.x;
    }
    return samp;
}

// Function for default/linear filtered textures
vec4 sample_linear(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, vec2 UVcoord) {
    float repeat = Scale;
    vec4 samp = vec4(0.0);
    float tps = float(tiles_per_side);
    vec2 tile_size = vec2(1.0 / tps);
    vec2 uv_offset = floor(UVcoord * tps) / tps;
    
    if (!Triplanar) {
        vec2 base_uv = UVcoord * repeat;
        samp += textureGrad(p_sampler, mod(base_uv, tile_size) + uv_offset, dFdx(base_uv), dFdy(base_uv));
    } else {
        vec2 uv_z = (UVcoord * repeat) + p_triplanar_pos.xy;
        samp += textureGrad(p_sampler, mod(uv_z, tile_size) + uv_offset, dFdx(uv_z), dFdy(uv_z)) * p_weights.z;
        vec2 uv_y = (UVcoord * repeat) + p_triplanar_pos.xz;
        samp += textureGrad(p_sampler, mod(uv_y, tile_size) + uv_offset, dFdx(uv_y), dFdy(uv_y)) * p_weights.y;
        vec2 uv_x = (UVcoord * repeat) + (p_triplanar_pos.zy * vec2(-1.0, 1.0));
        samp += textureGrad(p_sampler, mod(uv_x, tile_size) + uv_offset, dFdx(uv_x), dFdy(uv_x)) * p_weights.x;
    }
    return samp;
}

// Function specifically for hint_normal textures
vec4 sample_normal(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, vec2 UVcoord) {
    float repeat = Scale;
    vec4 samp = vec4(0.0);
    float tps = float(tiles_per_side);
    vec2 tile_size = vec2(1.0 / tps);
    vec2 uv_offset = floor(UVcoord * tps) / tps;
    
    if (!Triplanar) {
        vec2 base_uv = UVcoord * repeat;
        samp += textureGrad(p_sampler, mod(base_uv, tile_size) + uv_offset, dFdx(base_uv), dFdy(base_uv));
    } else {
        vec2 uv_z = (UVcoord * repeat) + p_triplanar_pos.xy;
        samp += textureGrad(p_sampler, mod(uv_z, tile_size) + uv_offset, dFdx(uv_z), dFdy(uv_z)) * p_weights.z;
        vec2 uv_y = (UVcoord * repeat) + p_triplanar_pos.xz;
        samp += textureGrad(p_sampler, mod(uv_y, tile_size) + uv_offset, dFdx(uv_y), dFdy(uv_y)) * p_weights.y;
        vec2 uv_x = (UVcoord * repeat) + (p_triplanar_pos.zy * vec2(-1.0, 1.0));
        samp += textureGrad(p_sampler, mod(uv_x, tile_size) + uv_offset, dFdx(uv_x), dFdy(uv_x)) * p_weights.x;
    }
    return samp;
}

void fragment() {
    ALBEDO = sample_nearest(texture_albedo, uv1_power_normal, uv1_triplanar_pos, UV).rgb * texture(texture_AO_UV2, UV2).rgb;
    METALLIC = sample_linear(texture_metallic, uv1_power_normal, uv1_triplanar_pos, UV).r;
    ROUGHNESS = sample_linear(texture_roughness, uv1_power_normal, uv1_triplanar_pos, UV).g;
    SPECULAR = sample_linear(specular, uv1_power_normal, uv1_triplanar_pos, UV).b;
    
    AO = sample_linear(texture_AO, uv1_power_normal, uv1_triplanar_pos, UV).r;
    AO_LIGHT_AFFECT = AO_LightAffect;
    
    NORMAL_MAP = sample_normal(texture_normal, uv1_power_normal, uv1_triplanar_pos, UV).rgb;
    NORMAL_MAP_DEPTH = normal_scale;
    
    EMISSION = sample_linear(texture_emission, uv1_power_normal, uv1_triplanar_pos, UV).rgb * emission_energy;
}
