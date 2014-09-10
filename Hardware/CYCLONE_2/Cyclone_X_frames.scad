// This file is part of Cyclone PCB Factory: an open-source 3D printable CNC machine for PCB manufacture
// http://reprap.org/wiki/Cyclone_PCB_Factory
// Original author: Carlosgs (http://carlosgs.es)
// License: CC BY-SA 4.0 (Attribution-ShareAlike 4.0 International, http://creativecommons.org/licenses/by-sa/4.0/)
// Designed with http://www.openscad.org/


Xmotor_sideLen = 42.20;

axes_XgearSeparation = 37;
axes_XgearRatio = 21/21; // Number of tooth (motor/rod)
axes_XgearThickness = 10;

X_frames_additional_thickness = 5;

module Cyclone_X_rightFrame() {
	scale([-1,1,1]) Cyclone_X_leftFrame(isLeft=false);
}

include <MCAD/stepper.scad>
module Cyclone_X_leftFrame(isLeft=true) {
	
	screwSize = 3; // M3, M4, etc (integers only)
	
	motorWallSeparation = 5;
	motorRotatedOffset = 10;
	gearWallSeparation = 5;
	
	partThickness = X_frames_additional_thickness+screwSize*2;
	
	dimX = partThickness;
	dimY = max(-axes_Xreference_posY,axes_Xsmooth_separation+axes_XgearSeparation*cos(motorRotatedOffset)+Xmotor_sideLen/2+2);
	dimZ = axes_Yreference_height+axes_Xreference_height+axes_Xsmooth_separation;
	
	
	footSeparation = screwSize*3;
	footThickness = 10;
	footWidth = dimX+2*footSeparation;
	
	bearingDepth = 3;
	
	corner_radius = 10;
	
	
	module Cyclone_XsubPart_gearCover() {
		margin = 4;
		rodGearAddedMargin = 1;
		wallThickness = 0.4*4;
		screwHeadSpaceHeight = 4;
		screwHeadSpaceDiam = 7;
		coverHeight = 16;
		coverExtraHeight = 5;
		coverExtraRadius = -7;
		nema_screw_separation = lookup(NemaDistanceBetweenMountingHoles, Nema17);
		
		motorGearRadius = axes_XgearSeparation/(1+axes_XgearRatio)+margin;
		rodGearRadius = axes_XgearSeparation/(1+1/axes_XgearRatio)+margin+rodGearAddedMargin;
		
		difference() {
			union() {
				// Cover for the rod gear
				rotate([0,90,0])
					cylinder(r=rodGearRadius+wallThickness, h=coverHeight);
				translate([coverHeight,0,0])
					rotate([0,90,0])
						cylinder(r1=rodGearRadius+wallThickness, r2=rodGearRadius+wallThickness+coverExtraRadius, h=coverExtraHeight+wallThickness);
				// Translate to motor position
				rotate([motorRotatedOffset,0,0]) {
					translate([0,axes_XgearSeparation,0])
						rotate([-motorRotatedOffset,0,0]) {
							// Cover for the motor gear
							rotate([0,90,0]) cylinder(r=motorGearRadius+wallThickness, h=coverHeight);
							translate([coverHeight,0,0])
								rotate([0,90,0]) cylinder(r1=motorGearRadius+wallThickness, r2=motorGearRadius+wallThickness+coverExtraRadius, h=coverExtraHeight+wallThickness);
							// Cylinder for the support screw
							translate([0,-nema_screw_separation/2,nema_screw_separation/2])
								rotate([0,90,0]) cylinder(r=screwHeadSpaceDiam/2+wallThickness, h=coverHeight);
						}
				}
			}
			translate([-0.02,0,0])
				union() {
					// Hole for the rod gear
					rotate([0,90,0])
						cylinder(r=rodGearRadius, h=coverHeight);
					translate([coverHeight-0.02,0,0])
						rotate([0,90,0])
							cylinder(r1=rodGearRadius, r2=rodGearRadius+coverExtraRadius, h=coverExtraHeight);
					rotate([0,90,0])
						cylinder(r=rodGearRadius+coverExtraRadius, h=coverHeight+coverExtraHeight+wallThickness+0.1);
					// Translate to motor position
					rotate([motorRotatedOffset,0,0]) {
						translate([0,axes_XgearSeparation,0])
							rotate([-motorRotatedOffset,0,0]) {
								difference() {
									union() {
										// Hole for the motor gear
										rotate([0,90,0]) cylinder(r=motorGearRadius, h=coverHeight);
										translate([coverHeight-0.02,0,0])
											rotate([0,90,0]) cylinder(r1=motorGearRadius, r2=motorGearRadius+coverExtraRadius, h=coverExtraHeight);
										rotate([0,90,0]) cylinder(r=motorGearRadius+coverExtraRadius, h=coverHeight+coverExtraHeight+wallThickness+0.1);
										// Outer hole for the support screw
										translate([0,-nema_screw_separation/2,nema_screw_separation/2])
											rotate([0,90,0]) cylinder(r=screwHeadSpaceDiam/2, h=coverHeight+coverExtraHeight);
									}
									// Support screw holder
									translate([0,-nema_screw_separation/2,nema_screw_separation/2])
										rotate([0,90,0]) cylinder(r=screwHeadSpaceDiam/2+wallThickness, h=wallThickness);
								}
								// Inner hole for the support screw
								translate([0,-nema_screw_separation/2,nema_screw_separation/2])
									rotate([0,90,0]) cylinder(r=(screwSize+1)/2, h=coverHeight+0.1);
								// Holes for the other two screws
								translate([0,nema_screw_separation/2,-nema_screw_separation/2])
									rotate([0,90,0]) cylinder(r=screwHeadSpaceDiam/2, h=screwHeadSpaceHeight);
								translate([0,-nema_screw_separation/2,-nema_screw_separation/2])
									rotate([0,90,0]) cylinder(r=screwHeadSpaceDiam/2, h=screwHeadSpaceHeight);
							}
					}
				}
		}
	}
	
	
	module Cyclone_X_endstopHolder(holes=false) {
		// Endstop holder
		translate([-partThickness-0.04,19,-5+axes_Xsmooth_separation])
			rotate([-60,0,0]) {
				rotate([0,0,-90]) mirror([1,0,0]) endstop_holder(holes, shortNuts=true);
				if(holes)
					cube([partThickness+1,100,50]);
			}
	}
	
	
	difference() {
		// Main block
		union() {
			translate([-axes_Xreference_posX-dimX-0.01,axes_Xreference_posY,-axes_Yreference_height]) {
				cube([dimX,dimY,dimZ-axes_Xsmooth_separation]);
				translate([-footWidth/2+dimX,dimY/2,footThickness/2]) bcube([footWidth,dimY,footThickness], cr=corner_radius, cres=10);
			}
			rodHolder(rodD=axes_Ysmooth_rodD, screwSize=screwSize, height=axes_Yreference_height, sideLen=-axes_Xreference_posX-1);
			// TRANSLATE REFERENCE POSITION to the left frame, X lower smooth rod end
			translate([-axes_Xreference_posX,axes_Xreference_posY,axes_Xreference_height]) {
				// TRANSLATE REFERENCE POSITION to the threaded rod
				translate([-0.01,axes_Xsmooth_separation,0]) {
					rotate([0,-90,0]) cylinder(r=axes_Xsmooth_separation,h=partThickness);
					if(!isLeft) 
						Cyclone_X_endstopHolder(holes=false);
				}
			}
		}
		
		// TRANSLATE REFERENCE POSITION to the left frame, X lower smooth rod end
		translate([-axes_Xreference_posX,axes_Xreference_posY,axes_Xreference_height]) {
			rotate([0,0,90]) standard_rod(diam=axes_Xsmooth_rodD, length=partThickness*4, threaded=false, renderPart=true, center=true);
			rotate([0,0,-90])
				rotate([0,90,0])
					rodHolder(rodD=axes_Xsmooth_rodD, screwSize=screwSize, negative=true);
			// TRANSLATE REFERENCE POSITION to the threaded rod
			translate([+0.01,axes_Xsmooth_separation,0]) {
				// Plastic saving holes
				translate([0,-15,-40]) rotate([0,-90,0]) cylinder(r=15,h=partThickness*2);
				translate([0,30,-40]) rotate([0,-90,0]) cylinder(r=15,h=partThickness*2);
				translate([0,-15,-80]) rotate([0,-90,0]) cylinder(r=15,h=partThickness*2);
				rotate([0,-90,0]) bearingHole(depth=bearingDepth, thickness=partThickness);
				
				// Translate to motor position
				if(isLeft)
					translate([-motorWallSeparation,0,0])
					rotate([motorRotatedOffset,0,0])
						translate([0,axes_XgearSeparation,0])
							rotate([-motorRotatedOffset,0,0])
								rotate([0,90,0]) stepperMotor_mount(motorWallSeparation, sideLen=Xmotor_sideLen, slideOut=true);
			// Endstop holder
			if(!isLeft) 
						Cyclone_X_endstopHolder(holes=true);
			
			translate([0,0,axes_Xsmooth_separation]) {
				rotate([0,0,90]) standard_rod(diam=axes_Xsmooth_rodD, length=partThickness*4, threaded=false, renderPart=true, center=true);
				rotate([0,0,-90])
					rodHolder(rodD=axes_Xsmooth_rodD, screwSize=screwSize, negative=true);
			}
			}
		}
		// Holes for the screws
		translate([-axes_Xreference_posX-dimX-footSeparation,axes_Xreference_posY+footSeparation,-axes_Yreference_height+footThickness]) {
			rotate([0,90,0])
					rotate([0,0,90])
						hole_for_screw(size=screwSize,length=footThickness+base_thickness,nutDepth=0,nutAddedLen=0,captiveLen=0, invert=true);
			translate([0,dimY/2,0])
				rotate([0,90,0])
						rotate([0,0,90])
							hole_for_screw(size=screwSize,length=footThickness+base_thickness,nutDepth=0,nutAddedLen=0,captiveLen=0, invert=true);
			translate([0,dimY-2*footSeparation,0])
				rotate([0,90,0])
						rotate([0,0,90])
							hole_for_screw(size=screwSize,length=footThickness+base_thickness,nutDepth=0,nutAddedLen=0,captiveLen=0, invert=true);
		}
	}
	
	// Draw rod holders, motor, gears, screws
	// TRANSLATE REFERENCE POSITION to the left frame, X lower smooth rod end
	translate([-axes_Xreference_posX,axes_Xreference_posY,axes_Xreference_height]) {
		if(draw_references) color("red") %frame(20);
		rotate([0,0,-90])
			rotate([0,90,0])
				rodHolder(rodD=axes_Ysmooth_rodD, screwSize=screwSize);
		// TRANSLATE REFERENCE POSITION to the threaded rod
		translate([0,axes_Xsmooth_separation,0]) {
			if(draw_references) color("green") %frame(20);
			translate([-bearingDepth,0,0]) rotate([0,90,0])
				radialBearing(echoPart=true);
			if(isLeft) {
				translate([gearWallSeparation,0,0]) rotate([0,90,0])
					rodGear(r=axes_XgearSeparation/(1+1/axes_XgearRatio), h=axes_XgearThickness, echoPart=true);
				// Translate to motor position
				rotate([motorRotatedOffset,0,0]) {
					translate([0,axes_XgearSeparation,0])
						rotate([-motorRotatedOffset,0,0]) {
							translate([-motorWallSeparation,0,0]) rotate([0,90,0]) stepperMotor(screwHeight=motorWallSeparation, echoPart=true);
							translate([gearWallSeparation,0,0]) rotate([0,90,0]) motorGear(r=axes_XgearSeparation/(1+axes_XgearRatio), h=axes_XgearThickness, echoPart=true);
						}
				}
				translate([0.1,0,0])
					Cyclone_XsubPart_gearCover();
			}
			translate([0,0,axes_Xsmooth_separation])
				rotate([0,0,-90])
					rodHolder(rodD=axes_Ysmooth_rodD, screwSize=screwSize);
		}
	}
	translate([-axes_Xreference_posX-dimX-footSeparation,axes_Xreference_posY+footSeparation,-axes_Yreference_height+footThickness]) {
		rotate([0,90,0])
				rotate([0,0,90])
					screw_and_nut(size=screwSize,length=footThickness+base_thickness,nutDepth=0,nutAddedLen=0,captiveLen=0, invert=true, autoNutOffset=true, echoPart=true);
		translate([0,dimY/2,0])
			rotate([0,90,0])
					rotate([0,0,90])
						screw_and_nut(size=screwSize,length=footThickness+base_thickness,nutDepth=0,nutAddedLen=0,captiveLen=0, invert=true, autoNutOffset=true, echoPart=true);
		translate([0,dimY-2*footSeparation,0])
			rotate([0,90,0])
					rotate([0,0,90])
						screw_and_nut(size=screwSize,length=footThickness+base_thickness,nutDepth=0,nutAddedLen=0,captiveLen=0, invert=true, autoNutOffset=true, echoPart=true);
	}
}






module rodHolder(rodD=8.5, screwSize=3, height=0, sideLen=0, thickness=5, space=2, negative=false) {
	screwAditionalDistance = rodD/2;
	dimX = rodD+4*screwSize+screwAditionalDistance;
	dimY = X_frames_additional_thickness+screwSize*2;
	dimZ = rodD/2+thickness;
	
	corner_radius = 4;
	
	if(negative) {
		translate([screwSize+screwAditionalDistance,-dimY/2,dimZ])
			rotate([-90,0,0])
				rotate([0,0,180])
					hole_for_screw(size=screwSize,length=dimZ+15,nutDepth=5,nutAddedLen=0,captiveLen=10, rot=90);
		translate([-screwSize-screwAditionalDistance,-dimY/2,dimZ])
			rotate([-90,0,0])
				rotate([0,0,180])
					hole_for_screw(size=screwSize,length=dimZ+15,nutDepth=5,nutAddedLen=0,captiveLen=10, rot=90);
	} else {
		difference() {
			union() {
				translate([0,-dimY/2,dimZ/2+space/4]) bcube([dimX,dimY,dimZ-space/2],cr=corner_radius,cres=10);
				if(sideLen>dimX/2)
					translate([sideLen/2-dimX/4,-dimY/2,-height/2-space/4]) bcube([dimX/2+sideLen,dimY,height-space/2],cr=corner_radius,cres=10);
				else
					translate([0,-dimY/2,-height/2-space/4]) bcube([dimX,dimY,height-space/2],cr=corner_radius,cres=10);
			}
			translate([screwSize+screwAditionalDistance,-dimY/2,dimZ])
				rotate([-90,0,0])
					rotate([0,0,180])
						hole_for_screw(size=screwSize,length=dimZ+15,nutDepth=5,nutAddedLen=0,captiveLen=10, rot=90);
			translate([-screwSize-screwAditionalDistance,-dimY/2,dimZ])
				rotate([-90,0,0])
					rotate([0,0,180])
						hole_for_screw(size=screwSize,length=dimZ+15,nutDepth=5,nutAddedLen=0,captiveLen=10, rot=90);
			standard_rod(diam=rodD, length=dimY*4, threaded=false, renderPart=true, center=true);
			rodHolder(rodD=rodD, screwSize=screwSize, negative=true);
		}
		// Draw screws
		translate([screwSize+screwAditionalDistance,-dimY/2,dimZ+0.01])
			rotate([-90,0,0])
				rotate([0,0,180])
					screw_and_nut(size=screwSize,length=dimZ+15,nutDepth=5,nutAddedLen=0,captiveLen=0, rot=90, echoPart=true);
		translate([-screwSize-screwAditionalDistance,-dimY/2,dimZ+0.01])
			rotate([-90,0,0])
				rotate([0,0,180])
					screw_and_nut(size=screwSize,length=dimZ+15,nutDepth=5,nutAddedLen=0,captiveLen=0, rot=90, echoPart=true);
	}
}




