/**
 *  BDIdecision
 *  Author: Truong Chi Quang, Patrick Taillandier et Huynh Quang Nghi
 *  Description: model based on a BDI architecture
 * scenario :  Scenarios from 2010 to 2020 
 * Shrimp price increase ; 
 * - Policy of credit 
 * Kappa = 50.1%
 * cleaning:
 * - Stop simulation in cycle 10
 * - Land-use: get from field Lu10
 */

model LUC_sce_sluicegate
import "common_model_scena_2.gaml"
//import "M_F_interface.gaml"

global {
	map<int,map<string,list<float>>> transitions;
	float distance_neighbours <- 30.0 parameter: true;
	float weight_profit <- 0.5;
	float weight_implementation <- 1.0;
	float weight_cost <- 0.2;
	float paraCreditedControl <-0.1 parameter:true;
	// Parameter
	float w_rich <- 0.10 parameter: true;
	float w_standard <- 0.20 parameter: true;
	float w_medium <- 0.40 parameter: true;
	float w_poor <- float(1-(w_rich+w_standard+w_medium)) ;
	
	bool debug<-false;
	file price_file <- csv_file("../includes/datasets/price.csv", ",",string,false);
	file suitability_file <- csv_file("../includes/datasets/suitability_scenarioIDECAF.csv", ",",string,false);
	file transition_file <- csv_file("../includes/datasets/transition.csv", ",",string,false);
	file cost_file <- csv_file("../includes/datasets/cost.csv", ",",string,false);
	
//	file land_unit_file<-file("../includes/environmental/land_unit2010.shp");
	file land_unit_file<-file("../includes/environmental/land_unit20_opensluice.shp");	// land_unit of the senario , This file are set = landunit 2010 by default, 
		
	map<int, map<string,int>> suitability_map;
	map<string, list<float>> price_map;
	map<string, list<float>> cost_map;
	map<string, map<string,int>> implementation_map;
	float max_price update: price_map.values max_of (each[cycle > 0 ? (cycle-1) mod 6 : 0 ]);
	float max_cost update: cost_map.values max_of (each[cycle > 0 ? (cycle-1) mod 6 : 0]);
	FarmerBDI fol;
	list<string> landuse_types;
	
//	each profile have a proportion of borrow from banks
	map<string,float> profiles <- ["poor"::0.3,"medium"::0.4,"standard"::0.2,"rich"::0.1];//	map<string,float> profiles <- ["innovator"::0.0,"early_adopter"::0.1,"early_majority"::0.2,"late_majority"::0.3, "laggard"::0.5];
//	modelID <-"BDI";
	bool batch_mode <-false ;
	// number of People with plans selected 
	int pl_copy_neig;
	int pl_suitability;											// people copy land-use of thier neighbors
	int pl_loan;											// peolpe change to land suitability
	int pl_income; 											//people will change to the highest income
	int pl_no_intention;  										// people dont have intention
	int pl_stay ;
	
	action create_parcel {
		do build_suitability_map;
		do build_price_cost_map;
		do build_implementation_map;
		
		max_price <-price_map.values max_of (each[0 ]);
		max_cost <- cost_map.values max_of (each[0]);
		landuse_types <-LUT.keys - "OTHER_LU";
		create FarmerBDI  from: land_parcel_file with: [region::int(read('Region')),landuse_init::string(read('Lu10')),landuse_obs::string(read('Lu10')),  nearhouse::int(read("Nearhouse")),acid_sulfat::string(read("Acid_sul_d")), parcel_area::read("Area"),land_unit::int(read("Landunit"))]
		//
		{
			landuse <- landuse_init;
			probabilistic_choice <- false;
			neighbours <- (FarmerBDI at_distance distance_neighbours) where (each.landuse_init != "OTHER_LU");
			income<-compute_profit(landuse);
		}
		create landunit_parcel from: land_unit_file with: [landunit_id::int(read('LANDUNIT'))]; 		
		do get_landUnit;																// set land_unit for the parcel
		
	}
	
	action other_init {		
		parcels <- list(FarmerBDI where (each.shape.area > 0));
		fol <-one_of(FarmerBDI);
	}

	action build_suitability_map {
//		write "farmer     \n " +  suitability_file;
		matrix st_mat <- matrix(suitability_file);
		loop i from: 1 to: st_mat.rows - 1{
			map<string,int> map_land_unit <- [];
			int land_unit <- int(st_mat[0,i]);
			loop j from: 1 to: st_mat.columns -1{
				map_land_unit[string(st_mat[j,0])] <-int(st_mat[j,i]); 
			}
			suitability_map[land_unit] <- map_land_unit;
		}
	}
	
	action build_price_cost_map {
		matrix price_mat <- matrix(price_file);
		matrix cost_mat <- matrix(cost_file);
		loop i from: 1 to: price_mat.rows -1{
			list<float> pr <- [];
			list<float> ct <- [];
			string lu <- string(price_mat[0,i]);
			loop j from: 1 to: price_mat.columns -1 {
				pr << float(price_mat[j,i]);
				ct << float(cost_mat[j,i]); 
			}
			price_map[lu] <- pr;
			cost_map[lu] <- ct;
		}
	}
	
	action build_implementation_map {
		matrix st_mat <- matrix(transition_file);
		loop i from: 1 to: st_mat.rows - 1{
			map<string,int> map_transition_s <- [];
			string source_lu <- string(st_mat[0,i]);
			loop j from: 1 to: st_mat.columns -1{
				map_transition_s[st_mat[j,0]] <-int(st_mat[j,i]); 
			}
			implementation_map[source_lu] <- map_transition_s;
		}
	}
	action get_landUnit{
//		get land_unit id from land unit agent to the parcel
		loop lunit_obj  over: landunit_parcel{									//loop for the land unit object  - declared in the common model  
			ask FarmerBDI overlapping lunit_obj{								// select the land parcel object that overlap with land unit object
				land_unit <- lunit_obj.landunit_id;								// set land_unit of the parcel
//				write land_unit_code;
			}
		}
		save FarmerBDI to:"../includes/test_gan_land_unit.shp" type:"shp"; 		 
	}
	// calculate area 
	reflex calcul_area{
		
	}
// calculate the number of farmers for each plan 
	reflex dynamic {
	pl_loan<-0;pl_copy_neig <-0; pl_suitability<-0; pl_income<-0; pl_stay <-0;pl_no_intention<-0;
		ask FarmerBDI{
			if self.has_desire(request_invesment_from_bank){
				pl_loan<- pl_loan+1;
			}
			if self.has_desire(imitate_their_successful_neighbors){
				pl_copy_neig<- pl_copy_neig+1;
			}
			if self.has_desire(minimize_risks){
				pl_suitability<- pl_suitability+1;
			}
			if self.has_desire(earn_the_highest_possible_income){
				pl_income<- pl_income+1;
			}
			if self.has_desire(try_not_to_change) {
				pl_stay <- pl_stay+1;
			}
			if (not self.has_desire(imitate_their_successful_neighbors) and  not self.has_desire(minimize_risks) and not self.has_desire(earn_the_highest_possible_income)){
				pl_no_intention<- pl_no_intention+1;
			} 
		}
//		write "NUmber of farmer borrow:"+ i + "; D_neighbor:"+j+"; D_land suitability: "+ k + "; D_hight_income:"+h;
		if (not batch_mode ) {
			write "Year, loan, limitation, Land suitability, high income, stay, mo_intention";
			write "Year "+(cycle+2010) +"," + pl_loan + ","+ pl_copy_neig + "," + pl_suitability + ","+pl_income +"," +pl_stay +","+pl_no_intention;
		}
	}
	//	area of the simulated land use types
	float v_luc; float v_luk; float v_lnc; float v_ltm; float v_tsl; float v_lnq; float v_lnk;
	float v_bhk ; 
	reflex write_sim_result{
		// wrtite simulation result each cycle 
		v_luc<-0;v_luk<-0; v_lnc<-0; v_ltm<-0; v_tsl<-0;v_lnq<-0;v_lnk<-0;v_bhk<-0;v_lnq<-0;
		
//		calculate the area of the land-use type each simulation step 
		ask FarmerBDI{
//			write land-use simulated  
			switch landuse{
				match 'BHK'{ v_bhk<- v_bhk + parcel_area;}
				match 'LNC'{ v_lnc<- v_lnc + parcel_area;}
				match 'LNK'{ v_lnk<- v_lnk + parcel_area;}
				match 'LNQ'{ v_lnq<- v_lnq + parcel_area;}
				match 'LTM'{ v_ltm<- v_ltm + parcel_area;}
				match 'LUC'{ v_luc<- v_luc + parcel_area;}
				match 'LUK'{ v_luk<- v_luk + parcel_area;}
				match 'LUK'{ v_luk<- v_luk + parcel_area;}
				match 'TSL'{ v_tsl<- v_tsl + parcel_area;}
			}	
		}
		if (not batch_mode ){
			write "Year, BHK, LNC, Fruit, LTM, LUC, LUK, TSL";
			write " Year:" + (cycle + 2010) +"," + v_bhk/10000+","+v_lnc/10000+","+(v_lnk+v_lnq)/10000+"," +v_ltm/10000+"," +v_luc/10000+"," +v_luk/10000+"," +v_tsl/10000;
		}
	}
}

species FarmerBDI parent: land_parcel control: simple_bdi				
	schedules:FarmerBDI where (each.landuse in ["BHK", "LNC","LUC","LUK","TSL","LTM"] ){ 
	rgb color;
	//int land_unit;
	list<FarmerBDI> neighbours; 
	float income;
	float money;
//	string profile <- profiles.keys[rnd_choice([0.30,0.40,0.20,0.10])];   //10,20,40,30])];
	string profile <- profiles.keys[rnd_choice([w_poor,w_medium,w_standard,w_rich])];   //10,20,40,30])];
//	float intention_persistence <- profiles[profile] ;
	
	predicate try_not_to_change<-new_predicate("income greater than average");
	predicate many_neighbors_change_to_other_land_use<-new_predicate("many_neighbors_change_to_other_land_use");
	predicate imitate_their_successful_neighbors<-new_predicate("imitate_their_successful_neighbors");
	predicate earn_the_highest_possible_income<-new_predicate("earn_the_highest_possible_income");
	predicate minimize_risks<-new_predicate("minimize_risks");
	predicate request_invesment_from_bank<-new_predicate("request_invesment_from_bank");
	predicate borrowed<-new_predicate("borrowed");  // for set belief
//	change_based_farming_habit
	predicate fitted_to_location<-new_predicate("fitted_to_location");

	bool have_changed_to_favorite_land_use<-false;
//	list neighbours<-self neighbours_at(10);

	init {
		if(debug){if(int(self)=0){write "init";}}
//		fitted_to_location 
		if (nearhouse =1 ){
//			small parcel near house

			do add_desire(fitted_to_location);  
		} 
		else {
			if(profile="poor"){			

				do add_desire(imitate_their_successful_neighbors);
			}else{
				if (profile ="rich" ){  
					do add_desire(earn_the_highest_possible_income);				
				} else {
					do add_desire(minimize_risks);
				}
				
			}			
		}
	}
		
	plan change_to_land_use_of_neighbors 
		intention:(imitate_their_successful_neighbors) {
			if(debug){write "nei";}
			have_changed_to_favorite_land_use<-false;			
			loop n over: neighbours  {		//where (each.profile="medium")) {//	
				string new_landuse<-n.landuse;
				money<-compute_profit(landuse);
//				\write ("plan change neighbors; money:" + money +"; income="+ income);
				if(income - money >=0){
					have_changed_to_favorite_land_use<-true;
					landuse<-new_landuse;
					income<-income-money;
					do add_desire(try_not_to_change);
					// remove desire imitate neighbors
					do add_belief(imitate_their_successful_neighbors);  
				}
				else{
//					if(flip(profiles[profile]) ){ //and new_landuse="TSL"

							do add_subintention(get_current_intention(), request_invesment_from_bank, true);
							do current_intention_on_hold(); // tam dung intension dang lam de vay von
					}
					break;
		}
	}
	plan change_based_farming_habit	
		intention:(fitted_to_location)
		finished_when: has_belief(fitted_to_location)
	{
		//deleted
	}
// plan execute when farmer have intention to request investment from bank
	plan loan_from_banks 
		intention:request_invesment_from_bank{
//		credited depend on the paraCreditedControl, this is a parameter
		if flip(paraCreditedControl) { 
			income<-income+1000;
			do add_belief(request_invesment_from_bank);  // remove the disire request_invesment_from_bank
		}
	}

	plan change_to_land_suitability
//	high high land suitability
		intention:minimize_risks
		finished_when:
			(have_changed_to_favorite_land_use){
			if(debug){write "suit";}
			list LS_choice<- LUT.keys sort_by int(compute_suitability(each));
		
		loop new_landuse over:(LS_choice){						
			float money<-compute_profit(landuse);
			if(income - money >=0){
				have_changed_to_favorite_land_use<-true;
				landuse<-new_landuse;
				income<-income-compute_profit(landuse);

				do add_desire(try_not_to_change);
				do add_belief(minimize_risks);
			}
			else
			if( new_landuse="TSL"){

						do add_subintention(get_current_intention(), request_invesment_from_bank, true);
						do current_intention_on_hold();				
			}
			break;
		}
	}
	
//	
//	select land use high incom
	plan change_to_highest_income
	intention:earn_the_highest_possible_income
		finished_when:
			(have_changed_to_favorite_land_use)
	{
			string new_landuse <-"";
			list LS_choice<- LUT.keys sort_by int(compute_profit(each));
			//select a land_use temp 		
			loop new_landuse over:(LS_choice){						
				if (compute_suitability(new_landuse)<2 ){
					if new_landuse ="TSL" and not has_belief(request_invesment_from_bank){
						do add_subintention(get_current_intention(), request_invesment_from_bank, true);
						do current_intention_on_hold(); // tam dung intension dang lam de vay von	
					}
					else{
//						if farmers have loan, they can change their land use  
						landuse<-new_landuse;
					}
					break;
				}// if
			}//loop	
			
	}
//	
	plan stay_in_current_land_use 
		intention:try_not_to_change 
		finished_when: 
			has_belief(many_neighbors_change_to_other_land_use)
			or has_belief(earn_the_highest_possible_income){
		if(debug){write "stay";}
		income<-income+compute_profit(landuse);
		profile<-profiles.keys[income<3000?0:(income>=3000 and income <6000?1:(income>=6000 and income<9000?2:3))];
		intention_persistence <- profiles[profile];
			
//		profile <- profiles.keys[rnd_choice([10,20,30,40])];
		
		if(profile="poor" and not has_belief(imitate_their_successful_neighbors)){			
//			do remove_belief(imitate_their_successful_neighbors);
			do add_desire(imitate_their_successful_neighbors);
		}else if(not has_belief(earn_the_highest_possible_income)){
//			do remove_belief(earn_the_highest_possible_income);
			do add_desire(earn_the_highest_possible_income);
		}
		do remove_desire(try_not_to_change);
	}

	float compute_profit(string lu) {
		if (lu in price_map.keys) {
			return (price_map[lu][cycle > 0 ? (cycle-1) mod 6 : 0] / compute_suitability(lu)) ;
		}
		return 0.0;
	}
	
	float compute_cost(string lu) {
		if (lu in cost_map.keys) {
			return (1 - (cost_map[lu][cycle > 0 ? (cycle-1) mod 6 : 0]/max_cost));
		}
		return 0.0;
	}
	
	float compute_implementation(string lu) {
		if ((lu in implementation_map.keys) and (landuse in implementation_map.keys)) {
			return ((3 - implementation_map[landuse][lu]) /2);
		}
		return 0.0;
	}
	
	float compute_suitability(string lu) {		
		float v_l_suitability<-4.0;
		if(length(LS_map.pairs)>0){
//		if(debug){write land_suitability;}
			if(lu in LS_map.keys){				
//				write LS_map[lu];
				v_l_suitability<- LS_map[lu];
			}
		}
		if (lu in suitability_map[land_unit].keys) {
			v_l_suitability<- suitability_map[land_unit][lu]<v_l_suitability?suitability_map[land_unit][lu]:v_l_suitability;
		}
		return v_l_suitability;
	}
	
	aspect bdi {
		draw circle(1) color: color;
	}
}

experiment Farmer_exp type: gui { //parent:M_F_interface
	output {
		
		display simResult {//} type:opengl{
			species river aspect: default refresh: false; 
			species FarmerBDI aspect:default;
			
//			species legend aspect: my_aspect  refresh: false;
//			species legend_text_point aspect: text_aspect refresh: false;
		}
		display salinity {
			species landunit_parcel ;
		}
//		display chart{
////			chart ;pl_loan + ","+ pl_copy_neig + "," + pl_suitability + ","+pl_income +"," +pl_stay +","+pl_no_intention;
//			    chart "Desires of farmers" type:series {
//			        data "Loan" value:pl_loan color:#red;
//                	data "Imitate" value:pl_copy_neig color:#mediumblue;
//			        data "Land suitability" value:pl_suitability color:#gold;
//                	data "High income" value:pl_income color:#midnightblue;
//                	data "Not change" value:pl_stay color:#purple;
//                	data "No intention" value:pl_no_intention color:#violet;
//                }
//		}

		display chart{
//			chart ;pl_loan + ","+ pl_copy_neig + "," + pl_suitability + ","+pl_income +"," +pl_stay +","+pl_no_intention;
			    chart "Area of land-use type" type:series {
			        data "Rice" value:v_luc color:#yellow;
                	data "Rice - Shrimp" value:v_ltm color:#mediumblue;
			        data "Shrimp" value:v_tsl color:#blue;
                	data "Fruit" value:v_lnk color:#green;
                	data "Fruit industrielle" value:v_lnc color:#purple;
                	data "Annual crops" value:v_bhk color:#violet;
                }
//                match 'BHK'{ v_bhk<- v_bhk + parcel_area;}
//				match 'LNC'{ v_lnc<- v_lnc + parcel_area;}
//				match 'LNK'{ v_lnk<- v_lnk + parcel_area;}
//				match 'LNQ'{ v_lnq<- v_lnq + parcel_area;}
//				match 'LTM'{ v_ltm<- v_ltm + parcel_area;}
//				match 'LUC'{ v_luc<- v_luc + parcel_area;}
//				match 'LUK'{ v_luk<- v_luk + parcel_area;}
//				match 'LUK'{ v_luk<- v_luk + parcel_area;}
//				match 'TSL'{ v_tsl<- v_tsl + parcel_area;}
		}

	}
}

experiment batch_100_sim type:batch keep_simulations: false keep_seed: true repeat: 100 until: ( cycle  > 7 ) {
	
}
// Exploration parameters
experiment 'Farmer_BDI_calibration' type: batch repeat: 1 keep_seed: true until: cycle > 7 {
	parameter w_rich var: w_rich min: 0.1 max: 0.5 step: 0.1;
	parameter w_standard var: w_standard min: 0.1 max: 0.3 step: 0.1;
	parameter w_medium var: w_medium min: 0.3 max: 0.6 step: 0.1;
//	method exhaustive  minimize: pad;
	method genetic pop_dim: 3 crossover_prob: 0.7 mutation_prob: 0.1 nb_prelim_gen: 1 max_gen: 5  minimize: pad  ;
}