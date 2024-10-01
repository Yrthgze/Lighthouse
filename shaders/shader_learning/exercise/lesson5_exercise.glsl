#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Plot a line on Y using a value between 0.0-1.0
float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) -
          smoothstep( pct, pct+0.02, st.y);
}

float ex5_row1_func1(float x){
    float y = 1.0 - pow(abs(x), 0.5);
    return y;
}

float ex5_row1_func2(float x){
    float y = 1.0 - pow(abs(x), 1.0);
    return y;
}

float ex5_row2_func4(float x){
    float y = pow(cos(3.1415 * x / 2.0), 2.0);
    return y;
}

float ex5_row3_func1(float x){
    float y = 1.0 - pow(abs(sin(3.1415 * x / 2.0)), 0.5);
    return y;
}

float ex5_row4_func1(float x){
    float y = pow(min(cos(3.1415 * x / 2.0), 1.0 - abs(x)), 0.5);
    return y;
}

float ex5_row5_func1(float x){
    float y = 1.0 - pow(max(0.0, abs(x) * 2.0 - 1.00), 0.5);
    return y;
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution;

    float y = ex5_row5_func1(st.x);

    //Each point will have a (x, x, x) color -> the gradient from black to white
    vec3 color = vec3(y);

    // Plot a line
    float pct = plot(st,y);
    // in the line, pct=0=> color = 1*color + 0*red
    //Here it is adding the wave of the color gradient base (substracting the pct)
    // and then adding the wave of the pct itself.
    color = (1.0-pct)*color+pct*vec3(1.0, 0.0, 0.0);

	gl_FragColor = vec4(color,1.0);
}
