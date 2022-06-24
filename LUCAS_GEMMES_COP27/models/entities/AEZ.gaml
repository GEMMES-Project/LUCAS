model Aez

species AEZ {
	int Id_1;
	int Id_2;
	int climat_cod;
	string aezone;
	string zone_name;
//	list data_pr;
	map<string,float> data_pr;
	map<string,float> data_tas;
	float debt;
	float benefit<-0.0;
	float wu;
	init {
	}
	aspect default{
		draw shape   border:#red;
	}
}
