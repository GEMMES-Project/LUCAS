model cell_dat

import "../params.gaml"
species tinh {
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
	list data_pr;
	list data_tas;

	init {
	}
	aspect default{
		draw shape empty:true border:#gray;
	}
}
