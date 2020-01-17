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
	file lua_file_validate <- grid_file("../includes/dulieuthaydoi/input_mohinh/lua_muakho2016_kiemchung_asc.asc");
	//	file lua_file <- shape_file("../includes/bandolua_2014.shp");
	//	file lua_file_nb <- shape_file("../includes/bandolua_2014_nb.shp");
	file river_file <- shape_file("../includes/SONG_TN106_region.shp");
	//	file diked_file <- shape_file("../includes/vungngapman_region.shp");
	file vungthuyloi_file <- shape_file("../includes/dulieuthaydoi/input_mohinh/vungthuyloi_risk.shp");
	file vungngapman_file <- shape_file("../includes/vungngapman_region.shp");
	matrix domancaonhat <- matrix(csv_file("../includes/dulieuthaydoi/domancaonhat_tram.csv"));
	map<int, string> legend_map <- [2::"Lúa 2 vụ", 3::"Lúa-màu"];
	map<int, rgb> legend_color <- [1::# green, 0::# white];
	map<int, rgb> legend_color_v <- [-1::# white, 1::# black, 0::# white];
	map<int, rgb> color_man <- [0::# white, 4::# yellow, 8::# yellowgreen, 15::# lightcoral];
	geometry shape <- envelope(lua_file);
	float step <- 1 # week;
	date starting_date <- date([2016, 2, 28, 0, 0, 0]);
	float salinity_threshold <- 4.0; //28.0
	float damage_adjust <- 0.5; //0.1
	float damage_threshold <- 0.5; //0.4
	float risk_threshold <- 5.0; //8.0

	//		float salinity_threshold<-24.0;
	//		float damage_adjust<-0.4;
	//		float damage_threshold<-0.8;
	//		float risk_threshold<-1.0;

	//	bool rain_season -> { current_date.month >= 6 and current_date.month < 5 };
	//	river the_main_river;
	//	list<cell_lua> parcels_not_diked -> { cell_lua where (not each.diked) };
	//	list<int> idx <- [346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358];
	//	float tongdientichL3<-sum((cell_lua where (each.code = 3)) collect each.dientich);
	list<cell_lua> cell_lua_available;
	init
	{
		create vungngapman from: vungngapman_file with: [cao2016::int(read("cao2016")), thuongnien::int(read("thuongnien"))]
		{
		//			write cao2016;
		}

		create vungthuyloi from: vungthuyloi_file with: [risk::float(read("risk")), tenvung::string(read("Tenvung")), tramquantr::string(read("tramquantr"))]
		{
		//			write tramquantr;
		}

		loop i from: 0 to: domancaonhat.rows - 1
		{
			string ten <- domancaonhat[0, i];
			ask (vungthuyloi where (each.tramquantr = ten))
			{
				domanmax <+ float(domancaonhat[2, i]);
			}

		}

		ask vungthuyloi
		{
		//			write "" + tramquantr + " " + domanmax;
			cells <- (cell_lua overlapping self); //  where (each.shape.location distance_to self.location < 500);
			ask cells
			{
				risk <- myself.risk;
				dd <- (self.shape.location distance_to myself.location) + 0.1;

				//				color<-#red;
			}

			float mm <- max(cells collect each.dd);
			ask cells
			{
				dd <- dd / mm;
			}

		}

		//		ask vungngapman
		//		{
		//			list<cell_lua> ss <- cell_lua where (each intersects self.shape);
		//			ask ss
		//			{
		//				current_salinity <- float(myself.thuongnien);
		//				priority_salt <- current_salinity;
		//			}
		//		}
		//		ask cell_lua
		//		{
		//			do ss;
		//		}
		//
		//		objective <- length(cell_lua_validate where (each.color = # black));
		//		write "init " + salinity_threshold + " " + damage_adjust + " " + damage_threshold + " " + risk_threshold + " " + objective;
		//		cell_lua_available<-cell_lua where (each.grid_value> 0);
	}

	reflex salinity_diffusion
	{
		ask vungthuyloi
		{
			if (current_date.month > 1 and current_date.month < 7 and length(domanmax) > 0)
			{
				float tmp <- domanmax[current_date.month - 2];
				ask cells
				{
					current_salinity <- tmp;
				}

			}

		}
		//		ask cell_lua where (each.grid_value>0){
		//			do diffusion;
		//		}
		//		ask cell_lua where (each.grid_value>0){
		//			do update_salinity;
		//		}
	}

	int objective;
	float kappa;
	//Calculate Fuzzy Kappa
	action call_fuzzy_kappa
	{

	//		Calculate fuzzy Kappa
		int nb_LUT <- length(legend_color.keys); // number of land-use types
		bool use_fuzzy_kappa_sim <- false;
		float distance_kappa <- 200.0; // Distance for calculation Fuzzy Kappa
		matrix<float> fuzzy_categories; // Categories to calculate the FKappa
		matrix<float> fuzzy_transitions; // Categories to calculate the FKapp
		list<float> nb_per_cat_obs; // Categories to transition matrix 
		list<float> nb_per_cat_sim; // Number of categories observed 
		list<int> categories <- legend_color.keys;
		write "Cat:" + categories;
		//		ask cell {
		//			if (not (landuse in categories)) {categories << landuse; }
		//		}
		//		ask Landuse_obs{
		//			if (not (landuse_obs in categories)) {categories << landuse_obs;}
		//		}
		fuzzy_categories <- 0.0 as_matrix { nb_LUT, nb_LUT };
		loop i from: 0 to: nb_LUT - 1
		{
			fuzzy_categories[i, i] <- 1.0;
		}

		fuzzy_transitions <- 0.0 as_matrix { nb_LUT * nb_LUT, nb_LUT * nb_LUT };
		loop i from: 0 to: (nb_LUT * nb_LUT) - 1
		{
			fuzzy_transitions[i, i] <- 1.0;
		}

		list<float> similarity_per_agents <- [];
		kappa <- kappa(cell_lua collect (int(each.grid_value)), cell_lua collect (each.rice_obs), categories);
		write 'He so kappa:' + kappa;
		//		loop c over: listLUT {
		//			list<float> area_shape_c <- Landuse_obs collect (each.shape.area);
		//			nb_per_cat_obs << sum(area_shape_c );
		//			nb_per_cat_sim << sum((Parcel where (each.landuse = c)) collect (each.shape.area)); 
		//		}
		//		pad <- percent_absolute_deviation(nb_per_cat_obs,nb_per_cat_sim);
	}

	bool is_batch <- false;
	reflex end_simulation when: current_date.year = 2016 and current_date.month = 5 and current_date.day >= 14
	{
		ask cell_lua
		{
			do compute;
		}

		if (length(cell_lua where (each.dead)) > 0)
		{
			objective <- length(cell_lua_validate where (each.color = # black));
			do call_fuzzy_kappa;
			write "" + salinity_threshold + " " + damage_adjust + " " + damage_threshold + " " + risk_threshold + " " + objective;
		}

		if (!is_batch)
		{
			do pause;
		}

	}

}

species vungngapman
{
	rgb color <- # red;
	int thuongnien <- 0;
	int cao2016 <- 0;
	aspect cao2016
	{
		draw shape color: hsb(0.6 - 0.1 * (30 - min([1.0, (max([0.0, cao2016 - 2])) / 30])), 1.0, 1.0);
	}

	aspect thuongnien
	{
		draw shape color: hsb(0.6 - 0.1 * (30 - min([1.0, (max([0.0, thuongnien - 2])) / 30])), 1.0, 1.0);
	}

}

species vungthuyloi
{
	rgb color <- # red;
	float risk <- 0.0;
	string tenvung <- "";
	string tramquantr <- "";
	list<float> domanmax <- [];
	list<cell_lua> cells;
	aspect thuongnien
	{
		draw shape color: hsb(0.6 - 0.1 * (30 - min([1.0, (max([0.0, risk - 2])) / 30])), 1.0, 1.0);
		draw tramquantr at: location;
	}

}

//species canals
//{
//	rgb color <- # blue;
//	aspect default
//	{
//		draw shape color: color border: color;
//	}
//
//}
grid cell_lua file: lua_file use_individual_shapes: false use_regular_agents: false neighbors: 8
{
	float damage <- 0.0;
	float risk <- -1.0;
	float dd <- 0.0;
	float priority_salt <- 0.0;
	float current_salinity max: 30.0;
	float current_salinity_tmp;
	bool diked <- false;
	bool disableByDrain <- false;
	bool dead <- false;
	int rice_obs;

	//	reflex diffusion when:grid_value>0
	//	{
	//		float cs <-current_salinity;
	//		ask neighbors{			
	//			current_salinity <-  max([current_salinity,cs]);
	//		}
	//	}
	rgb color <- legend_color[int(grid_value)];
	reflex gogo when: grid_value > 0
	{
		if (current_salinity > salinity_threshold)
		{
			if (flip(risk / dd / risk_threshold ))
			{
				damage <- damage + damage_adjust;
			}

		}

		color <- legend_color[int(grid_value)] - (damage * 100);
		if (damage > damage_threshold)
		{
			diked <- true;
			dead <- true;
			grid_value <- 0.0;
			color <- legend_color[int(grid_value)];
		}

		//		do ss;
	}

	action compute
	{
		if (grid_value > 0)
		{

		//		write grid_x;
		//		write grid_y;
		//		write "  ";
			cell_lua_validate c <- cell_lua_validate[grid_x, grid_y];
			rice_obs <- int(c.grid_value); // QUang thêm vào để tỉnh Kappa
			if (c.grid_value = grid_value)
			{
				c.color <- # white;
			} else
			{
				c.color <- # black; //legend_color_v[int(grid_value)];
			}

		}

	}

}

grid cell_lua_validate file: lua_file_validate use_individual_shapes: false use_regular_agents: false neighbors: 8
{
	action compute
	{
		if (grid_value > 0)
		{

		//		write grid_x;
		//		write grid_y;
		//		write "  ";
			cell_lua c <- cell_lua[grid_x, grid_y];
			if (c.grid_value = grid_value)
			{
				color <- # white;
			} else
			{
				color <- # black; //legend_color_v[int(grid_value)];
			}

		}

	}

	rgb color <- legend_color_v[int(grid_value)];
}

//grid cell_lua_validate2 file: lua_file_validate use_individual_shapes: false use_regular_agents: false neighbors: 8
//{
//	init
//	{
//		if (grid_value < 1)
//		{
//			grid_value <- -1.0;
//		}
//
//	}
//
//	rgb color <- legend_color[int(grid_value)];
//}
experiment mohinhluaman type: gui
{
/** Insert here the definition of the input and output of the model */
	output
	{
		display "Hien trang lua 2016" refresh: every(1 # day) type: opengl
		{
			overlay position: { 5, 5 } size: { 350 # px, (90) # px } background: # black transparency: 0.5 border: # black rounded: true
			{
				draw "Date: " + current_date.day + " - " + current_date.month + " - " + current_date.year at: { 20 # px, 30 # px } color: # white font: font("SansSerif", 24, # bold);
				draw "DT: " + length(cell_lua where (each.dead)) at: { 20 # px, 70 # px } color: # white font: font("SansSerif", 24, # bold);
			}

			//			species river aspect: default;
			grid cell_lua;
		}

		display "So sanh" refresh: every(1 # day) type: opengl
		{
			grid cell_lua_validate;
			//			species vungthuyloi aspect: thuongnien transparency: 0.35;
		}

		//		display "compare2" refresh: every(1 # day) type: opengl
		//		{
		//			grid cell_lua_validate2;
		//		}

		//				display "Hien trang ngap man" //type: opengl
		//		
		//				{
		//					overlay position: { 5, 5 } size: { 350 # px, (90) # px } background: # black transparency: 0.5 border: # black rounded: true
		//					{
		//						draw "Date: 20 - 3 - 2016" at: { 20 # px, 30 # px } color: # white font: font("SansSerif", 24, # bold);
		//		//				draw "DT: " +tongdientichL3  at: { 20 # px, 70 # px } color: # white font: font("SansSerif", 24, # bold);
		//		
		//						//				draw "Date: " + current_date.day + " - " + current_date.month + " - " + current_date.year at: { 20 # px, 30 # px } color: # white font: font("SansSerif", 24, # bold);
		//					}
		//		
		//					species vungngapman aspect: cao2016 transparency: 0.18;
		//					//			species vungngapman aspect: thuongnien;
		//					species river aspect: default;
		//		//			species cell_lua aspect: thuongnien;
		//				}

	}

}

experiment Calibration type: batch keep_seed: true repeat: 1 until: cycle >= 12
{
//	parameter salinity_threshold var: salinity_threshold min: 4.0 max: 28.0 step: 4.0;
	parameter damage_adjust var: damage_adjust min: 0.1 max: 0.5 step: 0.1;
	parameter damage_threshold var: damage_threshold min: 0.5 max: 1.0 step: 0.1;
	parameter risk_threshold var: risk_threshold min: 5.0 max: 10.0 step: 1.0;

	//	method exhaustive minimize: objective ;
	method genetic pop_dim: 3 crossover_prob: 0.7 mutation_prob: 0.1 improve_sol: true stochastic_sel: false nb_prelim_gen: 1 max_gen: 5 maximize:kappa aggregation: "max";

	//	method genetic pop_dim: 10 crossover_prob: 0.7 mutation_prob: 0.1 improve_sol: true stochastic_sel: false
	//	nb_prelim_gen: 1 max_gen: 20  minimize: objective ;
	init
	{
		is_batch <- true;
		//			save ("probability_changing, probability_risk, weight_profit, weight_risk, weight_implementation, weight_suitability, weight_neighborhood, weight_transition_tax, weight_lu_tax,kappa_sim") to: "result.csv" ;
		//			is_mode_batch <- true;
		write "salinity_threshold  damage_adjust   damage_threshold  risk_threshold objective";
	}
	//	float kk<-0;
	//	reflex results {
	//		if(kk<kappa_sim){
	//			kk<-kappa_sim;
	//			write "\n max kappa_sim  "+kk;
	////		write "probability_changing:" + probability_changing + " weight_profit: " + weight_profit + " weight_risk: " + weight_risk + " weight_implementation: " + weight_implementation + " weight_suitability: " + weight_suitability  + " weight_transition_tax: " + weight_transition_tax  + " weight_lu_tax: " + weight_lu_tax + " kappa_sim: " + mean(simulations collect each.kappa_sim);
	////		write mean(simulations collect each.kappa_sim);
	//		write ""+probability_changing + ","+probability_risk + "," + weight_profit + "," + weight_risk + "," + weight_implementation + "," + weight_suitability + "," + weight_neighborhood + ","+ weight_transition_tax + ","+ weight_lu_tax;
	//		} 
	//
	//		save (""+probability_changing + ","+probability_risk + "," + weight_profit + "," + weight_risk + "," + weight_implementation + "," + weight_suitability + "," + weight_neighborhood + ","+ weight_transition_tax + ","+ weight_lu_tax + "," + mean(simulations collect each.kappa_sim)) to: "result.csv" rewrite: false;
	//	}
}