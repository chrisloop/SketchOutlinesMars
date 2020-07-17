TEXTURE2D(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);
#define PI2 6.28318530717959
 
float4 getCol(float2 UV)
{
    //return float4(0.0,0.0,0.0,0.0);
    //vec2 uv = pos / iResolution.xy;
    return SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, UV);
} 

float getVal(float2 UV)
{
    float3 c = getCol(UV);
    return dot(c.xyz, float3(0.2126, 0.7152, 0.0722));
}

float2 getGrad(float2 UV, float eps)
{
   	float2 d = float2(eps,0);
    return float2(
        getVal(UV+d.xy)-getVal(UV-d.xy),
        getVal(UV+d.yx)-getVal(UV-d.yx)
    )/eps/2.0;
}

void pR(inout float2 p, float a) {
	p = cos(a)*p + sin(a)*float2(p.y, -p.x);
}

float absCircular(float t)
{
    float a = floor(t + 0.5);
    return fmod(abs(a - t), 1.0);
}

void Sketch_float(float2 UV, float Angles, float Range, float Step, float Threshold, float Sensitivity, float var_1, float var_2, out float4 Out, out float4 Outline)
{
    float2 pos = UV;
    float weight = 1;

    if (Step <= 0)
    {
        Step = .1;
    }

    for (float j = 0.0; j < Angles; j+= 1.0)
    {
        float2 dir = float2(1, 0);
        pR(dir, j * PI2 / (2.0 * Angles));
 
        float2 grad = float2(-dir.y, dir.x);
        grad = 1.0;

        for (float i = -Range; i <= Range; i+= Step)
        {
            float2 pos2 = pos + normalize(dir)*i;
            float2 g = getGrad(pos2, var_1);
 
/*
            if (length(g) < Threshold)
            {
             //   i+= 200;
            }
*/
            if (length(g) >= Threshold)
            {
              //  weight -= .01;
              weight -= pow(abs(dot(normalize(grad), normalize(g))), Sensitivity) / floor((2.0 * Range + 1.0) / Step) * var_2;// / Angles * 6;
            }
            else
            {
             //   go = false;
            }

        }
    }
    Out = float4(weight,weight,weight,weight);
    Outline = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, UV);
    //Out = float4(weight,weight,weight,weight);
    //Outline = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, UV);
    //Out = getCol(UV); 
}