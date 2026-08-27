/**
* @description       : 
* @author            : Marlin
* @group             : 
* @created date		 : 12/15/2025
* @last modified on  : 
* @last modified by  : 
* Modifications Log
* 
*/

public with sharing class BusinessHoursDiffAction {

    @InvocableMethod(
        label='Business Hours Difference (Hours & Minutes)'
        description='Calculate business-hours difference between two DateTime values'
    )
    public static List<Output> calculateDiff(List<Input> inputs) {

        List<Output> results = new List<Output>();

        for (Input i : inputs) {

            Long diffMs = BusinessHours.diff(
                i.businessHoursId,
                i.startDateTime,
                i.endDateTime
            );

            Output o = new Output();
            o.milliseconds = diffMs;
            o.totalMinutes = diffMs / (1000 * 60);
            o.totalHours = (Decimal) diffMs / (1000 * 60 * 60);

            results.add(o);
        }

        return results;
    }

    // ===== INPUTS =====
    public class Input {

        @InvocableVariable(
            label='Business Hours Id'
            required=true
        )
        public Id businessHoursId;

        @InvocableVariable(
            label='Start Date Time'
            required=true
        )
        public Datetime startDateTime;

        @InvocableVariable(
            label='End Date Time'
            required=true
        )
        public Datetime endDateTime;
    }

    // ===== OUTPUTS =====
    public class Output {

        @InvocableVariable(label='Milliseconds')
        public Long milliseconds;

        @InvocableVariable(label='Total Minutes')
        public Long totalMinutes;

        @InvocableVariable(label='Total Hours')
        public Decimal totalHours;
    }
}