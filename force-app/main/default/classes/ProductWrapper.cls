public class ProductWrapper { 
	public Integer replenishmentLeadTime;
	public boolean isExclusive;
	public String attribute;	//Aquamarine with Black Ink
	public String partId;	//55250.1
	public String childItem;	//1071334
	public boolean isManufactured;
	public boolean isBuyToOrder;
	public Integer partGroup;	//1
	public String partDescription;	//Aquamarine with Black Ink
	public boolean isMainPart;
	public ratio ratio;
	public boolean partGroupRequired;
	public lastModifiedDate lastModifiedDate;
	public customerArray[] customerArray;
	public colorArray[] colorArray;
	public String partGroupDescription;	//Item Color
	public String parentItem;	//2007499
	public String attributeGroup;	//Item Color
	public String pricingClassification;	//Standard
	public String marketingABCcategory;	//N25
	public String fobId;	//CLW
	/*class replenishmentLeadTime {
	}*/
	class ratio {
		public String DnumberDecimal;	//1
	}
	class lastModifiedDate {
		public String Ddate;	//2025-06-03T14:12:56.000+00:00
	}
	class customerArray {
	}
	class colorArray {
		public String hexCode;	//#006D7E
		public String pmsColor;	//8225 C
	}
	public static ProductWrapper parse(String json){
		return (ProductWrapper) System.JSON.deserialize(json, ProductWrapper.class);
	}

}