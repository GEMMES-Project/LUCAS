model SDD_MX_6_10_20

global control: reflex {
	file cell_file <- grid_file("../includes/lu_100x100_mx_2005_new.tif");
	file MKD_bound <- shape_file("../includes/MKD.shp");
	geometry shape <- envelope(MKD_bound);
	list<cell_dat> active_cell <- cell_dat where (each.grid_value != 0.0);
	float tong_luc;
	float tong_tsl;
	float tong_bhk;
	file song_file <- shape_file('../includes/rivers_myxuyen_region.shp');
	file duong_file <- shape_file('../includes/road_myxuyen_region.shp');
	file dvdd_file <- shape_file("../includes/landunit_mx_region.shp");
	file bandodebao <- shape_file("../includes/soctrang_debao2010_region.shp");
	matrix matran_khokhan;
	file khokhanchuyendoi_file <- csv_file("../includes/khokhanchuyendoi.csv", false);
	matrix matran_thichnghi;
	file thichnghidatdai_file <- csv_file("../includes/landsuitability.csv", false);
	float w_lancan <- 0.2;
	list tieuchi;
	float v_kappa <- 0.0;
	file cell_dat_2010_file <- grid_file("../includes/lu_100x100_mx_2015_new.tif");
	list<cell_dat_2010> active_cell_dat2010 <- cell_dat_2010 where (each.grid_value != 0.0);
	file xa_file <- shape_file("../includes/commune_myxuyen.shp");
	float tong_lnk;
	float tong_luk;
	float tong_khac;
	float dt_luc;
	float dt_luk;
	float dt_lua_tom;
	float dt_lnk;
	float dt_bhk;
	float dt_tsl;
	float dt_khac;
	float w_khokhan <- 0.7;
	float w_thichnghi <- 0.8;
	float tong_lua_tom;
	float w_loinhuan <- 0.7;
	float w_flip <- 0.02;

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
		ask cell_dat {
			landuse_obs <- cell_dat_2010[self.grid_x, self.grid_y].landuse;
		}

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

}

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

	init {
	}

	action to_mau {
		if (landuse = 5) {
			color <- #yellow;
		}

		if (landuse = 37) {
			color <- rgb(170, 255, 255);
		}

		if (landuse = 6) {
			color <- rgb(196, 196, 0);
		}

		if (landuse = 12) {
			color <- #lightgreen;
		}

		if (landuse = 14) {
			color <- #darkgreen;
		}

		if (landuse = 34) {
			color <- #cyan;
		}

		if (landuse = 100) {
			color <- rgb(40, 150, 120);
		}

		if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 100) and (landuse != 12) and (landuse != 34) {
			color <- #gray;
		}

	}

	action tinh_chiso_lancan {

	//so cell xung quanh cuar mot cell co kieu su dung la luk/8 (8-tong so o lan can cua moi o)
		list<cell_dat> cell_lancan <- (self neighbors_at 2); //1 ban kinh lan can laf 2 cell = 8 cell xung quanh 1 cell
		//dem so cell trong cell_lancan co landuse=6 (6:luk)
		chiso_luc_lancan <- (cell_lancan count (each.landuse = 5)) / 25;
		chiso_luk_lancan <- (cell_lancan count (each.landuse = 6)) / 25;
		chiso_bhk_lancan <- (cell_lancan count (each.landuse = 12)) / 25;
		chiso_lnk_lancan <- (cell_lancan count (each.landuse = 14)) / 25;
		chiso_tsl_lancan <- (cell_lancan count (each.landuse = 34)) / 25;
		chiso_lua_tom_lancan <- (cell_lancan count (each.landuse = 100)) / 25;
		//chiso_khac_lancan <-(cell_lancan count (each.landuse=1))/8;

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
		if (landuse = 5 or landuse = 6 or landuse = 12 or landuse = 14 or landuse = 34 or landuse = 100) {
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
				if (xet_thichnghi(madvdd, 100) > 0) {
					landuse <- 100;
				}

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
		cand_luatom << xet_thichnghi(madvdd, 100);
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

species song control: reflex {
	int id;
	rgb color <- rgb(128, 255, 255);

	init {
	}

}

species donvidatdai control: reflex {
	int dvdd;
	rgb color <- rgb(rnd(255), rnd(255), rnd(255));

	init {
	}

}

species duong control: reflex {
	int id;
	rgb color <- #red;

	init {
	}

}

species vungbaode control: reflex {
	int de;
	rgb color;

	init {
	}

}

grid cell_dat_2010 file: cell_dat_2010_file control: reflex frequency: 8 {
	int landuse <- int(grid_value);
	rgb color;

	init {
	}

	action tomau {
		if (landuse = 5) {
			color <- rgb(196, 196, 0);
		}

		if (landuse = 37) {
			color <- rgb(170, 255, 255);
		}

		if (landuse = 6) {
			color <- #yellow;
		}

		if (landuse = 12) {
			color <- #lightgreen;
		}

		if (landuse = 14) {
			color <- #darkgreen;
		}

		if (landuse = 34) {
			color <- #cyan;
		}

		if (landuse = 100) {
			color <- rgb(40, 150, 120);
		}

		if (landuse > 0) and (landuse != 14) and (landuse != 5) and (landuse != 6) and (landuse != 100) and (landuse != 12) and (landuse != 34) {
			color <- #gray;
		}

	}

}

species xa control: reflex {
	string tenxa;
	float tong_luc_xa;
	float tong_luk_xa;
	float tong_bhk_xa;
	float tong_khac_xa;
	float tong_tsl_xa;
	float tong_lnk_xa;
	float tong_lua_tom_xa;

	init {
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

		display bieudo type: opengl {
			chart "Layer" type: series background: rgb(255, 255, 255) {
				data "Tong dt lua" style: line value: tong_luc color: #red;
				data "Tong dt tsl" style: line value: tong_tsl color: #blue;
			}

		}

	}

}

experiment "can_chinh" type: batch repeat: 1 keep_seed: true until: (time > 10) {
	parameter "lan can" var: w_lancan min: 0.7 max: 1.0 step: 0.1;
	parameter "TN" var: w_thichnghi min: 0.6 max: 0.8 step: 0.1;
	parameter "Kho khan" var: w_khokhan min: 0.6 max: 0.8 step: 0.1;
	parameter "LN" var: w_loinhuan min: 0.1 max: 0.3 step: 0.1;
	parameter "Flip" var: w_flip min: 0.02 max: 0.15 step: 0.03;
	method exhaustive maximize: v_kappa;
}
