public with sharing class GetDealTemplateApi {
    public class GetDealTemplateApiException extends Exception {}

    @AuraEnabled
    public static string getTemplate(Integer templateId){
        ResponseData rd = new ResponseData();
        try{

            HttpResponse res = new HttpResponse();
            String url = 'v4/deal-templates/' + templateID;
            res = Utilities.makeRightslineCallout(url, 'GET', null);             
            
            System.debug(res);
            
            if(res.getStatusCode() == 200){
                rd.put('template', GetDealTemplateApiResponse.parse(res.getBody()));  
            }else{
                throw new GetDealTemplateApiException('Unable to obtain template.'); 
            }
        }catch(Exception e){
            rd.addError(e);
        }
        
        return rd.getJsonString();
    }
}
