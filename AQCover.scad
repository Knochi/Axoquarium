//Enter OpenSCAD code here.
 echo("Version:",version());
fanth=34;
sheetth=3;
glasth=5;
$fn=100;
shimwdth=40;
innerwdth=337;
innerlgth=502;

//the sheet
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




module 4drills(square,drill,depth){
     translate([square,square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([-square,square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([square,-square,0]) cylinder(depth+0.1,d=drill,center=true);
   translate([-square,-square,0]) cylinder(depth+0.1,d=drill,center=true);
}

module LEDMatrix(rows,cols){
    //forfor
        translate([3,-3,21.15]) rotate([0,180,0]) color("lightgrey") import("led-5mm.STL");
}