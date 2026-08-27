/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   10-31-2023   Ritesh Kumar   Initial Version
**/
public class ProductRequest{

	public EventRequest eventRequest;

	public class EventRequest {
		public String eventObject;
		public String eventDateTime;
		public String eventSourceSystem;
		public String eventBusinessID;
		public ProductData[] productData;
	}

	public class ProductData {
		public String websiteID; 
		public String salesforceID;
		public String productCatalogNumber;
		public String productName;
		public String categories;
		public String subCategories;
		public String departments;
		public String brand;
		public String countryofOrgin;
		public ManufacturingSite manufacturingSite;
		public String productURL;
		public String productURLCA;
		public String productImageURL;
		public String productStatus;
		public String pricingCode;
		public Double endQtyPrice;
		public Double endQtyPriceCA;
		public String endQtPriceCode;
		public Double endQtyRetailPrice;
		public Double endQtyRetailPriceCA;
		public String Exclusive_To;
        public String RecordTypeName;
		public String productSubStatus;
		public Boolean isOutOfStock;
	}

	public class ManufacturingSite {
		public String postalCode;
		public String city;
		public String state;
		public String country;
	}

	public static ProductRequest parse(String json){
		return (ProductRequest) System.JSON.deserialize(json, ProductRequest.class);
	}

}