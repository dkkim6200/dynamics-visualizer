Shader "Unlit/SphericalDepthVisualizer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DepthTex ("DepthTexture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma target 3.5

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float size : PSIZE;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DepthTex;

            v2f vert (appdata v, uint vid : SV_VertexID)
            {
                float x = (float)(vid % 640) / 640.0;
                float y = (float)(vid / 640) / 480.0;

                float depth = tex2Dlod(_DepthTex, float4(x, y, 0, 0)).r;
                
                if (depth > 0.2 && depth < 1.0) {
                    depth = 1.0 - depth;

                    float theta = lerp(0, 2*3.1415, x);
                    float phi = lerp(0, 3.1415, y);
                    float rho = depth / 5.0;

                    v.vertex.x = rho * sin(phi) * cos(theta);
                    v.vertex.y = rho * sin(phi) * sin(theta);
                    v.vertex.z = rho * cos(phi);
                    
                    // v.vertex.x = lerp(-1.0, 1.0, x);
                    // v.vertex.y = lerp(-1.0, 1.0, y) / (640.0 / 480.0);
                    // v.vertex.z = depth;
                } else {
                    float theta = lerp(0, 2*3.1415, x);
                    float phi = lerp(0, 3.1415, y);
                    float rho = 0;

                    v.vertex.x = rho * sin(phi) * cos(theta);
                    v.vertex.y = rho * sin(phi) * sin(theta);
                    v.vertex.z = rho * cos(phi);
                }

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = float2(x, y);
                o.size = 3;
                UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            float3 hsv_to_rgb(float3 HSV)
            {
                    float3 RGB = HSV.z;
                
                    float var_h = HSV.x * 6;
                    int var_i = floor(var_h);   // Or ... var_i = floor( var_h )
                    float var_1 = HSV.z * (1.0 - HSV.y);
                    float var_2 = HSV.z * (1.0 - HSV.y * (var_h-var_i));
                    float var_3 = HSV.z * (1.0 - HSV.y * (1-(var_h-var_i)));
                    if      (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
                    else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
                    else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
                    else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
                    else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
                    else                 { RGB = float3(HSV.z, var_1, var_2); }
                
                return (RGB);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4(hsv_to_rgb(float3(i.uv.x, i.uv.y, 1)), 1);
                return col;
            }
            ENDCG
        }
    }
}
