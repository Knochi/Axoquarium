use <LED.scad>
use <MCAD/nuts_and_bolts.scad>

fanth=34;
sheetth=3; //thickness of the top sheet
glasth=5;
$fn=100;
shimwdth=40;
innerwdth=337;
innerlgth=502;
fudge=0.1;


*projection(true)
    rotate([0,90,0])
    tempSens(100,sheetth,0.1,cutChildren=false);
 
 
//the sheet
//projection(true)
    tempSens(100,sheetth,0.1,[ -116.17, 197.54, -1.5 ])

        difference(){
            cube([innerwdth-2,innerlgth,sheetth],true); // Sheet Acryl
                intersection() {
                    cylinder(sheetth+0.1,d=125,center=true);
                    cube([116,116,sheetth+0.1],true);
                }
        4drills(104.8/2,4.5,sheetth);
    }


// the Fan
translate([0,0,fanth/2]) difference() {
   color("grey") cube([119,119,32],true); // 120 fan
   cylinder(fanth+2,d=100 ,center=true); 
   4drills(104.8/2,4.3,fanth);
    
 }

// the shims
 translate([(innerwdth-shimwdth)/2,0,-(sheetth+glasth)/2]) color("LightCyan",0.5) cube([shimwdth,innerlgth,glasth],true);
 translate([-(innerwdth-shimwdth)/2,0,-(sheetth+glasth)/2]) color("LightCyan",0.5) cube([shimwdth,innerlgth,glasth],true);

//the LEDs
translate ([ 0, -120, sheetth/2+3 ]) LEDMatrix(6,3,15,10);
translate ([ 0, 120, sheetth/2+3 ]) LEDMatrix(6,3,15,10);




module 4drills(square,drill,depth){
     translate([square,square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([-square,square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([square,-square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([-square,-square,0]) cylinder(depth+0.1,d=drill,center=true);
}

module LEDMatrix(rows,cols,row_spc,col_spc,res=true){
    cols=cols-1;
    rows=rows-1;
    dim=([(rows-1)*row_spc,(cols-1)*col_spc,0]);
    
    for (i = [-cols/2:cols/2]) { //column   i.e. 3
        for (j = [-rows/2:rows/2]) { //row  i.e. 6
            
            union(){
                translate([i*col_spc,j*row_spc,0])rotate([0,180,0])LED5730("blue",0); //LEDs
                color("grey") translate([i*col_spc-col_spc/2,j*row_spc,0])cube([col_spc-5.7,1,0.2],true); //connection
                
                if (i==cols/2){ //only once per row

                    //#spaces * regular distance + reduced distances                     
                    translate([(cols/2)*col_spc+6,j*row_spc,0]) rotate([0,180,0]) res1210(); //resistor (one per row)
                    translate([(cols/2)*col_spc+10.5,j*row_spc,0]) rotate([0,180,180]) SOT23(); //transistor (one per row)
                    
                    color("grey"){   
                        //#spaces * regular distance + reduced distances
                                                                                 //-5.7 is center, +width of comp
                        translate([(cols/2)*col_spc+3.5,j*row_spc,0])cube([2,1,0.2],true); //connection to res
                        translate([(cols/2)*col_spc+8.5,j*row_spc,0])cube([2,1,0.2],true); //connection to SOT23
                        translate([(cols/2)*col_spc+13.5,j*row_spc+0.95,0])cube([4,1,0.2],true); //connection to PWM-Signal
                        translate([(cols/2)*col_spc+13.5,j*row_spc-0.95,0])cube([4,1,0.2],true); //connection to Gnd
                       
                   } //color
                
                } //if
            } //union traces and pads
        }
        
    }
    
}

module tempSens(cableLen,topSheetTh,fudge=0.1,position=[0,0,0],cutChildren=true) //DS18b2 wired waterproof sensor
{   
    sensLen=50;
    sensDia=6;
    cableDia=4;
    border=10;//border around sensor
    roundness=5;//rounding
    sheetTh=3;
    sheetWd=border*2+sensDia; //width of the sheet holding the sensor without roudness
    sheetHg=border+cableLen+sensLen; //Hight of the sheet holding the sensor without roudness
    
    translate(position) {
        //sensor + cable
        translate([0,0,-cableLen]) union() {
            translate([0,0,-sensLen]) color("lightgrey") cylinder(h=sensLen,d=sensDia); //Sensor
            color("darkslategrey") translate([0,0,-fudge]) cylinder(h=cableLen+fudge*2+topSheetTh,d=cableDia); //cable
        }
        //sheet
        translate()
            union(){
                translate([0,-(sheetWd+cableDia)/4,topSheetTh/2]) cube([sheetTh,6,topSheetTh+fudge],true); //tongue
                translate([0,sheetWd/2-1.5,topSheetTh/2]) cube([sheetTh,3,topSheetTh+fudge],true); //tongue
                
                difference(){
                    minkowski() { //roundings
                        translate([0,0,-sheetHg/2]) 
                            cube([sheetTh-roundness/2,sheetWd-roundness,sheetHg],true); //body
                            rotate([0,90,0]) cylinder(h=roundness/2,d=roundness,center=true); //rounding
                    }
                    
                    translate([0,0,-sensLen/2-cableLen]) cube([sheetTh+fudge,sensDia+fudge,sensLen+fudge],true); //cut for sens
                    translate([0,0,-cableLen/2]) cube([cableDia+fudge,cableDia+fudge,cableLen+fudge+topSheetTh+roundness*2],true); //cut for cable
                    translate([0,0,topSheetTh/2]) cube([sheetTh+fudge,sheetWd+fudge,topSheetTh],true); //cut Top
                    
                    //joinage
                    translate([0,(sheetWd+cableDia)/4,-10]) nutHole(3);
                    translate([0,(sheetWd+cableDia)/4,0]) cube([3+fudge,3+fudge,25],true);
                    
                }
                 %translate([0,(sheetWd+cableDia)/4,topSheetTh]) rotate([180]) boltHole(size=3,length=20);
                 %translate([0,(sheetWd+cableDia)/4,-10]) nutHole(3);
            }
        }
     // placeholders for drills
            if (cutChildren)    
                difference(){
                    children(0);
                    translate(position) {
                        translate([0,0,-fudge/2]) cylinder(h=topSheetTh+fudge,d=cableDia+fudge); //drill for cable                    
                        translate([0,(sheetWd+cableDia)/4,-fudge/2]) cylinder(h=topSheetTh+fudge,d=3+fudge); //drill for bolt
                        //groove
                        translate([0,-(sheetWd+cableDia)/4,topSheetTh/2-fudge/2]) cube([sheetTh+fudge,6+fudge,topSheetTh+fudge],true);
                        translate([0,sheetWd/2-1.5,topSheetTh/2-fudge/2]) cube([sheetTh+fudge,3+fudge,topSheetTh+fudge],true); //tongue
                    }
            }
                
        
        
}

