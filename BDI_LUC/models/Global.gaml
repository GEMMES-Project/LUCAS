/***
* Name: Global
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Global
import "Parameters.gaml"
import "Functions.gaml"
import "species/LandParcel.gaml"
import "species/Legend.gaml"
import "species/River.gaml"
import "species/LegendTextPoint.gaml"
global {

	init {
	//Create agent from shapefile and get attribute data.
		time <- start_simulation;
		do create_parcel;
		//		write "Year:" + step_sim;
		//		write "end time - start time:"+ (end_simulation - start_simulation)/#year;
		create Legend from: legend_symbol_file with: [legend_str::string(read('Legend_cod'))] {
			color <- LUT[legend_str];
		}

		create LegendTextPoint from: txt_file with: [legend_text::string(read('Legend_tex'))];
		create River from: river_file;
		do other_init;
		// save the header of the CSV file
		//		save "Order,FKappaBDI, ADP_BDI"   to: "../includes/results/result_MCDM.csv" type: csv;
		gridsSize <- getGridsSize(netcdf_sample);
		timesAxisSize <- netcdf_sample getTimeAxisSize grid_num;
	}

	action create_parcel; // will be ovewrite in the model of Farmer 
	action other_init; //init other agent, will be overwrite by Farmer 			
	//	comment for explore parameters for the model Multicriteria 
//	reflex end_simulation when: (cycle = 10 and not mode_batch) { //   time = end_simulation{//
//		write ("\nFuzzy-Kappa BDI - LS+ price ..." + cycle);
//		do call_fuzzy_kappa;
//		write "FK=" + kappa + ",PAD=" + pad;
//		save modelID + "," + kappa + ", " + pad to: "../includes/results/result_B.csv" type: csv;
//		//save parcels to:"../includes/land_parcelMarkov2010.shp" type:"shp"; 							// save agents to shapefile
//		do pause;
//		write " End of simulation";
//	}
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

	action call_fuzzy_kappa {
	//		Calculate fuzzy Kappa
		ask parcels {
			if (not (landuse in categories)) {
				categories << landuse;
			}

			if (not (landuse_obs in categories)) {
				categories << landuse_obs;
			}

		}
		//		write parcels;
		//		write "Caterogies:" + world.categories;
		if (true) {
			fuzzy_categories <- 0.0 as_matrix {nb_LUT, nb_LUT};
			loop i from: 0 to: nb_LUT - 1 {
				fuzzy_categories[i, i] <- 1.0;
			}

			fuzzy_transitions <- 0.0 as_matrix {nb_LUT * nb_LUT, nb_LUT * nb_LUT};
			loop i from: 0 to: (nb_LUT * nb_LUT) - 1 {
				fuzzy_transitions[i, i] <- 1.0;
			}

			list<float> similarity_per_agents <- [];
			//			if (use_fuzzy_kappa_sim) {
			//				kappa <- fuzzy_kappa_sim(parcels, parcels collect (each.landuse_init),parcels collect (each.landuse_obs),parcels collect (each.landuse), similarity_per_agents,LUT.keys,fuzzy_categories, distance_kappa);
			//				if (not mode_batch) {write  kappa;}//"fuzzy kappa sim(map init, map observed, map simulation,categories):\n" +
			//			}else {
			kappa <- fuzzy_kappa(parcels, parcels collect (each.landuse_obs), parcels collect (each.landuse), similarity_per_agents, LUT.keys, fuzzy_categories, distance_kappa);
			//				kappa <- kappa( parcels collect (each.landuse_obs),parcels collect (each.landuse),categories);
			//				if (not mode_batch) {write kappa;}//"fuzzy kappa(map observed, map simulation,categories):\n" + 
			//			}
			loop i from: 0 to: length(parcels) - 1 {
				int val <- int(255 * similarity_per_agents[i]);
				ask parcels[i] {
					color_fuzzy <- rgb(val, val, val);
				}

			}

		}

		loop c over: LUT.keys {
			list<LandParcel> area_c <- parcels where (each.landuse_obs = c);
			list<float> area_shape_c <- area_c collect (each.shape.area);
			nb_per_cat_obs << sum(area_shape_c);
			nb_per_cat_sim << sum((parcels where (each.landuse = c)) collect (each.shape.area));
		}

		pad <- percent_absolute_deviation(nb_per_cat_obs, nb_per_cat_sim);
		//		if (not mode_batch) {write "" + pad  + "%";}
	}

}