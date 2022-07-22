public class GetDealTemplateApiResponse {

	public class Fields {
		public String fieldName {get;set;} 
		public String label {get;set;} 
		public Boolean required {get;set;} 
		public Integer maxLength {get;set;} 
		public Boolean editable {get;set;} 
		public String dataType {get;set;} 
		public Boolean allowMultiple {get;set;} 
		public List<ListOfValues> listOfValues {get;set;} 

		public Fields(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'fieldName') {
							fieldName = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'required') {
							required = parser.getBooleanValue();
						} else if (text == 'maxLength') {
							maxLength = parser.getIntegerValue();
						} else if (text == 'editable') {
							editable = parser.getBooleanValue();
						} else if (text == 'dataType') {
							dataType = parser.getText();
						} else if (text == 'allowMultiple') {
							allowMultiple = parser.getBooleanValue();
						} else if (text == 'listOfValues') {
							listOfValues = arrayOfListOfValues(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Fields consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ParentRelationships {
		public Integer charTypeID {get;set;} 
		public Integer templateID {get;set;} 
		public String templateName {get;set;} 
		public Integer relRecTypeID {get;set;} 
		public String relRecTypeDescription {get;set;} 

		public ParentRelationships(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'charTypeID') {
							charTypeID = parser.getIntegerValue();
						} else if (text == 'templateID') {
							templateID = parser.getIntegerValue();
						} else if (text == 'templateName') {
							templateName = parser.getText();
						} else if (text == 'relRecTypeID') {
							relRecTypeID = parser.getIntegerValue();
						} else if (text == 'relRecTypeDescription') {
							relRecTypeDescription = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ParentRelationships consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PartyRelationships {
		public Integer partyID {get;set;} 
		public String partyName {get;set;} 
		public PartyGroup partyGroup {get;set;} 
		public Integer sequenceNumber {get;set;} 
		public Boolean isPrimary {get;set;} 
		public Boolean allowMultiple {get;set;} 
		public Boolean required {get;set;} 
		public List<AllowedTemplates> allowedTemplates {get;set;} 

		public PartyRelationships(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'partyID') {
							partyID = parser.getIntegerValue();
						} else if (text == 'partyName') {
							partyName = parser.getText();
						} else if (text == 'partyGroup') {
							partyGroup = new PartyGroup(parser);
						} else if (text == 'sequenceNumber') {
							sequenceNumber = parser.getIntegerValue();
						} else if (text == 'isPrimary') {
							isPrimary = parser.getBooleanValue();
						} else if (text == 'allowMultiple') {
							allowMultiple = parser.getBooleanValue();
						} else if (text == 'required') {
							required = parser.getBooleanValue();
						} else if (text == 'allowedTemplates') {
							allowedTemplates = arrayOfAllowedTemplates(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'PartyRelationships consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ListOfValues {

		public ListOfValues(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'ListOfValues consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PartyGroup {
		public Integer partyGroupID {get;set;} 
		public Object partyGroupName {get;set;} 

		public PartyGroup(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'partyGroupID') {
							partyGroupID = parser.getIntegerValue();
						} else if (text == 'partyGroupName') {
							partyGroupName = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'PartyGroup consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AllowedTemplates {
		public Integer templateId {get;set;} 
		public String templateName {get;set;} 
		public Integer processId {get;set;} 
		public Object processName {get;set;} 

		public AllowedTemplates(JSONParser parser) {
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
							processName = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'AllowedTemplates consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Fields> fields {get;set;} 
	public Integer templateId {get;set;} 
	public String templateName {get;set;} 
	public Integer processId {get;set;} 
	public String processName {get;set;} 
	public List<ParentRelationships> parentRelationships {get;set;} 
	public List<ParentRelationships> childRelationships {get;set;} 
	public List<PartyRelationships> partyRelationships {get;set;} 

	public GetDealTemplateApiResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'fields') {
						fields = arrayOfFields(parser);
					} else if (text == 'templateId') {
						templateId = parser.getIntegerValue();
					} else if (text == 'templateName') {
						templateName = parser.getText();
					} else if (text == 'processId') {
						processId = parser.getIntegerValue();
					} else if (text == 'processName') {
						processName = parser.getText();
					} else if (text == 'parentRelationships') {
						parentRelationships = arrayOfParentRelationships(parser);
					} else if (text == 'childRelationships') {
						childRelationships = arrayOfParentRelationships(parser);
					} else if (text == 'partyRelationships') {
						partyRelationships = arrayOfPartyRelationships(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'GetDealTemplateApiResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static GetDealTemplateApiResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new GetDealTemplateApiResponse(parser);
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
	


    private static List<ListOfValues> arrayOfListOfValues(System.JSONParser p) {
        List<ListOfValues> res = new List<ListOfValues>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ListOfValues(p));
        }
        return res;
    }


    private static List<Fields> arrayOfFields(System.JSONParser p) {
        List<Fields> res = new List<Fields>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Fields(p));
        }
        return res;
    }







    private static List<PartyRelationships> arrayOfPartyRelationships(System.JSONParser p) {
        List<PartyRelationships> res = new List<PartyRelationships>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new PartyRelationships(p));
        }
        return res;
    }



    private static List<AllowedTemplates> arrayOfAllowedTemplates(System.JSONParser p) {
        List<AllowedTemplates> res = new List<AllowedTemplates>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AllowedTemplates(p));
        }
        return res;
    }


    private static List<ParentRelationships> arrayOfParentRelationships(System.JSONParser p) {
        List<ParentRelationships> res = new List<ParentRelationships>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ParentRelationships(p));
        }
        return res;
    }
}