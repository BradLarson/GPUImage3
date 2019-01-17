#ifndef BLENDSHADERTYPES_H
#define BLENDSHADERTYPES_H

half lum(half3 c);

half3 clipcolor(half3 c);

half3 setlum(half3 c, half l);

half sat(half3 c);

half mid(half cmin, half cmid, half cmax, half s);

half3 setsat(half3 c, half s);

float mod(float x, float y);

float2 mod(float2 x, float2 y);


#endif 
