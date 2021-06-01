model cell_dat

import "../params.gaml"
import "tinh.gaml"
import "cell_sal.gaml"
grid cell_dat file: cell_file control: reflex neighbors: 8 {
	int landuse <- int(grid_value);
	float chiso_luk_lancan;
	float chiso_luc_lancan;
	float chiso_bhk_lancan;
	float chiso_tsl_lancan;
	float chiso_lnk_lancan;
	float chiso_khac_lancan;
	int landuse_obs;
	int madvdd;
	float chiso_lua_tom_lancan;
	float chiso_thichnghi_lua_tom;
	float chiso_khokhan_lua_tom;
	rgb color;
	int dyke <- 1; //1: inside; 2: outside of dyke
	map<int, list> Pr <- [];
	map<int, list> Tas <- [];
	map<int, list> Tas_max <- [];
	map<int, list> Tas_min <- [];
	list<cell_dat> cell_lancan <- [];

	init {
	/*
		 * 1113 1130
		 * 3457 2730
		 * 1113 1130
		 * 2783 2824
		 */
		if (grid_value != 0.0) {
			active_cell <+ self;
		} else {
			do die;
		}

	}

	action to_mau {
		if (landuse = 5) {
			color <- #lightyellow;
		}

		if (landuse = 6) {
			color <- #yellow;
		}

		if (landuse = 37) {
			color <- rgb(170, 255, 255);
		}

		//		if (landuse = 6) {
		//			color <- rgb(196, 196, 0);
		//		}
		if (landuse = 12) {
			color <- #lightgreen;
		}

		if (landuse = 14) {
			color <- #darkgreen;
		}

		if (landuse = 34) {
			color <- #cyan;
		}

		if (landuse = 101) {
			color <- rgb(40, 150, 120);
		}

		if (landuse = 102) {
			color <- rgb(40, 100, 120);
		}

		if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 102) and (landuse != 101) and (landuse != 12) and (landuse != 34) {
			color <- #gray;
		}

		if (Pr[the_date.year] != nil and length(Pr) > 0) {
			int rr <- int(mean(Pr[the_date.year]));
			color <- rgb(rr);
		}

	}

	action tinh_chiso_lancan {

	//so cell xung quanh cuar mot cell co kieu su dung la luk/8 (8-tong so o lan can cua moi o)
	//dem so cell trong cell_lancan co landuse=6 (6:luk)
		chiso_luc_lancan <- (cell_lancan count (each.landuse = 5)) / 25;
		chiso_luk_lancan <- (cell_lancan count (each.landuse = 6)) / 25;
		chiso_bhk_lancan <- (cell_lancan count (each.landuse = 12)) / 25;
		chiso_lnk_lancan <- (cell_lancan count (each.landuse = 14)) / 25;
		chiso_tsl_lancan <- (cell_lancan count (each.landuse = 34)) / 25;
		chiso_lua_tom_lancan <- (cell_lancan count (each.landuse = 101)) / 25;
		//chiso_khac_lancan <-(cell_lancan count (each.landuse=1))/8;

	}

	float get_climate_PR (int month) {
		tinh t <- first(tinh overlapping self);
		int idx <- 12;
		if (t != nil) {
			list tmp <- [];
			loop i from: idx + (cycle * 12) to: idx + 8 + (cycle * 12) {
				tmp <- tmp + t.data_pr[i];
			}
			//			write (t.dulieu);
			//			return float(t.data_pr[1 + month]);
			return float(max(tmp));
		}

		return 0.0;
	}

	float get_climate_TAS (int year) {
		tinh t <- first(tinh overlapping self);
		if (t != nil) {
			int idx <- 12;
			list tmp <- [];
			loop i from: idx + (cycle * 12) to: idx + 8 + (cycle * 12) {
				tmp <- tmp + t.data_tas[i];
			}
			//			write (t.dulieu);
			return float(min(tmp));
		}

		return 0.0;
	}

	float xet_thichnghi (int madvdd_, int LUT) {
		float kqthichnghi <- 0.0;
		int i <- 0;
		int j <- 0;
		loop i from: 1 to: matran_thichnghi.rows - 1 {
			if (int(matran_thichnghi[0, i]) = madvdd_) { //cot 0; cot ma dvdd, i:dong
				loop j from: 1 to: matran_thichnghi.columns - 1 { //do tung cot cua matran
					if (int(matran_thichnghi[j, 0]) = LUT) { //dong 0:chua cac ten cot
						kqthichnghi <- float(matran_thichnghi[j, i]);
					}

				}

			}

		}

		float sal <- first(cell_sal overlapping self).grid_value;
		if (sal > 4.0) {
			kqthichnghi <- kqthichnghi - 0.33;
		}

		return kqthichnghi;
	}

	float xet_khokhanchuyendoi (int landuse1, int landuse2) {
		float kqkhokhanchuyendoi <- 0.0;
		int i <- 0;
		int j <- 0;
		loop i from: 1 to: matran_khokhan.rows - 1 {
			if (int(matran_khokhan[0, i]) = landuse1) { //cot 0; cot ma dvdd, i:dong
				loop j from: 1 to: matran_khokhan.columns - 1 { //do tung cot cua matran
					if (int(matran_khokhan[j, 0]) = landuse2) { //dong 0:chua cac ten cot
						kqkhokhanchuyendoi <- float(matran_khokhan[j, i]);
					}

				}

			}

		}

		return kqkhokhanchuyendoi;
	}

	action luachonksd {
		list<list> cands <- landuse_eval();
		int choice <- 0;
		//if (de >1){}
		if (landuse = 5 or landuse = 6 or landuse = 12 or landuse = 14) {
		//or (landuse>0)and (landuse!=14) and (landuse!=5) and (landuse!=6) and(landuse!=100) and (landuse!=12) and (landuse!=34
			choice <- weighted_means_DM(cands, tieuchi);
			//choice tra vi tri ung vien trong danh sach
			if (choice = 0) {
				if flip(0.05) {
					landuse <- 5;
				}

			}

			if (choice = 1) {
				if (xet_thichnghi(madvdd, 34) > 0.33) { // Suitability > S3
					if flip(w_flip) {
						landuse <- 34;
					}

				}

			}

			if (choice = 2) {
				if (xet_thichnghi(madvdd, 12) > 0.33) {
					landuse <- 12;
				}

			}

			if (choice = 3) {
				if (xet_thichnghi(madvdd, 6) > 0.33) {
					landuse <- 6;
				}

			}

			if (choice = 4) {
				if (xet_thichnghi(madvdd, 14) > 0.33) {
					landuse <- 14;
				}

			}

			if (choice = 5) {
				if (xet_thichnghi(madvdd, 101) > 0) {
					landuse <- 101;
				}

			}

		}

			if (get_climate_TAS(cycle) > 24.5 and get_climate_PR(cycle) > 300) {
				if (flip(0.2)) {
					landuse <- 6;
				}

			}
		// xet lua tom - tom 
		//dua dac tinh ung vien tsl, lua tom
		list<list> candidates;
		list<float> candtsl;
		list<float> cand_luatom;
		candtsl << chiso_tsl_lancan;
		candtsl << xet_khokhanchuyendoi(landuse, 34);
		candtsl << xet_thichnghi(madvdd, 34);
		candtsl << 389 / 389;
		cand_luatom << chiso_lua_tom_lancan;
		cand_luatom << chiso_khokhan_lua_tom;
		cand_luatom << xet_thichnghi(madvdd, 101);
		cand_luatom << 150 / 389; // tamj thowi
		//nap cac ung vien vao danh sach candidates
		candidates << candtsl;
		candidates << cand_luatom;
		if (landuse = 34 or landuse = 101) {
			choice <- weighted_means_DM(candidates, tieuchi);
			if (choice = 0) {
			//if (xet_thichnghi(madvdd, 14) > 0.33) {
				if flip(0.20) {
					landuse <- 34;
				}

			}

			if (choice = 1) {
			//	if (xet_thichnghi(madvdd, 101) > 0) {
				landuse <- 101;
				//}

			}

		}

	}

	action landuse_eval {

	//lập danh sách các kiểu sử dụng đất
		list<list> candidates;
		list<float> candluc;
		list<float> candtsl;
		list<float> candbhk;
		list<float> candluk;
		list<float> candlnk;
		list<float> cand_luatom;

		//dua dat tinh cua cac ung vien
		candluc << chiso_luc_lancan;
		candluc << xet_khokhanchuyendoi(landuse, 5);
		candluc << xet_thichnghi(madvdd, 5);
		candluc << 34 / 389;
		//dua dac tinh ung vien tsl
		candtsl << chiso_tsl_lancan;
		candtsl << xet_khokhanchuyendoi(landuse, 34);
		candtsl << xet_thichnghi(madvdd, 34);
		candtsl << 389 / 389;

		//dua dac tinh ung vien hnk
		candbhk << chiso_bhk_lancan;
		candbhk << xet_khokhanchuyendoi(landuse, 12);
		candbhk << xet_thichnghi(madvdd, 12);
		candbhk << 180 / 389;
		//dua dac tinh ung vien lnk
		candluk << chiso_luk_lancan;
		candluk << xet_khokhanchuyendoi(landuse, 6);
		candluk << xet_thichnghi(madvdd, 6);
		candluk << 98 / 389;
		//dua dac tinh ung vien rst
		candlnk << chiso_lnk_lancan;
		candlnk << xet_khokhanchuyendoi(landuse, 14);
		candlnk << xet_thichnghi(madvdd, 6);
		candlnk << 294 / 389;
		// bổ sung thêm ứng viên lua-tom
		cand_luatom << chiso_lua_tom_lancan;
		cand_luatom << chiso_khokhan_lua_tom;
		cand_luatom << xet_thichnghi(madvdd, 101);
		cand_luatom << 150 / 389; // tamj thowi
		//nap cac ung vien vao danh sach candidates
		candidates << candluc;
		candidates << candtsl;
		candidates << candbhk;
		candidates << candluk;
		candidates << candlnk;
		candidates << cand_luatom;
		return candidates;
	}

}
