public with sharing class Tomatoes_Settings_Controller {

  public String gitHubAccessToken { get; set; }
  public Boolean isGitHubAccessTokenInputVisible { get; private set; }

  public Tomatoes_Settings_Controller() {
    Tomatoes_Settings__c tsCustomSettings = Tomatoes_Settings__c.getInstance(UserInfo.getUserId());
    if (tsCustomSettings != null && String.isNotBlank(tsCustomSettings.GitHub_Access_Token__c)) {
      gitHubAccessToken = tsCustomSettings.GitHub_Access_Token__c;
    } else {
      gitHubAccessToken = null;
    }
    isGitHubAccessTokenInputVisible = false;
    /*System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_Settings_Controller ---\n'
      +'\n - tsCustomSettings: ' + tsCustomSettings
      +'\n - gitHubAccessToken: ' + gitHubAccessToken
      +'\n - isGitHubAccessTokenInputVisible: ' + isGitHubAccessTokenInputVisible
      +'\n - isGitHubAccessTokenInputVisible == null: ' + (isGitHubAccessTokenInputVisible == null)
      +'\n\n');*/
  }

  public void saveSettings() {
    Tomatoes_Settings__c tsCustomSettings = Tomatoes_Settings__c.getInstance(UserInfo.getUserId());
    tsCustomSettings.GitHub_Access_Token__c = gitHubAccessToken;
    upsert tsCustomSettings;
  }

  public void hideShowInputGitHubAccessToke() {
    /*System.debug(LoggingLevel.WARN, '\n\n\n --- Tomatoes_Settings_Controller - hideShowInputGitHubAccessToke ---\n'
      +'\n - isGitHubAccessTokenInputVisible: ' + isGitHubAccessTokenInputVisible
      +'\n - isGitHubAccessTokenInputVisible == null: ' + (isGitHubAccessTokenInputVisible == null)
    +'\n\n');*/
    isGitHubAccessTokenInputVisible = !isGitHubAccessTokenInputVisible;
  }
}