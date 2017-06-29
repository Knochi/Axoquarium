$fn=50;

// 92x42x3mm
//100x50
//radius 4mm

fudge=0.1;
sheetTh=3;
edgeRad=4;
sizeX = 100;
sizeY = 50;

drillX = 92;
drillY = 42;
drill  = 2.4;

!projection()
difference(){
        minkowski(){
            cube([100-edgeRad*2,50-edgeRad*2,sheetTh-1],true);
            cylinder(h=1,r=edgeRad,center=true);
        }
        //holes
        translate([drillX/2,drillY/2,0]) cylinder(h=sheetTh+fudge,d=3,center=true);
        translate([-drillX/2,drillY/2,0]) cylinder(h=sheetTh+fudge,d=3,center=true);
        translate([drillX/2,-drillY/2,0]) cylinder(h=sheetTh+fudge,d=3,center=true);
        translate([-drillX/2,-drillY/2,0]) cylinder(h=sheetTh+fudge,d=3,center=true);
        //components
        cube([75,46,sheetTh+fudge],true);
        translate([-43,0,0]) #cube([7,32,sheetTh+fudge],true);
        translate([43,0,0]) #cube([7,32,sheetTh+fudge],true);
    }
