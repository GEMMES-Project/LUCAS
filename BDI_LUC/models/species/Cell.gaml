/***
* Name: Legend
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/

@no_experiment

model Cell
import "../Parameters.gaml"

grid Cell file: netcdf_sample {

	init {
		color <- rgb(grid_value);
	}

}

