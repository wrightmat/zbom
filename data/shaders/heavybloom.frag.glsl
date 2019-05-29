/*
 * Copyright (C) 2010 WhateverMan
 * Copyright (C) 2018 Christopho, Solarus - http://www.solarus-games.org
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

// Bloom shader from WhateverMan
// https://gitorious.org/bsnes/xml-shaders
// Adapted for Solarus by Christopho.

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

#define glarebasesize 0.42
#define power 0.35 // 0.50 is good

uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

void main()
{
    vec4 sum = vec4(0.0);
    vec4 bum = vec4(0.0);
    vec2 texcoord = vec2(sol_vtex_coord);
    int j;
    int i;

    vec2 glaresize = vec2(glarebasesize) / sol_texture_size;

    for (i = -2; i < 5; i++)
    {
        for (j = -1; j < 1; j++)
        {
            sum += COMPAT_TEXTURE(sol_texture, texcoord + vec2(-i, j) * glaresize) * power;
            bum += COMPAT_TEXTURE(sol_texture, texcoord + vec2(j, i) * glaresize) * power;
        }
    }

    if (COMPAT_TEXTURE(sol_texture, texcoord).r < 2.0)
    {
        FragColor = sum * sum * sum * 0.001 + bum * bum * bum *0.0080 + texture2D(sol_texture, texcoord);
    }
}
