/*
 * Edge-detection GLSL shader by the Themaister from the bsnes project.
 * https://gitorious.org/bsnes/xml-shaders
 * Adapted for Solarus by Christopho.
 *
 * Placed in the public domain.
 */
#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D sol_texture;
COMPAT_VARYING vec4 vertex_coord[5];
COMPAT_VARYING vec4 sol_vcolor;

uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

vec3 grayscale(vec3 color) {
    return vec3(dot(color, vec3(0.3, 0.59, 0.11)));
}
 
void main() {
    vec3 c00 = COMPAT_TEXTURE(sol_texture, vertex_coord[1].xy).xyz;
    vec3 c02 = COMPAT_TEXTURE(sol_texture, vertex_coord[4].xy).xyz;
    vec3 c11 = COMPAT_TEXTURE(sol_texture, vertex_coord[0].xy).xyz;
    vec3 c20 = COMPAT_TEXTURE(sol_texture, vertex_coord[2].xy).xyz;
    vec3 c22 = COMPAT_TEXTURE(sol_texture, vertex_coord[3].xy).xyz;

    vec2 tex = vertex_coord[0].xy;
    vec2 texsize = sol_texture_size;
   
    vec3 first = mix(c00, c20, fract(tex.x * texsize.x + 0.5));
    vec3 second = mix(c02, c22, fract(tex.x * texsize.x + 0.5));
   
    vec3 res = mix(first, second, fract(tex.y * texsize.y + 0.5));
    vec4 final = vec4(5.0 * grayscale(abs(res - c11)), 1.0);
    FragColor = clamp(final, 0.0, 1.0);
}
