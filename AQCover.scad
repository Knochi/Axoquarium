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


*projection(true) //the temp sens
    translate([0,0,125])
        //rotate([0,90,0])
            tempSens(100,sheetth,0.1,cutChildren=false);
 
 
//the sheet

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
            color("darkslategrey") translate([0,0,-fudge]) cylinder(h=cableLen+fudge*2+topSheetTh,d=cableDia); //cable
            color("darkslategrey") translate([0,sheetWd/3,-sensLen/2]) cylinder(h=electrHg,d=electrDia,center=true);
            color("darkslategrey") translate([0,-sheetWd/3,-sensLen/2]) cylinder(h=electrHg,d=electrDia,center=true);
        }
        //sheet
        union(){
            translate([0,-(sheetWd+cableDia)/4,topSheetTh/2]) cube([sheetTh,6,topSheetTh+fudge],true); //tongue
            translate([0,sheetWd/2-1.5,topSheetTh/2]) cube([sheetTh,3,topSheetTh+fudge],true); //tongue
                
            
            difference(){
                minkowski() { //roundings
                    translate([0,0,-sheetHg/2]) 
                        cube([sheetTh-roundness/2,sheetWd-roundness,sheetHg],true); //body
                        rotate([0,90,0]) cylinder(h=roundness/2,d=roundness,center=true); //rounding
                }
                // ------ Free Cuts ------
                
                // Sensor + cable
                translate([0,0,-sensLen/2-cableLen]) cube([sheetTh+fudge,sensDia+fudge,sensLen+fudge],true); //Sensor
                translate([0,0,-cableLen/2]) cube([cableDia+fudge,cableDia+fudge,cableLen+fudge+topSheetTh+roundness*2],true); //cable
                
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
                translate([0,0,topSheetTh/2]) cube([sheetTh+fudge,sheetWd+fudge,topSheetTh],true); //cut TopSheet
                
                //nudges for holder
                translate([(-sheetTh-fudge)/2,sheetWd/2-clipsTh/2,-sensLen/2-cableLen-(sheetTh+fudge)/2]) 
                    cube([sheetTh+fudge,clipsTh/2+fudge,sheetTh+fudge]);//right
                translate([(-sheetTh-fudge)/2,(-sheetWd-fudge)/2,-sensLen/2-cableLen-(sheetTh+fudge)/2]) 
                    cube([sheetTh+fudge,clipsTh/2+fudge,sheetTh+fudge]);//left
                
            } //difference
             %translate([0,(sheetWd+cableDia)/4,topSheetTh]) rotate([180]) boltHole(size=3,length=20);
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
                        translate([0,0,-fudge/2]) cylinder(h=topSheetTh+fudge,d=cableDia+fudge); //drill for cable                    
                        translate([0,(sheetWd+cableDia)/4,-fudge/2]) cylinder(h=topSheetTh+fudge,d=3+fudge); //drill for bolt
                        //groove
                        translate([0,-(sheetWd+cableDia)/4,topSheetTh/2-fudge/2]) cube([sheetTh+fudge,6+fudge,topSheetTh+fudge],true);
                        translate([0,sheetWd/2-1.5,topSheetTh/2-fudge/2]) cube([sheetTh+fudge,3+fudge,topSheetTh+fudge],true); //tongue
                    }
            }
            
                
                
        
        
}

