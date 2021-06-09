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
		dt_raumau_risk <- 0.0;
		dt_caq_risk <- 0.0;
		ask active_cell parallel: true {
			do tinh_chiso_lancan;
		}

		ask active_cell parallel: true {
			do luachonksd;
			do to_mau;
			if (landuse = 5) {
				tong_luc <- tong_luc + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

			if (landuse = 6) {
				tong_luk <- tong_luk + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

			if (landuse = 101) {
				tong_lua_tom <- tong_lua_tom + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

			if (landuse = 34) {
				tong_tsl <- tong_tsl + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

			if (landuse = 12) {
				tong_bhk <- tong_bhk + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

			if (landuse = 14) {
				tong_lnk <- tong_lnk + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		write "Tong dt lua:" + tong_luc;
		write "Tong dt lúa khác:" + tong_luk;
		write "Tong dt lúa tom:" + tong_lua_tom;
		write "Tong dt ts:" + tong_tsl;
		write "Tong dt rau mau:" + tong_bhk;
		write "Tong dt lnk:" + tong_lnk;
		write "Tong dt khac:" + tong_khac;
		if (cycle = 15) {
			do tinh_kappa;
			ask active_cell {
				grid_value <- float(landuse);
			}

			save cell_dat to: "../results/landuse_sim_" + 2015 + cycle + ".tif" type: "geotiff";
			//	do tinh_dtmx;
			do pause;
		}

	}

}

experiment "my_GUI_xp" type: gui {
	parameter "Trong số lân cận" var: w_lancan <- 0.8;
	parameter "Trọng số khó khăn" var: w_khokhan <- 0.7;
	parameter "Trọng số thích nghi" var: w_thichnghi <- 0.8;
	parameter "Trọng số lợi nhuận" var: w_loinhuan <- 0.0;
	parameter "Trọng số rủi ro biến đổi khí hậu" var: w_risky_climate <- 0.0;
	output {
		display mophong type: java2D {
			grid cell_dat;
			species song;
			species duong;
		}

		display landunit type: java2D {
			species donvidatdai;
		}

		display risk_cell type: java2D {
			species tinh;
			species cell_dat aspect: risky;
		}

		display "Risk by climate" type: java2D {
			chart "Layer" type: series background: rgb(255, 255, 255) {
				data "Risk for shrimp" style: line value: dt_tsl_risk color: #red;
				data "Fresh water demand area vegetable" style: line value: dt_raumau_risk color: #lightgreen;
				data "Fresh water demand area fruit" style: line value: dt_caq_risk color: #darkgreen;
			}

		}

		display "landuse chart" type: java2D {
			chart "Layer" type: series background: rgb(255, 255, 255) {
				data "3 rice" style: line value: tong_luc color: #lightyellow;
				data "2 rice" style: line value: tong_luk color: #yellow;
				data "Fruit trees" style: line value: tong_lnk color: #darkgreen;
				data "Annual crops" style: line value: tong_bhk color: #lightgreen;
				data "Aquaculture" style: line value: tong_tsl color: #cyan;
				data "Rice - aquaculture" style: line value: tong_lua_tom color: rgb(40, 150, 120);
			}

		}

	}

}

experiment "explore" type: batch repeat: 5 keep_seed: true until: ( time >= 15 ) {

//	float climate_maxTAS_thuysan<- 30.0;//-35 , tăng 0.5
//	float climate_maxPR_thuysan<-300.0;//-500, tăng 50
//
//	float climate_maxTAS_caytrong<- 30.0;//-35 , tăng 0.5
//	float climate_maxPR_caytrong<- 100.0;// - 300, tăng 50
	parameter 'climate_maxTAS_thuysan' var: climate_maxTAS_thuysan min: 30.0 max: 35.0 step: 0.5;
	parameter 'climate_maxPR_thuysan' var: climate_maxPR_thuysan min: 300.0 max: 500.0 step: 50.0;
	parameter 'climate_maxTAS_caytrong' var: climate_maxTAS_caytrong min: 30.0 max: 35.0 step: 0.5;
	parameter 'climate_maxPR_caytrong' var: climate_maxPR_caytrong min: 100.0 max: 300.0 step: 50.0;
	method exhaustive minimize: (dt_raumau_risk + dt_tsl_risk);

	reflex end_of_runs {
		ask simulations {
			string
			ss <- "" + climate_maxTAS_thuysan + ";" + climate_maxPR_thuysan + ";" + climate_maxTAS_caytrong + ";" + climate_maxPR_caytrong + ";" + dt_raumau_risk + ";" + dt_tsl_risk + "\n";
			save ss type: "text" to: "result/res.csv";
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
