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
	
	map<int,float> debt_lu<-[5::0.0,34::0.0,12::0.0,6::0.0,14::0.0,101::0.0];
	
	map<int,float> benefit_lu<-[5::0.0,34::0.0,12::0.0,6::0.0,14::0.0,101::0.0];
	float wu;
	init {
	}
	aspect default{
		draw shape   border:#red;
	}
}
