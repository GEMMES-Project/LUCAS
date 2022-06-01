model SDD_MX_6_10_20

import "entities/farming_unit.gaml" 
//import "entities/cell_dat_2010.gaml"

global {
	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ_clipped.tif");
//	file cell_file <- grid_file("../includes/subsidence/subscidence_tot_2030_500x500.tif");
	grid_file cell_salinity_file <- grid_file("../includes/mk_sal_2030_45_500x500.tif");
	grid_file cell_subsidence_file <- grid_file("../includes/subsidence/subscidence_tot_2030_500x500_nodata.tif");
	
	//	file cell_file <- grid_file("../includes/lu_100x100_mx_2005_new.tif");
//	file MKD_bound <- shape_file("../includes/MKD_district.shp"); 
	geometry shape <- envelope(cell_file);
	list<farming_unit> active_cell <-[];//<- cell_dat where (each.grid_value != 8.0);
	file song_file <- shape_file('../includes/road_polyline.shp');
	file duong_file <- shape_file('../includes/river_region.shp');
	file dvdd_file <- shape_file("../includes/vmd_land_unit_cleaned.shp");
	file MKD_file <- shape_file("../includes/MKD.shp");
	file dyke_file <- shape_file("../includes/mk_dyke_region.shp");
	file aez_file <- shape_file("../includes/AEZ/aezone_MKD_region.shp");
	matrix ability_matrix;
	map<string,float> ability_map;
	file ability_file <- csv_file("../includes/khokhanchuyendoi.csv", false);
	matrix suitability_matrix;	
	matrix profile_matrix;	
	map<string,float> suitability_map;
	map<string,string> profile_map;
	file suitability_file <- csv_file("../includes/landsuitability.csv", false);
	file profile_file <- csv_file("../includes/profile_adaptation.csv", true);
	string risk_csv_file_path<-"../data/_31model_RCP85_CMIP5_tmaxavg_tmaxmax_premin.csv";
	list criteria;
	float v_kappa <- 0.0;
	//file cell_dat_2010_file <- grid_file(""); //../includes/ht2015_500x500cutPQ.tif");
	//list<cell_dat_2010> active_cell_dat2010 <- cell_dat_2010 where (each.grid_value != 0.0);
	file district_file <- shape_file("../includes/MKD_district.shp");
	file province_file <- shape_file("../includes/MKD_province.shp");
	float tong_luc;
	float tong_tsl;
	float tong_bhk;
	float total_fruit_tree_lnk;
	float total_2rice_luk;
	float total_rice_shrimp;
	float total_other;
	float area_3rice_luc;
	float area_2rice_luk;
	float area_rice_shrimp;
	float area_fruit_tree_lnk;
	float area_vegetable_bhk;
	float area_shrimp_tsl;
	float area_shrimp_tsl_risk ;
	float area_rice_fruit_tree_risk;
	float area_fruit_tree_risk;
	float area_other;
	float w_neighbor_density <- 0.6;
	float w_ability <- 0.5;
	float w_suitability <- 0.7;
	float w_profit <- 0.8;
	//float w_risky_climate <- 1.0;
	float w_flip <- 0.3;  // xã suát chuyen doi lua tom - tom
//	date the_date <- date([2010, 1, 1]);
	float pixel_size <-500*500/10000;
	float budget_supported; // budget need for support to farmer to adapt (Decision 62/2019): 1 Milion VND /ha
	float total_income_lost; // lost income  shrimp 50% and 30% 3rice
	
	float climate_maxTAS_shrimp<- 33.0;//-32 , tăng 0.5
	float climate_maxPR_thuysan<-300.0;//-300, tăng 50

	float climate_maxTAS_caytrong<- 33.0;//-32 , tăng 0.5
	float climate_minPR_caytrong<-  120.0; // 200 chay, thu 180

	float proportion_aqua_supported<-0.6;
	float proportion_ago_supported<-0.6;
	float proportion_aquafarmers_adapted<-0.6;
	float proportion_agrofarmers_adapted<-0.6;
	int scenario <-0;
	
}
