/**
* Name: Economic
* Author: Chi-Quang Truong
* Description: Describe here the model and its experiments
* Get data from the datasets: cost, price
*  Provide the cost and price data in the variable :  price_map_e and  cost_map_e
*/ 


model Environment

global {
	/** Insert the global definitions, variables and actions here */
	//the land suitability structure: LS(land_unit, LUT1_ls, LUT2_ls, LUT3_ls...)
	// LUTi_ls: the land suitability of the land unit 
	// Value of land suitability: 1: highest suitable, 2: high, 3: low suitable; 4: non suitable  
//	file suitability_file <- csv_file("../includes/datasets/suitability_new.csv", ",",string,false); // define the suitability of the land-unit, csv format
	file suitability_file <- csv_file("../includes/datasets/suitability_new.csv", ",",string,false);
	file transition_file <- csv_file("../includes/datasets/transition.csv", ",",string,false);		 // define the difficulty transition , csv format	
	map<string, map<string,int>> implementation_map_envi;											// definition of the difficult to change from one LUT to another LUT
	map<int, map<string,int>> suitability_map_envi;													// definition map variable of sutability
	geometry shape <- envelope('../includes/environmental/land_unit2010.shp');					// define the environment boundery 
	init{
		
		do build_suitability_map;
		do build_implementation_map; 																//build implementatoi : measure difficulties of transition.
	}
	// load the suitability map into the suitability_map
	action build_suitability_map {		
//		write "envi  \n  "+suitability_file;																	// load the suitability map into
		matrix st_mat <- matrix(suitability_file);
		loop i from: 1 to: st_mat.rows - 1{
			map<string,int> map_land_unit <- [];
			int land_unit <- int(st_mat[0,i]);
			loop j from: 1 to: st_mat.columns -1{
				map_land_unit[string(st_mat[j,0])] <-int(st_mat[j,i]); 
			}
			suitability_map_envi[land_unit] <- map_land_unit;
		}
		
	}// load the transition from a land-use to the other land use 
	action build_implementation_map {
		matrix st_mat <- matrix(transition_file);
//		write "trans matrix:" + st_mat;
		loop i from: 1 to: st_mat.rows - 1{
			map<string,int> map_transition_s <- [];
			string source_lu <- string(st_mat[0,i]);
			loop j from: 1 to: st_mat.columns -1{
				map_transition_s[st_mat[j,0]] <-int(st_mat[j,i]); 
			}
			implementation_map_envi[source_lu] <- map_transition_s;
		}
//		write implementation_map_envi;
	}
	
	
}

species landunit_en{
	int landunit_id;
	rgb color <- rgb(rnd(255),rnd(255),rnd(255)) update:rgb(rnd(255),rnd(255),rnd(255))  ;
	aspect default{
		draw shape color:color;
	}
}
experiment Envi_exp type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display "land unit"{
			species landunit_en aspect:default;
		}
	}
}
