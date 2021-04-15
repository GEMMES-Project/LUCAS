model cell_dat
import "../params.gaml" 

grid cell_dat_2010 file: cell_dat_2010_file control: reflex frequency: 8 {
	int landuse <- int(grid_value);
	rgb color;

	init {
		if (grid_value = 8) {
			do die;
		}

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

