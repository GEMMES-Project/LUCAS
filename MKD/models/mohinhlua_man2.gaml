/**
* Name: mohinhluaman
* Author: Truong Chi Quang, Huynh Quang Nghi
* Description: Describe here the model and its experiments
* Tags: Tag1, Tag2, TagN
*/

model mohinhluaman

global {
	/** Insert the global definitions, variables and actions here */
	file lua_file <- grid_file("../includes/lua2014_asc.asc");
	file river_file <- shape_file("../includes/SONG_TN106_region.shp");
	file diked_file <- shape_file("../includes/vungngapman_region.shp");
	file vungthuyloi_file <- shape_file("../includes/vungngapman_region.shp");
	
	map<int, string> legend_map <- [2::"Lúa 2 vụ", 3::"Lúa-màu"];
	map<int, rgb> legend_color <- [2::#yellow, 3::#green, 0::#white];
	map<int,rgb> color_man <- [0::#white,4::#yellow, 8::#yellowgreen, 15::#lightcoral];
	
	init {
		
		create river from:river_file;
		create vungthuyloi from:vungthuyloi_file;
		create vungngapman from:diked_file;
		
	}
}

species river{
	rgb color <-#blue;
	string type;
	aspect default {
		draw shape color:color border:color;
	}
}
species vungngapman{
	rgb color<- #red;
	aspect default {
		draw shape color:color border:color;
	}
}
species vungthuyloi{
	rgb color<- #red;
	aspect default {
		draw shape color:color border:color;
	}
}
species canals{
	rgb color <-#blue;
	aspect default {
		draw shape color:color border:color;
	}
}
grid cell_lua file: lua_file use_individual_shapes: false use_regular_agents: false neighbours: 8{
	int landuse<- int(grid_value);
	rgb color <- legend_color[int(grid_value)];
}
experiment mohinhluaman type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display "Hien trang lua 2014" type:opengl{ 
			grid cell_lua;
			species river aspect:default;
		}
	}
}
