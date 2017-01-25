/*
Calculations were taken from http://www.deferredprocrastination.co.uk/blog/2011/lattice-hinge-test-results/

+-+ +-+
| | | | 
| | | | l
| | | | 
| +-+ |
|     | 2t
| +-+ |
| | | | 
| | | | l
| | | | 
+-+ +-+
 k b k
 
k = Clearence gap (m)
l = Connected length (m)
n = Number of links in series
t = Material thickness (m)
G = Torsional Modulus of the material (Pa) 
J′= Polar Moment of Inertia for non-circular sections (m4)
T = Torque (Nm)
W = Total hinge Width (m)
Θ = Total bend angle of the piece (Θ=θ×n)
θ = Angle of twist per link (radians) (90°=π/2 radians)
τ = Torsional Stress (Pa)
*/

//look up table from http://www.engineeringmechanics.cz/pdf/19_1_045.pdf

K1r = [
[1.0,0.141],
[1.5,0.196],
[2.0,0.229],
[3.0,0.263],
[4.0,0.281],
[5.0,0.291],
[6.0,0.298],
[8.0,0.307],
[10, 0.312],
[1e12,1/3]
];

K2r = [
[1.0,0.208],
[1.5,0.231],
[2.0,0.246],
[3.0,0.267],
[4.0,0.282],
[5.0,0.292],
[6.0,0.299],
[8.0,0.307],
[10, 0.313],
[1e12,1/3]
];

//setup
$fn=50;
pi = 3.14159265;
bendAng = 50 * pi/180; // (rad)
G = 2 * 1e9; //(GPa)
length = 10 * 1e-3; //(mm)
b = 1.5 * 1e-3; //width of beam
Tau = 60 * 1e6; // (MPa)
thickn = 3 * 1e-3; // (m)
fudge = 0.1; 

//http://www.roymech.co.uk/Useful_Tables/Torsion/Torsion.html
//J = 2.25 * pow(t,4);

//http://www.engineeringmechanics.cz/pdf/19_1_045.pdf


// 1. min. Number of links
// n ≥ 0.676125 × ΘGt/τ(yield)l
n = ceil(0.676125 * (bendAng * G * thickn) /(Tau * length));
echo ("number of links",n);

// 2. min. Link clearance
// k = −t+2√t²/2 × cos(π/4−Θ/n)

k = -thickn + 2*sqrt(pow(thickn,2)/2) * cos((pi/4)-(bendAng/n));
echo("clearance(k)",k*1e3,"mm");

// 3. Total Hinge width
// W = tn+k(n+1)
w = k*n+b*n;
echo ("hing width",w*1e3,"mm");

// length of the spring
// l ≤ 4t
if (length >= 4*thickn) echo("reduce connected length for better performance!");
    
//b = pi * r * (alpha/180°)
bendRad = w / bendAng;
echo ("bend radius",bendRad*1e-3,"mm");

L = 2*length*1e3+2*thickn*1e3;

J1 = 0.141 * pow(thickn,4);
J2 = lookup(thickn/b,K1r)*thickn*pow(b,3);
T = ((bendAng/n)*G*J2)/length;
//Tmax = Θ * mu * a * b² *K2r(a/b) //

n2 = ceil(4.808 * (bendAng * G * thickn) /(Tau * length));
echo("Lookup",thickn/b,"result",lookup(thickn/b,K1r));
echo("J1 vs. J2", J1,J2,"m4");
echo("Total Torque",T,"Nm");
//echo("Maximum Torque",Tmax,"Nm");

//projection (true) 
difference(){
    translate([0,-w*1e3/2,-thickn*1e3/2]) cube([(L+k*1e3)*4+thickn*1e3,2*w*1e3,thickn*1e3]);
    slotter();
}


module slotter() {
    L = 2*length*1e3+2*thickn*1e3;
    
    for (j=[0:n]) {
        for (i=[0:5]) {
            translate([(L+2*thickn*1e3)*i+(L/2+thickn*1e3)*(j%2),j*(k*1e3+b*1e3),0]) //+k*1e3 removed in y dir
                union(){
                    translate([-L/2,0,0]) cylinder(h=thickn*1e3+fudge,d=k*1e3,center=true);
                    translate([L/2,0,0]) cylinder(h=thickn*1e3+fudge,d=k*1e3,center=true);
                    cube([L,k*1e3,thickn*1e3+fudge],true);
                }
        }
    }
}
