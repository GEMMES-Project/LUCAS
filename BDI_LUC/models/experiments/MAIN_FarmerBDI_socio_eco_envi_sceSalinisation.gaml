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
model BDIdecision

import "../BaseLine.gaml"
//import "M_F_interface.gaml"
global {
}

experiment Farmer_exp type: gui { //parent:M_F_interface
	output {
		display simResult type: opengl background:#black{			
			image file: "../includes/satellite.png" refresh: false;
			grid Cell transparency:0.5;
			species River aspect: default refresh: false;
			species FarmerBDI aspect: default;

			//			species legend aspect: my_aspect  refresh: false;
			//			species legend_text_point aspect: text_aspect refresh: false;
		}

//		display salinity {
//			species LandUnitParcel;
//		}
//
//		display chart {
//		//			chart ;pl_loan + ","+ pl_copy_neig + "," + pl_suitability + ","+pl_income +"," +pl_stay +","+pl_no_intention;
//			chart "Area of land-use type" type: series {
//				data "Rice" value: v_luc color: #yellow;
//				data "Rice - Shrimp" value: v_ltm color: #mediumblue;
//				data "Shrimp" value: v_tsl color: #blue;
//				data "Fruit" value: v_lnk color: #green;
//				data "Fruit industrielle" value: v_lnc color: #purple;
//				data "Annual crops" value: v_bhk color: #violet;
//			}
//
//		}

	}

}

//experiment batch_100_sim type:batch keep_simulations: false keep_seed: true repeat: 100 until: ( cycle  > 7 ) {
//	
//}
//// Exploration parameters
//experiment 'Farmer_BDI_calibration' type: batch repeat: 1 keep_seed: true until: cycle > 7 {
//	parameter w_rich var: w_rich min: 0.1 max: 0.5 step: 0.1;
//	parameter w_standard var: w_standard min: 0.1 max: 0.3 step: 0.1;
//	parameter w_medium var: w_medium min: 0.3 max: 0.6 step: 0.1;
////	method exhaustive  minimize: pad;
//	method genetic pop_dim: 3 crossover_prob: 0.7 mutation_prob: 0.1 nb_prelim_gen: 1 max_gen: 5  minimize: pad  ;
//}