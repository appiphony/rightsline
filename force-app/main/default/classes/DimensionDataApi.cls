public class DimensionDataApi {
    
    public class DimensionDataApiException extends Exception {}

    @AuraEnabled
    public static string getDimensionDataOptions(){
        ResponseData rd = new ResponseData();
        try{
            HttpResponse res = Utilities.makeRightslineCallout('v4/avails/dimension-data', 'GET', null);        
            if(res.getStatusCode() == 200){
                rd.put('dimensionData', DimensionDataApiResponse.parse(res.getBody()));  
            }else{
                throw new DimensionDataApiException('Unable to obtain dimension options.'); 
            }
        }catch(Exception e){
            rd.addError(e);
        }
        
        return rd.getJsonString();
    }
    
}
