public class InventoryWrapper {
    
    public quantityByDateArray[] quantityByDateArray;
	public String partId;	//55250.9
	class quantityByDateArray {
		public boolean isEarliest;
		public minimumQuantity minimumQuantity;
		public truncQuantity truncQuantity;
		public Ddate Ddate;
	}
	class minimumQuantity {
		public String DnumberLong;	//30692
	}
	class truncQuantity {
		public String DnumberLong;	//0
	}
	class Ddate {
		public String Ddate;	//2025-08-09T00:00:00.000+00:00
	}
	public static InventoryWrapper parse(String json){
		return (InventoryWrapper) System.JSON.deserialize(json, InventoryWrapper.class);
	}
}