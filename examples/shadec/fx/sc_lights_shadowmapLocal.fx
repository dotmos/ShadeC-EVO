bool AUTORELOAD;
bool PASS_SOLID;

float4x4 matWorldViewProj;
//float4x4 matProj;

float4 vecSkill1; //depthmap stuff, x = | y = alpha clip | z = | w = maxDepth
float4 vecSkill5; //xyz = lightpos | w =

texture entSkin1;

sampler2D ColorSampler = sampler_state
{
	Texture = <entSkin1>;
	AddressU = WRAP;
	AddressV = WRAP;
};

struct vsOut
{
	float4 Pos : POSITION;
	float Pos2D : TEXCOORD0;
	float2 Tex : TEXCOORD1;
};

struct vsIn
{
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};

vsOut mainVS(vsIn In)
{
	vsOut Out = (vsOut)0;
	
	float4 pos = mul(In.Pos,matWorldViewProj);
	Out.Pos2D = pos.z;
	Out.Pos = pos;//mul(pos,matProj);
	Out.Tex = In.Tex;	
	
	return Out;
	
}

float4 mainPS(vsOut In):COLOR0
{
	//alpha clip
	clip(tex2D(ColorSampler,In.Tex).a-vecSkill1.y);
	
	half depth = 1-((In.Pos2D)/vecSkill1.w);
	depth += depth*vecSkill1.z;
	//half depth = 1-(( (In.Pos2D)/vecSkill1.w ) + vecSkill1.z);
	
	half2 outDepth = 0;
	outDepth.x=floor(depth*255)/255;
	outDepth.y=floor((depth-outDepth.x)*255*255)/255;
	
	//half3 Ln = vecSkill5.xzy - In.PosW.xyz;
   //half att = saturate(1-length(Ln)/vecSkill1.w);

	//return 1;
	return float4(outDepth,0,1);
}

float4 mainPS_lm(vsOut In):COLOR0
{
	//clip(tex2D(ColorSampler,In.Tex).a-vecSkill1.y);
	
	half depth = 1-((In.Pos2D)/vecSkill1.w);
	depth -= depth*vecSkill1.z;
	//half depth = 1-(( (In.Pos2D)/vecSkill1.w ) + vecSkill1.z);
	
	half2 outDepth = 0;
	outDepth.x=floor(depth*255)/255;
	outDepth.y=floor((depth-outDepth.x)*255*255)/255;
	
	//half3 Ln = vecSkill5.xzy - In.PosW.xyz;
   //half att = saturate(1-length(Ln)/vecSkill1.w);
	
	//return 1;
	return float4(outDepth,0,1);
}

technique t1
{
	pass p0
	{
		cullmode = cw;
		FogEnable = False;
		alphablendenable = false;
		zwriteenable = true;
		vertexshader = compile vs_2_0 mainVS();
		pixelshader = compile ps_2_0 mainPS();
	}
}

technique t1_lm
{
	pass p0
	{
		cullmode = cw;
		FogEnable = False;
		alphablendenable = false;
		zwriteenable = true;
		vertexshader = compile vs_2_0 mainVS();
		pixelshader = compile ps_2_0 mainPS_lm();
	}
}