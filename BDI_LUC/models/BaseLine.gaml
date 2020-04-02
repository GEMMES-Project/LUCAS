/**
 *  Author:  Truong Chi Quang et Patrick Taillandier
 *  Description: Common model on MAB-LUC - Data of  Binh Thanh village, Thanh Phu district, Ben Tre province, Viet nam
 * 
 */
model common_model

import "Global.gaml"
import "species/FarmerBDI.gaml"
import "species/Cell.gaml"
import "species/LandUnitParcel.gaml"

global {

	reflex s {
		matrix<int> m <- (matrix<int>(netcdf_sample readDataSlice (grid_num, times, 0, -1, -1)));
		ask Cell {
			grid_value <- float(m at {grid_x, grid_y});
			color <- rgb(grid_value);
		}

		times <- times + 1;
		if (times > timesAxisSize - 1) {
			times <- 0;
		}

		grid_num <- grid_num + 1;
		if (grid_num > gridsSize - 1) {
			grid_num <- 0;
			timesAxisSize <- netcdf_sample getTimeAxisSize grid_num;
		}
		
		ask Cell{
			ask FarmerBDI overlapping self{
				land_suitability<-myself.grid_value;
			}
		}

	}

	action create_parcel {
		do build_suitability_map;
		do build_price_cost_map;
		do build_implementation_map;
		max_price <- price_map.values max_of (each[0]);
		max_cost <- cost_map.values max_of (each[0]);
		landuse_types <- LUT.keys - "OTHER_LU";
		create FarmerBDI from: land_parcel_file with:
		[region::int(read('Region')), landuse_init::string(read('lu2005')), landuse_obs::string(read('Lu10')), nearhouse::int(read("Nearhouse")), acid_sulfat::string(read("Acid_sul_d")), parcel_area::float(read("Area")), land_unit::int(read("Landunit"))]
		//
		{
		//temp
			land_unit <- 1 + rnd(5);
			//temp
			landuse <- landuse_init;
			probabilistic_choice <- false;
			income <- world.compute_profit(landuse, LS_map, land_unit);
		}

		ask FarmerBDI {
			neighbours <- (FarmerBDI at_distance distance_neighbours) where (each.landuse_init != "OTHER_LU");
		}
		//		create landunit_parcel from: land_unit_file with: [landunit_id::int(read('LANDUNIT'))]; 		
		create LandUnitParcel from: land_unit_file with: [landunit_id::int(read('lu2005'))];
		do set_landUnit; // set land_unit for the parcel

	}

	action other_init {
		parcels <- list(FarmerBDI where (each.shape.area > 0));
		fol <- one_of(FarmerBDI);
	}

	action build_suitability_map {
	//		write "farmer     \n " +  suitability_file;
		matrix st_mat <- matrix(suitability_file);
		loop i from: 1 to: st_mat.rows - 1 {
			map<string, int> map_land_unit <- [];
			int land_unit <- int(st_mat[0, i]);
			loop j from: 1 to: st_mat.columns - 1 {
				map_land_unit[string(st_mat[j, 0])] <- int(st_mat[j, i]);
			}

			suitability_map[land_unit] <- map_land_unit;
		}

	}

	action build_price_cost_map {
		matrix price_mat <- matrix(price_file);
		matrix cost_mat <- matrix(cost_file);
		loop i from: 1 to: price_mat.rows - 1 {
			list<float> pr <- [];
			list<float> ct <- [];
			string lu <- string(price_mat[0, i]);
			loop j from: 1 to: price_mat.columns - 1 {
				pr << float(price_mat[j, i]);
				ct << float(cost_mat[j, i]);
			}

			price_map[lu] <- pr;
			cost_map[lu] <- ct;
		}

	}

	action build_implementation_map {
		matrix st_mat <- matrix(transition_file);
		loop i from: 1 to: st_mat.rows - 1 {
			map<string, int> map_transition_s <- [];
			string source_lu <- string(st_mat[0, i]);
			loop j from: 1 to: st_mat.columns - 1 {
				map_transition_s[st_mat[j, 0]] <- int(st_mat[j, i]);
			}

			implementation_map[source_lu] <- map_transition_s;
		}

	}

	action set_landUnit {
	//		get land_unit id from land unit agent to the parcel
		loop lunit_obj over: LandUnitParcel { //loop for the land unit object  - declared in the common model  
			ask FarmerBDI at lunit_obj.location { // select the land parcel object that overlap with land unit object
				land_unit <- lunit_obj.landunit_id > 0 ? lunit_obj.landunit_id : land_unit; // set land_unit of the parcel
				//				write land_unit_code;
			}

		}

		//		save FarmerBDI to: "../includes/test_gan_land_unit.shp" type: "shp";
	}
	// calculate area 
	reflex calcul_area {
	}
	// calculate the number of farmers for each plan 
	reflex dynamic {
		pl_loan <- 0;
		pl_copy_neig <- 0;
		pl_suitability <- 0;
		pl_income <- 0;
		pl_stay <- 0;
		pl_no_intention <- 0;
		ask FarmerBDI {
			if self.has_desire(request_invesment_from_bank) {
				pl_loan <- pl_loan + 1;
			}

			if self.has_desire(imitate_their_successful_neighbors) {
				pl_copy_neig <- pl_copy_neig + 1;
			}

			if self.has_desire(minimize_risks) {
				pl_suitability <- pl_suitability + 1;
			}

			if self.has_desire(earn_the_highest_possible_income) {
				pl_income <- pl_income + 1;
			}

			if self.has_desire(try_not_to_change) {
				pl_stay <- pl_stay + 1;
			}

			if (not self.has_desire(imitate_their_successful_neighbors) and not self.has_desire(minimize_risks) and not self.has_desire(earn_the_highest_possible_income)) {
				pl_no_intention <- pl_no_intention + 1;
			}

		}
		//		write "NUmber of farmer borrow:"+ i + "; D_neighbor:"+j+"; D_land suitability: "+ k + "; D_hight_income:"+h;
		if (not batch_mode) {
			write "Year, loan, limitation, Land suitability, high income, stay, mo_intention";
			write "Year " + (cycle + 2010) + "," + pl_loan + "," + pl_copy_neig + "," + pl_suitability + "," + pl_income + "," + pl_stay + "," + pl_no_intention;
		}

	}
	//	area of the simulated land use types
	float v_luc;
	float v_luk;
	float v_lnc;
	float v_ltm;
	float v_tsl;
	float v_lnq;
	float v_lnk;
	float v_bhk;

	reflex write_sim_result {
	// wrtite simulation result each cycle 
		v_luc <- 0.0;
		v_luk <- 0.0;
		v_lnc <- 0.0;
		v_ltm <- 0.0;
		v_tsl <- 0.0;
		v_lnq <- 0.0;
		v_lnk <- 0.0;
		v_bhk <- 0.0;
		v_lnq <- 0.0;

		//		calculate the area of the land-use type each simulation step 
		ask FarmerBDI {
		//			write land-use simulated  
			switch landuse {
				match 'BHK' {
					v_bhk <- v_bhk + parcel_area;
				}

				match 'LNC' {
					v_lnc <- v_lnc + parcel_area;
				}

				match 'LNK' {
					v_lnk <- v_lnk + parcel_area;
				}

				match 'LNQ' {
					v_lnq <- v_lnq + parcel_area;
				}

				match 'LTM' {
					v_ltm <- v_ltm + parcel_area;
				}

				match 'LUC' {
					v_luc <- v_luc + parcel_area;
				}

				match 'LUK' {
					v_luk <- v_luk + parcel_area;
				}

				match 'LUK' {
					v_luk <- v_luk + parcel_area;
				}

				match 'TSL' {
					v_tsl <- v_tsl + parcel_area;
				}

			}

		}

		if (not batch_mode) {
			write "Year, BHK, LNC, Fruit, LTM, LUC, LUK, TSL";
			write
			" Year:" + (cycle + 2010) + "," + v_bhk / 10000 + "," + v_lnc / 10000 + "," + (v_lnk + v_lnq) / 10000 + "," + v_ltm / 10000 + "," + v_luc / 10000 + "," + v_luk / 10000 + "," + v_tsl / 10000;
		}

	}

}
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