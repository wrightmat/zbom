/*
 * Copyright (C) 2018 Solarus - http://www.solarus-games.org
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// Originally from a repository of BSNES shaders by guest(r).
// Modified by slime73 for use with love2d and mari0.
// Adapted for Solarus by Vlag and Christopho.

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
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

const float mx = 0.325;    // start smoothing factor
const float k = -0.250;    // smoothing decrease factor
const float max_w = 0.25;
const float min_w =-0.10;  // min smoothing/sharpening weigth
const float lum_add = 0.2; // effects smoothing

vec2 texcoord = sol_vtex_coord;

void main()
{
    float x = 0.5 / sol_texture_size.x;
    float y = 0.5 / sol_texture_size.y;

    vec2 dg1 = vec2( x,y);
    vec2 dg2 = vec2(-x,y);
    vec2 sd11 = dg1 * 0.5;
    vec2 sd21 = dg2 * 0.5;
 
    vec3 c  = COMPAT_TEXTURE(sol_texture, texcoord).xyz;
    vec3 i1 = COMPAT_TEXTURE(sol_texture, texcoord - sd11).xyz;
    vec3 i2 = COMPAT_TEXTURE(sol_texture, texcoord - sd21).xyz;
    vec3 i3 = COMPAT_TEXTURE(sol_texture, texcoord + sd11).xyz;
    vec3 i4 = COMPAT_TEXTURE(sol_texture, texcoord + sd21).xyz;
    vec3 o1 = COMPAT_TEXTURE(sol_texture, texcoord - dg1).xyz;
    vec3 o3 = COMPAT_TEXTURE(sol_texture, texcoord + dg1).xyz;
    vec3 o2 = COMPAT_TEXTURE(sol_texture, texcoord - dg2).xyz;
    vec3 o4 = COMPAT_TEXTURE(sol_texture, texcoord + dg2).xyz;

    vec3 dt = vec3(1.0);

    float ko1 = dot(abs(o1 - c),dt);
    float ko2 = dot(abs(o2 - c),dt);
    float ko3 = dot(abs(o3 - c),dt);
    float ko4 = dot(abs(o4 - c),dt);

    float sd1 = dot(abs(i1 - i3),dt);
    float sd2 = dot(abs(i2 - i4),dt);

    float w1 = sd2;
    if (ko3 < ko1)
        w1 = 0.0;
    float w2 = sd1;
    if (ko4 < ko2)
        w2 = 0.0;
    float w3 = sd2;
    if (ko1 < ko3)
        w3 = 0.0;
    float w4 = sd1;
    if (ko2 < ko4)
        w4 = 0.0;

    c = (w1 * o1 + w2 * o2 + w3 * o3 + w4 * o4 + 0.1 * c) / (w1 + w2 + w3 + w4 + 0.1);

    w3 = k / (0.4 * dot(c, dt) + lum_add);
 
    w1 = clamp(w3 * sd1 + mx, min_w, max_w); 
    w2 = clamp(w3 * sd2 + mx, min_w, max_w);

    FragColor = vec4(w1 * (i1 + i3) + w2 * (i2 + i4) + (1.0 - 2.0 * (w1 + w2)) * c, 1.0);
}
