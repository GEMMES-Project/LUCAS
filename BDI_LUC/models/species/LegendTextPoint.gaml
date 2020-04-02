/***
* Name: Legend
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/

@no_experiment

model LegendTextPoint

// MAPS LEGEND
species LegendTextPoint {
	string legend_text ;
	aspect text_aspect{
		draw legend_text at:{location.x,location.y-500 }  color:#black size:200;
	}
}
