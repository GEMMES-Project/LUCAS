model SDD_MX_6_10_20

global {
//	file tiff_in <- gama_tiff_file("../includes/A.tif");
//	file tiff_in <- gama_tiff_file("../includes/2015_Mer_tasmax_dbsc.tif");
//	file tiff_in<-gama_tiff_file("../includes/2015_Mer_pr_dbsc.tif");
//	file cell_file <- grid_file("../includes/Landuse_2015.tif");
//	list<cell_dat> active_cell <- [];
	shape_file shp <- shape_file("../includes/VNM_1.shp");

	init {
		float start <- machine_time;
		create adm from: shp;
		//		ask active_cell {
		//			Tas_max <- list<float>(read_bands(tiff_in, int(grid_x * (2783/1113 )), int(grid_y * (2824/1130 ))));
		////			write Tas_max;
		//			color <- rgb((Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28));
		//		}
		string fpath <- "../includes/DATA.csv";
		write fpath;
		if (!file_exists(fpath)) {
			return;
		}

		file risk_csv_file <- csv_file(fpath, ";", false);
		matrix data <- (risk_csv_file.contents);
		list<adm> aa <- [];
		loop i from: 1 to: data.rows - 1 {
			aa <- aa + adm where (each.VARNAME_1 = string(data[1, i]));
		}
		ask adm{
			if (!(self in aa)){ do die;}
		}
		save adm to: "../includes/MKD_1.shp" type: "shp" attributes:
		["ID"::int(self), "NAME_1"::NAME_1, "GID_1"::GID_1, "NAME_2"::NAME_2, "GID_2"::GID_2, "NAME_3"::NAME_3, "GID_3"::GID_3, "VARNAME_1"::VARNAME_1, "VARNAME_2"::VARNAME_2, "VARNAME_3"::VARNAME_3];
		float end <- machine_time;
		write end - start;
	}

}

species adm {
	string NAME_1;
	string NAME_2;
	string NAME_3;
	string GID_1;
	string GID_2;
	string GID_3;
	string VARNAME_1;
	string VARNAME_2;
	string VARNAME_3;
	string STT;
}

//grid cell_dat file: cell_file control: reflex neighbors: 8 {
//	rgb color;
//	list<float> Tas_max <- [];
//
//	init {
//	/*
//		 * 1113 1130
//		 * 3457 2730
//		 * 1113 1130
//		 * 2783 2824
//		 */
//		if (grid_value != 8.0) {
//			active_cell <+ self;
//		} else {
//			do die;
//		}
//
//	}
//
//	reflex ss {
//			color <- rgb((Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28));
//	}
//
//}
experiment "my_GUI_xp" type: gui {
	output {
	//		display mophong type: java2D {
	//			grid cell_dat;
	//		}

	}

}
 