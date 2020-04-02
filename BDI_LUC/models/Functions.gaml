/***
* Name: Global
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Functions
import "Parameters.gaml"

global { 
	

	float compute_profit(string lu, map<string,float> LSmap, int landunit) {
		if (lu in price_map.keys) {
			return (price_map[lu][cycle > 0 ? (cycle-1) mod 6 : 0] / compute_suitability(lu,LSmap,landunit)) ;
		}
		return 0.0;
	}
	
	float compute_cost(string lu) {
		if (lu in cost_map.keys) {
			return (1 - (cost_map[lu][cycle > 0 ? (cycle-1) mod 6 : 0]/max_cost));
		}
		return 0.0;
	}
	
	float compute_implementation(string lu, string landuse) {
		if ((lu in implementation_map.keys) and (landuse in implementation_map.keys)) {
			return ((3 - implementation_map[landuse][lu]) /2);
		}
		return 0.0;
	}
	
	float compute_suitability(string lu, map<string,float> LSmap, int landunit) {		
		float v_l_suitability<-4.0;
		if(length(LSmap.pairs)>0){
//		if(debug){write land_suitability;}
			if(lu in LSmap.keys){				
//				write LS_map[lu];
				v_l_suitability<- LSmap[lu];
			}
		}
		if(suitability_map[landunit]=nil){
			write ""+suitability_map+" "+landunit;
		}
		if (lu in suitability_map[landunit].keys) {
			v_l_suitability<- suitability_map[landunit][lu]<v_l_suitability?suitability_map[landunit][lu]:v_l_suitability;
		}
		return v_l_suitability;
	}
}