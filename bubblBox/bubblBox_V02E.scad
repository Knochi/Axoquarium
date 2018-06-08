$fn=100;

bBoxDia=40;
bBoxAng=60;
openAng=bBoxAng/4;
wallThck=2;

legLngth=85;
fltThck=20;
fltRadOffset=20;

fudge=0.1;

filter();
bBox(false);

module filter(){
  linear_extrude(280)
    intersection(){
      translate([-fltRadOffset,-fltRadOffset]) 
        difference(){
        circle(legLngth+fltRadOffset);
          circle(legLngth+fltRadOffset-fltThck);
        }
      square(legLngth+fltRadOffset);
  }
}

module bBox(endCaps=true, meander=true){

  if (meander)
    translate([-fltRadOffset,-fltRadOffset,280]) 
      rotate([90,0,(90-bBoxAng)/2+bBoxAng/1.6]) 
        translate([legLngth+fltRadOffset+bBoxDia,0]) 
          difference(){
            cylinder(h=wallThck,r=bBoxDia-wallThck/2);
            translate([0,bBoxDia*2*0.5,wallThck/2]) cube([bBoxDia*2+fudge,bBoxDia*2+fudge,wallThck+fudge],true);
          }

  //meander 1
  if (meander)
  #translate([-fltRadOffset,-fltRadOffset,280]) 
    rotate([90,0,(90-bBoxAng)/1.5+openAng+3]) 
      translate([legLngth+fltRadOffset+bBoxDia,0]) 
        difference(){
          cylinder(h=wallThck,r=bBoxDia-wallThck/2);
          translate([0,bBoxDia*2*0.5,wallThck/2]) cube([bBoxDia*2+fudge,bBoxDia*2+fudge,wallThck+fudge],true);
        }


  //EndCap 2
  if (endCaps)
  translate([-fltRadOffset,-fltRadOffset,280]) 
    rotate([90,0,(90-bBoxAng)/2+bBoxAng]) 
      translate([legLngth+fltRadOffset+bBoxDia,0]) 
        cylinder(h=wallThck,r=bBoxDia);

  //EndCap 1
  if (endCaps)
  translate([-fltRadOffset,-fltRadOffset,280]) 
    rotate([90,0,(90-bBoxAng)/2]) 
      translate([legLngth+fltRadOffset+bBoxDia,0]) 
        cylinder(h=wallThck,r=bBoxDia);
  
  //pipe
  difference(){
    
    translate([-fltRadOffset,-fltRadOffset,280]) // shift center of rotation back
    rotate([0,0,(90-bBoxAng)/2]) //rotate to center
      rotate_extrude(angle=bBoxAng,convexity=3){ //rotate extrude
        translate([legLngth+fltRadOffset+bBoxDia,0]) //shift the center of rotation 
          difference(){ //the bBox extrusion poly
            circle(bBoxDia);
            circle(bBoxDia-wallThck);
          }
      }
  
  
  //Opening 2
  translate([-fltRadOffset,-fltRadOffset,280-bBoxDia/2])
    rotate([0,0,90-openAng-(90-bBoxAng)/1.5])
      rotate_extrude(angle=openAng,convexity=3) //rotate extrude
        translate([legLngth+fltRadOffset+bBoxDia*2-18,0]) square([40,7],true);
  
  //Opening 1  
  translate([-fltRadOffset,-fltRadOffset,280-bBoxDia/2])
    rotate([0,0,(90-bBoxAng)/1.5])
      rotate_extrude(angle=openAng,convexity=3) //rotate extrude
        translate([legLngth+fltRadOffset+bBoxDia*2-18,0]) square([40,7],true);
      
    }
}