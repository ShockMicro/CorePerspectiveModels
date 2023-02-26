#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in int isGUI;
in int isHand;
in float zpos;
in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

bool roughly_equal(float num1, float num2, float threshold) {
    return abs(num1 - num2) <= threshold;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
	
	float alpha255 = textureLod(Sampler0, texCoord0, 0.0).a * 255.0; // Take the alpha from the texture's LOD so it doesn't have any issues (this has hurt me before with VDE)
	float alpha100 = textureLod(Sampler0, texCoord0, 0.0).a * 100.0; // Added to make it easier to work with for more image editors
	
    if (color.a < 0.1) discard; // Snipped due to size.
	
    // updated to 1.19.4 thanks to the der discohund

    // Switch used parts of the texture depending on where the model is displayed
    if (isGUI == 0 && roughly_equal(alpha, 253.0, 0.01)) discard;
    if (isGUI == 1) {
             if (zpos  > 125.0 && roughly_equal(alpha, 254.0, 0.01)) discard;     // Handled as inventory slot
        else if (zpos <= 125.0 && roughly_equal(alpha, 253.0, 0.01)) discard; // Handled as on the player doll
    }
	
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
