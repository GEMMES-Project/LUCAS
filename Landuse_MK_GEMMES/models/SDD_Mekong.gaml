model SDD_MX_6_10_20

import "params.gaml"
import "functions.gaml"
import "entities/song.gaml"
import "entities/duong.gaml"
import "entities/donvidatdai.gaml"
import "entities/vungbaode.gaml"
import "entities/xa.gaml"

global {

	init {
	//load ban do tu cac ban do vao tac tu
		do docmatran_thichnghi;
		do docmatran_khokhan;
		//		create song from: song_file;
		//		create duong from: duong_file;
		create donvidatdai from: dvdd_file with: [dvdd::int(read('id'))];
		create vungbaode from: bandodebao with: [de::int(read('De'))];
		create xa from: xa_file with: [tenxa::read('Tenxa')];
		ask active_cell parallel: true {
			cell_lancan <- (self neighbors_at 2) where (!dead(each)); //1 ban kinh lan can laf 2 cell = 8 cell xung quanh 1 cell
			do to_mau;
			date tmp <- the_date;
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
		the_date <- the_date add_years 5;
		ask active_cell parallel: true {
			do tinh_chiso_lancan;
			//				}
			//		
			//				ask active_cell  parallel:true{
			do luachonksd;
			do to_mau;
		}

		do tinhtongdt;
		if (cycle = 10) {
			do tinh_kappa;
			ask active_cell {
				grid_value <- float(landuse);
			}

			save cell_dat to: "../results/landuse_sim_" + 2010 + cycle + ".tif" type: "geotiff";
			//	do tinh_dtmx;
				do pause;
		}

	}

}

experiment "my_GUI_xp" type: gui {
	parameter "Trong số lân cận" var: w_lancan <- 0.2;
	parameter "Trọng số khó khăn" var: w_khokhan <- 0.7;
	parameter "Trọng số thích nghi" var: w_thichnghi <- 0.8;
	parameter "Trọng số lợi nhuận" var: w_loinhuan <- 0.7;
	output {
		display mophong type: java2D {
			grid cell_dat;
			species song;
			species duong;
		}
		display landunit type: java2D {
			
			species donvidatdai;
		}

				display "landuse chart" type: opengl {
					chart "Layer" type: series background: rgb(255, 255, 255) {
						data "3 rice" style: line value: tong_luc color: #yellow;
						data "2 rice" style: line value: tong_luk color: #brown;
						data "Aquaculture" style: line value: tong_tsl color: #blue;
						data "Rice - aquaculture" style: line value: tong_lua_tom color: #cyan;
					}
		
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
