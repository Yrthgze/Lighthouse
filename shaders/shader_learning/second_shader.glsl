#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Plot a line on Y using a value between 0.0-1.0
float plot(vec2 st) {    
    // In Y=X line, the abs return 0, and therefore, the smoothstep returns 1.0
    //but in the rest it returns some postive value, and therefore something. 
    //the difference between first and second parameters determines the diffusion
    // if a > b, a determines the line width
    return smoothstep(0.5, 0.00, abs(st.y - st.x));
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution;

    float y = st.x;

    //Each point will have a (x, x, x) color -> the gradient from black to white
    vec3 color = vec3(sin(y+u_time*2.0));

    // Plot a line
    float pct = plot(st);
    // in the line, pct=0=> color = 1*color + 0*red
    //Here it is adding the wave of the color gradient base (substracting the pct)
    // and then adding the wave of the pct itself.
    color = (1.0-pct)*color+pct*vec3(1.0, 0.0, 0.0);

	gl_FragColor = vec4(color,1.0);
}
