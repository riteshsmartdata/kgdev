/**
 * @description       :
 * @author            : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 * @group             :
 * @last modified on  : 03-11-2026
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 **/
public class KoozieConstants {

  //Koozie Setting 
  public static final String KOOKIE_DOMAIN = '@kooziegroup.com';

  //Custom Lable

  //Golf Parent Account Number (Used in TagSalesContactOnOrder apex)
  public static final String GOLF_PARENT_ACCOUNT_NUMBER = System.Label.Golf_Parent_Account_Number;

  // Koozie Group Account Id
  public static final Id KOOZIE_GROUP_ACCOUNT_ID = System.Label.Koozie_Group_Account_Id;

  //Constants for SalesContactsTervisGreen trigger handler
  public static final String TERVIS_GREEN_GRASS = System.Label.Tervis_Green_Grass;
  

  //Constants Contact values
  public static final String CONTACT_FIRST_NAME_VALUED = 'Valued';
  public static final String CONTACT_LAST_NAME_CUSTOMER = 'Customer';
  public static final String RECORD_TYPE_MULTI_LINE_REP = KoozieUtility.getRecordTypeId(
    'Contact',
    'Multi-Line Rep'
  );

  public static final String RECORD_TYPE_CRM_CONTACT = KoozieUtility.getRecordTypeId(
    'Contact',
    'CRM Contact'
  );

  public static final String CONTACT_ACTIVE_STATUS = 'Active';
  public static final String CONTACT_INACTIVE_STATUS = 'Inactive';

  // Account Constant values 
  public static final String ACCOUNT_CLASS_CODE_BDF = 'BDF';

  //Integration Constants
  public static final String CONTENT_TYPE ='content-type';
  public static final String BEARER ='Bearer ';
  public static final String AUTHORIZATION = 'Authorization';
  public static final String APPLICATION_JSON = 'application/json';
  public static final Integer TIMEOUT = 120000;
  public static final String METHOD_POST = 'POST';
  public static final List<Integer> SUCCESS_CODES = new List<Integer>{
    200,
    201,
    202
  };


  
  //Trigger Recursion
  public static Boolean STOP_RECURSION = TRUE;


  //Order Status 
  public static final String EMAIL_CATEGORY_BOOKED = 'Booked';
  public static final String EMAIL_CATEGORY_INVENTORY_HOLD = 'Inventory Hold';
  public static final String NOTIFICATION_STATUS_DELIVERED= 'delivered';
  public static final String LEAD_TIME_AUTOMATION ='Lead Time Automation';
  
}