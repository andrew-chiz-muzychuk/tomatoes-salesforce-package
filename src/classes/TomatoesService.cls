public class TomatoesService {
	@AuraEnabled
    public static String getTomateToken(){
        User currUser = [SELECT Id, Tomatoes_API_access_token__c, Tomatoes_API_provider__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (currUser.Tomatoes_API_access_token__c == null || currUser.Tomatoes_API_provider__c == null) return null;

        //Tomatoes_API_Settings__mdt tomatSetting = [SELECT Id, label, provider__c, access_token__c FROM Tomatoes_API_Settings__mdt WHERE label = 'MainTomatoesSetting' LIMIT 1];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://www.tomato.es/api/session');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String payLoad = 'provider=' + EncodingUtil.urlEncode(currUser.Tomatoes_API_provider__c, 'UTF-8')
            		  + '&access_token=' + EncodingUtil.urlEncode(currUser.Tomatoes_API_access_token__c, 'UTF-8');
        request.setBody(payLoad);
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return (String)results.get('token');
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> getTomates(Integer page, Date dateFrom, Date dateTo, String token){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'http://www.tomato.es/api/tomatoes';
        if(page == null) page = 1;
        endPoint += '?page=' + page;
        if(dateFrom != null) endPoint += '&from=' + dateFrom;
        if(dateTo != null) endPoint += '&to=' + dateTo;
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setHeader('Authorization', token);
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Map<String, Object>> tomatoesList = new List<Map<String, Object>>();
            List<Object> tomatoesPageList = (List<Object>)results.get('tomatoes');
            for(Object tomato: tomatoesPageList) {
                System.debug('tomato - ' + (Map<String, Object>) tomato);
                Tomato curTomato = new Tomato((Map<String, Object>) tomato);
                Map<String, Object> newTomato = new Map<String, Object>();
                newTomato.put('id', curTomato.tomatoId);
                newTomato.put('created_at', curTomato.created_at);
                newTomato.put('updated_at', curTomato.updated_at);
                newTomato.put('tags', curTomato.tags);
                tomatoesList.add(newTomato);
            }
            return tomatoesList;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Tomato> getAllTomates(String dateFrom, String dateTo, String token){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', token);
            
        List<Tomato> tomatoesList = new List<Tomato>();
        Integer lastPage = 2;
        
        for(Integer page=1; page<=lastPage; page++) {
            String endPoint = 'http://www.tomato.es/api/tomatoes';
            endPoint += '?page=' + page;
            if(dateFrom != null) endPoint += '&from=' + dateFrom + 'T00:00:00Z';
            if(dateTo != null) endPoint += '&to=' + dateTo + 'T23:59:59Z';
            request.setEndpoint(endPoint);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(page == 1) lastPage = (Integer)((Map<String, Object>)results.get('pagination')).get('total_pages');
                List<Object> tomatoesPageList = (List<Object>)results.get('tomatoes');
                for(Object tomato: tomatoesPageList) {
                    System.debug('tomato - ' + (Map<String, Object>) tomato);
                    Tomato curTomato = new Tomato((Map<String, Object>) tomato);
                    /*Map<String, Object> newTomato = new Map<String, Object>();
                    newTomato.put('id', curTomato.tomatoId);
                    newTomato.put('created_at', curTomato.created_at);
                    newTomato.put('updated_at', curTomato.updated_at);
                    newTomato.put('tags', curTomato.tags);
                    newTomato.put('clientName', curTomato.clientName);
                    tomatoesList.add(newTomato);*/
                    tomatoesList.add(curTomato);
                }
            } else break;
        }
        System.debug('output tomatoesList - ' + tomatoesList);
        return tomatoesList;
    }

    @AuraEnabled
    public static Map<String, Object> getWeeklyTomatoes(Integer weekFromNow, String token){
        Datetime monday = Datetime.now().addDays(-7*weekFromNow);
        Integer numOfWeek = Integer.valueof(monday.format('u'));
        monday = monday.addDays(1-numOfWeek);
        Datetime sunday = monday.addDays(6);

        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request.setMethod('GET');
        request.setHeader('Authorization', token);
            
        //List<Map<String, Object>> tomatoesList = new List<Map<String, Object>>();
        List<Tomato> tomatoesList = new List<Tomato>();
        Integer lastPage = 2;
        
        for(Integer page=1; page<=lastPage; page++) {
            String endPoint = 'http://www.tomato.es/api/tomatoes';
            endPoint += '?page=' + page;
            endPoint += '&from=' + monday.format('yyyy-MM-dd') + 'T00:00:00Z';//2019-05-31
            endPoint += '&to=' + sunday.format('yyyy-MM-dd') + 'T23:59:59Z';
            request.setEndpoint(endPoint);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(page == 1) lastPage = (Integer)((Map<String, Object>)results.get('pagination')).get('total_pages');
                List<Object> tomatoesPageList = (List<Object>)results.get('tomatoes');
                for(Object tomato: tomatoesPageList) {
                    System.debug('tomato - ' + (Map<String, Object>) tomato);
                    Tomato curTomato = new Tomato((Map<String, Object>) tomato);
                    tomatoesList.add(curTomato);
                }
            } else break;
        }
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('tomatoesList', tomatoesList);
        resultMap.put('from', monday.format('MM/dd'));
        resultMap.put('to', sunday.format('MM/dd'));
        return resultMap;
    }
    
    @AuraEnabled
    public static String[] getTomatoesSettings(){
        //List<Tomatoes_API_Settings__mdt> settings = [SELECT id FROM Tomatoes_API_Settings__mdt];
        User currUser = [SELECT Id, Tomatoes_API_access_token__c, Tomatoes_API_provider__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (currUser.Tomatoes_API_provider__c != null && currUser.Tomatoes_API_access_token__c != null) {
            return new String[]{currUser.Tomatoes_API_provider__c, currUser.Tomatoes_API_access_token__c};
        } 
        return null;
    }
    
    @AuraEnabled
    public static void setTomatoesSettings(String provider, String token){
        User currUser = [SELECT Id, Tomatoes_API_access_token__c, Tomatoes_API_provider__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (provider != null ) currUser.Tomatoes_API_provider__c = provider;
        if (token != null ) currUser.Tomatoes_API_access_token__c = token;
        update currUser;
    }
    
    public class Tomato {
        @AuraEnabled
        public String tomatoId;
        @AuraEnabled
        public Datetime created_at;
        @AuraEnabled
        public Datetime updated_at;
        @AuraEnabled
        public String tags;
        @AuraEnabled
        public String clientName;

        public Tomato(Map<String, Object> newTomato) {
            tomatoId = (String)newTomato.get('id');
            
            String dateString = (String)newTomato.get('created_at');
            dateString = dateString.replace('T',' ').replace('Z', '');
            created_at = Datetime.valueOf(dateString);
            
            dateString = (String)newTomato.get('updated_at');
            dateString = dateString.replace('T',' ').replace('Z', '');
            updated_at = Datetime.valueOf(dateString);

            /*tags = new List<String>();
            for (Object tag :(List<Object>) newTomato.get('tags')) {
                tags.add((String)tag);
            }*/

            setTags((List<Object>)newTomato.get('tags'));
            if (((List<Object>)newTomato.get('tags')).size() > 0) {
                clientName = (String)((List<Object>)newTomato.get('tags'))[0];
            }
        }
        
        public void setTags(List<Object> newTags) {
            System.debug(newTags);
            for(Object tag: newTags) {
                if (tags == null) {
                    tags = '';
                } else {
                    tags += (String)tag;
                    tags += ', ';
                }
            }
            if (tags != null) {
                tags = tags.left(tags.length()-2);
            }
        }
    }
}