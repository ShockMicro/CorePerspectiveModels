#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float zpos;
in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

bool check_alpha(float textureAlpha, float targetAlpha) {
	
	float targetLess = targetAlpha - 0.01;
	float targetMore = targetAlpha + 0.01;
	return (textureAlpha > targetLess && textureAlpha < targetMore);
	
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0; // Take the alpha from the texture's LOD so it doesn't have any issues (this has hurt me before with VDE)
    if (color.a < 0.1) discard; // This is vanilla, I just shorten it because big
	
	if (check_alpha(alpha, 253.0) && vertexDistance < 800) discard; // If it's inside the normal world space, it's always going to want to be the hand texture.
	
	if (vertexDistance >= 800) { // If it's in a GUI, figure out if it's the paper doll or an inventory slot.
	
		if (check_alpha(alpha, 254.0) && zpos < 2.0) discard; // If it's far back enough on the z-axis, it's usually in the paper doll's hand. Max set to 2 because nothing should be bigger than that.
		else if (check_alpha(alpha, 253.0) && zpos >= 2.0) discard; // If it's close enough on the z-axis, it's usually in an inventory slot.
		
	}
	
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
