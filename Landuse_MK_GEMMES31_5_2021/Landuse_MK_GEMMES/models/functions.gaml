model SDD_MX_6_10_20

import "SDD_Mekong.gaml"

global {

	action load_climate {
		create tinh from: MKD_bound;
		string fpath <- "../includes/DATA.csv";
		write fpath;
		if (!file_exists(fpath)) {
			return;
		}

		file risk_csv_file <- csv_file(fpath, ";", true);
		matrix data <- (risk_csv_file.contents);
		loop i from: 0 to: data.rows - 1 {
			tinh t <- (tinh where (each.VARNAME_1 = string(data[1, i])))[0];
			ask t {
				dulieu <- data[i];
			}

		}

	}

	action tinhtongdt {
		tong_luc <- 0.0;
		tong_luk <- 0.0;
		tong_lua_tom <- 0.0;
		tong_tsl <- 0.0;
		tong_lnk <- 0.0;
		tong_bhk <- 0.0;
		tong_khac <- 0.0;
		ask active_cell {
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

		//		ask active_cell {
		//			if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 100) and (landuse != 12) and (landuse != 34) {
		//				tong_khac <- tong_khac + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
		//			}
		//
		//		}
		write "Tong dt lua:" + tong_luc;
		write "Tong dt lúa khác:" + tong_luk;
		write "Tong dt lúa tom:" + tong_lua_tom;
		write "Tong dt ts:" + tong_tsl;
		write "Tong dt rau mau:" + tong_bhk;
		write "Tong dt lnk:" + tong_lnk;
		write "Tong dt khac:" + tong_khac;
	}

	action docmatran_khokhan {
		matran_khokhan <- matrix(khokhanchuyendoi_file);
		write "Matra kho khan:" + matran_khokhan;
	}

	action docmatran_thichnghi {
		matran_thichnghi <- matrix(thichnghidatdai_file);
		write "Ma tran thich nghi" + matran_thichnghi;
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
		save "tenhxa, dt_luc,dt_luk,dt_lua_tom,dt_tsl,dt_bhk,dt_lnk,dt_khac" to: "../results/hientrang_xa.csv" type: "csv" rewrite: true;
		loop xa_obj over: xa {
		// duyệt hết các cell chồng lắp với huyện để tính diên diện tich
			dt_luc <- 0.0;
			dt_luk <- 0.0;
			dt_lua_tom <- 0.0;
			dt_tsl <- 0.0;
			dt_bhk <- 0.0;
			dt_lnk <- 0.0;
			dt_khac <- 0.0;
			//đã chỉnh đến đây
			ask active_cell overlapping xa_obj {
				if (landuse = 5) {
					dt_luc <- dt_luc + pixel_size;
				}

				if (landuse = 6) {
					dt_luk <- dt_luk + pixel_size;
				}

				if (landuse = 101) {
					dt_lua_tom <- dt_lua_tom + pixel_size;
				}

				if (landuse = 34) {
					dt_tsl <- dt_tsl + pixel_size;
				}

				if (landuse = 12) {
					dt_bhk <- dt_bhk + pixel_size;
				}

				if (landuse = 14) {
					dt_lnk <- dt_lnk + pixel_size;
				}

				if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 101) and (landuse != 12) and (landuse != 34) {
					tong_khac <- tong_khac + pixel_size; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
				}

			}
			// Lưu kết quả tính từng loại đất vào biến toại đát ương ứng của huyện
			xa_obj.tong_luc_xa <- dt_luc;
			xa_obj.tong_luk_xa <- dt_luk;
			xa_obj.tong_lua_tom_xa <- dt_lua_tom;
			xa_obj.tong_tsl_xa <- dt_tsl;
			xa_obj.tong_bhk_xa <- dt_bhk;
			xa_obj.tong_lnk_xa <- dt_lnk;
			xa_obj.tong_khac_xa <- dt_khac;
			save [xa_obj.tenxa, xa_obj.tong_luc_xa, xa_obj.tong_luk_xa, xa_obj.tong_lua_tom_xa, xa_obj.tong_tsl_xa, xa_obj.tong_bhk_xa, xa_obj.tong_lnk_xa, xa_obj.tong_khac_xa] to:
			"../results/hientrang_xa.csv" type: "csv" rewrite: false;
			write xa_obj.tenxa + '; ' + tong_luc + '; ' + tong_luk + '; ' + tong_lua_tom + ';  ' + tong_tsl + '; ' + tong_bhk + '; ' + tong_lnk + '; ' + tong_khac;
		}
		// ghu kết quả huyen ra file shapfile thuộc tính gồm 3 cột: ten xa, dt luc, dt tsl. Nếu có thểm thì cứ thêm loại đất vào
		save xa to: "../results/xa_landuse.shp" type: "shp" attributes:
		["tenxa"::tenxa, "dt_luc"::tong_luc_xa, "dt_lua_tom"::tong_lua_tom_xa, "dt_tsl"::tong_tsl_xa, "dt_luk"::tong_luk_xa, "dt_lnk"::tong_lnk_xa, "dt_bhk"::tong_bhk_xa, "dt_khac"::tong_khac_xa];
		save cell_dat to: "../results/hientrang_sim.tif" type: "geotiff";
		write "Đa tinh dien tich hien trang theo xa xong";
	}

	action gan_dvdd {
		loop dvdd_obj over: donvidatdai {
			ask active_cell overlapping dvdd_obj {
				madvdd <- dvdd_obj.dvdd;
			}

		}

	}

	action set_dyke {
		loop dyke_obj over: vungbaode {
			ask active_cell overlapping dyke_obj {
				madvdd <- dyke_obj.de;
			}

		}

	}

	action gan_cell_hc {
	//		ask cell_dat {
	//			landuse_obs <- cell_dat_2010[self.grid_x, self.grid_y].landuse;
	//		}

	}

}
