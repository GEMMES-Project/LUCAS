/***
* Name: Legend
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/

@no_experiment

model LandParcel
import "../Parameters.gaml" 
species LandParcel{
	string landuse_init;
	string landuse;
	string landuse_tmp;
	string landuse_obs;	
	string acid_sulfat;
	int land_unit;
	int region ;
	int nearhouse ;
	rgb color_fuzzy;			
	float land_suitability<- -1.0;
	map<string,float> LS_map;
	float parcel_area;
	
	action change_landuse {
		landuse_tmp <- landuse;
	}
	
	action update_landuse {
		landuse <- landuse_tmp;
		do action_end;
	}
	action action_end;
	aspect fuzzy_sim {
		draw shape color: color_fuzzy border:false;
	}		
		
	aspect default {
		draw shape  color: LUT[landuse]  border: LUT[landuse] - 30;
    }
        
   aspect obs_data {
    	draw shape color: LUT[landuse_obs]  border: LUT[landuse_obs] - 30;
   }
   	
   
}

