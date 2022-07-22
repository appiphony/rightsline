public with sharing class AvailableCatalogItemsApi {
    public class AvailableCatalogItemsApiException extends Exception {}

    public class AvailableCatalogItemsApiRequestBody {
        /* Example Body
            {
                "recordId": [
                  ], 
                  "dim1": [300],
                  "dim2": [186],
                  "dim3": [],
                  "dim4": [], 
                  "windowStart": "2022-06-21", 
                  "windowEnd": "2023-06-21",   
                  "isExclusive": null,
                  "matchType": "CoverEntire",
                  "isExact": true,
                  "start": 0,   
                  "rows": 25
            }
        */

        List<Integer> recordId {get;set;}
        List<Integer> dim1 {get;set;}
        List<Integer> dim2 {get;set;}
        List<Integer> dim3 {get;set;}
        List<Integer> dim4 {get;set;}
        String windowStart {get;set;}
        String windowEnd {get;set;}
        Boolean isExclusive {get;set;}
        String matchType {get;set;}
        Boolean isExact {get;set;}
        Integer start {get;set;}
        Integer rows {get;set;}

        public AvailableCatalogItemsApiRequestBody(){
            recordId = new List<Integer>();
            //POC Construction, needs to be changed (TODO)
            dim1 = new List<Integer>();
            dim1.add(300);

            dim2 = new List<Integer>();
            dim2.add(186);

            dim3 = new List<Integer>();
            dim4 = new List<Integer>();

            windowStart = '2022-06-21';
            windowEnd = '2023-06-21';

            isExclusive = null;
            matchType = 'CoverEntire';
            isExact = true;
            start = 0;
            rows = 25;            
        }
    }

    @AuraEnabled
    public static string getAvailableCatalogItems(){
        ResponseData rd = new ResponseData();
        try{

            AvailableCatalogItemsApiRequestBody rbody = new AvailableCatalogItemsApiRequestBody();
            System.debug(JSON.serialize(rbody));

            HttpResponse res = Utilities.makeRightslineCallout('v4/avails/available-catalog-items', 'POST', JSON.serialize(rbody)); 
            
            System.debug(res);
            
            if(res.getStatusCode() == 200){
                rd.put('availableCatalogItems', AvailableCatalogItemsApiResponse.parse(res.getBody()));  
            }else{
                throw new AvailableCatalogItemsApiException('Unable to obtain available catalogs.'); 
            }
        }catch(Exception e){
            rd.addError(e);
        }
        
        return rd.getJsonString();
    }
}
