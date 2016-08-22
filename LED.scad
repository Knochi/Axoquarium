$fn=50;
//projection(true){
    LED5();
    translate([0,10,0]) LED5730("blue");
    translate([0,20,0]) PLCC6("blue");
    translate([0,30,0]) res0805();
    translate([0,40,0]) res1210();
    translate([0,50,0]) SOT23();
    translate([0,60,0]) LED3528();
//}

module LED5(col="red",angle=0)
{
    diameter=5;
    leadsLn=25.4; //Anode leg length
    fudge=0.05;
    coneHg=100; //height of the light cone
    coneTopRd=tan(angle/2)*coneHg; //topradius of the cone
    union() {
        //base
        color(col) {
            translate([0,0,fudge])difference() {
                cylinder(d=diameter+0.8,h=1);
                translate([diameter/2+fudge,-diameter/2,-fudge/2]) cube([2,diameter,1+fudge]);
            }
            //body
            translate([0,0,diameter+0.7])sphere(d=diameter);
            translate([0,0,0.7]) cylinder(d=diameter,h=diameter);
        }
        //leads
        color("grey") {
            translate([-1.275,0,-leadsLn/2+fudge/2]) cube([0.5,0.5,leadsLn+fudge],true);
            translate([1.275,0,-(leadsLn-1)/2+fudge/2]) cube([0.5,0.5,leadsLn-1+fudge],true);
        }
    }
    //render the light cone
    if (angle) color(col,0.25) translate([0,0,diameter]) cylinder($fn=10,h=coneHg,r1=0,r2=coneTopRd);
}

//set cooling to 0 to render without cooling fins otherwise it's the width of each fin
module LED5730(col="red", angle=0, cooling=4)
{
    fudge=0.05;
    coneHg=100; //height of the light cone
    coneTopRd=tan(angle/2)*coneHg; //topradius of the cone
    finWd=cooling;
    
    //body
    //color(col)
        %translate([0,0,0.4+fudge]) cube([5.4,3,0.8],true);
    
    //leads
    color("grey") translate([-3,0,0]) cube([1.5,1.7,0.2],true); //bigger for hand soldering
    color("grey") translate([3,0,0]) cube([1.5,1.7,0.2],true); //bigger for hand soldering
    color("grey") translate([0.32,0,0]) 
    
    if (cooling) union(){
        cube([2.25,1.7,0.2],true);
        cube([0.9,5.0,0.2],true);
        difference(){
            translate([-0.32,-1.3-finWd/2,0]) cube([5.7,finWd,0.2],true); //fin
            translate([0,-1.3-0.5,0]) cube([2,1+fudge,0.2+fudge],true);
        }
        difference(){
            translate([-0.32,1.3+finWd/2,0]) cube([5.7,finWd,0.2],true); //fin
            translate([0,1.3+0.5,0]) cube([2,1+fudge,0.2+fudge],true);
        }
    }
    
        
    if (angle) color(col,0.25) translate([0,0,0.2]) cylinder($fn=10,h=coneHg,r1=0,r2=coneTopRd);
}

module PLCC6 (col="red",angle=0)
{
    fudge=0.05;
    coneHg=100; //height of the light cone
    coneTopRd=tan(angle/2)*coneHg; //topradius of the cone
    
    //body
    color(col) translate([0,0,0.8+fudge]) cube([5,5,1.6],true);
    
    //leads
    color("grey") translate([(5.7-1.3)/2,0,0]) cube([1.3,1.3,0.2],true);
    color("grey") translate([-(5.7-1.3)/2,0,0]) cube([1.3,1.3,0.2],true);
    color("grey") translate([(5.7-1.3)/2,(4.6-1.4)/2,0]) cube([1.3,1.4,0.2],true);
    color("grey") translate([-(5.7-1.3)/2,-(4.6-1.4)/2,0]) cube([1.3,1.4,0.2],true);
    color("grey") translate([-(5.7-1.3)/2,(4.6-1.4)/2,0]) cube([1.3,1.4,0.2],true);
    color("grey") translate([(5.7-1.3)/2,-(4.6-1.4)/2,0]) cube([1.3,1.4,0.2],true);
}

module res1210()
{
    //body
    color("black") translate([0,0,0.325]) cube([3.2,2.5,0.55],true);
    //leads
    color("grey") translate([(2.0+1.4)/2,0,0]) cube([1.4,2.8,0.2],true);
    color("grey") translate([-(2.0+1.4)/2,0,0]) cube([1.4,2.8,0.2],true);
    
}

module res0805()
{
    //body
    color("black") translate([0,0,0.325]) cube([2,1.25,0.55],true);
    //leads
    color("grey") translate([(0.65+1.4)/2,0,0]) cube([1.4,1.5,0.2],true);
    color("grey") translate([-(0.65+1.4)/2,0,0]) cube([1.4,1.5,0.2],true);
    
}

module LED3528(col="blue",cooling=4)
{
    fudge=0.05;
    
    //body
    color(col) translate([0,0,0.4+fudge]) cube([3.5,2.8,0.8],true);
    
    //leads    
    color("grey") union(){
        if (cooling) {
            translate([0,-(cooling+2.5+0.9)/2,0]) cube([5,cooling,0.2],true);
            translate([0,(cooling+2.5+0.9)/2,0]) cube([5,cooling,0.2],true);
            cube([0.9,2.5+1.2+fudge,0.2],true);
        }
        difference(){
            cube([5.3,2.5,0.2],true);
            translate([-0.8,0,0]) cube([0.6,2.5+fudge,0.2+fudge],true);
        }
    }
    
}

module SOT23()
{
    //body
    color("black") translate([0,0,0.55]) cube([1.3,2.9,1],true);
    //pads
    color("grey") translate([-1.2,0,0]) cube([1.2,0.9,0.2],true);
    color("grey") translate([1.2,0.95,0]) cube([1.2,0.9,0.2],true);
    color("grey") translate([1.2,-0.95,0]) cube([1.2,0.9,0.2],true);
    
    //label
    translate ([-0.9,-0.3,0]) rotate([0,0,90]) text("C",0.6);
    translate ([1.5,-1.3,0]) rotate([0,0,90]) text("E",0.6);
    translate ([1.5,0.7,0]) rotate([0,0,90]) text("B",0.6);
}
