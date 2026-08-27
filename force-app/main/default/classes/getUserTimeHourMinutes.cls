public class getUserTimeHourMinutes {
    @InvocableMethod(label = 'Get User Time Info')
    public static List<returnValues> getUserTimes(List<DateTime> userdate) {
        
        List<returnValues> rtrList = new List<returnValues>();
        for (DateTime dt : userdate) {
            returnValues rtr = new returnValues();
            rtr.hour = dt.hour();
            rtr.minute = dt.minute();
            rtrList.add(rtr);
        }
        return rtrList;
    }
    
    public class returnValues {
        @InvocableVariable 
        public Integer hour;
        
        @InvocableVariable 
        public Integer minute;
    }
}