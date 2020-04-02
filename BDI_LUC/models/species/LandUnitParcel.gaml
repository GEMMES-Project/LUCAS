/***
* Name: LandUnitParcel
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
@ no_experiment 

model LandUnitParcel

species LandUnitParcel {
	int landunit_id;
	string SALINITY;
	rgb color <- rgb(rnd(255), rnd(255), rnd(255)) update: rgb(rnd(255), rnd(255), rnd(255));

	aspect default {
		draw shape color: #lightblue - (int(SALINITY) * 20);
	}

}