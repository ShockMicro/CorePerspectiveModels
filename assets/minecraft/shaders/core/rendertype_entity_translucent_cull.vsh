#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float FogStart;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

flat out int isGUI;
flat out int isHand;

out float zpos;
out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

// updated to 1.19.4 thanks to the der discohund
// updated to 1.20 thanks to HalbFettKaese + Evtema3

// gui item model detection from Onnowhere
bool isgui(mat4 ProjMat) {
    return abs(ProjMat[3][3]) > 0.01;
}
// first person hand item model detection from esben
bool ishand(float FogStart) {
    return FogStart * 0.000001 > 1;
}

void main() {
    zpos = Position.z;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
	
	isGUI = int(isgui(ProjMat));
    isHand = int(ishand(FogStart));

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
	vec4 lightColor = vertexDistance <= 800 ? minecraft_sample_lightmap(Sampler2, UV2) : texelFetch(Sampler2, UV2 / 16, 0); // Added this simply for better compat with light-altering packs.
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * lightColor;
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
