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

// Removes 32 to each RGB component.

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

void main() {
    FragColor = COMPAT_TEXTURE(sol_texture, sol_vtex_coord.xy);
    FragColor.rgb += 0.1255;
}
