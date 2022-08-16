# GitHub Repo Finder

The app fetchs GitHub repositories using a search term, and presents them in a list. Clicking on a row in the list navigates to a detail screen with the repo's README displayed in a WebView. To be able to view all images in the list and the README, first log in to GitHub by tapping on the profile icon in the upper right to bring up GitHub's sign in page (screenshot below). After going through GitHub's authorization flow, you should see images for some searched repos, and clicking on a row will display the README.

The UI is made using the Texture framework, with the exception of some subviews. 

After logging in using one's GitHub credentials, the app does decode some User data, although that is not currently used. The app uses the received access token to download a String of the HTML for each repo's README (from which it also parses the repo's first image source URL). 

After signing in once, the access token should persist, making signing in unnecessary on subsequent sessions. The repo search results should also persist, enabling an offline experience, and preserving the last search results for new app sessions.

Errors occuring in networking methods and while saving/loading using Core Data are logged to the system.

![Login Button](https://github.com/astruckm/GitHubRepoFinder/blob/main/Screenshots/LoginBarButton.png?raw=true)
