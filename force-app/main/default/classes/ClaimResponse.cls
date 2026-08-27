global class ClaimResponse{
	public EventResponse EventResponse = new EventResponse();
    
	public class EventResponse {		
		public String EventStatus;
        public String EventBusinessID;
		public String EventStatusMessage;
		public ClaimData ClaimData;
        
        public EventResponse(){
            EventBusinessID = '';
            EventStatus='';
            EventStatusMessage = '';
            ClaimData = new ClaimData(); 
        }
	}
	public class ClaimData {
		public String SalesforceID;
		public String ClaimID;
	}  
}