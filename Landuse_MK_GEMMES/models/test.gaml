model SDD_MX_6_10_20

global control: reflex {
//	file tiff_in<-gama_tiff_file("../includes/2015_Mer_tas_dbsc.tif");
	file tiff_in<-gama_tiff_file("../includes/2015_Mer_pr_dbsc.tif");
	init {
		float start<-machine_time;
		loop i from:0 to:345{
			loop j from:0 to:272{
//		loop i from:0 to:3456{
//			loop j from:2000 to:2729{
				list l<-readDataSlice(tiff_in,i,j,0);
//				write l;
			}
		}
		float end<-machine_time;
		write end-start;
	}

}
 

experiment "my_GUI_xp" type: gui {
	 

}
 