model province

species province {
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
	map<string, float> data_pr;
	map<string, float> data_tas;
	list<float> pump_val<-[-1.0,0.1,0.2];
	float pumping <- -1.0 ;//any(pump_val); //-1 no , 0-2%
	float budget_invest<-shape.area;
	float pumping_price <- pumping > -1 ? pumping * budget_invest /2E6: 0;
	bool agreed_aez <- true;

	init { 
	}

	aspect default {
		draw shape border: #black wireframe:true;
	}

}
