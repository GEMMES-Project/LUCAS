model land_subsidence

global{
	field  field_subsidence<-field(grid_file("../includes/subsidence/subscidence_tot_2030_500x500_nodata.tif"));
}
species land_subsidence {
	int Id_1;
	int Id_2;
	int climat_cod;
	string NAME_1;
	string NAME_2;
	string NAME_3;
	string GID_1;
	string GID_2;
	string GID_3;
	string VARNAME_1;
	string VARNAME_2;
	string VARNAME_3;
	string STT;
//	list data_pr;
	map<string,float> data_pr;
	map<string,float> data_tas;

	init {
	}
	aspect default{
		draw shape empty:true border:#gray;
	}
}
