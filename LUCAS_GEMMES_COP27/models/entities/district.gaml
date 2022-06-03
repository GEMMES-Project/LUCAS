model district
global{
	map<int,district> map_district_by_climat_cod;
}

species district {
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
		map_district_by_climat_cod<+climat_cod::self;
	}
	aspect default{
		draw shape wireframe:true border:#gray;
	}
}
