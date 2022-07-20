public class AWSSignature {
    //request values
    String region = '';  //eu-west-2
    String service = '';  //ec2
    String key = ''; //AWS key
    String secret = ''; //AWS Secret key
    String host = ''; //nsys.inf4mation.com
    string resource='';
    string method;
    
    //date for headers and the credential string
    String amzDate = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
    String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
    
    private string createCanonicalRequest()
    {
        //Task1. Step 2 - Add the canonical URI parameter
        String canonicalUri = '/'+resource; 
        
         //Task1. Step 3 - Add the canonical query string,
        String canonicalQueryString = '';
        
        //Task1. Step 4 - Add the canonical headers
        string canonicalHeaders=canonicalHeaders();
        
        //Task1. Step 5 - Add the signed headers
        String signedHeaders =signedHeaders();
        
        //Task1. Step 6 - Use a hash (digest) function like SHA256 to create a hashed value from the payload in the body of the HTTP or HTTPS request. 
        Blob payload = Blob.valueOf('');
        String payloadHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', payload));
        
        //Task1. Step 7: Combine elements to create create canonical request  
        String canonicalRequest = method + '\n' 
            + canonicalUri + '\n'  
            + canonicalQueryString + '\n' 
            + canonicalHeaders + '\n' 
            + signedHeaders + '\n' 
            + payloadHash;
        return canonicalRequest;
    }
    
    private string createStringToSign(string canonicalRequest)
    {
        //Task2 - Step 1 algorithm designation
		String algorithm = algorithm();
        
        //Task2 - Step 2 Append the request date value
        String credentialScope = credentialScope();
        
        //Task2 - Step 3 Append the credential scope value, 
        String stringToSign = algorithm + '\n' +  amzdate + '\n' +  credentialScope + '\n' + 
            EncodingUtil.convertToHex(Crypto.generateDigest('sha256', Blob.valueOf(canonicalRequest)));
       
		return stringToSign;
    }
    
    private string calculateSignature(string stringToSign)
    {
        //Task3 - Step 1 generate signing key
        Blob signingKey = createSigningKey(secret);
        
        //Task3 - Step 2 generate signature  
        String signature =  createSignature(stringToSign, signingKey); 
        
        return signature;
    }
    
    private string algorithm()
    {
        return 'AWS4-HMAC-SHA256';
    }
    private string credentialScope()
    {
        return datestamp + '/' + region + '/' + service + '/' + 'aws4_request';
    }
    private string signedHeaders()
    {
        return 'host;x-amz-date';
    }
    private string canonicalHeaders()
    {
        return 'host:' + host + '\n' + 'x-amz-date:' + amzdate + '\n';
    }
    private string endpoint()
    {
        system.debug('endpoint: '+ 'https://' + host +'/'+resource);
        return 'https://' + host +'/'+resource;
    }
    private Blob createSigningKey(String secretKey){
        Blob dateKey = signString(Blob.valueOf(datestamp),Blob.valueOf('AWS4'+secretKey));
        Blob dateRegionKey = signString(Blob.valueOf(region),dateKey);
        Blob dateRegionServiceKey = signString(Blob.valueOf(service),dateRegionKey);
        return signString(Blob.valueOf('aws4_request'),dateRegionServiceKey);
    }
    
    private Blob signString(Blob msg, Blob key){
        return Crypto.generateMac('HMACSHA256', msg, key);
    } 
    
    private String createSignature(String stringToSign, Blob signingKey){        
        return EncodingUtil.convertToHex(Crypto.generateMac('HMACSHA256', blob.valueof(stringToSign), signingKey));
    }
    
    public void setAWS(string regn, string servce, string k, string sct)
    {
        region=regn;
        service=servce;
        key=k;
        secret=sct;
    }
    
    public void setUrl(string hst,string resce)
    {
        host=hst;
        resource=resce;
    }
    
    public void setMethod(string mthd)
    {
        method=mthd;
    }
    
    public HttpRequest createSigntaureRequest(){
        
        HttpRequest req = new HttpRequest();
        
        //Task 1: Create a canonical request
        //Task1. Step 1 - set the request method (GET, POST,PUT,DELETE etc.)
        req.setMethod(method);
        string canonicalRequest=createCanonicalRequest();
        system.debug('canonicalRequest:'+canonicalRequest);

        //Task 2: Create a string to sign
        string stringToSign=createStringToSign(canonicalRequest);
        //Task 3: Calculate the signature
        
        string calculatedSignature=calculateSignature(stringToSign);
        
        //Task 4: Add the signature to the HTTP request
        String authorizationHeader = algorithm() + ' ' 
            + 'Credential=' + key + '/' 
            + credentialScope() + ', ' 
            +  'SignedHeaders=' + signedHeaders() + ', ' 
            + 'Signature=' + calculatedSignature;
        
        req.setHeader('Authorization',authorizationHeader);
        req.setHeader('x-amz-date', amzdate);
        req.setEndpoint(endpoint());
        
        return req;
    }
    
}