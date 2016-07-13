sheetWd=26;
sheetTh=3;
fudge=0.1;

//--- hook parametes --
a=2;
l=sheetTh;
d=1;

bevel=tan(45)*d;

translate([0,10,-sheetTh/2]) 
    linear_extrude(sheetTh) 
        polygon([[0,0],[0,l],[-d,l+bevel],[-d,l*2-bevel],[0,l*2],[a,l*2],[a,0]]);

difference(){
    cylinder(h=sheetTh,d=sheetWd*1.2,center=true);
    
    //cut half
    translate([-(sheetWd*1.2+fudge)/2, 0,-(sheetTh+fudge)/2]) cube([sheetWd*1.2+fudge,sheetWd*1.2/2+fudge,sheetTh+fudge]);
}

intersection(){
    cylinder(h=sheetTh,d=sheetWd*1.2,center=true);
    translate([sheetWd*1.2/2-a,0,-(sheetTh+fudge)/2])
   #    linear_extrude(sheetTh+fudge) 
        polygon([[0,0],[0,l],[-d,l+bevel],[-d,l*2-bevel],[0,l*2],[a,l*2],[a,0]]);
}