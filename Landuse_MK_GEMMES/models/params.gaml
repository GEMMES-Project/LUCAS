model SDD_MX_6_10_20

import "entities/cell_dat.gaml" 
//import "entities/cell_dat_2010.gaml"

global {
	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ_clipped.tif");
	file cell_salinity_file <- grid_file("../includes/mk_sal_2030_45_500x500.tif");
	//	file cell_file <- grid_file("../includes/lu_100x100_mx_2005_new.tif");
	file MKD_bound <- shape_file("../includes/MKD_district.shp"); 
	geometry shape <- envelope(cell_file);
	list<cell_dat> active_cell <-[];//<- cell_dat where (each.grid_value != 8.0);
	float tong_luc;
	float tong_tsl;
	float tong_bhk;
	file song_file <- shape_file('../includes/road_polyline.shp');
	file duong_file <- shape_file('../includes/river_region.shp');
	file dvdd_file <- shape_file("../includes/vmd_land_unit_cleaned.shp");
	file MKD_file <- shape_file("../includes/MKD.shp");
	file bandodebao <- shape_file("../includes/mk_dyke_region.shp");
	matrix matran_khokhan;
	map<string,float> kqkhokhanchuyendoi_map;
	file khokhanchuyendoi_file <- csv_file("../includes/khokhanchuyendoi.csv", false);
	matrix matran_thichnghi;	
	map<string,float> matran_thichnghi_map;
	file thichnghidatdai_file <- csv_file("../includes/landsuitability.csv", false);
	string risk_csv_file_path<-"../data/_31model_RCP85_CMIP5_tmaxavg_tmaxmax_premin.csv";
	list tieuchi;
	float v_kappa <- 0.0;
	//file cell_dat_2010_file <- grid_file(""); //../includes/ht2015_500x500cutPQ.tif");
	//list<cell_dat_2010> active_cell_dat2010 <- cell_dat_2010 where (each.grid_value != 0.0);
	file huyen_file <- shape_file("../includes/MKD_district.shp");
	float tong_lnk;
	float tong_luk;
	float tong_khac;
	float dt_luc;
	float dt_luk;
	float dt_lua_tom;
	float dt_lnk;
	float dt_bhk;
	float dt_tsl;
	float dt_khac;
	float w_lancan <- 0.6;
	float w_khokhan <- 0.5;
	float w_thichnghi <- 0.7;
	float w_loinhuan <- 0.8;
	float tong_lua_tom;
	//float w_risky_climate <- 1.0;
	float w_flip <- 0.3;  // xã suát chuyen doi lua tom - tom
//	date the_date <- date([2010, 1, 1]);
	float pixel_size <-500*500/10000;
	float dt_tsl_risk ;
	float dt_lua_caqrisk;
	float dt_caq_risk;
	float budget_supported; // budget need for support to farmer to adapt (Decision 62/2019): 1 Milion VND /ha
	float total_income_lost; // lost income  shrimp 50% and 30% 3rice
	
	float climate_maxTAS_thuysan<- 33.0;//-32 , tăng 0.5
	float climate_maxPR_thuysan<-300.0;//-300, tăng 50

	float climate_maxTAS_caytrong<- 33.0;//-32 , tăng 0.5
	float climate_minPR_caytrong<-  120.0; // 200 chay, thu 180

	float proportion_aqua_supported<-0.6;
	float proportion_ago_supported<-0.6;
	float proportion_aquafarmers_adapted<-0.6;
	float proportion_agrofarmers_adapted<-0.6;
	int scenario <-0;
	
}
