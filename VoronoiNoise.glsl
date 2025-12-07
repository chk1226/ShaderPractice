//reference https://www.youtube.com/watch?v=vcfIJ5Uu6Qw


#iChannel0 "file://asset/Lenna.png"


#include "lygia/generative/random.glsl"

vec3 mappingTexture(vec2 st)
{
    return texture2D(iChannel0, st).rgb;
} 

vec3 drawGrid(vec2 uv, float size, out vec2 currentGridId, out vec2 currentGridCoord)
{
    uv = uv * size;
    currentGridId = floor(uv);
    currentGridCoord = fract(uv);
    vec3 color = smoothstep(0.97, 1.0, max(currentGridCoord.x, currentGridCoord.y)) * vec3(1.0, 0.0, 0.0);

    return color;
}

vec2 noise2x2(vec2 p) {
#if 0
    float x = dot(p, vec2(123.4, 234.5));
    float y = dot(p, vec2(345.6, 456.7));
    vec2 noise = vec2(x, y);
    noise = sin(noise);
    noise = noise * 43758.5453;
    noise = fract(noise);
#else
    vec2 noise = vec2(random(p));
#endif
  return noise;
}


void main() {
    float time = iGlobalTime * 1.0;
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);

    // adjusts the x-coordinate aspect ratio correction
    // uv.x *= iResolution.x / iResolution.y;

    vec3 color = vec3(0.0);
    vec2 currentGridId;
    vec2 currentGridCoord;

    // draw grids
    float size = 4.0;
    vec3 redGrids = drawGrid(uv, size, currentGridId, currentGridCoord);
    redGrids = vec3(0.0, 0.0, 0.0);
    
    float pointsOnGrid = 0.0;
    float minDistFromPixel = 100.0;

#if 1
    // -2 is because we want the bottom-left area to reach further
    for (float i = -2.0; i <= 2.0; i++) 
    {
        for (float j = -2.0; j <= 2.0; j++) 
        {
            vec2 adjGridCoords = vec2(i,  j);
            vec2 pointOnAdjGrid = adjGridCoords + (sin(time)+1.0)*1.0;

            vec2 noise = noise2x2(currentGridId + adjGridCoords);
            pointOnAdjGrid = adjGridCoords + sin(time * noise) * 0.5;

            float dist = length(currentGridCoord - pointOnAdjGrid);
            minDistFromPixel = min(dist, minDistFromPixel);

            pointsOnGrid += smoothstep(0.95, 0.96, 1.0 - dist);
        }
    }
#else

    vec2 adjGridCoords = vec2(0.5,  0.5);
    vec2 pointOnAdjGrid = adjGridCoords + (sin(time))*0.5;

    // vec2 noise = noise2x2(currentGridId + adjGridCoords);
    // pointOnAdjGrid = adjGridCoords + sin(time * noise) * 0.5;

    float dist = length(currentGridCoord - pointOnAdjGrid);
    minDistFromPixel = min(dist, minDistFromPixel);

    pointsOnGrid += smoothstep(0.95, 0.96, 1.0 - dist);

#endif

    // color = redGrids + pointsOnGrid + minDistFromPixel*0.8;
    color = vec3(smoothstep(0.2, 1.0, 1.0 - minDistFromPixel));

    gl_FragColor = vec4(color, 1.0);

}