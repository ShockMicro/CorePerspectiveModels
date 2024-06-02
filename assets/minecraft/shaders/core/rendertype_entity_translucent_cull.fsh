#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

flat in int isGUI;
in float zpos;
in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) discard;
	
	int alpha = int(textureLod(Sampler0, texCoord0, 0.0).a * 255.5); // Take the alpha from the texture's LOD so it doesn't have any issues (this has hurt me before with VDE)

    // Switch used parts of the texture depending on where the model is displayed
    if(isGUI == 1) {
        if(alpha == 254 && zpos > 100.0) discard; // Handled as inventory slot
        if(alpha == 253 && zpos < 100.0) discard; // player doll, so discard the icon
    }else{
        if(alpha == 253) discard; // discard the icon outside of gui
    }

    // Remap alpha
    if(alpha >= 253)
        color.a = 1.0;
	
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
