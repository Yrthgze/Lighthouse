#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;  // Canvas size (width,height)
uniform vec2 u_mouse;       // mouse position in screen pixels
uniform float u_time;       // Time in seconds since load

vec4 red_color(){
    return vec4(abs(sin(u_time)),cos(u_time),sin(u_time),1.0);
}

void main() {
	gl_FragColor = red_color();
}
