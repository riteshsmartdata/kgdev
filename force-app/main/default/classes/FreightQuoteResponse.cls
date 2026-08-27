/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class FreightQuoteResponse{
	public data data;
	class data {
		public response[] response;
	}
	class response {
		public String item_number;	//ICLGEL
		public Integer quantity;	//50
		public String currency_code;	//USD
		public ship_method ship_method;
		public String packing_option;	//Standard
		public ship_from ship_from;
		public ship_to ship_to;
		public freight_calculation freight_calculation;
	}
	class ship_method {
	}
	class ship_from {
	}
	class ship_to {
		public address_line_1 address_line_1;
		public city city;
		public String state;	//IL
		public String zip_code;	//62278
		public String country;	//US
	}
	class address_line_1 {
	}
	class city {
	}
	class freight_calculation {
		public Double package_weight;	//1.602
		public charges[] charges;
	}
	class charges {
		public String ship_method;	//S/H Standard
		public Integer base;	//0
		public Integer variable;	//0
		public Integer hazmat;	//0
		public Integer delivery_in_days;	//5
		public Double total;	//27.06
	}
	public static FreightQuoteResponse parse(String json){
		return (FreightQuoteResponse) System.JSON.deserialize(json, FreightQuoteResponse.class);
	}
}