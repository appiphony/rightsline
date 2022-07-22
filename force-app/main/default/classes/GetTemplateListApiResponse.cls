public class GetTemplateListApiResponse {

	public List<Templates> templates {get;set;} 

	public GetTemplateListApiResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'templates') {
						templates = arrayOfTemplates(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'GetTemplateListApiResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Templates {
		public Integer templateId {get;set;} 
		public String templateName {get;set;} 
		public Integer processId {get;set;} 
		public String processName {get;set;} 

		public Templates(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'templateId') {
							templateId = parser.getIntegerValue();
						} else if (text == 'templateName') {
							templateName = parser.getText();
						} else if (text == 'processId') {
							processId = parser.getIntegerValue();
						} else if (text == 'processName') {
							processName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Templates consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static GetTemplateListApiResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new GetTemplateListApiResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


    private static List<Templates> arrayOfTemplates(System.JSONParser p) {
        List<Templates> res = new List<Templates>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Templates(p));
        }
        return res;
    }




}
