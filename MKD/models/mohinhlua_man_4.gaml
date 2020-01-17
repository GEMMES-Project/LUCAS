/**
* Name: mohinhluaman
* Author: Truong Chi Quang, Huynh Quang Nghi
* Description: Describe here the model and its experiments
* Tags: Tag1, Tag2, TagN
*/
model mohinhluaman


global
{
/** Insert the global definitions, variables and actions here */
	file lua_file <- grid_file("../includes/dulieuthaydoi/input_mohinh/input_lua_muakho_2016_asc.asc");
	file lua_validate_file <- grid_file("../includes/dulieuthaydoi/input_mohinh/lua_muakho2016_kiemchung_asc.asc");
//	file lua_file <- shape_file("../includes/bandolua_2014.shp");
	//	file lua_file_nb <- shape_file("../includes/bandolua_2014_nb.shp");
//	file river_file <- shape_file("../includes/SONG_TN106_region.shp");
	//	file diked_file <- shape_file("../includes/vungngapman_region.shp");
	file vungthuyloi_file <- shape_file("../includes/dulieuthaydoi/input_mohinh/vungthuyloi_risk.shp");
	map<int, string> legend_map <- [2::"Lúa 2 vụ", 3::"Lúa-màu"];
	map<int, rgb> legend_color <- [ 1::# green, 0::# white];
	map<int, rgb> legend_color_v <- [1::# yellow, 0::# white];
	map<int, rgb> color_man <- [0::# white, 4::# yellow, 8::# yellowgreen, 15::# lightcoral];
	geometry shape <- envelope(lua_file);
	float step <- 1 # week;
	date starting_date <- date([2016, 1, 1, 0, 0, 0]);
//	bool rain_season -> { current_date.month >= 6 and current_date.month < 5 };
//	river the_main_river;
//	list<cell_lua> parcels_not_diked update: cell_lua where (not each.diked);
//	list<int> idx <- [346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358];

	init
	{
//		create vungngapman from: vungthuyloi_file with: [cao2016::int(read("cao2016")), thuongnien::int(read("thuongnien"))]
//		{
//		//			write cao2016;
//		}
		create vungthuyloi from:vungthuyloi_file with: [risk::float(read("risk")), tenvung::string(read("Tenvung"))]{
			write tenvung;
		}
		
		ask  vungthuyloi{
			list<cell_lua> tmp<-(cell_lua where (each.risk=-1.0)) where (each intersects self.shape);
			ask tmp{
				risk<-myself.risk;
			}
		}
		ask cell_lua where (each.risk = -1.0){
			do die;
		}
		
		//		create vungngapman from:diked_file;
//		create river from: river_file;
//		the_main_river <- river at 356;
//		the_main_river.is_main_river <- true;
//		loop i over: idx
//		{
//			river[i].diked <- false;
//		}

	}

//	reflex salinity_diffusion
//	{
//		ask river
//		{
//			do diffusion;
//		}
//
//		ask river
//		{
//			do apply_diffusion;
//		}
//
//
//
//	}
//
//	reflex salt_intrusion
//	{
//		if (not rain_season)
//		{
//			the_main_river.river_salt_level <- 30.0;
//			the_main_river.river_salt_level_tmp <- 30.0;
//		} else
//		{
//			if (the_main_river.river_salt_level > 3)
//			{
//				the_main_river.river_salt_level <- the_main_river.river_salt_level - 100;
//				the_main_river.river_salt_level_tmp <- the_main_river.river_salt_level - 100;
//			}
//
//		}
//
//	}

	reflex end_simulation when: current_date.year = 2016 and current_date.month = 12 and current_date.day >= 23
	{
		do pause;
	}

}

//species river
//{
//	rgb color <- # blue;
//	string type;
//	bool diked <- true;
//	list<cell_lua> contactParcel <- cell_lua at_distance 100; // overlapping (self);
////	list<cell_lua> availableParcel -> { contactParcel where (not each.diked) };
//	list neighborhood <- river overlapping (self);
//	list availableNeighbours -> { self.neighborhood where (not each.diked) };
//	float river_salt_level <- 0.0;
//	float river_salt_level_tmp <- 0.0;
//	bool is_main_river <- false;
//	action diffusion
//	{
//		if (is_main_river = false)
//		{
//			ask (availableNeighbours)
//			{
//				myself.river_salt_level_tmp <- myself.river_salt_level_tmp + river_salt_level;
//			}
//
//		}
//
//	}
//
//	action apply_diffusion
//	{
//		river_salt_level <- river_salt_level_tmp;
//		if (river_salt_level > 30)
//		{
//			river_salt_level <- 30.0;
//		}
//
//		river_salt_level_tmp <- 0.0;
//	}
//
//
//	aspect default
//	{
//	//		draw shape color: rgb(rnd(255), rnd(255), rnd(255)); // border: color;
//		draw shape color: hsb(0.6 - 0.1 * (30 - min([1.0, (max([0.0, river_salt_level - 2])) / 30])), 1.0, 1.0);
//
//		//		draw shape color: hsb(0.4 - 0.4 * (min([1.0, (max([0.0, self.river_salt_level - 2])) / 30])), 1.0, 1.0) border:#black;
//
//	}
//
//}

species vungthuyloi
{
	rgb color <- # red;
	float risk<-0.0;
	string tenvung<-"";
	

	aspect thuongnien
	{
		draw shape color: rgb(risk*255) ;//hsb(0.6 - 0.1 * (30 - min([1.0, (max([0.0, risk - 2])) / 30])), 1.0, 1.0);
	}

}

grid cell_lua file: lua_file use_individual_shapes: false use_regular_agents: false neighbors: 8{
	float damage<-0.0;
	float risk<--1.0;
	
	int landuse<- int(grid_value);
	rgb color <- legend_color[int(grid_value)];
	reflex gogo{

		if(flip(risk/10)){
			damage<-damage+0.3;
		}
		if(damage>0.7){
			color<-#white;
		}
	}
	aspect aa{
		draw shape color:rgb(risk*255);
	}
}

//grid cell_lua_validate file: lua_validate_file use_individual_shapes: false use_regular_agents: false neighbors: 8{	
//	init{
//		if(grid_value=0){
//			do die;
//		}
//	}
//	int landuse<- int(grid_value);
//	rgb color <- legend_color_v[int(grid_value)];
//}
experiment mohinhluaman type: gui
{
/** Insert here the definition of the input and output of the model */
	output
	{
		display "Hien trang lua 2016" //type: opengl

		{
//			overlay position: { 5, 5 } size: { 350 # px, (90) # px } background: # black transparency: 0.5 border: # black rounded: true
//			{
//				draw "Date: " + current_date.day + " - " + current_date.month + " - " + current_date.year at: { 20 # px, 30 # px } color: # white font: font("SansSerif", 24, # bold);
////				draw "DT: " + sum((cell_lua where (each.code = 3)) collect each.dientich) at: { 20 # px, 70 # px } color: # white font: font("SansSerif", 24, # bold);
//			}

//			species vungthuyloi aspect:thuongnien  transparency:0.5;
			grid cell_lua;
			
//			grid cell_lua_validate transparency:0.5;
//			species river aspect: default;
		}


//		display "Hien trang ngap man" //type: opengl
//
//		{
//			overlay position: { 5, 5 } size: { 350 # px, (90) # px } background: # black transparency: 0.5 border: # black rounded: true
//			{
//				draw "Date: 20 - 3 - 2016" at: { 20 # px, 30 # px } color: # white font: font("SansSerif", 24, # bold);
////				draw "DT: " +tongdientichL3  at: { 20 # px, 70 # px } color: # white font: font("SansSerif", 24, # bold);
//
//				//				draw "Date: " + current_date.day + " - " + current_date.month + " - " + current_date.year at: { 20 # px, 30 # px } color: # white font: font("SansSerif", 24, # bold);
//			}
//
//			species vungngapman aspect: cao2016 transparency: 0.18;
//			//			species vungngapman aspect: thuongnien;
//			species river aspect: default;
//
//		}

	}

}
