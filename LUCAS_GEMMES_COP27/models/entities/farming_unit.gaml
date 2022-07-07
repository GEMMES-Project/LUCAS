model farming_unit

import "cell_sal.gaml"
import "AEZ.gaml"

global {
	field field_farming_unit <- field(cell_file);
	field field_risk_farming_unit <- field(515, 546);
	float total_debt <- 0.0;
	float total_benefit <- 0.0;
	float total_wu <- 0.0;
	map<int, int> lu_total_benefit <- [5::0, 34::0, 12::0, 6::0, 14::0, 101::0];
}

grid farming_unit file: cell_file neighbors: 8 schedules: [] use_individual_shapes: false use_regular_agents: false use_neighbors_cache: false {
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
	int risk <- 0; // bo sung risk de danh dau cell bi risk. DUng khi kich ban loai risk se xet cac cell nay de chuyen doi sang kieu phu hop honbool risk<- false
	// 1: risk thuy san; 2 : risk lua
	int vul_rice <- 0;
	int vul_aqua <- 0;
	// moi vong lap gan lai bang false de xet lai cho nam khac.
	rgb color;
	int dyke <- 1; //1: inside; 2: outside of dyke
	map<int, list> Pr <- [];
	map<int, list> Tas <- [];
	map<int, list> Tas_max <- [];
	map<int, list> Tas_min <- [];
	list<farming_unit> cell_lancan <- [];
	float sal <- 0.0;
	float sub <- 0.0;
	district my_district;
	province my_province;
	AEZ my_aez;
	string profile;
	float investment <- 0.0;
	float benefit <- 0.0;
	map<int, float> my_lu_benefit; //<-[5::34,34::389,12::180,6::98,14::294,101::150]; 
	float debt <- 0.0;
	float water_unit <- 0.0;

	init {
	/*
		 * 1113 1130
		 * 3457 2730
		 * 1113 1130
		 * 2783 2824
		 */
		benefit <- lu_benefit[landuse];
		if (grid_value != 0.0) {
			active_cell <+ self;
		} else {
			do die;
		}

	}

	//	action to_mau {
	//		if (landuse = 5) {
	//			color <- #yellow;
	//		}
	//
	//		if (landuse = 6) {
	//			color <- #lightyellow;
	//		}
	//
	//		if (landuse = 37) {
	//			color <- rgb(170, 255, 255);
	//		}
	//
	//		//		if (landuse = 6) {
	//		//			color <- rgb(196, 196, 0);
	//		//		}
	//		if (landuse = 12) {
	//			color <- #lightgreen;
	//		}
	//
	//		if (landuse = 14) {
	//			color <- #darkgreen;
	//		}
	//
	//		if (landuse = 34) {
	//			color <- #cyan;
	//		}
	//
	//		if (landuse = 101) {
	//			color <- rgb(40, 150, 120);
	//		}
	//
	//		if (landuse = 102) {
	//			color <- rgb(40, 100, 120);
	//		}
	//
	//		if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 102) and (landuse != 101) and (landuse != 12) and (landuse != 34) {
	//			color <- #gray;
	//		}
	//
	//	}
	action tinh_chiso_lancan {

	//so cell xung quanh cuar mot cell co kieu su dung la luk/8 (8-tong so o lan can cua moi o)
	//dem so cell trong cell_lancan co landuse=6 (6:luk)
		chiso_luc_lancan <- (cell_lancan count (each.landuse = 5)) / 8;
		chiso_luk_lancan <- (cell_lancan count (each.landuse = 6)) / 8;
		chiso_bhk_lancan <- (cell_lancan count (each.landuse = 12)) / 8;
		chiso_lnk_lancan <- (cell_lancan count (each.landuse = 14)) / 8;
		chiso_tsl_lancan <- (cell_lancan count (each.landuse = 34)) / 8;
		chiso_lua_tom_lancan <- (cell_lancan count (each.landuse = 101)) / 8;
		//chiso_khac_lancan <-(cell_lancan count (each.landuse=1))/8;
	}

	//		float get_climate_maxPR (int month) {
	//			// tim luong mua toi da trong cac thang mua kho trong mot nam
	//			// nham danh gia kha nang gay risk khi canh tac thuy san (tom) 
	//			if (my_district != nil) {
	//				int idx <- 12 + (int(cycle / 5) * 12);
	//				list
	//				tmp <- [my_district.data_pr[idx + 0], my_district.data_pr[idx + 1], my_district.data_pr[idx + 2], my_district.data_pr[idx + 3], my_district.data_pr[idx + 4], my_district.data_pr[idx + 5], my_district.data_pr[idx + 6], my_district.data_pr[idx + 7], my_district.data_pr[idx + 8]];
	//				return float(max(tmp));
	//			}
	//			return 0.0;
	//		}
	float get_climate_maxPR (int month) {
	// tim luong mua lớn nhất  trong cac thang mua kho trong mot nam
	// nham danh gia kha nang gay risk cho thuy san
		if (my_district != nil) {
			int idx <- cycle; //12 + (int(cycle / 5) * 12);
			//			write ""+(2016+idx) +",0";
			list
			tmp <- [my_district.data_pr["" + (2016 + idx) + ",0"], my_district.data_pr["" + (2016 + idx) + ",1"], my_district.data_pr["" + (2016 + idx) + ",2"], my_district.data_pr["" + (2016 + idx) + ",3"], my_district.data_pr["" + (2016 + idx) + ",4"], my_district.data_pr["" + (2016 + idx) + ",5"]];
			return float(max(tmp));
		}

		return 0.0;
	}

	float get_climate_minPR (int month) {
	// tim luong mua toi thieu  trong cac thang mua kho trong mot nam
	// nham danh gia kha nang gay risk cho cay trong
		if (my_district != nil) {
			int idx <- cycle; //12 + (int(cycle / 5) * 12);
			//			write ""+(2016+idx) +",0";
			list
			tmp <- [my_district.data_pr["" + (2016 + idx) + ",0"], my_district.data_pr["" + (2016 + idx) + ",1"], my_district.data_pr["" + (2016 + idx) + ",2"], my_district.data_pr["" + (2016 + idx) + ",3"], my_district.data_pr["" + (2016 + idx) + ",4"], my_district.data_pr["" + (2016 + idx) + ",5"], my_district.data_pr["" + (2016 + idx) + ",6"], my_district.data_pr["" + (2016 + idx) + ",11"]];
			return float(min(tmp));
		}

		return 0.0;
	}

	float get_climate_maxTAS (int year) {
	// tim nhiet do cao nhat cua cac thang mua kho 
	// phuc vu danh gia kha nang xay ra han man trong nam
		if (my_district != nil) {
			int idx <- cycle; //12 + (int(cycle / 5) * 12);			
			list
			tmp <- [my_district.data_tas["" + (2016 + idx) + ",0"], my_district.data_tas["" + (2016 + idx) + ",1"], my_district.data_tas["" + (2016 + idx) + ",2"], my_district.data_tas["" + (2016 + idx) + ",3"], my_district.data_tas["" + (2016 + idx) + ",4"], my_district.data_tas["" + (2016 + idx) + ",5"], my_district.data_tas["" + (2016 + idx) + ",11"]];
			return float(max(tmp));
		}

		return 0.0;
	}

	float xet_thichnghi (int madvdd_, int LUT) {
		float kqthichnghi <- 0.0;
		if (suitability_map["" + madvdd_ + " " + LUT] = nil) {
		} else {
			kqthichnghi <- suitability_map["" + madvdd_ + " " + LUT];
		}

		//		if (sal > 4.0) {
		//			kqthichnghi <- kqthichnghi - 0.33;
		//		}
		return kqthichnghi;
	}

	float xet_khokhanchuyendoi (int landuse1, int landuse2) {
		float kqkhokhanchuyendoi <- 0.0;
		if (ability_map["" + landuse1 + " " + landuse2] = nil) {
		} else {
			kqkhokhanchuyendoi <- ability_map["" + landuse1 + " " + landuse2];
		}

		return kqkhokhanchuyendoi;
	}
	// adaptation
	//Scenarios1: remove risk by changing land use type: Risk cell in 3 rice crops -> 2 rice crops or 2 rice + 1 other crop; Shrimp ->Intensive with high tech with out support from gov.
	//Sc2: Remove risk with support from goverment : Keeping LU but invest for  fresh water storing in the dry season, support for a percentage of farmers. ( explore this number to see risk area)
	action removerisk_invidual { // scenarios 1
		if (risk = 1) {
			if flip(proportion_aquafarmers_adapted) {
				if (xet_thichnghi(madvdd, 101) > 0) {
					landuse <- 101; // converted to rice-shrimp
					//budget_supported <- budget_supported + 1;
					risk <- 0;
				}

			}

		}

		if (risk = 2) { // risk for 3 rice
			if flip(proportion_agrofarmers_adapted) { // convert 3 rice -> 2 rice 
				landuse <- 6; // 2-rice or rice - vegetable
				risk <- 0;
			}

		}

	}

	action removerisk_supp_gov { // scenarios 2
		if (risk = 1) {
			if flip(proportion_aqua_supported) {
			//landuse <-101; //stay in aquculture but remove risk
				risk <- 0;
			}

		}

		if (risk = 2) {
			if flip(proportion_ago_supported) {
			//landuse <- 5;  // 
				risk <- 0;
			}

		}

	}

	action removerisk_mixed_supp_gov_indv { // scenarios 3 
		if (risk = 1) {
		// gov support farmer to doing rice shrimp
			if flip(proportion_aqua_supported) { // supported by gov.
				budget_supported <- budget_supported + 1;
				risk <- 0;
			} else { // farmer sel adaptation.
				total_income_lost <- total_income_lost + 1 * 384 / 2; //  50% LN
				//risk <-0;				
			}

		}

		if (risk = 2) {
			if flip(proportion_ago_supported) {
				landuse <- 6; // 2-rice or rice - vegetable
				risk <- 0;
				budget_supported <- budget_supported + 1;
			} else { // Khong ho tro, nguoi dan tu chuyne doi nhung ko co kinh phi cua nha nuoc., 
			//landuse <- 6; // 2-rice or rice - vegetable
			//risk <-0;
				total_income_lost <- total_income_lost + 1 * 22; // 22M VND / season 
			}

		}

	}
	// adaptation scenarios 
	action adptation_sc {
		if (scenario = 1) {
			do removerisk_invidual;
		} else if (scenario = 2) {
			do removerisk_supp_gov;
		} else if (scenario = 3) {
			do removerisk_mixed_supp_gov_indv;
		} }

	action luachonksd {
	//		int old_lu <- landuse;
		list<list> cands; // <- profile != nil ? landuse_eval_with_profile() : landuse_eval();
		if (profile = nil and use_subsidence_macro) {
			cands <- landuse_eval_with_subsi_no_profile();
		} else if (profile != nil) {
			cands <- landuse_eval_with_profile();
		} else {
			cands <- landuse_eval();
		}

		int choice <- 0;
		//if (de >1){} 
		if (landuse = 5 or landuse = 6 or landuse = 12 or landuse = 14) {
		//or (landuse>0)and (landuse!=14) and (landuse!=5) and (landuse!=6) and(landuse!=100) and (landuse!=12) and (landuse!=34
			choice <- weighted_means_DM(cands, criteria);
			//choice tra vi tri ung vien trong danh sach
			//			if (choice = 0) {
			//				//if flip(0.0) {
			//				//	landuse <- 5;
			//				}
			//
			//			}
			if (choice = 1) {
			//	if (xet_thichnghi(madvdd, 34) > 0) { // Suitability > S3
			//	if flip(w_flip) {
				landuse <- 34;
				//	}

				//	}

			}

			if (choice = 2) {
				if (xet_thichnghi(madvdd, 12) > 0) {
					landuse <- 12;
				}

			}

			if (choice = 3) {
				if (xet_thichnghi(madvdd, 6) > 0) {
					landuse <- 6;
				}

			}

			if (choice = 4) {
				if (xet_thichnghi(madvdd, 14) > 0.33) {
					if flip(0.1) {
						landuse <- 14;
					}

				}

			}

			if (choice = 5) {
				if (xet_thichnghi(madvdd, 101) > 0) {
					landuse <- 101;
				}

			}

		}

		//		if (landuse =101){
		//			if flip(0.9){
		//				landuse <-34;
		//			}
		//		}
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
		cand_luatom << xet_khokhanchuyendoi(landuse, 101);
		cand_luatom << xet_thichnghi(madvdd, 101);
		cand_luatom << 150 / 389; // tamj thowi
		//nap cac ung vien vao danh sach candidates
		candidates << candtsl;
		candidates << cand_luatom;
		int choicetsl <- 0;
		if (landuse = 34 or landuse = 101) {
			choicetsl <- weighted_means_DM(candidates, criteria);
			if (choicetsl = 0) {
			//if (xet_thichnghi(madvdd, 14) > 0.33) {
			//if flip(0.40) {
				landuse <- 34;
				//}

			}

			if (choicetsl = 1) {
			//	if (xet_thichnghi(madvdd, 101) > 0) {
				landuse <- 101;
				//}

			}

		}

		////
		////profile AEZ adaptation
		////
		////
		//		int new_lu <- landuse;
		//		if (profile != "") {
		//			landuse <- old_lu;
		//			if (supported_lu_type[profile + landuse] != nil) {
		//				if (flip(supported_lu_type[profile + landuse])) {
		//				//				if ((supported_lu_type[profile + landuse]) > 0.6) {
		//					landuse <- new_lu;
		//				}
		//
		//			}
		//
		//		}

		// xet risk thuy san va lua
		risk <- 0;
		if (landuse = 34) { // thuy san
		// Nhiet do cao nhat > nguong hoac luong mua max >nguong
			if (get_climate_maxTAS(cycle) > climate_maxTAS_shrimp or get_climate_maxPR(cycle) > climate_maxPR_thuysan) {
				if (flip(0.3)) {
					risk <- 1; // risk aqua
					vul_aqua <- vul_aqua + 1;
					risk_suitab_34 <- 0.33;
				}

			}

		}

		if (landuse = 5) { // lua 
		// nhiet do max > nguong  va luong mua max< nguong300
		// bo sung duyet 2 tham so nguong duoi: nhietdo tas>27- 29; Pr : 300-500
			if (get_climate_maxTAS(cycle) > climate_maxTAS_caytrong and get_climate_minPR(cycle) < climate_minPR_caytrong and sal > 2) {
			//			if (get_climate_maxTAS(cycle) > climate_maxTAS_caytrong and get_climate_minPR(cycle) < climate_minPR_caytrong) {
				if (flip(0.3)) {
					risk <- 2; // risk agro
					vul_rice <- vul_rice + 1;
					risk_suitab_5 <- 0.33;
				}

			}

		}

	}

	action economic_compute {
		if (my_province != nil) {
			float old_wu <- water_unit;
			water_unit <- water_unit + landuse;
			float coefficient <- 1.0;
			if (use_subsidence_macro and sub > my_province.subsi_threshold) {
				coefficient <- 0.8;
			}

			if (use_profile_adaptation and sub > my_province.subsi_threshold) {
				water_unit <- water_unit - landuse;
			}

			//
			// tinh benefit, debt pump
			my_lu_benefit[landuse] <- my_lu_benefit[landuse] = nil ? lu_benefit[landuse] * coefficient : my_lu_benefit[landuse] * coefficient;
			investment <- (lu_cost[landuse] * (shape.area / 10000) + lu_cost[landuse] * (shape.area / 1E4) * lending_rate["" + (2015 + cycle)] * lending_rate["" + (2015 + cycle)]) / 100;
			benefit <- my_lu_benefit[landuse] * 25; // 25ha - size of the cell 500*500/10000
			if (risk > 0) {
			//			if (my_province != nil and my_province.pumping >= 0) {
			//				risk <- 0;
			//				debt <- debt + investment + my_province.pumping_price;
			//			} else {
				benefit <- 0.0;
				debt <- debt + investment;
				//			}

			}

			float tmp <- benefit / 1000; //* coefficient has involve in lu_benefit
			my_province.wu <- my_province.wu + (water_unit - old_wu) / 10;
			my_province.debt <- my_province.debt + debt / 1E3; //convert to Milillard
			my_province.benefit <- my_province.benefit + tmp;
			total_wu <- total_wu + (water_unit - old_wu) / 10;
			total_debt <- total_debt + debt / 1E3;
			total_benefit <- total_benefit + tmp;
			if (my_aez != nil) {
				my_aez.wu <- my_aez.wu + (water_unit - old_wu) / 10;
				my_aez.debt <- my_aez.debt + debt / 1E3;
				my_aez.benefit <- my_aez.benefit + tmp; //convert to Milillard
			}

		}

	}

	action landuse_eval_with_profile {
	//lập danh sách các kiểu sử dụng đất Th3: landuse_eval có lọc lại danh sách candidate, giảm suitability
		list<list> candidates;
		list<float> candluc;
		list<float> candtsl;
		list<float> candbhk;
		list<float> candluk;
		list<float> candlnk;
		list<float> cand_luatom;

		//dua dat tinh cua cac ung vien
		bool fx <- flip(supported_lu_type[profile + 5]);
		candluc << fx ? chiso_luc_lancan : 0;
		candluc << fx ? xet_khokhanchuyendoi(landuse, 5) : 0;
		candluc << max([0, xet_thichnghi(madvdd, 5) - risk_suitab_5]);
		candluc << fx ? (my_lu_benefit[5] / max_lu_benefit) : 0;
		//dua dac tinh ung vien tsl
		fx <- flip(supported_lu_type[profile + 34]);
		candtsl << fx ? chiso_tsl_lancan : 0;
		candtsl << fx ? xet_khokhanchuyendoi(landuse, 34) : 0;
		candtsl << max([0, xet_thichnghi(madvdd, 34) - risk_suitab_34]);
		candtsl << fx ? (my_lu_benefit[34] / max_lu_benefit) : 0;
		//		if landuse=101{
		//			write "kk:" +xet_khokhanchuyendoi(landuse, 34)+ "tn:"+xet_thichnghi(madvdd, 34);
		//		}

		//dua dac tinh ung vien hnk
		fx <- flip(supported_lu_type[profile + 12]);
		candbhk << fx ? chiso_bhk_lancan : 0;
		candbhk << fx ? xet_khokhanchuyendoi(landuse, 12) : 0;
		candbhk << fx ? xet_thichnghi(madvdd, 12) : 0;
		candbhk << fx ? (my_lu_benefit[12] / max_lu_benefit) : 0;
		//dua dac tinh ung vien lnk
		fx <- flip(supported_lu_type[profile + 6]);
		candluk << fx ? chiso_luk_lancan : 0;
		candluk << fx ? xet_khokhanchuyendoi(landuse, 6) : 0;
		candluk << fx ? xet_thichnghi(madvdd, 6) : 0;
		candluk << fx ? (my_lu_benefit[6] / max_lu_benefit) : 0;
		//dua dac tinh ung vien rst
		fx <- flip(supported_lu_type[profile + 14]);
		candlnk << fx ? chiso_lnk_lancan : 0;
		candlnk << fx ? xet_khokhanchuyendoi(landuse, 14) : 0;
		candlnk << fx ? xet_thichnghi(madvdd, 14) : 0;
		candlnk << fx ? (my_lu_benefit[14] / max_lu_benefit) : 0;
		// bổ sung thêm ứng viên lua-tom
		fx <- flip(supported_lu_type[profile + 101]);
		cand_luatom << fx ? chiso_lua_tom_lancan : 0;
		cand_luatom << fx ? xet_khokhanchuyendoi(landuse, 101) : 0;
		cand_luatom << fx ? xet_thichnghi(madvdd, 101) : 0;
		cand_luatom << fx ? (my_lu_benefit[101] / max_lu_benefit) : 0; // tamj thowi
		//nap cac ung vien vao danh sach candidates
		candidates << candluc;
		candidates << candtsl;
		candidates << candbhk;
		candidates << candluk;
		candidates << candlnk;
		candidates << cand_luatom;
		return candidates;
	}

	float risk_suitab_5 <- 0.0;
	float risk_suitab_34 <- 0.0;

	action landuse_eval_with_subsi_no_profile {
	//lập danh sách các kiểu sử dụng đất TH2: Land_use eval có chỉnh landsuitability và benefit
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
		candluc << max([0, xet_thichnghi(madvdd, 5) - risk_suitab_5]);
		candluc << (my_lu_benefit[5] / max_lu_benefit);
		//dua dac tinh ung vien tsl
		candtsl << chiso_tsl_lancan;
		candtsl << xet_khokhanchuyendoi(landuse, 34);
		candtsl << max([0, xet_thichnghi(madvdd, 34) - risk_suitab_34]);
		candtsl << (my_lu_benefit[34] / max_lu_benefit);
		//		if landuse=101{
		//			write "kk:" +xet_khokhanchuyendoi(landuse, 34)+ "tn:"+xet_thichnghi(madvdd, 34);
		//		}

		//dua dac tinh ung vien hnk
		candbhk << chiso_bhk_lancan;
		candbhk << xet_khokhanchuyendoi(landuse, 12);
		candbhk << xet_thichnghi(madvdd, 12);
		candbhk << (my_lu_benefit[12] / max_lu_benefit);
		//dua dac tinh ung vien lnk
		candluk << chiso_luk_lancan;
		candluk << xet_khokhanchuyendoi(landuse, 6);
		candluk << xet_thichnghi(madvdd, 6);
		candluk << (my_lu_benefit[6] / max_lu_benefit);
		//dua dac tinh ung vien rst
		candlnk << chiso_lnk_lancan;
		candlnk << xet_khokhanchuyendoi(landuse, 14);
		candlnk << xet_thichnghi(madvdd, 14);
		candlnk << (my_lu_benefit[14] / max_lu_benefit);
		// bổ sung thêm ứng viên lua-tom
		cand_luatom << chiso_lua_tom_lancan;
		cand_luatom << xet_khokhanchuyendoi(landuse, 101);
		cand_luatom << xet_thichnghi(madvdd, 101);
		cand_luatom << (my_lu_benefit[101] / max_lu_benefit); // tamj thowi
		//nap cac ung vien vao danh sach candidates
		candidates << candluc;
		candidates << candtsl;
		candidates << candbhk;
		candidates << candluk;
		candidates << candlnk;
		candidates << cand_luatom;
		return candidates;
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
		//		if landuse=101{
		//			write "kk:" +xet_khokhanchuyendoi(landuse, 34)+ "tn:"+xet_thichnghi(madvdd, 34);
		//		}

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
		candlnk << xet_thichnghi(madvdd, 14);
		candlnk << 294 / 389;
		// bổ sung thêm ứng viên lua-tom
		cand_luatom << chiso_lua_tom_lancan;
		cand_luatom << xet_khokhanchuyendoi(landuse, 101);
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

	map<string, rgb>
	pcol <- ['Living with flood'::#gray, 'Optimize farmer income'::#red, 'Living with salt water'::#blue, 'Living with flood protect groundwater'::#cyan, 'Optimize  income protect groundwater'::#yellow, 'Living with salt water protect groundwater'::#green];

	aspect profile {
		draw shape color: pcol[profile];
	}

	aspect risky {
		if (risk = 1) {
			draw shape color: #blue;
		} else if (risk = 2) {
			draw shape color: #red;
		} else {
			draw shape color: #white;
		}

	} }
