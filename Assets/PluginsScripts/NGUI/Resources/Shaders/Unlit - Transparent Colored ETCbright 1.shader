// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Unlit/TransparentColoredETCbright 1"
{
	Properties
	{
		//_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}

		_MainTex ("Sprite Texture", 2D) = "white" {}
		_AlphaTex ("Alpha Texture", 2D) = "white" {}
				_Bright("Brightness", Float) = 2 
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			
			float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
			float2 _ClipArgs0 = float2(1000.0, 1000.0);
	        float _Bright;
	        
			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{


				////////////////////////////////

				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs0;
				fixed4 alpha = tex2D(_AlphaTex, IN.texcoord);

				// Sample the texture
				fixed4 col = tex2D(_MainTex, IN.texcoord);
				fixed4 vColor = col * IN.color;
				col.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);
				col.a = col.a * vColor.a * alpha.r;

				half3 vGrey = dot(col.rgb, float3(0.299, 0.587, 0.114));
				half3 vNormal = vColor.rgb;
				half3 vHighLight = vColor.rgb * 1.5f;

				col.rgb = lerp( vNormal, vHighLight, IN.color.r < 1.0f );
				col.rgb = lerp( col.rgb, vGrey, IN.color.b <= 0.001f );



				return col;
			}
			ENDCG
		}
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
