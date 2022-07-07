model SDD_MX_6_10_20

import "params.gaml"
import "entities/AEZ.gaml"
import "entities/province.gaml"
import "entities/land_subsidence.gaml"
import "entities/land_unit.gaml"
import "entities/dyke_protected.gaml"

global {

//	action load_climate_PR {
//		string fpath <- "../includes/data_sample/district_weather_proj_model1.csv";
//		write fpath;
//		if (!file_exists(fpath)) {
//			return;
//		}
//
//		file risk_csv_file <- csv_file(fpath, ";", true);
//		matrix data <- (risk_csv_file.contents);
//		loop i from: 0 to: data.rows - 1 {
//			huyen t <- (huyen where (each.ID_1 = int(data[0, i]) and each.ID_2 = int(data[2, i])))[0];
//			ask t {
//				data_pr <- data row_at i;
//			}
//
//		}
//
//	}
	action load_climate_TAS {
	//		string fpath <- "../includes/DATA_TAS.csv";
		string fpath <- risk_csv_file_path; // "../includes/data_sample/district_weather_proj_model1.csv";
		write fpath;
		if (!file_exists(fpath)) {
			return;
		}

		file risk_csv_file <- csv_file(fpath, ",", false);
		matrix data <- (risk_csv_file.contents);
		loop i from: 1 to: data.rows - 1 {
		//			if (length(district where (each.climat_cod = int(data[0, i]))) = 0) {
		//				write int(data[0, i]);
		//			}
			district t <- map_district_by_climat_cod[int(data[0, i])]; //(district where (each.climat_cod = int(data[0, i])))[0];
			//			write "" + int(data[1, i]) + "," + int(data[2, i]);
			ask t {
				data_tas["" + int(data[1, i]) + "," + int(data[2, i])] <- float(data[4, i]); //prcipitation is in column 5 in data file
				data_pr["" + int(data[1, i]) + "," + int(data[2, i])] <- float(data[6, i]); // prcipitation is in column 5 in data file
			}

		}

		/*
 *  60 chỉnh thành 59 để xài chung dữ liệu -
 * Get the nearest station of mising code stations 
72,73 -> 71
90->89
 
 */
		ask (district where (each.climat_cod = 60)) {
			district t <- (district where (each.climat_cod = 59))[0];
			data_tas <- t.data_tas;
			data_pr <- t.data_pr;
		}

		ask (district where (each.climat_cod = 72 or each.climat_cod = 73)) {
			district t <- (district where (each.climat_cod = 71))[0];
			data_tas <- t.data_tas;
			data_pr <- t.data_pr;
		}

		ask (district where (each.climat_cod = 90)) {
			district t <- (district where (each.climat_cod = 89))[0];
			data_tas <- t.data_tas;
			data_pr <- t.data_pr;
		}

	}

	//	action tinhtongdt {
	//		tong_luc <- 0.0;
	//		total_2rice_luk <- 0.0;
	//		total_rice_shrimp <- 0.0;
	//		tong_tsl <- 0.0;
	//		total_fruit_tree_lnk <- 0.0;
	//		tong_bhk <- 0.0;
	//		total_rice_shrimp <- 0.0;
	//		ask active_cell {
	//		}
	//
	//		//		ask active_cell {
	//		//			if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 100) and (landuse != 12) and (landuse != 34) {
	//		//				tong_khac <- tong_khac + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
	//		//			}
	//		//
	//		//		}
	//		write "Tong dt lua:" + tong_luc;
	//		write "Tong dt lúa khác:" + total_2rice_luk;
	//		write "Tong dt lúa tom:" + total_rice_shrimp;
	//		write "Tong dt ts:" + tong_tsl;
	//		write "Tong dt rau mau:" + tong_bhk;
	//		write "Tong dt lnk:" + total_fruit_tree_lnk;
	//		write "Tong dt khac:" + total_rice_shrimp;
	//	}
	action load_cost_benefit_data {
		matrix cb_matrix <- matrix(csv_file("../includes/cost_benefit.csv", true));
		loop i from: 0 to: cb_matrix.rows - 1 {
			int yy <- int(cb_matrix[0, i]);
			lu_cost <+ (yy)::float(cb_matrix[1, i]);
			lu_benefit <+ (yy)::float(cb_matrix[2, i]);
		}

		max_lu_benefit <- max(lu_benefit collect each);
		write "max_lu_benefit " + max_lu_benefit;
		write "cost benefit " + lu_cost + lu_benefit;
	}

	action update_benefit_from_landuse_change {
		loop k over: lu_benefit.keys {
			lu_benefit[k] <- lu_benefit_total[k] / lu_benefit_cnt[k];
			lu_benefit_total[k] <- 0;
			lu_benefit_cnt[k] <- 0;
		}

	}

	action load_macroeconomic_data {
		matrix macro_matrix <- matrix(macroeconomic_file);
		loop i from: 2 to: macro_matrix.rows - 1 {
			int yy <- int(macro_matrix[0, i]);
			lending_rate <+ "" + yy::float(macro_matrix[1, i]);
		}

		write "lending_rate map:" + lending_rate;
	}

	action load_ability_data {
		ability_matrix <- matrix(ability_file);
		loop i from: 1 to: ability_matrix.rows - 1 {
			int landuse1 <- int(ability_matrix[0, i]);
			loop j from: 1 to: ability_matrix.columns - 1 { //do tung cot cua matran
				int landuse2 <- int(ability_matrix[j, 0]);
				ability_map <+ "" + landuse1 + " " + landuse2::float(ability_matrix[j, i]);
			}

		}

		write "Ability map:" + ability_map;
	}

	action load_suitability_data {
		suitability_matrix <- matrix(suitability_file);
		loop i from: 1 to: suitability_matrix.rows - 1 {
			int madvdd_ <- int(suitability_matrix[0, i]);
			loop j from: 1 to: suitability_matrix.columns - 1 { //do tung cot cua matran
				int LUT <- int(suitability_matrix[j, 0]);
				suitability_map <+ "" + madvdd_ + " " + LUT::float(suitability_matrix[j, i]);
			}

		}

		write "Suitability Map" + suitability_map;
	}

	action load_profile_adaptation {
		profile_matrix <- matrix(profile_file);
		loop i from: 1 to: profile_matrix.rows - 1 {
			profile_map <+ ("" + profile_matrix[1, i] + profile_matrix[2, i] + profile_matrix[3, i])::("" + profile_matrix[0, i]);
			loop j from: 4 to: profile_matrix.columns - 1 { //do tung cot cua matran 
				supported_lu_type <+ "" + profile_matrix[0, i] + profile_matrix[j, 0]::float(profile_matrix[j, i]);
			}

		}

		write "Profile map" + profile_map;
		write "supported_lu_type " + supported_lu_type;
	}

	action tinh_kappa {
		list<int> categories <- [0];
		ask active_cell {
			if not (landuse in categories) {
				categories << landuse;
			}

		}

		//		ask cell_dat_2010 {
		//			if not (landuse in categories) {
		//				categories << landuse;
		//			}
		//
		//		}
		write "In kiem tra categories: " + categories;
		v_kappa <- kappa(active_cell collect (each.landuse), active_cell collect (each.landuse_obs), categories);
		write "Kappa: " + v_kappa;
	}

	action tinh_dtmx {
		save "prov_name, dt_luc,dt_luk,dt_lua_tom,dt_tsl,dt_bhk,dt_lnk,dt_khac" to: "../results/hientrang_xa.csv" type: "csv" rewrite: true;
		loop tinh_obj over: district {
		// duyệt hết các cell chồng lắp với huyện để tính diên diện tich
			area_3rice_luc <- 0.0;
			area_2rice_luk <- 0.0;
			area_rice_shrimp <- 0.0;
			area_shrimp_tsl <- 0.0;
			area_vegetable_bhk <- 0.0;
			area_fruit_tree_lnk <- 0.0;
			area_other <- 0.0;
			//đã chỉnh đến đây
			ask active_cell overlapping tinh_obj {
				if (landuse = 5) {
					area_3rice_luc <- area_3rice_luc + pixel_size;
				}

				if (landuse = 6) {
					area_2rice_luk <- area_2rice_luk + pixel_size;
				}

				if (landuse = 101) {
					area_rice_shrimp <- area_rice_shrimp + pixel_size;
				}

				if (landuse = 34) {
					area_shrimp_tsl <- area_shrimp_tsl + pixel_size;
				}

				if (landuse = 12) {
					area_vegetable_bhk <- area_vegetable_bhk + pixel_size;
				}

				if (landuse = 14) {
					area_fruit_tree_lnk <- area_fruit_tree_lnk + pixel_size;
				}

				if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 101) and (landuse != 12) and (landuse != 34) {
					total_rice_shrimp <- total_rice_shrimp + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
				}

			}
			// Lưu kết quả tính từng loại đất vào biến toại đát ương ứng của huyện
			save [tinh_obj.NAME_1, area_3rice_luc, area_2rice_luk, area_rice_shrimp, area_shrimp_tsl, area_vegetable_bhk, area_fruit_tree_lnk, area_other] to:
			"../results/hientrang_tinh.csv" type: "csv" rewrite: false;
			write
			tinh_obj.NAME_1 + '; ' + area_3rice_luc + '; ' + area_2rice_luk + '; ' + area_rice_shrimp + ';  ' + area_shrimp_tsl + '; ' + area_vegetable_bhk + '; ' + area_fruit_tree_lnk + '; ' + area_other;
		}
		// ghu kết quả huyen ra file shapfile thuộc tính gồm 3 cột: ten xa, dt luc, dt tsl. Nếu có thểm thì cứ thêm loại đất vào
		save district to: "../results/tinh_landuse.shp" type: "shp" attributes:
		["tentinh"::NAME_1, "dt_luc"::area_3rice_luc, "dt_lua_tom"::area_rice_shrimp, "dt_tsl"::area_shrimp_tsl, "dt_luk"::area_2rice_luk, "dt_lnk"::area_fruit_tree_lnk, "dt_bhk"::area_vegetable_bhk, "dt_khac"::area_other];
		save farming_unit to: "../results/hientrang_sim.tif" type: "geotiff";
		write "Đa tinh dien tich hien trang theo xa xong";
	}

	action gan_dvdd {
		ask active_cell parallel: true {
			madvdd <- field_land_unit[location];
		}
		//		loop dvdd_obj over: land_unit {
		//			ask active_cell overlapping dvdd_obj {
		//				madvdd <- dvdd_obj.dvdd;
		//			}
		//
		//		}

	}

	//	action set_dyke {
	//		loop dyke_obj over: dyke_protected {
	//			ask active_cell overlapping dyke_obj {
	//				madvdd <- dyke_obj.de;
	//			}
	//
	//		}
	//
	//	}
	//	action gan_cell_hc {
	//	//		ask cell_dat {
	//	//			landuse_obs <- cell_dat_2010[self.grid_x, self.grid_y].landuse;
	//	//		}
	//
	//	}

}
