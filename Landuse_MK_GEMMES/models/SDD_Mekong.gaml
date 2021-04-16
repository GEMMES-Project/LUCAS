model SDD_MX_6_10_20

import "params.gaml"
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
		create song from: song_file;
		create duong from: duong_file;
		create donvidatdai from: dvdd_file with: [dvdd::int(read('Sttdvdd'))];
		create vungbaode from: bandodebao with: [de::int(read('De'))];
		create xa from: xa_file with: [tenxa::read('Tenxa')];
		ask active_cell {
			do to_mau;
		}

		ask active_cell_dat2010 {
			do tomau;
		}

		do gan_dvdd;
		do gan_cell_hc;
		tieuchi <-
		[["name"::"lancan", "weight"::w_lancan], ["name"::"khokhan", "weight"::w_khokhan], ["name"::"thichnghi", "weight"::w_thichnghi], ["name"::"loinhuan", "weight"::w_loinhuan]];
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
				tong_luc <- tong_luc + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		ask active_cell {
			if (landuse = 6) {
				tong_luk <- tong_luk + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		ask active_cell {
			if (landuse = 100) {
				tong_lua_tom <- tong_lua_tom + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		ask active_cell {
			if (landuse = 34) {
				tong_tsl <- tong_tsl + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		ask active_cell {
			if (landuse = 12) {
				tong_bhk <- tong_bhk + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		ask active_cell {
			if (landuse = 14) {
				tong_lnk <- tong_lnk + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

		ask active_cell {
			if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 100) and (landuse != 12) and (landuse != 34) {
				tong_khac <- tong_khac + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
			}

		}

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
		ask cell_dat {
			if not (landuse in categories) {
				categories << landuse;
			}

		}

		ask cell_dat_2010 {
			if not (landuse in categories) {
				categories << landuse;
			}

		}

		write "In kiem tra categories: " + categories;
		v_kappa <- kappa(cell_dat collect (each.landuse), cell_dat collect (each.landuse_obs), categories);
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
			ask cell_dat overlapping xa_obj {
				if (landuse = 5) {
					dt_luc <- dt_luc + 100 * 100 / 10000;
				}

				if (landuse = 6) {
					dt_luk <- dt_luk + 100 * 100 / 10000;
				}

				if (landuse = 100) {
					dt_lua_tom <- dt_lua_tom + 100 * 100 / 10000;
				}

				if (landuse = 34) {
					dt_tsl <- dt_tsl + 100 * 100 / 10000;
				}

				if (landuse = 12) {
					dt_bhk <- dt_bhk + 100 * 100 / 10000;
				}

				if (landuse = 14) {
					dt_lnk <- dt_lnk + 100 * 100 / 10000;
				}

				if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 100) and (landuse != 12) and (landuse != 34) {
					tong_khac <- tong_khac + 100 * 100 / 10000; //kichs thuowcs mooix cell 50*50m tuwf duwx lieeuj rasster
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
			ask cell_dat overlapping dvdd_obj {
				madvdd <- dvdd_obj.dvdd;
			}

		}

	}

	action gan_cell_hc {
	//		ask cell_dat {
	//			landuse_obs <- cell_dat_2010[self.grid_x, self.grid_y].landuse;
	//		}

	}

	reflex main_reflex {
		ask active_cell {
			do tinh_chiso_lancan;
		}

		ask active_cell {
			do luachonksd;
			do to_mau;
		}

		do tinhtongdt;
		if (cycle = 10) {
			do tinh_kappa;
			ask cell_dat {
				grid_value <- float(landuse);
			}

			save cell_dat to: "../results/landuse_sim_" + 2005 + cycle + ".tif" type: "geotiff";
			//	do tinh_dtmx;
			//	do pause;
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

//		display bieudo type: opengl {
//			chart "Layer" type: series background: rgb(255, 255, 255) {
//				data "Tong dt lua" style: line value: tong_luc color: #red;
//				data "Tong dt tsl" style: line value: tong_tsl color: #blue;
//			}
//
//		}

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
