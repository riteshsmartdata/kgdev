/**
* @File Name : ProductInventoryWrapper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 2, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 2, 2025 |   | Initial Version
**/

public class ProductInventoryWrapper {
	public Integer replenishmentLeadTime;
	public boolean isExclusive;
	public futureAvailablityArray[] futureAvailablityArray;
	public String attribute;	//Blue with Blue Ink
	public String partId;	//55250.1
	public String childItem;	//1009313
	public boolean isManufactured;
	public boolean isBuyToOrder;
	public Integer partGroup;	//1
	public String partDescription;	//Blue with Blue Ink
	public boolean isMainPart;
	public ratio ratio;
	public quantityAvailable quantityAvailable;
	public boolean partGroupRequired;
	public lastModifiedDate lastModifiedDate;
	public customerArray[] customerArray;
	public colorArray[] colorArray;
	public String partGroupDescription;	//Item Color
	public String parentItem;	//2007499
	public String attributeGroup;	//Item Color
	public String pricingClassification;	//Standard
	public String marketingABCcategory;	//B
	public String fobId;	//CLW
	/*class replenishmentLeadTime {
	}*/
	class futureAvailablityArray {
		public boolean firmFlag;
		public String purchaseOrderNumber;	//2007219
		public String source;	//ORACLE
		public Integer purchaseOrderLineNumber;	//1
		public availableOn availableOn;
		public lastUpdatedDate lastUpdatedDate;
		public quantity quantity;
		public createdDate createdDate;
	}
	class availableOn {
		public String Ddate;	//2025-11-10T00:00:00.000+00:00
	}
	class lastUpdatedDate {
		public String Ddate;	//2025-08-09T09:01:51.000+00:00
	}
	class quantity {
		public String uom;	//EA
		public Integer value;	//29400
	}
	class createdDate {
		public String Ddate;	//2025-08-09T09:01:51.000+00:00
	}
	class ratio {
		public String DnumberDecimal;	//1
	}
	class quantityAvailable {
		public String uom;	//EA
		public Integer value;	//30692
	}
	class lastModifiedDate {
		public String Ddate;	//2025-08-01T03:25:09.000+00:00
	}
	class customerArray {
	}
	class colorArray {
		public String hexCode;	//#324A96
		public String pmsColor;	//7455 C
	}
	public static ProductInventoryWrapper parse(String json){
		return (ProductInventoryWrapper) System.JSON.deserialize(json, ProductInventoryWrapper.class);
	}
}