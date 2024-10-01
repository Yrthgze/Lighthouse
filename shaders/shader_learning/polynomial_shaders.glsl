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

float doubleCubicSeat (float x, float a, float b){
  
    float epsilon = 0.00001;
    float min_param_a = 0.0 + epsilon;
    float max_param_a = 1.0 - epsilon;
    float min_param_b = 0.0;
    float max_param_b = 1.0;
    a = min(max_param_a, max(min_param_a, a));  
    b = min(max_param_b, max(min_param_b, b)); 

    float y = 0.0;
    if (x <= a){
        y = b - b*pow(1.0-x/a, 3.0);
    } else {
        y = b + (1.0-b)*pow((x-a)/(1.0-a), 3.0);
    }
    return y;
}

float blinnWyvillCosineApproximation (float x){
  float x2 = x*x;
  float x4 = x2*x2;
  float x6 = x4*x2;
  
  float fa = ( 4.0/9.0);
  float fb = (17.0/9.0);
  float fc = (22.0/9.0);
  
  float y = fa*x6 - fb*x4 + fc*x2;
  return y;
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution;

    float y = doubleCubicSeat(st.x, 0.7, 0.95);

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
