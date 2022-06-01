model cell_sal 

import "../params.gaml"
import "district.gaml"
import "province.gaml"

global{
	field  field_salinity<-field(cell_salinity_file);
}
//grid cell_salinity file: cell_salinity_file control: reflex neighbors: 8 {
// 
// 
//}
