/**
 *  Author:  Truong Chi Quang et Patrick Taillandier
 *  Description: Common model on MAB-LUC - Data of  Binh Thanh village, Thanh Phu district, Ben Tre province, Viet nam
 * 
 */
 
model common_model

global { 
	//khai bao bien theo kieu tap tin
	file land_parcel_file<-file('../includes/LU_Myxuyen2005/landuse_myxuyen_2005_region.shp');			// //definition file variable of parcel layer
	file river_file <- file('../includes/basemaps/rivers_myxuyen_region.shp');				//definition file variable of river layer
	file legend_symbol_file <- file("../includes/legend/legends_rectangle.shp");			//definition file variable of layer  boundery layer
	file txt_file <- file("../includes/legend/legends_text_point.shp");						//definition file variable of legend  layer text

	
	bool mode_batch <- false;																// check if running in batch mode
	float step_sim <- 1 #year;																// simulation step
	float start_simulation <- 2004 #year;													// set simulation start times
	float end_simulation <- 2010 #year;														// simulation end times
	
	map<string,rgb> LUT <-[																	// map of Land-use type; each type have a color
		'BHK'::rgb(153,0,0),
		'LNK'::rgb(153,0,0)+50,
		'LNC':: rgb(255,102,178),
		'LTM'::#deepskyblue,
		'LUK'::rgb(153,153,0),
		'LUC'::#yellow,
		'OTHER_LU'::rgb(0,102,0),
		'TSL'::#blue,
		'LNQ'::#red+50,
		'QPH'::#blue+100
		
	];
	
//	map<string,int> LUTDepth <-[
//		'BHK'::45,
//		'LNK'::15,
//		'LNC'::50,
//		'LTM'::22,
//		'LUK'::15,
//		'LUC'::22,
//		'OTHER_LU'::27,
//		'TSL'::0,
//		'LNQ'::45,
//		'QPH'::40
//	];
	int nb_LUT <- length(LUT);															// number of land-use types 
	
	// FOR FUZZY-KAPPA variable 
	bool use_fuzzy_kappa_sim <- false parameter: true;									
	float distance_kappa <- 200 parameter: true; 										// Distance for calculation Fuzzy Kappa
	matrix<float> fuzzy_categories;														// Categories to calculate the FKappa
	matrix<float> fuzzy_transitions;													// Categories to calculate the FKapp
	list<float> nb_per_cat_obs;															// Categories to transition matrix 
	list<float> nb_per_cat_sim;															// Number of categories observed 
	float kappa;																		// NUmber of categories simulated
	float pad;																			// variable for Fuzzy Kappa
	list<string> categories ;															//List of categories  
	list<land_parcel> parcels;															//List of parcels
	geometry shape <- envelope(land_parcel_file);										//definition simulation environment - boundery of the parcel file
	string modelID <-"ID";
	init{		
		//Create agent from shapefile and get attribute data.
		time <- start_simulation;	
		do create_parcel;
//		write "Year:" + step_sim;
//		write "end time - start time:"+ (end_simulation - start_simulation)/#year;
		create legend  from: legend_symbol_file with: [legend_str::string(read('Legend_cod'))]{
			color <- LUT[legend_str] ;
		}
		create legend_text_point  from: text_file with: [legend_text::string(read('Legend_tex'))];
		create river from: river_file;
		
		do other_init;
		// save the header of the CSV file
//		save "Order,FKappaBDI, ADP_BDI"   to: "../includes/results/result_MCDM.csv" type: csv;
	}
	action create_parcel;																// will be ovewrite in the model of Farmer 
	
	action other_init ;																	//init other agent, will be overwrite by Farmer 			
//	comment for explore parameters for the model Multicriteria 
	reflex end_simulation when: (cycle =10 and not mode_batch ){//   time = end_simulation{//
		write ("\nFuzzy-Kappa BDI - LS+ price ..."+cycle);	      

		do call_fuzzy_kappa;
		write "FK="+ kappa + ",PAD="+ pad ;	
		save modelID+ ","+kappa + ", " + pad   to: "../includes/results/result_B.csv" type: csv;
		//save parcels to:"../includes/land_parcelMarkov2010.shp" type:"shp"; 							// save agents to shapefile
		do pause;
		write " End of simulation";
		
	}
	// write the result of simulation 
	
	
//	
	reflex dynamic {
		ask shuffle(parcels) {
			do change_landuse;
		}
		ask shuffle(parcels) {
			do update_landuse;
		}
	}

	
	action call_fuzzy_kappa{
//		Calculate fuzzy Kappa
		ask parcels {
			if (not (landuse in categories)) {categories << landuse; }
			if (not (landuse_obs in categories)) {categories << landuse_obs;}
			
		}
//		write parcels;
//		write "Caterogies:" + world.categories;
		if (true) {
			
			fuzzy_categories <- 0.0 as_matrix {nb_LUT,nb_LUT};
			loop i from: 0 to: nb_LUT - 1 {
				fuzzy_categories[i,i] <- 1.0;
			}
			fuzzy_transitions <- 0.0 as_matrix {nb_LUT*nb_LUT,nb_LUT*nb_LUT};
			loop i from: 0 to: (nb_LUT * nb_LUT) - 1 {
				fuzzy_transitions[i,i] <- 1.0;	
			}
			list<float> similarity_per_agents <- [];
//			if (use_fuzzy_kappa_sim) {
//				kappa <- fuzzy_kappa_sim(parcels, parcels collect (each.landuse_init),parcels collect (each.landuse_obs),parcels collect (each.landuse), similarity_per_agents,LUT.keys,fuzzy_categories, distance_kappa);
//				if (not mode_batch) {write  kappa;}//"fuzzy kappa sim(map init, map observed, map simulation,categories):\n" +
//			}else {
			kappa <- fuzzy_kappa(parcels, parcels collect (each.landuse_obs),parcels collect (each.landuse), similarity_per_agents,LUT.keys,fuzzy_categories, distance_kappa);
//				kappa <- kappa( parcels collect (each.landuse_obs),parcels collect (each.landuse),categories);
//				if (not mode_batch) {write kappa;}//"fuzzy kappa(map observed, map simulation,categories):\n" + 
//			}
				
			loop i from: 0 to: length(parcels) - 1 {
				int val <- int(255 * similarity_per_agents[i]);
				ask parcels[i] {color_fuzzy <- rgb(val, val, val);}
			}
		}
	
		loop c over: LUT.keys {
			list<land_parcel> area_c <- parcels where (each.landuse_obs = c);
			list<float> area_shape_c <- area_c collect (each.shape.area);
			nb_per_cat_obs << sum(area_shape_c );
			nb_per_cat_sim << sum((parcels where (each.landuse = c)) collect (each.shape.area)); 
		}
		pad <- percent_absolute_deviation(nb_per_cat_obs,nb_per_cat_sim);
//		if (not mode_batch) {write "" + pad  + "%";}
	}

}
species landunit_parcel{
	int landunit_id;
	string SALINITY;
	rgb color <- rgb(rnd(255),rnd(255),rnd(255)) update:rgb(rnd(255),rnd(255),rnd(255))  ;
	aspect default{
		draw shape color:#lightblue-(int(SALINITY)*20);
	}
}
   
species land_parcel{
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

species river {
	aspect default { draw shape color:#steelblue border:false;}
}
// MAPS LEGEND
species legend_text_point {
	string legend_text ;
	aspect text_aspect{
		draw legend_text at:{location.x,location.y-500 }  color:#black size:200;
	}
}

species legend {
	string legend_str;
	rgb color;
	rgb border;	
	aspect my_aspect {
		draw rectangle(2700,900) at:{location.x+2000,location.y-500 } color:#white border:false;
//		draw legend_str at:{location.x-1500,location.y-500 }  color:#black size:230;
		
		draw shape at:{location.x,location.y-500 } color: color border: border;		
	}
}// LEGEND

// This experiment runs the simulation 10 times.
//experiment 'Run 100 simulations' type: batch repeat: 100 keep_seed: true until: time = end_simulation {
//	parameter mode_batch var: mode_batch among: [true];
//	int cpt <- 0;
//	int nb_sim <- 100;
//	float sum_pad;
//	float sum_kappa;
//	action _step_ {
//		ask world {do call_fuzzy_kappa;}
//		sum_kappa <- sum_kappa + kappa;
//		sum_pad <- sum_pad + pad;
//		cpt <- cpt + 1;
//		if (cpt = nb_sim) {
//			write "pad for " + nb_sim +" simulations: " + (sum_pad/nb_sim);
//			write "kappa for " + nb_sim +" simulations: " + (sum_kappa/nb_sim);
//		}
//	}
//}
//	
//	