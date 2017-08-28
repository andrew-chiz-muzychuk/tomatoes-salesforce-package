public with sharing class Tomatoes_List_Controller {

  public String tomatoesToken { get; private set; }
  private String gitHubAccessToken;
  private String baseTomatoesEndpoint;
  private String sessionEndpoint;
  private String userInfoEndpoint;

  public Tomatoes_List_Controller() {
    Tomatoes_Settings__c tsCustomSettings = Tomatoes_Settings__c.getInstance(UserInfo.getUserId());
    if (tsCustomSettings != null && String.isNotBlank(tsCustomSettings.GitHub_Access_Token__c)) {
      gitHubAccessToken = tsCustomSettings.GitHub_Access_Token__c;
      baseTomatoesEndpoint = tsCustomSettings.Base_Endpoint__c;
      sessionEndpoint = tsCustomSettings.Session_Endpoint__c;
      userInfoEndpoint = tsCustomSettings.UserInfor_Endpoint__c;
    } else {
      gitHubAccessToken = null;
    }
    System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller ---\n'
      + '\n - gitHubAccessToken: ' + gitHubAccessToken
      + '\n\n');
  }

  public void getTomatoesToken() {
    if (String.isNotBlank(gitHubAccessToken)
      && String.isNotBlank(baseTomatoesEndpoint)
      && String.isNotBlank(sessionEndpoint)
    ) {
      HttpRequest req1 = new HttpRequest();
      req1.setendpoint(baseTomatoesEndpoint+sessionEndpoint);//?provider=github&access_token=4c62801980b014c770ba53d94745165e98b49745');
      req1.setmethod('POST'); //you can also SET method `GET` with Get there is no need of req1.setbody()
      String requestBody = '{'
        + '"provider":"github",'
        + '"access_token":"'+gitHubAccessToken+'"'
        + '}';
      req1.setbody(requestBody);
      System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoesToken - 1 ---\n'
        + '\n - req1: ' + req1
        + '\n - requestBody: ' + requestBody
        + '\n\n');
      HttpResponse res1;
      try {
        res1 = new Http().send(req1);
      } catch (Exception e) {
        System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoesToken - error ---\n'
          + '\n - e: ' + e
          + '\n\n');
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      }
      if (res1 != null) {
        String responseBody = res1.getbody();
        tomatoesToken = responseBody;
        System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoesToken - 2 ---\n'
          + '\n - res1: ' + res1
          + '\n - responseBody: ' + responseBody
          + '\n\n');
      }
    } else {
      if (String.isBlank(gitHubAccessToken)) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No GitHub Access Token is found.'));
      }
      if (String.isBlank(baseTomatoesEndpoint)) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No base Tomatoes enpoint is found.'));
      }
      if (String.isBlank(sessionEndpoint)) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No session endpoint is found.'));
      }
    }
  }
}