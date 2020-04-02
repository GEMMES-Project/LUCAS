/***
* Name: Global
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Global
import "species/LandParcel.gaml"
import "species/FarmerBDI.gaml"

global {
//khai bao bien theo kieu tap tin
	file netcdf_sample <- file("../includes/temperature/ENS_mm_rcp45.2015_2050_MKD_pr.nc");
	file land_parcel_file <- file('../includes/LU_Myxuyen2005/landuse_myxuyen_2005_region_3commune.shp'); // //definition file variable of parcel layer
	file river_file <- file('../includes/basemaps/rivers_myxuyen_region_3commune.shp'); //definition file variable of river layer
	file legend_symbol_file <- file("../includes/legend/legends_rectangle.shp"); //definition file variable of layer  boundery layer
	file txt_file <- file("../includes/legend/legends_text_point.shp"); //definition file variable of legend  layer text
	bool mode_batch <- false; // check if running in batch mode
	float step_sim <- 1 #year; // simulation step
	float start_simulation <- 2004 #year; // set simulation start times
	float end_simulation <- 2010 #year; // simulation end times
	map<string, rgb> LUT <- [ // map of Land-use type; each type have a color
	'BHK'::rgb(153, 0, 0), 'LNK'::rgb(153, 0, 0) + 50, 'LNC'::rgb(255, 102, 178), 'LTM'::#deepskyblue, 'LUK'::rgb(153, 153, 0), 'LUC'::#yellow, 'OTHER_LU'::rgb(0, 102, 0), 'TSL'::#blue, 'LNQ'::#red + 50, 'QPH'::#blue + 100];

	//	map<string,int> LUTDepth <-[
	//		'BHK'::45,
	//		'LNK'::15,
	//		'LNC'::50,
	//		'LTM'::22,
	//		'LUK'::15,
	//		'LUC'::22,
	//		'OTHER_LU'::27,
	//		'TSL'::0,
	//		'LNQ'::45,
	//		'QPH'::40
	//	];
	int nb_LUT <- length(LUT); // number of land-use types 

	// FOR FUZZY-KAPPA variable 
	bool use_fuzzy_kappa_sim <- false parameter: true;
	float distance_kappa <- 200.0 parameter: true; // Distance for calculation Fuzzy Kappa
	matrix<float> fuzzy_categories; // Categories to calculate the FKappa
	matrix<float> fuzzy_transitions; // Categories to calculate the FKapp
	list<float> nb_per_cat_obs; // Categories to transition matrix 
	list<float> nb_per_cat_sim; // Number of categories observed 
	float kappa; // NUmber of categories simulated
	float pad; // variable for Fuzzy Kappa
	list<string> categories; //List of categories  
	list<LandParcel> parcels; //List of parcels
//	geometry shape <- envelope(land_parcel_file); //definition simulation environment - boundery of the parcel file
	geometry shape<-to_GAMA_CRS(envelope(netcdf_sample),"4326");
	
	string modelID <- "ID";
	
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
	file suitability_file <- csv_file("../includes/datasets/suitability_new.csv", ",",string,false);
	file transition_file <- csv_file("../includes/datasets/transition.csv", ",",string,false);
	file cost_file <- csv_file("../includes/datasets/cost.csv", ",",string,false);
	
	file land_unit_file<-file("../includes/LU_Myxuyen2005/landuse_myxuyen_2005_region_3commune.shp");
//	file land_unit_file<-file("../includes/environmental/land_unit2020.shp");	// land_unit of the senario , This file are set = landunit 2010 by default, 
		
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
	
	
	
	int times <- 1;
	int grid_num <- 0;
	int gridsSize <- 0;
	int timesAxisSize <- 0;
	
}