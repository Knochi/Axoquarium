pos=10;
outLen=2.54*pos/2+7.62;
inLen=2.54*pos/2+5.42;
outWidth=8.9; //outer dimension width
inWidth=6.5; //inner dimension width
wallThickLen=(outWidth-inWidth)/2; //wall thickness in length
wallThickWidth=(outWidth-inWidth)/2; //wall thickness in width

inHeight=6.4;
outHeight=9;
fudge=0.1;

firstPinPos=-(2.54*(pos/2-1))/2;
echo(firstPinPos);

color("darkgrey") difference(){
    translate([0,0,9/2]) cube([outWidth,outLen,outHeight],true); //outer
    translate([0,0,6.4/2+9-6.4+fudge/2]) cube([6.5,inLen,inHeight+fudge],true); //inner
    translate([(6.5+wallThickWidth)/2+fudge/4,0,6.4/2+9-6.4+fudge/2]) cube([wallThickWidth+fudge,4.5,inHeight+fudge],true); //locking
    translate([0,(inLen+wallThickLen)/2,inHeight/2]) cube([3.5,wallThickLen+fudge,inHeight+fudge],true); //grasps
    translate([0,-(inLen+wallThickLen)/2,inHeight/2]) cube([3.5,wallThickLen+fudge,inHeight+fudge],true); //grasps
}
for (i=[0:pos/2-1]){
    echo (i);
    translate([-1.27,firstPinPos+i*2.54,11.6/2-3]) cube([0.64,0.64,11.6],true);
    translate([1.27,firstPinPos+i*2.54,11.6/2-3]) cube([0.64,0.64,11.6],true);
}