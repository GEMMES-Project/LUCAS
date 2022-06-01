
model SDD_MX_6_10_20
  
import "functions.gaml"
import "entities/river.gaml"
import "entities/road.gaml" 

global { 

	init {
	//load ban do tu cac ban do vao tac tu
		do load_suitability_data;
		do load_ability_data;
		do load_profile_adaptation;
		create district from: district_file{// with: [dist_name::read('dist_name')]
		//			write climat_cod;
		}
		create province from: province_file{// with: [dist_name::read('dist_name')]
		//			write climat_cod;
		}
		//		do load_climate_PR;
		do load_climate_TAS;
		//		create song from: song_file;
		//		create duong from: duong_file;
		create land_unit from: dvdd_file with: [dvdd::int(read('Code'))];
		create dyke_protected from: dyke_file with: [de::int(read('De'))];
		
		create AEZ from:aez_file;
		
//		create xa from: huyen_file with: [tenxa::read('Tenxa')];
		ask active_cell parallel: true {
			sal <- field_salinity[location];//first(cell_salinity overlapping self).grid_value;
			sub <- field_subsidence[location];//first(cell_salinity overlapping self).grid_value;
			my_district <- first(district overlapping self);
			my_province <- first(province overlapping self);
			my_aez <- first(AEZ overlapping self);
			cell_lancan <- (neighbors where (!dead(each)) where (each.grid_value != 0.0)); //1 ban kinh lan can laf 2 cell = 8 cell xung quanh 1 cell
			//			cell_lancan <- (self neighbors_at 2) where (!dead(each)); //1 ban kinh lan can laf 2 cell = 8 cell xung quanh 1 cell
			do to_mau;
			//			date tmp <- the_date;
			//			loop i from: 1 to: 5 {
			//				tmp <- tmp add_years 5;
			//				if (Pr[tmp.year] = nil) {
			//					if (Pr_tiff[tmp.year] != nil) {
			//						Pr[tmp.year] <- read_bands(Pr_tiff[tmp.year], int(grid_x * (11 / 1113)), int(grid_y * (12 / 1130)));
			//					}
			//
			//				}
			//
			//			}
			if(my_province!=nil and my_province.agreed_aez and my_aez!=nil){
				string p_key<-my_aez.aezone+(sub<=0.1?"00.1":"0.110");
				profile<-profile_map[p_key];
			}

		}
		//
		//		ask active_cell_dat2010 {
		//			do tomau;
		//		}
		do gan_dvdd;
		do gan_cell_hc;
		criteria <-
		[["name"::"lancan", "weight"::area_shrimp_tsl_risk], ["name"::"khokhan", "weight"::area_rice_fruit_tree_risk], ["name"::"thichnghi", "weight"::area_fruit_tree_risk], ["name"::"loinhuan", "weight"::w_profit]];
		//	save "year, 3 rice,2 rice, rice-shrimp,shrimp,vegetables, risk_aqua,risk_rice" type: "text" to: "result/landuse_res.csv" rewrite: true;
	}

	reflex main_reflex {
	//		the_date <- the_date add_years 5;
		tong_luc <- 0.0;
		total_2rice_luk <- 0.0;
		total_rice_shrimp <- 0.0;
		tong_tsl <- 0.0;
		total_fruit_tree_lnk <- 0.0;
		tong_bhk <- 0.0;
		total_rice_shrimp <- 0.0;
		area_shrimp_tsl_risk <- 0.0;
		area_rice_fruit_tree_risk <- 0.0;
		area_fruit_tree_risk <- 0.0;
		//	budget_supported <-0.0; // reset support budget every year.
		total_income_lost <- 0.0;
		ask active_cell parallel: true {
			do tinh_chiso_lancan;
			if(my_province!=nil and my_province.agreed_aez and my_aez!=nil){
				string p_key<-my_aez.aezone+(sub<=0.1?"00.1":"0.110");
				profile<-profile_map[p_key];
			}
		}

		ask active_cell parallel: true {
			do luachonksd;
			do adptation_sc; // applied when scenarios 1 or 2
			do to_mau;
			if (landuse = 5) {
				tong_luc <- tong_luc + pixel_size; //pixel size = 500x500
			}

			if (landuse = 6) {
				total_2rice_luk <- total_2rice_luk + pixel_size;
			}

			if (landuse = 101) {
				total_rice_shrimp <- total_rice_shrimp + pixel_size;
			}

			if (landuse = 34) {
				tong_tsl <- tong_tsl + pixel_size;
			}

			if (landuse = 12) {
				tong_bhk <- tong_bhk + pixel_size;
			}

			if (landuse = 14) {
				total_fruit_tree_lnk <- total_fruit_tree_lnk + pixel_size;
			}
			// calculate risk area  
			if risk = 1 {
				area_shrimp_tsl_risk <- area_shrimp_tsl_risk + pixel_size;
			} else if risk = 2 {
				area_rice_fruit_tree_risk <- area_rice_fruit_tree_risk + pixel_size;
			}

		}

		int year <- 2015 + cycle;
		//string output_filename <-"../result/landuse_sim" + scenario+".csv";
		save
		[year, tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, climate_maxTAS_shrimp, climate_maxPR_thuysan, climate_maxTAS_caytrong, climate_minPR_caytrong, area_shrimp_tsl_risk, area_rice_fruit_tree_risk]
		type: "csv" to: "../results/landuse_sim_scenarios" + scenario + ".csv" rewrite: false;
		write "Tong dt lua:" + tong_luc;
		write "Tong dt lúa khác:" + total_2rice_luk;
		write "Tong dt lúa tom:" + total_rice_shrimp;
		write "Tong dt ts:" + tong_tsl;
		write "Tong dt rau mau:" + tong_bhk;
		write "Tong dt lnk:" + total_fruit_tree_lnk;
		//write "Tong dt khac:" + tong_khac;
		write "Tong dt tsl risk:" + area_shrimp_tsl_risk;
		write "Tong dt lua  risk:" + area_rice_fruit_tree_risk;

		// Save risk into map
		if (year mod 10 = 0) {
			ask active_cell {
				grid_value <- float(risk);
			}

			save farming_unit to: "../results/risk_" + year + "sc" + scenario + ".tif" type: "geotiff";
			ask active_cell {
				grid_value <- float(landuse);
			}
			save farming_unit to: "../results/landuse_sim_" + year + "sc" + scenario + ".tif" type: "geotiff";
		}
		// save resul map
		if (year >2050) {
		//save ss type: "text" to: "result/res.csv" rewrite: false;
		//			string
		//			ss <- "" + climate_maxTAS_thuysan + ";" + climate_maxPR_thuysan + ";" + climate_maxTAS_caytrong + ";" + climate_maxPR_caytrong + ";" + dt_raumau_risk + ";" + area_shrimp_tsl_risk + "\n";
		//			save ss type: "text" to: "result/res.csv" rewrite: false;
		//			//			do tinh_kappa;
			
			//			//	do tinh_dtmx;
			do pause;
		}

	}

}

experiment "Landuse change" type: gui {
	parameter "Trong số lân cận" var: area_shrimp_tsl_risk <- 0.6;
	parameter "Trọng số khó khăn" var: area_rice_fruit_tree_risk <- 0.5;
	parameter "Trọng số thích nghi" var: area_fruit_tree_risk <- 0.7;
	parameter "Trọng số lợi nhuận" var: w_profit <- 0.8;
	//	parameter "Trọng số rủi ro biến đổi khí hậu" var: w_risky_climate <- 0.0;
	parameter "Scenarios" var: scenario <- 0; 
	
	output {
		display mophong type: opengl {
			species farming_unit aspect: profile;
////			grid farming_unit;
//			species river;
//			species road;
////			species province;
////			agents value:active_cell;
////			species AEZ transparency:0.3;			
//			mesh field_subsidence color: palette(reverse(brewer_colors("Blues"))) scale:10 smooth: 4;//  
//			mesh field_salinity color: palette(reverse(brewer_colors("Blues"))) scale:10 smooth: 4;//  
//			
////			species district;
//			//	species donvidatdai;
		}

		//		display landunit type: java2D {
		//			species donvidatdai;
		//		}
//		display risk_cell type: opengl {
//			species district;
//			species farming_unit aspect: risky;
//		}
//
//		display "Risk by climate" type: java2D {
//			chart "Layer" type: series background: rgb(255, 255, 255) {
//				data "Risk for shrimp" style: line value: area_shrimp_tsl_risk color: #blue;
//				data "Fresh water demand area 3 rice" style: line value: area_rice_fruit_tree_risk color: #red;
//				//data "Fresh water demand area fruit" style: line value: dt_caq_risk color: #darkgreen;
//			}
//
//		}
//
//		display "landuse chart" type: java2D {
//			chart "Layer" type: series background: rgb(255, 255, 255) {
//				data "3 rice" style: line value: tong_luc color: #yellow;
//				data "2 rice" style: line value: total_2rice_luk color: #lightyellow;
//				data "Fruit trees" style: line value: total_fruit_tree_lnk color: #darkgreen;
//				data "Annual crops" style: line value: tong_bhk color: #lightgreen;
//				data "Aquaculture" style: line value: tong_tsl color: #cyan;
//				data "Rice - aquaculture" style: line value: total_rice_shrimp color: rgb(40, 150, 120);
//			}
//
//		}

	}

}
//experiment "LU_3scenarios" type: batch repeat: 1 keep_seed: true until: (time > 35) {
//	//parameter 'proportion_aqua_supported' var: proportion_aqua_supported min: 0.3 max: 0.9 step: 0.3;
//	//parameter 'proportion_ago_supported' var: proportion_ago_supported min: 0.3 max: 0.9 step: 0.3;
//	parameter "Scenarios" var: scenario  min: 1 max: 3 step: 2;
//	output {
//		display sim_LU type: java2D {
//			grid farming_unit;
//			species river;
//			species road;
//		}
//		display vulnerable_cell type: opengl {
//			species district;
//			species farming_unit aspect: risky;
//		}
//
//		display "Vulnerable by climate" type: java2D {
//			chart "Layer" type: series background: rgb(255, 255, 255) {
//				data "Risk for shrimp" style: line value: area_shrimp_tsl_risk color: #blue;
//				data "Fresh water demand area 3 rice" style: line value: area_rice_fruit_tree_risk color: #red;
//				//data "Fresh water demand area fruit" style: line value: dt_caq_risk color: #darkgreen;
//			}
//
//		}
//
//		display "landuse chart" type: java2D {
//			chart "Layer" type: series background: rgb(255, 255, 255) {
//				data "3 rice" style: line value: tong_luc color: #yellow;
//				data "2 rice" style: line value: total_2rice_luk color: #lightyellow;
//				data "Fruit trees" style: line value: total_fruit_tree_lnk color: #darkgreen;
//				data "Annual crops" style: line value: tong_bhk color: #lightgreen;
//				data "Aquaculture" style: line value: tong_tsl color: #cyan;
//				data "Rice - aquaculture" style: line value: total_rice_shrimp color: rgb(40, 150, 120);
//			}
//
//		}
//
//	}
//
//}

//experiment "ExploreVulnerable" type: batch repeat: 1 keep_seed: true until: (time >= 15) {
//
////	float climate_maxTAS_thuysan<- 30.0;//-35 , tăng 0.5
////	float climate_maxPR_thuysan<-300.0;//-500, tăng 50
////
////	float climate_maxTAS_caytrong<- 30.0;//-35 , tăng 0.5
////	float climate_maxPR_caytrong<- 100.0;// - 300, tăng 50
//
////	parameter 'climate_maxTAS_thuysan' var: climate_maxTAS_thuysan min: 28.0 max: 30.0 step: 0.5;
////	parameter 'climate_maxPR_thuysan' var: climate_maxPR_thuysan min: 380.0 max: 420.0 step: 20.0;
//	parameter 'climate_maxTAS_caytrong' var: climate_maxTAS_caytrong min: 28.0 max: 30.0 step: 0.5;
//	parameter 'climate_minPR_caytrong' var: climate_minPR_caytrong min: 100.0 max: 200.0 step: 50.0;
//	parameter "Scenarios" var: scenario <- 0;
//	//	method exhaustive minimize: (area_rice_fruit_tree_risk + area_shrimp_tsl_risk);
//	reflex end_of_runs {
//		ask simulations {
//			save
//			['2030', tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, proportion_ago_supported, proportion_aqua_supported, climate_maxTAS_shrimp, climate_maxPR_thuysan, climate_maxTAS_caytrong, climate_minPR_caytrong, area_shrimp_tsl_risk, area_rice_fruit_tree_risk, budget_supported]
//			type: "csv" to: "../result/Climate_explore_rice.csv" rewrite: false;
//		}
//
//	}
//
//}
//
//experiment "ExploreSC3" type: batch repeat: 1 keep_seed: true until: (time >= 15) {
//	parameter 'proportion_aqua_supported' var: proportion_aqua_supported min: 0.3 max: 0.9 step: 0.3;
//	parameter 'proportion_ago_supported' var: proportion_ago_supported min: 0.3 max: 0.9 step: 0.3;
//	parameter "Scenarios" var: scenario <- 3;
//	//	method exhaustive minimize: (area_rice_fruit_tree_risk + area_shrimp_tsl_risk);
//	parameter "proportion_aquafarmers_adapted" var: proportion_aquafarmers_adapted <- 1 - proportion_aqua_supported;
//	// proportion_aquafarmers_adapted when applied proportion_aqua_supported .
//	reflex end_of_runs {
//		ask simulations {
//			save
//			['2030', tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, proportion_ago_supported, proportion_aqua_supported, area_shrimp_tsl_risk, area_rice_fruit_tree_risk, budget_supported, total_income_lost]
//			type: "csv" to: "../results/Sc3_explore.csv" rewrite: false;
//		}
//
//	}
//
//}
//
//experiment "ExploreSC2" type: batch repeat: 1 keep_seed: true until: (time >= 15) {
//	parameter 'proportion_aqua_supported' var: proportion_aqua_supported min: 0.3 max: 0.9 step: 0.3;
//	parameter 'proportion_ago_supported' var: proportion_ago_supported min: 0.3 max: 0.9 step: 0.3;
//	parameter "Scenarios" var: scenario <- 2;
//	//	method exhaustive minimize: (area_rice_fruit_tree_risk + area_shrimp_tsl_risk)  ;
//	reflex end_of_runs {
//		ask simulations {
//			save
//			['2030', tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, proportion_ago_supported, proportion_aqua_supported, area_shrimp_tsl_risk, area_rice_fruit_tree_risk, budget_supported]
//			type: "csv" to: "../results/Sc2_explore.csv" rewrite: false;
//		}
//
//	}
//
//}
//
//experiment "ExploreSC1" type: batch repeat: 1 keep_seed: true until: (time >= 15) {
//	parameter 'proportion_aquafarmers_adapted' var: proportion_aquafarmers_adapted min: 0.3 max: 0.9 step: 0.3;
//	parameter 'proportion_agrofarmers_adapted' var: proportion_agrofarmers_adapted min: 0.3 max: 0.9 step: 0.3;
//	parameter "Scenarios" var: scenario <- 1;
//	//	method exhaustive minimize: (area_rice_fruit_tree_risk + area_shrimp_tsl_risk)  ;
//	reflex end_of_runs {
//		ask simulations {
//			save
//			['2030', tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, proportion_agrofarmers_adapted, proportion_aquafarmers_adapted, area_shrimp_tsl_risk, area_rice_fruit_tree_risk, budget_supported]
//			type: "csv" to: "../results/Sc1_explore_" + scenario + ".csv" rewrite: false;
//		}
//
//	}
//
//}
//
//experiment "single sim SC1" type: gui {
//parameter "Trong số lân cận" var: area_shrimp_tsl_risk <- 0.6;
//	parameter "Trọng số khó khăn" var: area_rice_fruit_tree_risk <- 0.5;
//	parameter "Trọng số thích nghi" var: area_fruit_tree_risk <- 0.7;
//	parameter "Trọng số lợi nhuận" var: w_profit <- 0.8;
//	//	parameter "Trọng số rủi ro biến đổi khí hậu" var: w_risky_climate <- 0.0;
//	parameter "Scenarios" var: scenario <- 1;
//	
//	action _init_ {
//		create simulation ;
//	}
//
//	output {
//		display mophong type: java2D {
//			grid farming_unit;
//			species river;
//			species road;
//			//	species donvidatdai;
//		}
//
//		//		display landunit type: java2D {
//		//			species donvidatdai;
//		//		}
////		display risk_cell type: opengl {
////			species district;
////			species farming_unit aspect: risky;
////		}
////
////		display "Risk by climate" type: java2D {
////			chart "Layer" type: series background: rgb(255, 255, 255) {
////				data "Risk for shrimp" style: line value: area_shrimp_tsl_risk color: #blue;
////				data "Fresh water demand area 3 rice" style: line value: area_rice_fruit_tree_risk color: #red;
////				//data "Fresh water demand area fruit" style: line value: dt_caq_risk color: #darkgreen;
////			}
////
////		}
////
////		display "landuse chart" type: java2D {
////			chart "Layer" type: series background: rgb(255, 255, 255) {
////				data "3 rice" style: line value: tong_luc color: #yellow;
////				data "2 rice" style: line value: total_2rice_luk color: #lightyellow;
////				data "Fruit trees" style: line value: total_fruit_tree_lnk color: #darkgreen;
////				data "Annual crops" style: line value: tong_bhk color: #lightgreen;
////				data "Aquaculture" style: line value: tong_tsl color: #cyan;
////				data "Rice - aquaculture" style: line value: total_rice_shrimp color: rgb(40, 150, 120);
////			}
////
////		}
//
//	}
//
//	reflex save_result_sim_csv when: (cycle mod 10 = 0) {
//		ask simulations {
//			save
//			[cycle+2015, tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, proportion_agrofarmers_adapted, proportion_aquafarmers_adapted, area_shrimp_tsl_risk, area_rice_fruit_tree_risk, budget_supported]
//			type: "csv" to: "../results/Lu_sim_sc_" + scenario + ".csv" rewrite: false;
//		}
//
//	}
//
//}
//
//experiment "multi sim SC1" type: gui {
////	parameter 'proportion_aquafarmers_adapted' var: proportion_aquafarmers_adapted min: 0.3 max: 0.9 step: 0.3;
////	parameter 'proportion_agrofarmers_adapted' var: proportion_agrofarmers_adapted min: 0.3 max: 0.9 step: 0.3;
//	parameter "Scenarios" var: scenario <- 1;
//	//	method exhaustive minimize: (area_rice_fruit_tree_risk + area_shrimp_tsl_risk)  ;
//	action _init_ {
//		list<string> dirs <- folder("../data").contents;
//		loop x from: 1 to: 3 {
//			loop y from: 1 to: 3 {
//				write "" + x * 0.3 + " " + y * 0.3;
//				loop d over: dirs {
//					write ("../data/" + d);
//					//			if (!file_exists("../data/"+d)) {
//					//				return;
//					//			}
//					//
//					//			file risk_csv_file <- csv_file("../data/"+d, ",", false);
//					//			matrix data <- (risk_csv_file.contents);
//					//			loop i from: 0 to: data.rows - 1 {
//					//				write data[0, i];
//					//			}
//					create simulation with: [proportion_aquafarmers_adapted::(x * 0.3), proportion_agrofarmers_adapted::(y * 0.3), risk_csv_file_path::("../data/" + d)];
//				}
//
//			}
//
//		}
//
//	}
//
//	reflex end_of_runs when: cycle >= 15 {
//		ask simulations {
//			save
//			['2030', tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, proportion_agrofarmers_adapted, proportion_aquafarmers_adapted, area_shrimp_tsl_risk, area_rice_fruit_tree_risk, budget_supported]
//			type: "csv" to: "../results/Sc1_explore_" + scenario + ".csv" rewrite: false;
//		}
//
//	}
//
//}
//
//experiment "can_chinh" type: batch repeat: 1 keep_seed: true until: (time > 10) {
//	parameter "lan can" var: w_lancan min: 0.7 max: 1.0 step: 0.1;
//	parameter "TN" var: w_thichnghi min: 0.6 max: 0.8 step: 0.1;
//	parameter "Kho khan" var: w_khokhan min: 0.6 max: 0.8 step: 0.1;
//	parameter "LN" var: w_loinhuan min: 0.1 max: 0.3 step: 0.1;
//	parameter "Flip" var: w_flip min: 0.02 max: 0.15 step: 0.03;
//	method exhaustive maximize: v_kappa;
//}
//float climate_maxTAS_thuysan<- 30.0;//-35 , tăng 0.5
//	float climate_maxPR_thuysan<-400.0;//-500, tăng 50
//
//	float climate_maxTAS_caytrong<- 28.0;//-35 , tăng 0.5
//	float climate_maxPR_caytrong<-  400.0; // tăng 50 100-300

  