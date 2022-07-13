global with sharing class customPropertyEditorClass {
    @InvocableMethod(label='Choose Operation' description='Choose an operation to be done during record triggered flow' configurationEditor='c-custom-property-editor')
    global static void performOperation(List<params> p) {
        //insert new Lead(FirstName = 'John', LastName = 'Smith', Email = 'daniel.ferenc@appiphony.com', Description = String.valueOf(p), Company = 'testcompany');
        System.debug(String.valueOf(p));
    }

    global class params {
        @InvocableVariable(label='data')
        global String data;
    }
}