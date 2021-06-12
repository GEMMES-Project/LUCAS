model SDD_MX_6_10_20

import "params.gaml"
import "functions.gaml"
import "entities/song.gaml"
import "entities/duong.gaml"
import "entities/donvidatdai.gaml"
import "entities/vungbaode.gaml"
import "entities/xa.gaml"
import "entities/tinh.gaml"

global {

	init {
	//load ban do tu cac ban do vao tac tu
		do docmatran_thichnghi;
		do docmatran_khokhan;
		create tinh from: MKD_bound;
		do load_climate_PR;
		do load_climate_TAS;
		//		create song from: song_file;
		//		create duong from: duong_file;
		create donvidatdai from: dvdd_file with: [dvdd::int(read('Code'))];
		create vungbaode from: bandodebao with: [de::int(read('De'))];
		create xa from: xa_file with: [tenxa::read('Tenxa')];
		ask active_cell parallel: true {
			sal <- first(cell_sal overlapping self).grid_value;
			my_tinh <- first(tinh overlapping self);
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

		}
		//
		//		ask active_cell_dat2010 {
		//			do tomau;
		//		}
		do gan_dvdd;
		do gan_cell_hc;
		tieuchi <-
		[["name"::"lancan", "weight"::w_lancan], ["name"::"khokhan", "weight"::w_khokhan], ["name"::"thichnghi", "weight"::w_thichnghi], ["name"::"loinhuan", "weight"::w_loinhuan]];
		save "year, 3 rice,2 rice, rice-shrimp,shrimp,vegetables, risk_aqua,risk_rice" type: "text" to: "result/landuse_res.csv" rewrite: true;
	}

	reflex main_reflex {
	//		the_date <- the_date add_years 5;
		tong_luc <- 0.0;
		tong_luk <- 0.0;
		tong_lua_tom <- 0.0;
		tong_tsl <- 0.0;
		tong_lnk <- 0.0;
		tong_bhk <- 0.0;
		tong_khac <- 0.0;
		dt_tsl_risk <- 0.0;
		dt_lua_caqrisk <- 0.0;
		dt_caq_risk <- 0.0;
		ask active_cell parallel: true {
			do tinh_chiso_lancan;
		}

		ask active_cell parallel: true {
			do luachonksd;
			do adptation_sc;  // applied when scenarios 1 or 2
			do to_mau;
			if (landuse = 5) {
				tong_luc <- tong_luc + pixel_size; //pixel size = 500x500
			}

			if (landuse = 6) {
				tong_luk <- tong_luk + pixel_size; 
			}

			if (landuse = 101) {
				tong_lua_tom <- tong_lua_tom + pixel_size;
			}

			if (landuse = 34) {
				tong_tsl <- tong_tsl + pixel_size; 
			}

			if (landuse = 12) {
				tong_bhk <- tong_bhk + pixel_size; 
			}

			if (landuse = 14) {
				tong_lnk <- tong_lnk + pixel_size; 
			}

		}	
		// calculate risk area  
		
		ask active_cell where (each.risk >0) parallel: true {
			if risk=1{
				dt_tsl_risk <- dt_tsl_risk + pixel_size;
			}
			else if risk =2{
				dt_lua_caqrisk <- dt_lua_caqrisk + pixel_size;
			} 
			
		}
		int year <-2015+ cycle; 
		save [ year, tong_luc,tong_luk, tong_lua_tom,tong_tsl,tong_bhk,dt_tsl_risk,dt_lua_caqrisk] type: "csv" to: "result/landuse_res.csv" rewrite: false;
		write "Tong dt lua:" + tong_luc;
		write "Tong dt lúa khác:" + tong_luk;
		write "Tong dt lúa tom:" + tong_lua_tom;
		write "Tong dt ts:" + tong_tsl;
		write "Tong dt rau mau:" + tong_bhk;
		write "Tong dt lnk:" + tong_lnk;
		//write "Tong dt khac:" + tong_khac;
		write "Tong dt tsl risk:" + dt_tsl_risk;
		write "Tong dt lua  risk:" + dt_lua_caqrisk;
		
		
		if (cycle  =15) {
			//save ss type: "text" to: "result/res.csv" rewrite: false;
		//			string
		//			ss <- "" + climate_maxTAS_thuysan + ";" + climate_maxPR_thuysan + ";" + climate_maxTAS_caytrong + ";" + climate_maxPR_caytrong + ";" + dt_raumau_risk + ";" + dt_tsl_risk + "\n";
		//			save ss type: "text" to: "result/res.csv" rewrite: false;
		//			//			do tinh_kappa;
		//			ask active_cell {
		//				grid_value <- float(landuse);
		//			}
		//
		//			save cell_dat to: "../results/landuse_sim_" + 2015 + cycle + ".tif" type: "geotiff";
		//			//	do tinh_dtmx;
					do pause;
		}

	}

}

experiment "Landuse change" type: gui {
	parameter "Trong số lân cận" var: w_lancan <- 0.8;
	parameter "Trọng số khó khăn" var: w_khokhan <- 0.7;
	parameter "Trọng số thích nghi" var: w_thichnghi <- 0.8;
	parameter "Trọng số lợi nhuận" var: w_loinhuan <- 0.0;
	parameter "Trọng số rủi ro biến đổi khí hậu" var: w_risky_climate <- 0.0;
	parameter "Scenarios" var: scenario<-0;
	output {
		display mophong type: java2D {
			grid cell_dat;
			species song;
			species duong;
		}

//		display landunit type: java2D {
//			species donvidatdai;
//		}

		display risk_cell type: opengl {
			species tinh;
			species cell_dat aspect: risky;
		}

		display "Risk by climate" type: java2D {
			chart "Layer" type: series background: rgb(255, 255, 255) {
				data "Risk for shrimp" style: line value: dt_tsl_risk color: #blue;
				data "Fresh water demand area 3 rice" style: line value: dt_lua_caqrisk color: #red;
				//data "Fresh water demand area fruit" style: line value: dt_caq_risk color: #darkgreen;
			}

		}

		display "landuse chart" type: java2D {
			chart "Layer" type: series background: rgb(255, 255, 255) {
				data "3 rice" style: line value: tong_luc color: #yellow;
				data "2 rice" style: line value: tong_luk color: #lightyellow;
				data "Fruit trees" style: line value: tong_lnk color: #darkgreen;
				data "Annual crops" style: line value: tong_bhk color: #lightgreen;
				data "Aquaculture" style: line value: tong_tsl color: #cyan;
				data "Rice - aquaculture" style: line value: tong_lua_tom color: rgb(40, 150, 120);
			}

		}
		

	}

}

experiment "ExploreVulnerable" type: batch repeat: 1 keep_seed: true until: (time >= 15) {

//	float climate_maxTAS_thuysan<- 30.0;//-35 , tăng 0.5
//	float climate_maxPR_thuysan<-300.0;//-500, tăng 50
//
//	float climate_maxTAS_caytrong<- 30.0;//-35 , tăng 0.5
//	float climate_maxPR_caytrong<- 100.0;// - 300, tăng 50

	parameter 'climate_maxTAS_thuysan' var: climate_maxTAS_thuysan min: 30.0 max: 31.0 step: 0.5;
	parameter 'climate_maxPR_thuysan' var: climate_maxPR_thuysan min: 300.0 max: 400.0 step: 50.0;
	parameter 'climate_maxTAS_caytrong' var: climate_maxTAS_caytrong min: 28.0 max: 30.0 step: 0.5;
	parameter 'climate_minPR_caytrong' var: climate_minPR_caytrong min: 100.0 max: 200.0 step: 50.0;
//	method exhaustive minimize: (dt_lua_caqrisk + dt_tsl_risk);

	reflex end_of_runs {
		ask simulations {
		
			save [ '2030', tong_luc,tong_luk, tong_lua_tom,tong_tsl,tong_bhk,proportion_ago_supported,proportion_aqua_supported,climate_maxTAS_thuysan, climate_maxPR_thuysan , climate_maxTAS_caytrong,climate_minPR_caytrong, dt_tsl_risk,dt_lua_caqrisk] type: "csv" to: "result/Climate_explore.csv" rewrite: false;
		}

	}

}
experiment "ExploreSC2" type: batch repeat: 1 keep_seed: true until: (time >= 15) {
	parameter 'proportion_aqua_supported' var: proportion_aqua_supported min: 0.2 max: 0.9 step: 0.1;
	parameter 'proportion_ago_supported' var: proportion_ago_supported min: 0.2 max: 0.9 step:0.1;
	parameter "Scenarios" var: scenario<-2;
//	method exhaustive minimize: (dt_lua_caqrisk + dt_tsl_risk)  ;

	reflex end_of_runs {
		ask simulations {
			save [ '2030', tong_luc,tong_luk, tong_lua_tom,tong_tsl,tong_bhk,proportion_ago_supported,proportion_aqua_supported,dt_tsl_risk,dt_lua_caqrisk] type: "csv" to: "result/Sc2_explore.csv" rewrite: false;
		}
	}
}
experiment "ExploreSC1" type: batch repeat: 1 keep_seed: true until: (time >= 15) {
	parameter 'proportion_aquafarmers_adapted' var: proportion_aquafarmers_adapted min: 0.2 max: 0.9 step: 0.1;
	parameter 'proportion_agrofarmers_adapted' var: proportion_agrofarmers_adapted min: 0.2 max: 0.9 step:0.1;
	parameter "Scenarios" var: scenario<-1;
//	method exhaustive minimize: (dt_lua_caqrisk + dt_tsl_risk)  ;

	reflex end_of_runs {
		ask simulations {
			save [ '2030', tong_luc,tong_luk, tong_lua_tom,tong_tsl,tong_bhk,proportion_agrofarmers_adapted,proportion_aquafarmers_adapted,dt_tsl_risk,dt_lua_caqrisk] type: "csv" to: "result/Sc1_explore.csv" rewrite: false;
		}
	}
}
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