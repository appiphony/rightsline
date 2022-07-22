public with sharing class GetTemplateListApi {
    public class GetTemplateListApiException extends Exception {}

    @AuraEnabled
    public static string getTemplateList(String entity){
        ResponseData rd = new ResponseData();
        try{

            HttpResponse res = new HttpResponse();
            if( entity == 'deal' ){
                res = Utilities.makeRightslineCallout('v4/deal-templates', 'GET', null); 
            }
            
            System.debug(res);
            
            if(res.getStatusCode() == 200){
                rd.put('templates', GetTemplateListApiResponse.parse(res.getBody()));  
            }else{
                throw new GetTemplateListApiException('Unable to obtain ' + entity + ' templates.'); 
            }
        }catch(Exception e){
            rd.addError(e);
        }
        
        return rd.getJsonString();
    }
}
