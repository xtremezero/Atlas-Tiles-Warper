shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_schlick_ggx,world_vertex_coords;

uniform sampler2D texture_albedo : source_color;
uniform sampler2D specular:source_color;
uniform float AO_LightAffect;
uniform sampler2D texture_metallic : hint_default_black;
uniform sampler2D texture_roughness : source_color;
uniform sampler2D texture_emission : source_color;
uniform float emission_energy;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16) = 1.0;
uniform sampler2D texture_AO : hint_default_white;
uniform sampler2D texture_AO_UV2: hint_default_white;

uniform bool Triplanar = true;
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness=1.;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale=vec3(1,1,1);
uniform vec3 uv1_offset;

uniform int TilesPerSide=1;
uniform float Scale=1;
void vertex() {
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,-1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,-1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}


vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos, vec2 UVcoord) {
	float repeat = Scale;
	vec4 samp=vec4(0.0);
	vec2 UVnew;
	if (!Triplanar)
	{
		
		UVnew = mod((UVcoord)*repeat,vec2(1./float(TilesPerSide),1./float(TilesPerSide)))+(floor(UVcoord*float(TilesPerSide))/float(TilesPerSide));
		samp+= texture(p_sampler,UVnew);
	}
	else
	{
	samp+= texture(p_sampler,mod(((UVcoord)*repeat)+p_triplanar_pos.xy,vec2(1./float(TilesPerSide),1./float(TilesPerSide)))+(floor(UVcoord*float(TilesPerSide))/float(TilesPerSide))) * p_weights.z;
	samp+= texture(p_sampler,mod(((UVcoord)*repeat)+p_triplanar_pos.xz,vec2(1./float(TilesPerSide),1./float(TilesPerSide)))+(floor(UVcoord*float(TilesPerSide))/float(TilesPerSide))) * p_weights.y;
	samp+= texture(p_sampler,mod(((UVcoord)*repeat)+(p_triplanar_pos.zy* vec2(-1.0,1.0)),vec2(1./float(TilesPerSide),1./float(TilesPerSide)))+(floor(UVcoord*float(TilesPerSide))/float(TilesPerSide))) * p_weights.x;
	}
	return samp;
}


void fragment() {
	vec4 albedo_tex = triplanar_texture(texture_albedo,uv1_power_normal,uv1_triplanar_pos,UV);
	ALBEDO = albedo_tex.rgb*texture(texture_AO_UV2,UV2).rgb;
	float metallic_tex = triplanar_texture(texture_metallic,uv1_power_normal,uv1_triplanar_pos,UV).r;
	METALLIC = metallic_tex;
	float roughness_tex = triplanar_texture(texture_roughness,uv1_power_normal,uv1_triplanar_pos,UV).g;
	ROUGHNESS = roughness_tex;
	SPECULAR = triplanar_texture(specular,uv1_power_normal,uv1_triplanar_pos,UV).b;
	AO = triplanar_texture(texture_AO,uv1_power_normal,uv1_triplanar_pos,UV).r;
	AO_LIGHT_AFFECT = AO_LightAffect;
	NORMAL_MAP = triplanar_texture(texture_normal,uv1_power_normal,uv1_triplanar_pos,UV).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	vec3 emission_tex = triplanar_texture(texture_emission,uv1_power_normal,uv1_triplanar_pos,UV).rgb;
	EMISSION = (emission_tex)*emission_energy;
}
