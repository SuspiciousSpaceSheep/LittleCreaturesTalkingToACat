shader_type spatial;
render_mode depth_draw_always, blend_mix, depth_prepass_alpha;

// GLOBAL
varying vec3 sv_object_normal;
struct EvalCtx {
			vec2 uv;
			vec3 generated;
			vec3 object;
			vec3 camera;
			vec2 screen_uv;
			vec3 world_pos;
			vec3 world_normal;
		};
// UNIFORMS
uniform vec4 u_30b7fca0_base_color : source_color = vec4(0.80000001192093, 0.80000001192093, 0.80000001192093, 1.0);
uniform float u_30b7fca0_metallic : hint_range(0.0,1.0,0.01) = 0;
uniform float u_30b7fca0_roughness : hint_range(0.0,1.0,0.01) = 1;
uniform float u_30b7fca0_ior : hint_range(1.0,100.0,0.01) = 1.5;
uniform float u_30b7fca0_alpha : hint_range(0.0,1.0,0.01) = 1;
uniform vec3 u_30b7fca0_normal = vec3(0.0, 0.0, 0.0);
uniform float u_30b7fca0_weight = 1.0;
uniform float u_30b7fca0_diffuse_roughness = 0;
uniform float u_30b7fca0_subsurface_weight = 0;
uniform vec3 u_30b7fca0_subsurface_radius = vec3(1.0, 0.20000000298023, 0.10000000149012);
uniform float u_30b7fca0_subsurface_scale = 0.05000000074506;
uniform float u_30b7fca0_subsurface_ior = 1.4;
uniform float u_30b7fca0_subsurface_anisotropy = 0;
uniform float u_30b7fca0_specular_ior_level : hint_range(0.0,1.0,0.01) = 0.5;
uniform vec4 u_30b7fca0_specular_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float u_30b7fca0_anisotropic = 0;
uniform float u_30b7fca0_anisotropic_rotation = 0;
uniform vec3 u_30b7fca0_tangent = vec3(0.0, 0.0, 0.0);
uniform float u_30b7fca0_transmission_weight : hint_range(0.0,1.0,0.01) = 0;
uniform float u_30b7fca0_coat_weight : hint_range(0.0,1.0,0.01) = 0;
uniform float u_30b7fca0_coat_roughness : hint_range(0.0,1.0,0.01) = 0.02999999932945;
uniform float u_30b7fca0_coat_ior : hint_range(1.0,4.0,0.01) = 1.5;
uniform vec4 u_30b7fca0_coat_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec3 u_30b7fca0_coat_normal = vec3(0.0, 0.0, 0.0);
uniform float u_30b7fca0_sheen_weight : hint_range(0.0,1.0,0.01) = 0;
uniform float u_30b7fca0_sheen_roughness : hint_range(0.0,1.0,0.01) = 0.5;
uniform vec4 u_30b7fca0_sheen_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 u_30b7fca0_emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float u_30b7fca0_emission_strength : hint_range(0.0,100.0,0.01) = 0;
uniform float u_30b7fca0_thin_film_thickness = 0;
uniform float u_30b7fca0_thin_film_ior = 1.33000004291534;
uniform sampler2D u_7a392955_image_texture;
uniform int u_7a392955_interpolation : hint_enum("Linear","Closest","Cubic") = 0;
uniform int u_7a392955_projection : hint_enum("Flat","Box","Sphere","Tube") = 0;
uniform float u_7a392955_box_blend : hint_range(0.0,1.0,0.01) = 0;
uniform int u_7a392955_extension : hint_enum("Repeat","Extend","Clip","Mirror") = 0;
uniform int u_7a392955_color_space : hint_enum("sRGB","Non-Color") = 0;
uniform int u_7a392955_alpha_mode : hint_enum("Straight","Premultiplied","ChannelPacked","None") = 0;
uniform int u_8e42270a_operation : hint_enum("Add","Subtract","Multiply","Divide","Multiply Add","Power","Logarithm","Square Root","Inverse Square Root","Absolute","Exponent","Sine","Cosine","Tangent","Floor","Ceil","Fract","Minimum","Maximum","Less Than","Greater Than","Sign","Modulo","Truncated Modulo","Floored Modulo","Wrap","Snap","PingPong","Arctan2","Compare","Round","Truncate","Smooth Minimum","Smooth Maximum","Arcsine","Arccosine","Arctangent","Hyperbolic Sine","Hyperbolic Cosine","Hyperbolic Tangent","To Radians","To Degrees") = 20;
uniform bool u_8e42270a_clamp_result = false;
uniform float u_8e42270a_a = 1;
uniform sampler2D u_7ff85612_image_texture;
uniform int u_7ff85612_interpolation : hint_enum("Linear","Closest","Cubic") = 0;
uniform int u_7ff85612_projection : hint_enum("Flat","Box","Sphere","Tube") = 0;
uniform float u_7ff85612_box_blend : hint_range(0.0,1.0,0.01) = 0;
uniform int u_7ff85612_extension : hint_enum("Repeat","Extend","Clip","Mirror") = 0;
uniform int u_7ff85612_color_space : hint_enum("sRGB","Non-Color") = 0;
uniform int u_7ff85612_alpha_mode : hint_enum("Straight","Premultiplied","ChannelPacked","None") = 0;
uniform int u_53f5fa4b_mix_data_type : hint_enum("Float","Vector","Color") = 2;
uniform int u_53f5fa4b_mix_blend_type : hint_enum("Mix","Darken","Multiply","Color Burn","Lighten","Screen","Color Dodge","Add","Overlay","Soft Light","Linear Light","Difference","Exclusion","Subtract","Divide","Hue","Saturation","Color","Value") = 0;
uniform bool u_53f5fa4b_clamp_result = false;
uniform bool u_53f5fa4b_clamp_factor = false;
uniform float u_2fe19288_fac = 0.5;
uniform int u_2fe19288_opt_mode : hint_enum("CONST","LINEAR") = 1;
uniform sampler2D u_2fe19288_colormap;
uniform int u_6a3a8f3e_mix_data_type : hint_enum("Float","Vector","Color") = 2;
uniform int u_6a3a8f3e_mix_blend_type : hint_enum("Mix","Darken","Multiply","Color Burn","Lighten","Screen","Color Dodge","Add","Overlay","Soft Light","Linear Light","Difference","Exclusion","Subtract","Divide","Hue","Saturation","Color","Value") = 0;
uniform bool u_6a3a8f3e_clamp_result = false;
uniform bool u_6a3a8f3e_clamp_factor = false;
uniform vec4 u_6a3a8f3e_a_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
#define INCLUDE_WRAPPER

// INCLUDES
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/formulas/physical.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/formulas/math.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/formulas/struct_Material.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/BSDF_principled.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/Material_Output.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/formulas/coords.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/color_conversions.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/formulas/struct_Tex_img.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/Tex_image.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/color_ramp.gdshaderinc"
#include "res://addons/godot_shader_linker_(gsl)/Nodes/inc_shader/mix_modes.gdshaderinc"

// FUNCTIONS

// Mix: 53f5fa4b (GEN)
vec3 mix_color_53f5fa4b(bool use_cf, bool use_cr, float Factor, vec3 A, vec3 B) {
	float t = use_cf ? clamp(Factor, 0.0, 1.0) : Factor;
	vec3 res = node_mix_blend(t, A, B);
	if (use_cr) { res = node_mix_clamp(res); }
	return res;
}

// Color Ramp: 2fe19288 (GEN)
	vec4 color_ramp_2fe19288(float fac) {
		vec4 outcol; float outa;
	valtorgb_lut(fac, u_2fe19288_colormap, outcol, outa);
		return outcol;
	}
	float alpha_ramp_2fe19288(float fac) {
		vec4 outcol; float outa;
	valtorgb_lut(fac, u_2fe19288_colormap, outcol, outa);
		return outa;
	}

// Mix: 6a3a8f3e (GEN)
vec3 mix_color_6a3a8f3e(bool use_cf, bool use_cr, float Factor, vec3 A, vec3 B) {
	float t = use_cf ? clamp(Factor, 0.0, 1.0) : Factor;
	vec3 res = node_mix_blend(t, A, B);
	if (use_cr) { res = node_mix_clamp(res); }
	return res;
}


void vertex() {
	// SHARED VARYINGS (VERTEX)
	sv_object_normal = NORMAL;
}

void fragment() {
	// Principled BSDF: 30b7fca0
	Material output_30b7fca0_bsdf = bsdf_mini(
	u_30b7fca0_base_color, 
	u_30b7fca0_metallic, 
	u_30b7fca0_roughness, 
	u_30b7fca0_ior, 
	u_30b7fca0_alpha, 
	NORMAL, 
	normalize(VIEW), 
	1.0, 
	u_30b7fca0_specular_ior_level, 
	u_30b7fca0_specular_tint, 
	u_30b7fca0_transmission_weight, 
	u_30b7fca0_coat_weight, 
	u_30b7fca0_coat_roughness, 
	u_30b7fca0_coat_ior, 
	u_30b7fca0_coat_tint, 
	NORMAL, 
	u_30b7fca0_sheen_weight, 
	u_30b7fca0_sheen_roughness, 
	u_30b7fca0_sheen_tint, 
	u_30b7fca0_emission, 
	u_30b7fca0_emission_strength, 
	true, 
	SCREEN_UV
	);
	// Texture Image: 7a392955
	Tex_img_params params_7a392955;
	params_7a392955.interpolation  = u_7a392955_interpolation;
	params_7a392955.projection     = u_7a392955_projection;
	params_7a392955.box_blend      = u_7a392955_box_blend;
	params_7a392955.extension      = u_7a392955_extension;
	params_7a392955.color_space    = u_7a392955_color_space;
	params_7a392955.alpha_mode     = u_7a392955_alpha_mode;
	vec4 tex_7a392955 = _sample_image(vec3(vec3(UV, 0.0)), 
									sv_object_normal * ROT_X(-90.0),
									u_7a392955_image_texture,
									params_7a392955);
	vec4 output_7a392955_color = tex_7a392955;
	// Math: 8e42270a (FRAG)
	float output_8e42270a_value = ((u_8e42270a_a) > (output_7a392955_alpha) ? 1.0 : 0.0);
	output_8e42270a_value = u_8e42270a_clamp_result ? clamp(output_8e42270a_value, 0.0, 1.0) : output_8e42270a_value;
	// Texture Image: 7ff85612
	Tex_img_params params_7ff85612;
	params_7ff85612.interpolation  = u_7ff85612_interpolation;
	params_7ff85612.projection     = u_7ff85612_projection;
	params_7ff85612.box_blend      = u_7ff85612_box_blend;
	params_7ff85612.extension      = u_7ff85612_extension;
	params_7ff85612.color_space    = u_7ff85612_color_space;
	params_7ff85612.alpha_mode     = u_7ff85612_alpha_mode;
	vec4 tex_7ff85612 = _sample_image(vec3(vec3(UV, 0.0)), 
									sv_object_normal * ROT_X(-90.0),
									u_7ff85612_image_texture,
									params_7ff85612);
	vec4 output_7ff85612_color = tex_7ff85612;
	// {module}: 53f5fa4b (FRAG)
	vec3 res_col_53f5fa4b = mix_color_53f5fa4b(u_53f5fa4b_clamp_factor, u_53f5fa4b_clamp_result, output_8e42270a_value, output_7a392955_color.rgb, output_7ff85612_color.rgb);
	vec4 output_53f5fa4b_color = vec4(res_col_53f5fa4b, 1.0);
	// Color Ramp: 2fe19288 (FRAG)
		vec4 output_2fe19288_color = color_ramp_2fe19288(u_2fe19288_fac);
		float output_2fe19288_alpha = alpha_ramp_2fe19288(u_2fe19288_fac);
	// {module}: 6a3a8f3e (FRAG)
	vec3 res_col_6a3a8f3e = mix_color_6a3a8f3e(u_6a3a8f3e_clamp_factor, u_6a3a8f3e_clamp_result, dot((output_2fe19288_color).rgb, vec3(0.2126, 0.7152, 0.0722)), u_6a3a8f3e_a_color.rgb, output_53f5fa4b_color.rgb);
	vec4 output_6a3a8f3e_color = vec4(res_col_6a3a8f3e, 1.0);
	// Material Output: ae463280
	Material mat_ae463280 = material_from_color(output_6a3a8f3e_color);
	ALBEDO   = mat_ae463280.albedo;
	ROUGHNESS = mat_ae463280.roughness;
	METALLIC = mat_ae463280.metallic;
	#ifdef ALPHA_TRANSFER
		ALPHA = mat_ae463280.alpha;
	#endif
	NORMAL = mat_ae463280.normal;
	SPECULAR = mat_ae463280.specular_level;
	EMISSION = mat_ae463280.emission;
	CLEARCOAT = mat_ae463280.coat_weight;
	CLEARCOAT_ROUGHNESS = mat_ae463280.coat_roughness;
}
