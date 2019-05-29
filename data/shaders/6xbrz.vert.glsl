/*
 * Copyright (C) 2011/2016 Hyllian - sergiogdb@gmail.com
 * Copyright (C) 2014-2016 DeSmuME team
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

// 6xBRz shader from libretro GLSL shaders project.
// https://github.com/libretro/glsl-shaders/blob/master/xbrz/shaders/6xbrz.glsl
// Hyllian's xBR-vertex code and texel mapping.
// Adapted to Solarus by Christopho.

#define BLEND_NONE 0
#define BLEND_NORMAL 1
#define BLEND_DOMINANT 2
#define LUMINANCE_WEIGHT 1.0
#define EQUAL_COLOR_TOLERANCE 30.0/255.0
#define STEEP_DIRECTION_THRESHOLD 2.2
#define DOMINANT_DIRECTION_THRESHOLD 3.6

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform mat4 sol_mvp_matrix;
uniform mat3 sol_uv_matrix;
COMPAT_ATTRIBUTE vec2 sol_vertex;
COMPAT_ATTRIBUTE vec2 sol_tex_coord;
COMPAT_ATTRIBUTE vec4 sol_color;
uniform COMPAT_PRECISION vec2 sol_input_size;
uniform COMPAT_PRECISION vec2 sol_output_size;

COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

#define COLOR sol_color
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec4 t1;
COMPAT_VARYING vec4 t2;
COMPAT_VARYING vec4 t3;
COMPAT_VARYING vec4 t4;
COMPAT_VARYING vec4 t5;
COMPAT_VARYING vec4 t6;
COMPAT_VARYING vec4 t7;

#define MVPMatrix sol_mvp_matrix
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;

#define TextureSize sol_input_size
#define InputSize sol_input_size
#define OutputSize sol_output_size

// vertex compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define outsize vec4(OutputSize, 1.0 / OutputSize)

vec4 VertexCoord = vec4(sol_vertex, 0.0, 1.0);
vec4 TexCoord = vec4((vec3(sol_tex_coord,1)*sol_uv_matrix).xy, 0.0, 1.0);

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;
    vec2 ps = vec2(SourceSize.z, SourceSize.w);
    float dx = ps.x;
    float dy = ps.y;

     //  A1 B1 C1
    // A0 A  B  C C4
    // D0 D  E  F F4
    // G0 G  H  I I4
     //  G5 H5 I5

    t1 = vTexCoord.xxxy + vec4( -dx, 0.0, dx,-2.0*dy); // A1 B1 C1
    t2 = vTexCoord.xxxy + vec4( -dx, 0.0, dx, -dy);    //  A  B  C
    t3 = vTexCoord.xxxy + vec4( -dx, 0.0, dx, 0.0);    //  D  E  F
    t4 = vTexCoord.xxxy + vec4( -dx, 0.0, dx, dy);     //  G  H  I
    t5 = vTexCoord.xxxy + vec4( -dx, 0.0, dx, 2.0*dy); // G5 H5 I5
    t6 = vTexCoord.xyyy + vec4(-2.0*dx,-dy, 0.0, dy);  // A0 D0 G0
    t7 = vTexCoord.xyyy + vec4( 2.0*dx,-dy, 0.0, dy);  // C4 F4 I4
}
