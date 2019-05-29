/*
 * Edge-detection GLSL shader by the Themaister from the bsnes project.
 * https://gitorious.org/bsnes/xml-shaders
 * Adapted for Solarus by Christopho.
 *
 * Placed in the public domain.
 */
#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform mat4 sol_mvp_matrix;
uniform mat3 sol_uv_matrix;
COMPAT_ATTRIBUTE vec2 sol_vertex;
COMPAT_ATTRIBUTE vec2 sol_tex_coord;
COMPAT_ATTRIBUTE vec4 sol_color;

COMPAT_VARYING vec4 vertex_coord[5];

uniform vec2 sol_input_size; 
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

void main() {
    float x = 0.5 / sol_texture_size.x;
    float y = 0.5 / sol_texture_size.y; 
    vec2 dg1 = vec2( x, y);
    vec2 dg2 = vec2(-x, y);
    vec2 dx = vec2(x, 0.0);
    vec2 dy = vec2(0.0, y);
 
    gl_Position = sol_mvp_matrix * vec4(sol_vertex, 0.0, 1.0);
    vertex_coord[0].xy = (sol_uv_matrix * vec3(sol_tex_coord, 1.0)).xy;
    vertex_coord[1].xy = vertex_coord[0].xy - dg1;
    vertex_coord[1].zw = vertex_coord[0].xy - dy;
    vertex_coord[2].xy = vertex_coord[0].xy - dg2;
    vertex_coord[2].zw = vertex_coord[0].xy + dx;
    vertex_coord[3].xy = vertex_coord[0].xy + dg1;
    vertex_coord[3].zw = vertex_coord[0].xy + dy;
    vertex_coord[4].xy = vertex_coord[0].xy + dg2;
    vertex_coord[4].zw = vertex_coord[0].xy - dx;
}
