use <LED.scad>
use <MCAD/nuts_and_bolts.scad>
use <LatticeHinge.scad>
$fn=100;
pi = 3.14159265;
fanTh=34;
sheetTh=6; //thickness of the base sheet
topHg= fanTh + 10; //Hight of the case
topTh = 3; //thickness of Top sheet
glasth=5; //thickness of the glass

// side cover
sideTh=6; //thickness of side sheet
sideR1=18.85; //radius of the top edge
sideR2=1; //radius of the lower edge
sideAlpha=45;// angle of front

bendW=(sideR1+topTh/2)*(pi/180)*sideAlpha; //width of the bend including "stretched length"

sideY = topHg - sideR1 - sideR2; //

sideX1= sideR1/cos(sideAlpha);  //HYP=AK/cos(alpha)
sideX2= sideR2/cos(sideAlpha);  //HYP=AK/cos(alpha)
sideX3= tan(sideAlpha)*sideY;   //GK=tan(alpha)*AK
sideX = sideX1 +  sideX2 + sideX3;

sideA1= tan(sideAlpha)*sideR1;  //GK=tan(alpha)*AK
sideA2= sideY/cos(sideAlpha);   //HYP=AK/cos(alpha)
sideA3= tan(sideAlpha)*sideR2;  //GK=tan(alpha)*AK
sideA = sideA1+sideA2+sideA3; //length of the tangent



echo(sideY);

// Aquarium Dimensions
shimwdth=40; //width of the shims
innerwdth=337; //inner width of the aquarium above the shims
innerlgth=502; //length of the cover/shims
fudge=0.1;

echo([ 107.00, -255.92, 48.56 ]-[ 121.95, -242.14, 49.07 ]);

*projection(true) //the temp sens
    translate([0,0,125])
        //rotate([0,90,0])
            tempSens(100,sheetTh,0.1,cutChildren=false);
*projection(true) {
    LEDMatrix(6,3,12,10);
    rotate([0,0,-90]) LEDMatrix(2,3,10,24,LEDs=3528);
}

*projection() 
    rotate([-90,0,0]) sideWall();

*projection() cover();
 
//the sheet with cutout for tempSens
tempSens(100,sheetTh,0.1,[ -116.17, 197.54, -1.5 ])

        difference(){
            cube([innerwdth-2,innerlgth,sheetTh],true); // Sheet Acryl
                intersection() { //cutout for fan
                    cylinder(sheetTh+0.1,d=125,center=true); 
                    cube([116,116,sheetTh+0.1],true); 
                }
        4drills(104.8/2,4.5,sheetTh);
    }

//side walls
// 4 cylinders with hull?


color("grey") sideWall();
   
    
//surface with lattice hinge
color("lightgrey") cover();

// the Fan
translate([0,0,fanTh/2+sheetTh/2]) difference() {
   color("grey") cube([119,119,fanTh],true); // 120 fan
   cylinder(fanTh+2,d=100 ,center=true); 
   4drills(104.8/2,4.3,fanTh);
    
 }

// the shims
 translate([(innerwdth-shimwdth)/2,0,-(sheetTh+glasth)/2]) color("LightCyan",0.5) cube([shimwdth,innerlgth,glasth],true);
 translate([-(innerwdth-shimwdth)/2,0,-(sheetTh+glasth)/2]) color("LightCyan",0.5) cube([shimwdth,innerlgth,glasth],true);

//the LEDs
*translate ([ 0, -140, sheetTh/2+3 ]) rotate([0,0,180]) LEDMatrix(6,3,12,10);
*translate ([ 0, 140, sheetTh/2+3 ]) LEDMatrix(6,3,12,10);
*translate ([ 0,140, sheetTh/2+2.4]) rotate([0,0,-90]) LEDMatrix(2,3,10,24,LEDs=3528);


module sideWall(){
    hull(){
        translate([innerwdth/2-sideX-topTh,-innerlgth/2+sideTh/2,sheetTh/2+sideY+sideR2])
            rotate([90,0,0]) 
                intersection(){
                    cylinder(h=sideTh,r=sideR1,center=true);
                    translate([0,sideR1/2,0]) 
                        cube([sideR1*2+fudge,sideR1+fudge,5],true);
                }
                
        translate([-(innerwdth/2-sideR1-topTh),-innerlgth/2+sideTh/2,sheetTh/2+sideY+sideR2])
            rotate([90,0,0]) 
                intersection(){
                    cylinder(h=sideTh,r=sideR1,center=true);
                    translate([0,sideR1/2,0]) 
                        cube([sideR1*2+fudge,sideR1+fudge,5],true);
                }
        
        translate([-(innerwdth/2-sideR2-topTh),-innerlgth/2+sideTh/2,sheetTh/2+sideR2]) rotate([90,0,0]) cylinder(h=sideTh,r=sideR2,center=true);
        translate([innerwdth/2-sideR2-topTh,-innerlgth/2+sideTh/2,sheetTh/2+sideR2]) rotate([90,0,0]) cylinder(h=sideTh,r=sideR2,center=true);
        }//hull
        
}//module

module cover(){
 translate([0,0,topHg+(sheetTh+topTh)/2]) {
    //cube([innerwdth-sideX*2+bendW*2+sideA*2,innerlgth,topTh],center=true);
    difference(){
        translate([0,-(innerlgth-48)/2,0]) cube([innerwdth-sideX*2+bendW*2+sideA*2,48,topTh],center=true);
        translate([innerwdth/2-sideX+bendW,-innerlgth/2,0])rotate([0,0,90]) slotter();
        translate([-innerwdth/2+sideX,-innerlgth/2,0])rotate([0,0,90]) slotter();
    }
}
}

module 4drills(square,drill,depth){
     translate([square,square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([-square,square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([square,-square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([-square,-square,0]) cylinder(depth+0.1,d=drill,center=true);
}

module LEDMatrix(rows,cols,row_spc,col_spc,res=true, LEDs=5730){
    cols=cols-1;
    rows=rows-1;
    dim=([(rows-1)*row_spc,(cols-1)*col_spc,0]);
    
    for (i = [-cols/2:cols/2]) { //column   i.e. 3
        for (j = [-rows/2:rows/2]) { //row  i.e. 6
            
            union(){
                if (LEDs==5730){ translate([i*col_spc,j*row_spc,0])rotate([0,180,0])LED5730("orange",0); //LEDs
                    color("grey") translate([i*col_spc-col_spc/2,j*row_spc,0])cube([col_spc-5.7,1,0.2],true); //connection
                }
                if (LEDs==3528){ translate([i*col_spc,j*row_spc,0])rotate([0,180,0])LED3528("orange",3); //LEDs
                    color("grey") translate([i*col_spc-col_spc/2,j*row_spc,0])cube([col_spc-4,1,0.2],true); //connection
                }
                if (i==cols/2){ //only once per row

                    //#spaces * regular distance + reduced distances                     
                    translate([(cols/2)*col_spc+6,j*row_spc,0]) rotate([0,180,0]) res1210(); //resistor (one per row)
                    translate([(cols/2)*col_spc+10.5,j*row_spc,0]) rotate([0,180,180]) SOT23(); //transistor (one per row)
                    translate([(cols/2)*col_spc+13.5,j*row_spc-2,0]) rotate([0,180,90]) res0805(); //Base Resistor (one per row)
                    
                    
                    color("grey"){ //traces
                        //#spaces * regular distance + reduced distances
                                                                                 //-5.7 is center, +width of comp
                        translate([(cols/2)*col_spc+3.5,j*row_spc,0])cube([2,1,0.2],true); //connection to res
                        translate([(cols/2)*col_spc+8.5,j*row_spc,0])cube([2,1,0.2],true); //connection to SOT23
                        
                        translate([(cols/2)*col_spc+12.75,j*row_spc-0.95,0])cube([2.5,1,0.2],true); //connection to Base resistor
                        translate([(cols/2)*col_spc+12.75,j*row_spc-3.05,0])cube([2.5,1,0.2],true); //connection to PWM signal
                        translate([(cols/2)*col_spc+10.7,j*row_spc-3.05,0])cylinder(h=0.2,r=1,center=true); //Solder Pad for PWM signal
                        
                        translate([(cols/2)*col_spc+13.5,j*row_spc+0.95,0])cube([4,1,0.2],true); //connection to Gnd
                        translate([-(cols)*col_spc+3.6,j*row_spc+row_spc/2-0.5,0])cube([2,row_spc+fudge,0.2],true); //inter-connection to Vcc
                        translate([(cols/2)*col_spc+16,j*row_spc+row_spc/2-1.4,0])cube([2,row_spc+fudge,0.2],true); //inter-connection to Gnd
                   } //color
                
                } //if
            } //union traces and pads
        }
        
    }
    
}

module tempSens(cableLen,topsheetTh,fudge=0.1,position=[0,0,0],cutChildren=true) //DS18b2 wired waterproof sensor
{   
    //Sensor and Cable Geometry
    sensLen=50;
    sensDia=6;
    cableDia=4;
    insulatTh=0.5; //Thickness of Insulation Tube adder to Diameter
    insulatLnSens=17; //Height of Insulation Tube on Sensor
    insulatLnCable=22; //Height of Insulation Tube on Cable
    
    //body geometry
    border=10;//border around sensor
    roundness=5;//rounding
    sheetTh=3;
    sheetWd=border*2+sensDia; //width of the sheet holding the sensor without roudness
    sheetHg=border+cableLen+sensLen; //Hight of the sheet holding the sensor without roudness
    clipsTh=2; //thickness for clips
    
    //electrodes
    electrHg=16; //height of electrodes
    electrDia=2; //Diameter of electrodes
    
    translate(position) {
        //sensor + cable
        translate([0,0,-cableLen]) union() {
            translate([0,0,-sensLen]) color("lightgrey") cylinder(h=sensLen,d=sensDia); //Sensor
            translate([0,0,-insulatLnSens+fudge]) color("SlateGray") cylinder(h=insulatLnSens,d=sensDia+insulatTh); //Insulate on Sens
            translate([0,0,-fudge]) color("SlateGray") cylinder(h=insulatLnCable,d=cableDia+insulatTh); //Insulate on Cable
            color("darkslategrey") translate([0,0,-fudge]) cylinder(h=cableLen+fudge*2+topsheetTh,d=cableDia); //cable
            color("darkslategrey") translate([0,sheetWd/3,-sensLen/2]) cylinder(h=electrHg,d=electrDia,center=true);
            color("darkslategrey") translate([0,-sheetWd/3,-sensLen/2]) cylinder(h=electrHg,d=electrDia,center=true);
        }
        //sheet
        union(){
            translate([0,-(sheetWd+cableDia)/4,topsheetTh/2]) cube([sheetTh,6,topsheetTh+fudge],true); //tongue
            translate([0,sheetWd/2-1.5,topsheetTh/2]) cube([sheetTh,3,topsheetTh+fudge],true); //tongue
                
            
            difference(){
                minkowski() { //roundings
                    translate([0,0,-sheetHg/2]) 
                        cube([sheetTh-roundness/2,sheetWd-roundness,sheetHg],true); //body
                        rotate([0,90,0]) cylinder(h=roundness/2,d=roundness,center=true); //rounding
                }
                // ------ Free Cuts ------
                
                // Sensor + cable
                translate([0,0,-sensLen/2-cableLen]) cube([sheetTh+fudge,sensDia+fudge,sensLen+fudge],true); //Sensor
                translate([0,0,-cableLen/2]) cube([cableDia+fudge,cableDia+fudge,cableLen+fudge+topsheetTh+roundness*2],true); //cable
                
                //Insulation
                translate([0,0,-cableLen-insulatLnSens/2+fudge]) 
                    cube([sheetTh+fudge,sensDia+insulatTh+fudge,insulatLnSens+fudge],true); //Insulate on Sens
                translate([0,0,-cableLen+insulatLnCable/2-fudge]) 
                    cube([sheetTh+fudge,cableDia+insulatTh+fudge,insulatLnCable+fudge],true); //Insulate on cable
                  
           
                //Conductivity Elektrodes
                translate([0,sheetWd/3,-sensLen/2-cableLen]) cube([sheetTh+fudge,electrDia+fudge,electrHg+fudge],true);//right
                translate([0,-sheetWd/3,-sensLen/2-cableLen]) cube([sheetTh+fudge,electrDia+fudge,electrHg+fudge],true);//left
                
                //joinage to top sheet
                translate([0,(sheetWd+cableDia)/4,-10]) nutHole(3); //nut
                translate([0,(sheetWd+cableDia)/4,0]) cube([3+fudge,3+fudge,25],true);//bolt
                translate([0,0,topsheetTh/2]) cube([sheetTh+fudge,sheetWd+fudge,topsheetTh],true); //cut TopSheet
                
                //nudges for holder
                translate([(-sheetTh-fudge)/2,sheetWd/2-clipsTh/2,-sensLen/2-cableLen-(sheetTh+fudge)/2]) 
                    cube([sheetTh+fudge,clipsTh/2+fudge,sheetTh+fudge]);//right
                translate([(-sheetTh-fudge)/2,(-sheetWd-fudge)/2,-sensLen/2-cableLen-(sheetTh+fudge)/2]) 
                    cube([sheetTh+fudge,clipsTh/2+fudge,sheetTh+fudge]);//left
                
            } //difference
             %translate([0,(sheetWd+cableDia)/4,topsheetTh]) rotate([180]) boltHole(size=3,length=20);
             %translate([0,(sheetWd+cableDia)/4,-10]) nutHole(3);
            } //union
            
            //the holder
            *translate ([0,0,-sensLen/2-cableLen]) 
                union(){
                    difference(){
                    //holder body
                        minkowski() {
                            cube([sheetTh*border/3-roundness,sheetWd+6-roundness,sheetTh-roundness/2],true);
                            cylinder(h=roundness/2,d=roundness,center=true); //rounding
                        }
                    
                        *cylinder(h=sheetTh,d1=sheetWd*1.2,d2=sheetWd*1.2,center=true);
                        
                        //Sensor
                        cylinder(h=sensLen+fudge,d=sensDia+fudge,center=true);
                        cube([sheetTh-1,sensDia+fudge,sensLen+fudge],true); //cut sharp edges
                        
                        //Electrodes
                        translate([0,sheetWd/3,0]) cylinder(h=electrHg+fudge,d=electrDia+fudge,center=true);//right
                        translate([0,-sheetWd/3,0]) cylinder(h=electrHg+fudge,d=electrDia+fudge,center=true); //left
                        translate([0,sheetWd/3,0]) cube([sheetTh-1.2,electrDia+fudge,electrHg+fudge],true);//right
                        translate([0,-sheetWd/3,0]) cube([sheetTh-1.2,electrDia+fudge,electrHg+fudge],true);//left
                        
                        //BodySheet
                        translate([(-sheetTh-fudge)/2,sheetWd/3+electrDia/2,-sheetTh]) 
                            cube([sheetTh+fudge,sheetWd/2-sheetWd/3-clipsTh/2-electrDia/2+fudge,sheetTh*2]);
                        translate([(-sheetTh-fudge)/2,clipsTh/2-(sheetWd+fudge)/2,-sheetTh])                                               
                            cube([sheetTh+fudge,sheetWd/2-sheetWd/3-clipsTh/2-electrDia/2+fudge,sheetTh*2]);
                        translate([(-sheetTh-fudge)/2,sensDia/2,-sheetTh]) cube([sheetTh+fudge,sheetWd/3-sensDia/2-electrDia/2,sheetTh*2]);
                        translate([(-sheetTh-fudge)/2,-sheetWd/3+electrDia/2,-sheetTh]) cube([sheetTh+fudge,sheetWd/3-sensDia/2-electrDia/2,sheetTh*2]);
                        
                        //cut in half
                        //translate([sheetWd*1.2/4,0,0])cube([sheetWd*1.2/2+fudge,sheetWd*1.2,sheetTh+fudge],true);
                        
                        //joinage
                    
                } //difference
//                
            }//union
                
            
            
        } //position
        
        
     // placeholders for drills
            if (cutChildren)    
                difference(){
                    children(0);
                    translate(position) {
                        translate([0,0,-fudge/2]) cylinder(h=topsheetTh+fudge,d=cableDia+fudge); //drill for cable                    
                        translate([0,(sheetWd+cableDia)/4,-fudge/2]) cylinder(h=topsheetTh+fudge,d=3+fudge); //drill for bolt
                        //groove
                        translate([0,-(sheetWd+cableDia)/4,topsheetTh/2-fudge/2]) cube([sheetTh+fudge,6+fudge,topsheetTh+fudge],true);
                        translate([0,sheetWd/2-1.5,topsheetTh/2-fudge/2]) cube([sheetTh+fudge,3+fudge,topsheetTh+fudge],true); //tongue
                    }
            }
            
                
                
        
        
}

