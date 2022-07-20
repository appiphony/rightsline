public class DimensionDataApiResponse {
    public class childValues {
        public Integer id {get;set;} 
        public String label {get;set;} 
        public List<childValues> childValues {get;set;} 

        public childValues(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'label') {
                            label = parser.getText();
                        } else if (text == 'childValues') {
                            childValues = arrayOfchildValues(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'childValues consuming unrecognized property: '+text); //TODO - get rid of this later
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Dimension {
        public Integer id {get;set;} 
        public String label {get;set;} 
        public List<childValues> childValues {get;set;} 

        public Dimension(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'label') {
                            label = parser.getText();
                        } else if (text == 'childValues') {
                            childValues = arrayOfchildValues(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Dimension consuming unrecognized property: '+text); //TODO - get rid of this later
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Dimension> media {get;set;} 
    public List<Dimension> territory {get;set;} 
    public List<Dimension> language {get;set;} 

    public DimensionDataApiResponse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'dim1'){
                        media = arrayOfDimension(parser);
                    } else if(text == 'dim2'){
                        territory = arrayOfDimension(parser);
                    } else if(text == 'dim3') {
                        language = arrayOfDimension(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'DimensionDataApiResponse consuming unrecognized property: '+text); //TODO - get rid of this later
                        consumeObject(parser);
                    }
                }
            }
        }
    }        
    
    public static DimensionDataApiResponse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new DimensionDataApiResponse(parser);
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
    


    private static List<childValues> arrayOfchildValues(System.JSONParser p) {
        List<childValues> res = new List<childValues>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new childValues(p));
        }
        return res;
    }

    private static List<Dimension> arrayOfDimension(System.JSONParser p) {
        List<Dimension> res = new List<Dimension>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Dimension(p));
        }
        return res;
    }
}
