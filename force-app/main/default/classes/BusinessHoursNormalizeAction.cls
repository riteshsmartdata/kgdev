/**
* @description       : 
* @author            : Marlin
* @group             : 
* @created date		 : 1/5/2026
* @last modified on  : 
* @last modified by  : 
* Modifications Log
* 
*/

public with sharing class BusinessHoursNormalizeAction {

    public class Request {
        @InvocableVariable(required=true)
        public Datetime inputDateTime;

        @InvocableVariable(required=true)
        public Id businessHoursId;
    }

    public class Response {
        @InvocableVariable
        public Datetime resultDateTime;
    }

    @InvocableMethod(
        label='Normalize DateTime to Business Hours'
        description='Returns the same DateTime if within Business Hours, otherwise returns the start of the next business day'
    )
    public static List<Response> normalizeDateTime(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();

            Boolean isWithin = BusinessHours.isWithin(
                req.businessHoursId,
                req.inputDateTime
            );

            if (isWithin) {
                res.resultDateTime = req.inputDateTime;
            } else {
                // Apex supports addSeconds(), not addMilliseconds()
                Datetime adjusted = req.inputDateTime.addSeconds(1);

                res.resultDateTime = BusinessHours.nextStartDate(
                    req.businessHoursId,
                    adjusted
                );
            }

            responses.add(res);
        }

        return responses;
    }
}