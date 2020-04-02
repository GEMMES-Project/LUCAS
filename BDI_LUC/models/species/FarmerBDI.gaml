/***
* Name: Legend
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/

@no_experiment

model Legend

import "../Functions.gaml"
import "../Parameters.gaml"
species FarmerBDI parent: LandParcel control: simple_bdi				
//	schedules:FarmerBDI where (each.landuse in ["BHK", "LNC","LUC","LUK","TSL","LTM"] )
	{ 
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
				money<-world.compute_profit(landuse, LS_map, land_unit);
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
			list LS_choice<- LUT.keys sort_by int(world.compute_suitability(each, LS_map, land_unit));
		
		loop new_landuse over:(LS_choice){						
			money<-world.compute_profit(landuse, LS_map, land_unit);
			if(income - money >=0){
				have_changed_to_favorite_land_use<-true;
				landuse<-new_landuse;
				income<-income-world.compute_profit(landuse, LS_map, land_unit);

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
			list LS_choice<- LUT.keys sort_by int(world.compute_profit(each, LS_map, land_unit));
			//select a land_use temp 		
			loop new_landuse over:(LS_choice){						
				if (world.compute_suitability(new_landuse, LS_map, land_unit)<2 ){
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
		income<-income+world.compute_profit(landuse, LS_map, land_unit);
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
 
	
	aspect bdi {
		draw circle(1) color: color;
	}
}
