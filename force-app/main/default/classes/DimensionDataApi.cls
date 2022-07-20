public class DimensionDataApi {
    
    public static void callEndpoint(){
        HttpResponse res = Utilities.makeRightslineCallout('v4/avails/dimension-data', 'GET', null);        
        DimensionDataApiResponse dimensionDataResponse = DimensionDataApiResponse.parse(res.getBody());
        System.debug(dimensionDataResponse);
    }
    
}
