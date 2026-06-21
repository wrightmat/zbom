/*
 * HEAT HAZE shader (version 2.0)
 *
 * Creates a rippling heat-haze distortion with a red/orange tint, meant to
 * be applied to a whole screen (or any surface/sprite) to denote extreme
 * heat -- lava rooms, fire damage zones, desert heat, etc.
 *
 * Written for Solarus - http://www.solarus-games.org
 * Follows the same GLSL / GLSL ES compatibility pattern as the "distortion"
 * shader by froggy77.
 *
 * No Lua code is required to see the effect: every tunable value below is
 * a plain #define constant, not a uniform, so it's baked into the shader
 * itself and works identically with zero setup, in the Solarus Quest
 * Editor's built-in shader viewer, and in-game.
 *
 * (An earlier version of this shader used uniforms with default-value
 * initializers instead, following the "distortion" shader's pattern. That
 * syntax is desktop-GLSL-only, and relies on the shader being compiled with
 * "#if VERSION >= 130" actually picking the desktop branch -- which turned
 * out not to be a safe assumption to make blind. Testing directly against
 * a real Solarus build showed it takes the #else / GLSL-ES-style branch,
 * which doesn't support uniform initializers, so every value silently sat
 * at 0 with no error -- no tint, no ripple, nothing. Plain #define
 * constants have no such dependency: they're substituted at the
 * preprocessor level before any of that branching even happens.)
 *
 * To customize the look, just edit the #define lines below directly.
 *
 *
 * -- Example usage in a Solarus script:
 *
 * local shader = sol.shader.create("heat_haze")
 * sol.video.set_shader(shader)
 *
 * Or, to apply it only to the map surface (so it doesn't distort the HUD or
 * dialog box drawn above it):
 *
 * local shader = sol.shader.create("heat_haze")
 * map:get_camera():get_surface():set_shader(shader)
 *
 * ----
 *
 * Tuning notes:
 * - RIPPLE_AMOUNT / RIPPLE_SCALE control how wavy the distortion looks.
 *   Keep RIPPLE_AMOUNT fairly small (under ~3.0) -- heat haze should be a
 *   subtle shimmer, not the bigger wobble of an "underwater" style effect.
 * - RISE_SPEED controls how fast the ripple pattern drifts upward, which is
 *   what reads as "hot air rising" rather than just side-to-side wobble.
 *   Set it to 0.0 to disable the rising motion and leave a stationary
 *   shimmer.
 * - TINT_STRENGTH blends TINT_COLOR into the scene; TINT_COLOR itself
 *   doesn't have to be pure red -- try a deep orange for embers/lava, or a
 *   duller brick red for a "dangerously overheating room" feel.
 * - GLOW_PULSE_AMOUNT adds a slow brightening/dimming pulse on top of the
 *   tint, to suggest shimmering heat glare rather than a flat color wash.
 *   Set it to 0.0 to disable the pulse entirely.
 */
#if VERSION >= 130
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
// sol_time grows for the entire play session, and the time-derived values
// below (t, rising_y) grow right along with it. At mediump precision (often
// an effective 16-bit float on GLSL ES hardware), that magnitude is already
// coarse enough after a couple of hours of play to turn the ripple's phase
// into visible noise rather than smooth motion. highp avoids this; GLSL ES
// doesn't strictly guarantee highp in fragment shaders on every device, but
// where it's missing the spec requires the compiler to silently fall back
// to the best available precision rather than erroring, so this is a safe
// "ask for better, gracefully degrade" request rather than a hard
// requirement.
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#endif
#endif

// ---- Tunable look, edit these directly ----
#define TINT_COLOR vec3(1.0, 0.25, 0.05)  // Color blended into the scene to sell the "extreme heat" look. Defaults to a hot orange-red.
#define TINT_STRENGTH 0.35                // How strongly TINT_COLOR is blended in, from 0.0 (no tint) to 1.0 (fully TINT_COLOR).

#define RIPPLE_SPEED 1.0                  // How fast the shimmer animates. Higher is faster.
#define RIPPLE_AMOUNT 0.2                 // How far pixels get displaced by the ripple, in percent of screen width/height. Keep this small for a subtle haze; large values look more like an "underwater" distortion.
#define RIPPLE_SCALE 18.0                 // How many ripple bands fit on screen. Higher values give tighter, more frequent waves.

#define RISE_SPEED 0.6                    // How fast the ripple pattern drifts upward, to suggest rising hot air.

#define GLOW_PULSE_SPEED 1.5              // How fast the heat glow brightens and dims.
#define GLOW_PULSE_AMOUNT 0.06            // How much extra brightness the glow pulse adds at its peak.
// ---------------------------------------------

uniform sampler2D sol_texture;        // Texture.
uniform int sol_time;                 // Simulated time elapsed since Solarus started, in milliseconds.

// Declare the texture coordinates and color to be used in the shader.
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

void main() {
  // Initialize the texture coordinate.
  vec2 coord = sol_vtex_coord.xy;

  // sol_time keeps counting up for the entire play session (milliseconds
  // since Solarus started), which is why precision float; above asks for
  // highp where it's available. mod() below is a cheap extra safety net on
  // top of that: it keeps the actual angle handed to sin() bounded to one
  // period, which costs nothing and only helps, but doesn't by itself fix
  // a too-low-precision multiply upstream -- that's what the precision
  // qualifier is for.
  const float TWO_PI = 6.283185307179586;
  float time_s = float(sol_time) * 0.001;

  // Time in shimmer units. Subtracting RISE_SPEED * time from y before
  // feeding it into the wave makes the whole ripple pattern slowly travel
  // upward over time, on top of its regular side-to-side animation -- this
  // is what makes it read as "rising heat" rather than a static wobble.
  float t = time_s * RIPPLE_SPEED;
  float rising_y = coord.y - time_s * RISE_SPEED;

  // Two slightly different sine waves, offset in phase and frequency, are
  // layered together so the ripple doesn't look like one uniform repeating
  // wave -- real heat haze is a bit irregular. mod() keeps the argument
  // passed to sin() bounded to one period; combined with requesting highp
  // above, this keeps the animation smooth for arbitrarily long play
  // sessions instead of degrading after a couple of hours.
  float angle1 = mod((rising_y * RIPPLE_SCALE) + t * 2.0, TWO_PI);
  float angle2 = mod((rising_y * RIPPLE_SCALE * 1.7) - t * 1.3 + 1.7, TWO_PI);
  float wave1 = sin(angle1);
  float wave2 = sin(angle2);
  float wave = (wave1 * 0.65 + wave2 * 0.35);

  coord.x += wave * (RIPPLE_AMOUNT / 100.0);

  // Clamp instead of showing a background color: for a full-screen heat
  // haze the small RIPPLE_AMOUNT values keep coord.x just barely outside
  // [0,1] for a few pixels at the very left/right edge, and clamping there
  // reads as the image gently pinching at the edge rather than flashing an
  // unrelated background color in. If you push RIPPLE_AMOUNT very high,
  // consider switching this to a bgcolor fill instead, the way the
  // "distortion" shader does.
  coord.x = clamp(coord.x, 0.0, 1.0);

  vec4 tex_color = COMPAT_TEXTURE(sol_texture, coord);

  // Blend the heat tint in. mix() keeps this proportional to TINT_STRENGTH
  // so a TINT_STRENGTH of 0.0 reproduces the original colors exactly.
  vec3 tinted = mix(tex_color.rgb, tex_color.rgb * TINT_COLOR * 2.0, TINT_STRENGTH);

  // Slow brightness pulse on top of the tint, to suggest shimmering glare.
  float pulse_angle = mod(time_s * GLOW_PULSE_SPEED, TWO_PI);
  float pulse = sin(pulse_angle) * 0.5 + 0.5;
  tinted += pulse * GLOW_PULSE_AMOUNT;

  // Respect the drawable's own color/opacity (set via drawable:set_color(),
  // drawable:set_opacity(), etc.), the same way Solarus's own built-in
  // shader examples multiply by sol_vcolor.
  FragColor = vec4(tinted, tex_color.a) * sol_vcolor;
}
