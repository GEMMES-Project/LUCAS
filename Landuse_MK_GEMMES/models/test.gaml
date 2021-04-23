model SDD_MX_6_10_20

global {
	file tiff_in <- gama_tiff_file("../includes/A.tif");
//	file tiff_in <- gama_tiff_file("../includes/2015_Mer_tasmax_dbsc.tif");
	//	file tiff_in<-gama_tiff_file("../includes/2015_Mer_pr_dbsc.tif");
	file cell_file <- grid_file("../includes/Landuse_2015.tif");
	list<cell_dat> active_cell <- [];

	init {
		float start <- machine_time;
		ask active_cell {
			Tas_max <- list<float>(read_bands(tiff_in, int(grid_x * (2783/1113 )), int(grid_y * (2824/1130 ))));
//			write Tas_max;
			color <- rgb((Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28));
		}

		float end <- machine_time;
		write end - start;
	}

}

grid cell_dat file: cell_file control: reflex neighbors: 8 {
	rgb color;
	list<float> Tas_max <- [];

	init {
	/*
		 * 1113 1130
		 * 3457 2730
		 * 1113 1130
		 * 2783 2824
		 */
		if (grid_value != 8.0) {
			active_cell <+ self;
		} else {
			do die;
		}

	}

	reflex ss {
			color <- rgb((Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28)*(Tas_max[cycle mod 12]-28));
	}

}

experiment "my_GUI_xp" type: gui {
	output {
		display mophong type: java2D {
			grid cell_dat;
		}

	}

}
 