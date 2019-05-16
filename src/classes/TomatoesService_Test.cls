@isTest
public class TomatoesService_Test {
	@isTest
    public static void getTokenTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String token = TomatoesService.getTomateToken();
        Test.stopTest();
        
        System.assertEquals('correct_token', token);
    }

    @isTest
    public static void getTomatesTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String token = TomatoesService.getTomateToken();
        Date testDate = Date.today();
        List<Map<String, Object>> tomatoesList = TomatoesService.getTomates(1, testDate, testDate, token);
        Test.stopTest();
        
        System.assertEquals(1, tomatoesList.size());
    }

    @isTest
    public static void getAllTomatesTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String token = TomatoesService.getTomateToken();
        Date testDate = Date.today();
        List<Map<String, Object>> tomatoesList = TomatoesService.getAllTomates(String.valueOf(testDate), String.valueOf(testDate), token);
        Test.stopTest();
        
        System.assertEquals(1, tomatoesList.size());
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            Map<String, Object> body = new Map<String, Object>();
            Boolean errorResponse = false;
            if (req.getEndpoint().contains('http://www.tomato.es/api/session') && req.getMethod() == 'POST') {
                body.put('token', 'correct_token');
                
            } else if (req.getEndpoint().contains('http://www.tomato.es/api/tomatoes') && req.getMethod() == 'GET') {
                //Example of endpoint http://www.tomato.es/api/tomatoes?page=*&from=*&to=*
                List<String> endpointList = req.getEndpoint().split('&');
                if (req.getHeader('Authorization') == 'correct_token' && 
                    endpointList.size() == 3 && 
                    endpointList[0].split('=')[1].isNumeric() && 
                    Datetime.valueOf(endpointList[1].split('=')[1].replace('T',' ').replace('Z','')) != null && 
                    Datetime.valueOf(endpointList[2].split('=')[1].replace('T',' ').replace('Z','')) != null) {
                        Map<String, Object> pagination = new Map<String, Object>();
                        pagination.put('total_pages', 1);
                    body.put('pagination', pagination);
                        List<Object> tomatoesPageList = new List<Object>();
                            Map<String, Object> newTomato = new Map<String, Object>(); 
                            newTomato.put('id', '123');
                            newTomato.put('created_at', '2019-01-01T07:33:09.334Z');
                            newTomato.put('updated_at', '2019-01-01T07:33:09.334Z');
                            newTomato.put('tags', new List<Object>());
                        tomatoesPageList.add(newTomato);
                    body.put('tomatoes', tomatoesPageList);
                } else {
                    errorResponse = true;
                }
                body.put('id', 123);
                body.put('name', 'TestName');
                
            } else {
                res.setStatusCode(404);
                res.setStatus('Test not found');
                return res;
            }
            
            if (errorResponse) {
                res.setStatusCode(400);
                res.setStatus('Test error');
                return res;
            }
            String serializedBody = JSON.serialize(body, true);
            res.setBody(serializedBody);
            res.setStatusCode(200);
            res.setStatus('Test status');
            return res;
        }
    }
}