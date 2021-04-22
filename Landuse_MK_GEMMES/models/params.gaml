model SDD_MX_6_10_20

import "entities/cell_dat.gaml"
import "entities/cell_dat_2010.gaml"

global {
	file cell_file <- grid_file("../includes/Landuse_2015.tif");
	//	file cell_file <- grid_file("../includes/lu_100x100_mx_2005_new.tif");
	file MKD_bound <- shape_file("../includes/MKD.shp");
	geometry shape <- envelope(MKD_bound);
	list<cell_dat> active_cell <-[];//<- cell_dat where (each.grid_value != 8.0);
	float tong_luc;
	float tong_tsl;
	float tong_bhk;
	file song_file <- shape_file('../includes/rivers_myxuyen_region.shp');
	file duong_file <- shape_file('../includes/road_myxuyen_region.shp');
	file dvdd_file <- shape_file("../includes/landunit_mx_region.shp");
	file bandodebao <- shape_file("../includes/soctrang_debao2010_region.shp");
	matrix matran_khokhan;
	file khokhanchuyendoi_file <- csv_file("../includes/khokhanchuyendoi.csv", false);
	matrix matran_thichnghi;
	file thichnghidatdai_file <- csv_file("../includes/landsuitability.csv", false);
	float w_lancan <- 0.2;
	list tieuchi;
	float v_kappa <- 0.0;
	file cell_dat_2010_file <- grid_file("../includes/lu_100x100_mx_2015_new.tif");
	list<cell_dat_2010> active_cell_dat2010 <- cell_dat_2010 where (each.grid_value != 0.0);
	file xa_file <- shape_file("../includes/commune_myxuyen.shp");
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
	float w_khokhan <- 0.7;
	float w_thichnghi <- 0.8;
	float tong_lua_tom;
	float w_loinhuan <- 0.7;
	float w_flip <- 0.02;  
	date the_date <- date([2010, 1, 1]);
	
	map<int, file>
	Pr_tiff <- [2015::gama_tiff_file("../includes/Extent/Pr/Pr_2015_extent.tif"), 
		2020::gama_tiff_file("../includes/Extent/Pr/Pr_2020_extent.tif"), 
		2025::gama_tiff_file("../includes/Extent/Pr/Pr_2025_extent.tif"), 
		2030::gama_tiff_file("../includes/Extent/Pr/Pr_2030_extent.tif"), 
		2035::gama_tiff_file("../includes/Extent/Pr/Pr_2035_extent.tif"), 
		2040::gama_tiff_file("../includes/Extent/Pr/Pr_2040_extent.tif"), 
		2045::gama_tiff_file("../includes/Extent/Pr/Pr_2045_extent.tif"), 
		2050::gama_tiff_file("../includes/Extent/Pr/Pr_2050_extent.tif")
	];
	map<int, file>
	Tas_tiff <- [2015::gama_tiff_file("../includes/Extent/Tas/Tas_2015_extent.tif"), 
		2020::gama_tiff_file("../includes/Extent/Tas/Tas_2020_extent.tif"), 
		2025::gama_tiff_file("../includes/Extent/Tas/Tas_2025_extent.tif"), 
		2030::gama_tiff_file("../includes/Extent/Tas/Tas_2030_extent.tif"), 
		2035::gama_tiff_file("../includes/Extent/Tas/Tas_2035_extent.tif"), 
		2040::gama_tiff_file("../includes/Extent/Tas/Tas_2040_extent.tif"), 
		2045::gama_tiff_file("../includes/Extent/Tas/Tas_2045_extent.tif"), 
		2050::gama_tiff_file("../includes/Extent/Tas/Tas_2050_extent.tif")
	];
	map<int, file>
	Tas_min_tiff <- [2015::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2015_extent.tif"), 
		2020::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2020_extent.tif"), 
		2025::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2025_extent.tif"), 
		2030::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2030_extent.tif"), 
		2035::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2035_extent.tif"), 
		2040::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2040_extent.tif"), 
		2045::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2045_extent.tif"), 
		2050::gama_tiff_file("../includes/Extent/Tas_min/TasMin_2050_extent.tif")
	];
	map<int, file>
	Tas_max_tiff <- [
		2015::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2015_extent.tif"), 
		2020::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2020_extent.tif"), 
		2025::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2025_extent.tif"), 
		2030::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2030_extent.tif"), 
		2035::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2035_extent.tif"), 
		2040::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2040_extent.tif"), 
		2045::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2045_extent.tif"), 
		2050::gama_tiff_file("../includes/Extent/Tas_max/TasMax_2050_extent.tif")
	];
}
