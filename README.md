#GitHub Repo Finder

The app presents GitHub repos fetched using the search term in a list. Clicking on a row in the list navigates to a detail screen with the repo's ReadMe displayed in a WebView. To be able to view all images in the list and the ReadMe, first log in to GitHub by tapping on the profile icon in the upper right to bring up GitHub's sign in page. 

The UI is made using the Texture framework, with exception of the search bar and the navigation controller's UIBarButtonItem. 

After logging in using one's GitHub credentials, the app does decode some User data, although that is not currently used. The app uses the received access token to download each repo's ReadMe as HTML. A GitHub app was created to enable more requests to be made per hour.
