uniform float time;

vec3 normal = vec3(0);
float map(vec3 p){
    vec3 q = (p-floor(p)) * 2. - 1.;

     return length(q) - .25;   
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773;
    const float eps = 0.0005;
    return normalize( e.xyy*map( pos + e.xyy*eps ) + 
                      e.yyx*map( pos + e.yyx*eps ) + 
                      e.yxy*map( pos + e.yxy*eps ) + 
                      e.xxx*map( pos + e.xxx*eps ) );
}
    
vec3 filmicToneMapping(vec3 color)
{
    color = max(vec3(0.), color - vec3(.004));
    color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + .06);
    return color;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float timemod = mod(time,25.025);
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;

    vec3 r = normalize(vec3(uv,1.));
    vec3 rr = r;
    float z = timemod*.25;
    r.xz *= mat2(cos(z), -sin(z), sin(z), cos(z));
    
    vec3 o = vec3(0.,timemod,timemod);
    
    float t = 0.;
    for (int i = 0; i < 96; i++){

        vec3 p = o+r*t;   
        float d=map(p);
        normal = calcNormal(p);
        t += d * .5;    
    }


    float brightness = 1. / (1. + t * t * .1);
    vec3 light = vec3(-1,-.8,1.5);
    vec3 dirtolight = normalize(normal - light);
    float diffuse = max(.2, dot(normal, dirtolight));
    
    vec3 color = vec3(.12,.32,.75);
    

    // Blinn-phong shading
    vec3 H = normalize(vec3(8.,7.,-8.) + light);

    float specular = pow(max(0., dot(normal, H)), 256.)*9.;
    //phong shading -> float specular = pow(diffuse,96.);
    
    float fresnel = 0.05+0.95*pow(1.0+dot(r, normal),5.);
        
    vec3 fc =color*diffuse*(1.0-fresnel) + specular*fresnel;
    
    // yes
    if (fresnel > .5) {fc = vec3(.5);}
    if (brightness < .1) {fc = vec3(.5);}

    fragColor = vec4(filmicToneMapping(fc),1.);
}
