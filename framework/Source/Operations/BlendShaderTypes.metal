#include <metal_stdlib>
using namespace metal;
#include "BlendShaderTypes.h"

half lum(half3 c) {
    return dot(c, half3(0.3, 0.59, 0.11));
}

half3 clipcolor(half3 c) {
    half l = lum(c);
    half n = min(min(c.r, c.g), c.b);
    half x = max(max(c.r, c.g), c.b);
    
    if (n < 0.0h) {
        c.r = l + ((c.r - l) * l) / (l - n);
        c.g = l + ((c.g - l) * l) / (l - n);
        c.b = l + ((c.b - l) * l) / (l - n);
    }
    if (x > 1.0h) {
        c.r = l + ((c.r - l) * (1.0h - l)) / (x - l);
        c.g = l + ((c.g - l) * (1.0h - l)) / (x - l);
        c.b = l + ((c.b - l) * (1.0h - l)) / (x - l);
    }
    
    return c;
}

half3 setlum(half3 c, half l) {
    half d = l - lum(c);
    c = c + half3(d);
    return clipcolor(c);
}

half sat(half3 c) {
    half n = min(min(c.r, c.g), c.b);
    half x = max(max(c.r, c.g), c.b);
    return x - n;
}

half mid(half cmin, half cmid, half cmax, half s) {
    return ((cmid - cmin) * s) / (cmax - cmin);
}

half3 setsat(half3 c, half s) {
    if (c.r > c.g) {
        if (c.r > c.b) {
            if (c.g > c.b) {
                /* g is mid, b is min */
                c.g = mid(c.b, c.g, c.r, s);
                c.b = 0.0h;
            } else {
                /* b is mid, g is min */
                c.b = mid(c.g, c.b, c.r, s);
                c.g = 0.0h;
            }
            c.r = s;
        } else {
            /* b is max, r is mid, g is min */
            c.r = mid(c.g, c.r, c.b, s);
            c.b = s;
            c.g = 0.0h;
        }
    } else if (c.r > c.b) {
        /* g is max, r is mid, b is min */
        c.r = mid(c.b, c.r, c.g, s);
        c.g = s;
        c.b = 0.0h;
    } else if (c.g > c.b) {
        /* g is max, b is mid, r is min */
        c.b = mid(c.r, c.b, c.g, s);
        c.g = s;
        c.r = 0.0h;
    } else if (c.b > c.g) {
        /* b is max, g is mid, r is min */
        c.g = mid(c.r, c.g, c.b, s);
        c.b = s;
        c.r = 0.0h;
    } else {
        c = half3(0.0h);
    }
    return c;
}

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}
