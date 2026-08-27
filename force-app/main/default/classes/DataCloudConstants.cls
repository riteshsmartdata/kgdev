/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DataCloudConstants {    
    
    //Freight Quote Constants
    public static final String CURRENCY_USD = 'USD';
    public static final String PACKING_OPTION_STANDARD = 'Standard';
    public static final String COUNTRY_US = 'US'; 
    public static final Boolean RESIDENTIAL_FLAG_FALSE = false;
    public static List<Integer> SUCCESS_CODES = new List<Integer>{200,201,202};

    //Integration Constants
    public static final String APPLICATION_JSON = 'application/json';
    public static final Integer TIMEOUT = 120000;
    public static final String METHOD_POST = 'POST';
    
}