/***
* Name: Legend
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/

@no_experiment

model Legend

species Legend {
	string legend_str;
	rgb color;
	rgb border;	
	aspect my_aspect {
		draw rectangle(2700,900) at:{location.x+2000,location.y-500 } color:#white border:false;
//		draw legend_str at:{location.x-1500,location.y-500 }  color:#black size:230;
		
		draw shape at:{location.x,location.y-500 } color: color border: border;		
	}
}// LEGEND
