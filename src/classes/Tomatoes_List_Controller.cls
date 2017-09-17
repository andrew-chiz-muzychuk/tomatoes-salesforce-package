public with sharing class Tomatoes_List_Controller {

  public String tomatoesToken {get; private set;}
  private String gitHubAccessToken;
  private String baseTomatoesEndpoint;
  private String sessionEndpoint;
  private String userInfoEndpoint;

  public Tomatoes_List_Controller() {
    //getGitHubInfo();
    fromDate = Date.newInstance(2017, 09, 02);
    toDate = Date.newInstance(2017, 09, 16);
    System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller ---\n'
      + '\n - gitHubAccessToken: ' + gitHubAccessToken
      + '\n\n');
    tomatoesToShow = new List<TomatoesTomato>();
    tagCountToShow = new Map<String, Integer>();
    tomatoTagCombinationList = new Set<String>();
    tomatoTagCombinationCountList = new Map<String, Integer>();
  }

  private void getGitHubInfo() {
    Tomatoes_Settings__c tsCustomSettings = Tomatoes_Settings__c.getInstance(UserInfo.getUserId());
    if (tsCustomSettings != null && String.isNotBlank(tsCustomSettings.GitHub_Access_Token__c)) {
      gitHubAccessToken = tsCustomSettings.GitHub_Access_Token__c;
      baseTomatoesEndpoint = tsCustomSettings.Base_Endpoint__c;
      sessionEndpoint = tsCustomSettings.Session_Endpoint__c;
      userInfoEndpoint = tsCustomSettings.UserInfor_Endpoint__c;
    } else {
      gitHubAccessToken = null;
    }
  }

  private String getTomatoesToken() {
    getGitHubInfo();
    if (String.isNotBlank(gitHubAccessToken)
      && String.isNotBlank(baseTomatoesEndpoint)
      && String.isNotBlank(sessionEndpoint)
      ) {
      HttpRequest req1 = new HttpRequest();
      req1.setEndpoint(baseTomatoesEndpoint + sessionEndpoint);// + '?provider=github&access_token='+gitHubAccessToken);
      req1.setMethod('POST');
      String requestBody = '{'
        + '"provider":"github",'
        + '"access_token":"' + gitHubAccessToken + '"'
        + '}';
      req1.setbody(requestBody);
      req1.setHeader('Content-Type', 'application/json');
      req1.setTimeout(20000);
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
        TomatoesTokenResponse tomatoesToken = (TomatoesTokenResponse) JSON.deserialize(responseBody, TomatoesTokenResponse.class);
        System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoesToken - 2 ---\n'
          + '\n - res1: ' + res1
          + '\n - responseBody: ' + responseBody
          + '\n - tomatoesToken: ' + tomatoesToken
          + '\n\n');
        return tomatoesToken.token;
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
    return null;
  }


  public Date fromDate {get; set;}
  public Date toDate {get; set;}
  public Integer pageNumber {get; set;}
  public String debugString {get; set;}

  public void getTomatoes() {
    String fromDateString;
    if (fromDate != null) {
      Datetime fromDT = Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
      fromDateString = String.valueOf(fromDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
    }
    String toDateString;
    if (toDate != null) {
      Datetime toDT = Datetime.newInstance(toDate, Time.newInstance(0, 0, 0, 0));
      toDateString = String.valueOf(toDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
    }
    debugString = '\n\n\n --- getTomatoes --- \n'
      + '\n - fromDate: ' + fromDate
      + '\n - fromDateString: ' + fromDateString
      + '\n - toDate: ' + toDate
      + '\n - toDateString: ' + toDateString
      + '\n\n'
      + '';
    System.debug(LoggingLevel.DEBUG, debugString);

    Tomatoes_Settings__c tsCustomSettings = Tomatoes_Settings__c.getInstance(UserInfo.getUserId());
    String getTomatoesEndpoint;
    if (tsCustomSettings != null && String.isNotBlank(tsCustomSettings.Tomatoes_Endpoint__c)) {
      getTomatoesEndpoint = tsCustomSettings.Tomatoes_Endpoint__c;
    }
    if (String.isBlank(getTomatoesEndpoint)) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Tomatoes Endpoint is found. Plaese, add Tomatoes Endpoint to Custom Settings.'));
      return;
    }

    HttpRequest getTomatoesRequest = new HttpRequest();
    getGitHubInfo();
    getTomatoesRequest.setEndpoint(baseTomatoesEndpoint + getTomatoesEndpoint
      + '?page=1'
      + (fromDateString == null ? '' : '&from=' + fromDateString)
      + (toDateString == null ? '' : '&to=' + toDateString)
    );
    getTomatoesRequest.setMethod('GET');

    String tomatoesToken = getTomatoesToken();

    getTomatoesRequest.setHeader('Authorization', tomatoesToken);
    getTomatoesRequest.setTimeout(10000);
    System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - 1 ---\n'
      + '\n - tomatoesToken: ' + tomatoesToken
      + '\n - getTomatoesRequest: ' + getTomatoesRequest
      + '\n\n');
    HttpResponse getTomatoesResponse;
    try {
      getTomatoesResponse = new Http().send(getTomatoesRequest);
    } catch (Exception e) {
      System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - error ---\n'
        + '\n - e: ' + e
        + '\n\n');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
    if (getTomatoesResponse == null) {
      // error message here
    } else {
      String getTomatoesResponseBody = getTomatoesResponse.getbody();
      debugString += getTomatoesResponseBody;
      System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - 2 ---\n'
        + '\n - getTomatoesResponse: ' + getTomatoesResponse
        + '\n - getTomatoesResponseBody: ' + getTomatoesResponseBody
        + '\n\n');
      TomatoesGetTomatoesResponse tomatoesGetTomatoesResponseEl = (TomatoesGetTomatoesResponse) JSON.deserialize(getTomatoesResponseBody, TomatoesGetTomatoesResponse.class);
      System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - 3 ---\n'
        + '\n - tomatoesGetTomatoesResponseEl: ' + tomatoesGetTomatoesResponseEl
        + '\n - tomatoesGetTomatoesResponseEl.tomatoes: ' + tomatoesGetTomatoesResponseEl.tomatoes
        + '\n\n');
      List<TomatoesTomato> allTomatoes = new List<TomatoesTomato>();
      if (tomatoesGetTomatoesResponseEl.pagination.total_pages > 1) {
        List<TomatoesGetTomatoesResponse> tgtResponses = new List<TomatoesGetTomatoesResponse>();
        tgtResponses.add(tomatoesGetTomatoesResponseEl);
        allTomatoes.addAll(tomatoesGetTomatoesResponseEl.tomatoes);
        for (Integer i = 2; i <= tomatoesGetTomatoesResponseEl.pagination.total_pages; i++) {
          getTomatoesRequest.setEndpoint(baseTomatoesEndpoint + getTomatoesEndpoint
            + '?page=' + i
            + (fromDateString == null ? '' : '&from=' + fromDateString)
            + (toDateString == null ? '' : '&to=' + toDateString)
          );
          try {
            getTomatoesResponse = new Http().send(getTomatoesRequest);
          } catch (Exception e) {
            System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - error ---\n'
              + '\n - e: ' + e
              + '\n\n');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
          }
          if (getTomatoesResponse == null) {
            // error message here
          } else {
            getTomatoesResponseBody = getTomatoesResponse.getbody();
            debugString += getTomatoesResponseBody;
            System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - 4 ---\n'
              + '\n - i: ' + i
              + '\n - getTomatoesResponse: ' + getTomatoesResponse
              + '\n - getTomatoesResponseBody: ' + getTomatoesResponseBody
              + '\n\n');
            TomatoesGetTomatoesResponse tomatoesGetTomatoesResponseEl2 = (TomatoesGetTomatoesResponse) JSON.deserialize(getTomatoesResponseBody, TomatoesGetTomatoesResponse.class);
            System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - 5 ---\n'
              + '\n - i: ' + i
              + '\n - tomatoesGetTomatoesResponseEl2: ' + tomatoesGetTomatoesResponseEl2
              + '\n - tomatoesGetTomatoesResponseEl2.tomatoes: ' + tomatoesGetTomatoesResponseEl2.tomatoes
              + '\n - tomatoesGetTomatoesResponseEl2.tomatoes.size(): ' + tomatoesGetTomatoesResponseEl2.tomatoes.size()
              + '\n\n');
            tgtResponses.add(tomatoesGetTomatoesResponseEl2);
            allTomatoes.addAll(tomatoesGetTomatoesResponseEl2.tomatoes);
            System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_List_Controller - getTomatoes - 6 ---\n'
              + '\n - i: ' + i
              + '\n - tgtResponses: ' + tgtResponses
              + '\n - allTomatoes: ' + allTomatoes
              + '\n - allTomatoes.size(): ' + allTomatoes.size()
              + '\n\n');
          }
        }
        tomatoesToShow.addAll(allTomatoes);
        for (TomatoesTomato ttItem : tomatoesToShow) {
          if (ttItem.tags != null && ttItem.tags.size() > 0) {
            String tagCombination = String.valueOf(ttItem.tags);
            tagCombination = tagCombination.substring(1, tagCombination.length() - 2);
            tomatoTagCombinationList.add(tagCombination);
            if (!tomatoTagCombinationCountList.containsKey(tagCombination)) {
              tomatoTagCombinationCountList.put(tagCombination, 1);
            } else {
              tomatoTagCombinationCountList.put(tagCombination, tomatoTagCombinationCountList.get(tagCombination) + 1);
            }
            for (String tagItem : ttItem.tags) {
              if (!tagCountToShow.containsKey(tagItem)) {
                tagCountToShow.put(tagItem, 1);
              } else {
                tagCountToShow.put(tagItem, tagCountToShow.get(tagItem) + 1);
              }
            }
          }
        }
      }
    }
  }

  class TomatoesTokenResponse {
    public String token {get; set;}
  }

  class TomatoesGetTomatoesResponse {
    public List<TomatoesTomato> tomatoes {get; set;}
    public TomatoesPagination pagination {get; set;}
  }

  class TomatoesTomato {
    public String id {get; set;}
    public String created_at {get; set;}
    public String updated_at {get; set;}
    public List<String> tags {get; set;}
    public String tagsAsOneString {
      get {
        if (tags != null) {
          return String.valueOf(tags);
        } else {
          return '';
        }
      }
      private set;
    }
  }

  class TomatoesPagination {
    public Integer current_page {get; set;}
    public Integer total_pages {get; set;}
    public Integer total_count {get; set;}
  }


  public List<TomatoesTomato> tomatoesToShow {get; private set;}
  public Map<String, Integer> tagCountToShow {get; private set;}
  public Set<String> tomatoesTagList {
    get {
      if (tagCountToShow != null && tagCountToShow.size() > 0) {
        return tagCountToShow.keySet();
      } else {
        return null;
      }
    }
    private set;
  }
  public Set<String> tomatoTagCombinationList {get; private set;}
  public Map<String, Integer> tomatoTagCombinationCountList {get; private set;}
}