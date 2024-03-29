model SDD_MX_6_10_20

import "functions.gaml"
import "entities/river.gaml"
import "entities/road.gaml"

global {

	init {
		write "use_profile_adaptation " + use_profile_adaptation + " use_subsidence_macro " + use_subsidence_macro + " explo_param " + explo_param;
		//load ban do tu cac ban do vao tac tu
		create district from: district_file {
		}

		create province from: province_file {
		//			agreed_aez <- use_profile_adaptation;
			subsi_threshold <- prov_sub_thres[int(self)] = nil ? subsidence_threshold : prov_sub_thres[int(self)];
		}

		create AEZ from: aez_file;
		write "gis loaded";
		do load_suitability_data;
		do load_cost_benefit_data;
		do load_WU_data;
		do load_ability_data;
		do load_profile_adaptation;
		do load_macroeconomic_data;
		do load_climate_TAS;
		write "matrix loaded";

		//		create xa from: huyen_file with: [tenxa::read('Tenxa')];
		ask active_cell parallel: true {
			sal <- field_salinity[location]; //first(cell_salinity overlapping self).grid_value;
			sub <- field_subsidence[location]; //first(cell_salinity overlapping self).grid_value;
			my_district <- first(district overlapping self);
			my_province <- first(province overlapping self);
			my_aez <- first(AEZ overlapping self);
			cell_lancan <- (neighbors where (!dead(each)) where (each.grid_value != 0.0)); //1 ban kinh lan can laf 2 cell = 8 cell xung quanh 1 cell
			//			cell_lancan <- (self neighbors_at 2) where (!dead(each)); //1 ban kinh lan can laf 2 cell = 8 cell xung quanh 1 cell
			//			do to_mau;
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
			//			if (my_province != nil and my_province.agreed_aez and my_aez != nil) {
			//				string p_key <- my_aez.aezone + (sub <= my_province.subsi_threshold ? "00.1" : "0.110");
			//				profile <- profile_map[p_key];
			//			}

			//			if(my_province!=nil and my_province.agreed_aez and my_aez!=nil){
			//				string p_key<-my_aez.aezone+(sub<=0.1?"00.1":"0.110");
			//				profile<-profile_map[p_key];
			//			}
		}

		write "cell initialized";
		//
		//		ask active_cell_dat2010 {
		//			do tomau;
		//		}
		do gan_dvdd;
		//		do gan_cell_hc;
		criteria <-
		[["name"::"lancan", "weight"::w_neighbor_density], ["name"::"khokhan", "weight"::w_ability], ["name"::"thichnghi", "weight"::w_suitability], ["name"::"loinhuan", "weight"::w_profit]];
		//	save "year, 3 rice,2 rice, rice-shrimp,shrimp,vegetables, risk_aqua,risk_rice" type: "text" to: "result/landuse_res.csv" rewrite: true;
		string s <- "";
		s <- s + ["year", "subsi_scenario", "subsidence_threshold"];
		s <- s + province collect (each.NAME_1);
		s <- s + (AEZ group_by (each.aezone)).keys;
		s <- s + ["total_debt"];
		s <- s + ["total_debt_5"];
		s <- s + ["total_debt_34"];
		s <- s + ["total_wu"];
		s <- (s replace ("][", ",") replace ("[", "") replace ("]", ""));
		write s;
		if (int(world) = 0) {
			save s to: "../results/" + explo_param + "_" + subsidence_threshold + "_debt.csv" type: text rewrite: true;
		}

		s <- "";
		s <- s + ["year", "sc","subsidence_threshold"];
		s <- s + province collect (each.NAME_1);
		s <- s + (AEZ group_by (each.aezone)).keys;
		s <- s + ["total_benefit"];
		s <- s + ["total_benefit_5"];
		s <- s + ["total_benefit_34"];
		s <- (s replace ("][", ",") replace ("[", "") replace ("]", ""));
		write s;
		if (int(world) = 0) {
			save s to: "../results/" + explo_param + "_" + subsidence_threshold + "_benefit.csv" type: text rewrite: true;
			save
		["year", 'tong_luc', 'total_2rice_luk', 'total_rice_shrimp', 'tong_tsl', 'tong_bhk', 'total_fruit_tree_lnk', 'climate_maxTAS_shrimp', 'climate_maxPR_thuysan', 'climate_maxTAS_caytrong', 'climate_minPR_caytrong', 'area_shrimp_tsl_risk', 'area_rice_fruit_tree_risk']
		type: "csv" to: "../results/" + explo_param + "_" + subsidence_threshold + "_landuse_sim.csv" rewrite: true;
		}

		write "ready";
	}

	reflex main_reflex {
		int year <- 2015 + cycle;
		write cycle;
		//		the_date <- the_date add_years 5;
		//		total_debt <- 0.0;
		ask province {
			benefit <- 0.0;
			wu <- 0.0;
		}

		ask AEZ {
			benefit <- 0.0;
			wu <- 0.0;
		}

		total_wu <- 0.0;
		total_benefit <- 0.0;
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
		total_debt_lu<-[5::0.0,34::0.0,12::0.0,6::0.0,14::0.0,101::0.0];
		if (year mod 10 = 0) {
			do load_subsidence((year - 2020) / 10);
			ask active_cell parallel: true {
				sub <- field_subsidence[location]; //first(cell_salinity overlapping self).grid_value; 
				if (my_province != nil and my_aez != nil and use_profile_adaptation) {
					string p_key <- my_aez.aezone + (sub <= my_province.subsi_threshold ? "00.1" : "0.110");
					profile <- profile_map[p_key];
				}

			}

			//				write "subsidence updated";
		}

		ask active_cell parallel: true {
			benefit <- 0.0;
			debt <- 0.0;
			water_unit <- 0.0;
			do tinh_chiso_lancan;
		}

		ask active_cell parallel: true {
			do luachonksd;
		}

		ask active_cell parallel: false {
			do adptation_sc; // applied when scenarios 1 or 2
			do economic_compute;
			field_farming_unit[location] <- landuse;
			field_risk_farming_unit[location] <- risk;
			//			do to_mau;
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

		save
		[year, tong_luc, total_2rice_luk, total_rice_shrimp, tong_tsl, tong_bhk, total_fruit_tree_lnk, climate_maxTAS_shrimp, climate_maxPR_thuysan, climate_maxTAS_caytrong, climate_minPR_caytrong, area_shrimp_tsl_risk, area_rice_fruit_tree_risk]
		type: "csv" to: "../results/" + explo_param + "_" + subsidence_threshold + "_landuse_sim.csv" rewrite: false;
		write "Tong dt lua:" + tong_luc;
		write "Tong dt lúa khác:" + total_2rice_luk;
		write "Tong dt lúa tom:" + total_rice_shrimp;
		write "Tong dt ts:" + tong_tsl;
		write "Tong dt rau mau:" + tong_bhk;
		write "Tong dt lnk:" + total_fruit_tree_lnk;
		//write "Tong dt khac:" + tong_khac;
		write "Tong dt tsl risk:" + area_shrimp_tsl_risk;
		write "Tong dt lua  risk:" + area_rice_fruit_tree_risk;

		//			debt per province
		//			debt (total)
		//			debt   AEZ
		//			benefits per province
		//			benefits per AEZ
		//			benefits total	
		string s <- "";
		s <- s + [year, scenario_subsidence, subsidence_threshold];
		s <- s + province collect each.debt;
		map<string, list<AEZ>> mm <- (AEZ group_by each.aezone);
		s <- s + mm.values collect sum(each collect each.debt);
		s <- s + [total_debt];
		s <- s + [total_debt_lu[5]];
		s <- s + [total_debt_lu[34]];
		s <- s + [total_wu];
		s <- (s replace ("][", ",") replace ("[", "") replace ("]", ""));
		//			write s;
		save s to: "../results/" + explo_param + "_" + subsidence_threshold  + "_debt.csv" type: text rewrite: false;
		s <- "";
		s <- s + [year, scenario_subsidence, subsidence_threshold];
		s <- s + province collect (each.benefit);
		s <- s + mm.values collect sum(each collect (each.benefit));
		s <- s + [total_benefit];
		s <- s + [total_benefit_lu[5]];
		s <- s + [total_benefit_lu[34]];
		s <- (s replace ("][", ",") replace ("[", "") replace ("]", ""));
		//			write s;
		save s to: "../results/" + explo_param + "_" + subsidence_threshold + "_benefit.csv" type: text rewrite: false;

		// Save risk into map
		if (year mod 10 = 0) {
		//			string output_filename <- "../result/landuse_sim" + scenario + ".csv";

		//			ask active_cell {
		//				grid_value <- float(risk);
		//			}
		//
		//			save farming_unit to: "../results/" + explo_param + "_" + subsidence_threshold + "_risk_" + year + ".tif" type: "geotiff";
			ask active_cell {
				grid_value <- float(landuse);
			}

			save farming_unit to: "../results/" + explo_param + "_" + subsidence_threshold + "_landuse_sim_" + year + ".tif" type: "geotiff";
		}
		// save resul map
		if (year > 2050) {
		//save ss type: "text" to: "result/res.csv" rewrite: false;
		//			string
		//			ss <- "" + climate_maxTAS_thuysan + ";" + climate_maxPR_thuysan + ";" + climate_maxTAS_caytrong + ";" + climate_maxPR_caytrong + ";" + dt_raumau_risk + ";" + area_shrimp_tsl_risk + "\n";
		//			save ss type: "text" to: "result/res.csv" rewrite: false;
		//			//			do tinh_kappa;

		//			//	do tinh_dtmx;
			ask active_cell {
				grid_value <- float(vul_rice);
			}

			save farming_unit to: "../results/" + explo_param + "_" + subsidence_threshold + "_vulnerable_rice_" + year + ".tif" type: "geotiff";
			ask active_cell {
				grid_value <- 0.0;
				if (vul_aqua > 0) {
					grid_value <- 200.0 + float(vul_aqua);
				}

			}

			save farming_unit to: "../results/" + explo_param + "_" + subsidence_threshold + "_vulnerable_aqua_" + year + ".tif" type: "geotiff";
			do pause;
		}

	}

}

experiment "Abstract" virtual: true {
	parameter "Trong số lân cận" var: w_neighbor_density <- 0.6;
	parameter "Trọng số khó khăn" var: w_ability <- 0.5;
	parameter "Trọng số thích nghi" var: w_suitability <- 0.7;
	parameter "Trọng số lợi nhuận" var: w_profit <- 0.8;
	//	parameter "Trọng số rủi ro biến đổi khí hậu" var: w_risky_climate <- 0.0;
	//	parameter "Scenarios" var: scenario <- 0;
	//	parameter "Scenario subsidence" var: scenario_subsidence among: ["M1", "B1", "B2"]; 
	output {
		display LU_sim type: opengl axes: false {
			mesh field_farming_unit color: scale(lu_color) smooth: false;
		}

		display "Benefit - Debt" type: java2D {
			chart "Layer" type: series {
				data "Benefit" style: line value: total_benefit color: #blue;
				data "Debt" style: line value: total_debt  color: #red; 
				data "WU" style: line value: total_wu color: #green;
			}

		}

		display risk_cell type: opengl axes: false {
			mesh field_risk_farming_unit color: scale([#white::0, #blue::1, #red::2]) smooth: false; //  
			species province;
		}

	}

}

experiment "Baseline 1 - No strategies, no subsidence" type: gui autorun: true parent: "Abstract" {

	action _init_ {
	//create simulation with: [use_profile_adaptation::false, explo_param::"SC1noSubsi"];
		create simulation with: [scenario_subsidence::"B2", use_profile_adaptation::false, use_subsidence_macro::false, use_subsidence::false,explo_param::"Baseline1_B2", subsidence_threshold::10,subsidence_macro_threshold::0.2];
	}

}

experiment "Baseline 2 - No strategies, only MacroEco impacted by Subsidence" type: gui autorun: true parent: "Abstract" {

	action _init_ {
	//	create simulation with: [use_profile_adaptation::false, use_subsidence_macro::true, explo_param::"Baseline2"];
		create simulation with: [scenario_subsidence::"B2", use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::false,explo_param::"Baseline2_B2", subsidence_threshold::10,subsidence_macro_threshold::0.2];
	}

}

experiment "Exp 3 No strategies, FU impacted by Subsidence" type: gui autorun: true parent: "Abstract" {

	action _init_ {
		// check scenario_subsidence::"B2" ; subsidence_threshold::0.1'
		create simulation with: [scenario_subsidence::"B2",use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP3_B2",subsidence_threshold::10,subsidence_macro_threshold::0.2];
	}

}
experiment "Exp 4 with strategies, FU impacted by Subsidence" type: gui autorun: true parent: "Abstract" {

	action _init_ {
		create simulation with: [scenario_subsidence::"B2",use_profile_adaptation::true, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP4_B2", subsidence_threshold::0.1,subsidence_macro_threshold::0.2];
	}

}

experiment "Exp 1,2,3" type: gui autorun: true {

	action _init_ {
		create simulation with: [scenario_subsidence::"B2", use_profile_adaptation::false, use_subsidence_macro::false, use_subsidence::false,explo_param::"Baseline1_B2", subsidence_threshold::10,subsidence_macro_threshold::0.2];
		create simulation with: [scenario_subsidence::"B2", use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::false,explo_param::"Baseline2_B2", subsidence_threshold::10,subsidence_macro_threshold::0.2];
		create simulation with: [scenario_subsidence::"B2",use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP3_B2",subsidence_threshold::10,subsidence_macro_threshold::0.2];
		
	}

}

//experiment "Explore EXP3" type: gui autorun: true {
//	parameter "Scenarios" var: scenario <- 0;
//	//	parameter "Scenario subsidence" var: scenario_subsidence among: ["M1", "B1", "B2"] <- "B2";
//	//	parameter "Subsidence threshold" var: subsidence_threshold among: [0.1, 0.15, 0.2, 0.3] <- 0.3;
//	action _init_ {
//	//		loop s over: ["M1", "B1", "B2"] {
//		loop t over: [0.1, 0.2, 0.5, 1.0] { //, [0.1,0.15, 0.2, 0.3] { [0.007,0.005,0.5] 
////			create simulation with:	[scenario_subsidence::"M1",use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP3_M1",subsidence_threshold::t];
////			create simulation with: [scenario_subsidence::"B1",use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP3_B1",subsidence_threshold::t];
//		    create simulation with: [scenario_subsidence::"B2",use_profile_adaptation::false, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP3_B2",subsidence_threshold::t,subsidence_macro_threshold::0.2];
//		}
//
//	}
//
//}

experiment "Explore EXP4" type: gui autorun: true {
	parameter "Scenarios" var: scenario <- 0;
	//	parameter "Scenario subsidence" var: scenario_subsidence among: ["M1", "B1", "B2"] <- "B2";
	//	parameter "Subsidence threshold" var: subsidence_threshold among: [0.1, 0.15, 0.2, 0.3] <- 0.3;
	action _init_ {
	//		loop s over: ["M1", "B1", "B2"] {
		loop t over: [0.1, 0.2, 0.5, 1.0] { //, [0.1,0.15, 0.2, 0.3] { [0.007,0.005,0.5] 
			create simulation with:
//			[scenario_subsidence::"M1", use_profile_adaptation::true, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP4_M1", subsidence_threshold::t];
//			create simulation with:
//			[scenario_subsidence::"B1", use_profile_adaptation::true, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP4_B1", subsidence_threshold::t];
//			create simulation with:
			[scenario_subsidence::"B2", use_profile_adaptation::true, use_subsidence_macro::true, use_subsidence::true, explo_param::"EXP4_B2", subsidence_threshold::t,subsidence_macro_threshold::0.2];
			//[scenario_subsidence::"B2",use_profile_adaptation::true, use_subsidence_macro::true, use_subsidence::true, explo_param::scenario_subsidence, subsidence_threshold::0.1,subsidence_macro_threshold::0.2];
		}

	}

}
