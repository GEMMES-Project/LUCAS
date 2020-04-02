/**
* Name: Economic
* Author: Chi-Quang Truong
* Description: Describe here the model and its experiments
* Get data from the datasets: cost, price
*  Provide the cost and price data in the variable :  price_map_e and  cost_map_e
*/ 


model Economic

global {
	/** Insert the global definitions, variables and actions here */
	file price_file <- csv_file("../includes/datasets/price.csv", ",",string,false);				// define the price of product dataset, csv format
	file cost_file <- csv_file("../includes/datasets/cost.csv", ",",string,false);					// the cost of the land-use, csv file
	map<string, list<float>> price_map_e;														// map of the price of the land-use types
	map<string, list<float>> cost_map_e;														// map of the cost of the land-use types
	
	init{
		do build_price_cost_map;
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
			price_map_e[lu] <- pr;
			cost_map_e[lu] <- ct;
		}	
			
	}
//	write
}

experiment Eco_exp type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
	}
}
