# NewsByte

NewsByte App for MobileAppDev CW 1 Part B

NewsByte is a user-friendly application designed for staying updated with the latest news across various categories. It includes functionalities like article bookmarking, reading history tracking, sharing, sorting, filtering, and an integrated web view for reading full articles.


## Features

- **Retrieve and Display News Articles:** Retrieve and display articles with details like source, title, summary, and image.
- **Search News:** Allow users to search for articles using search terms
- **Sort News:** Organize articles by date, popularity or relevance.
- **Filter News by Categories:*** Choose from predefined categories like Technology, Sports, Politics, Science, Entertainment and more to access a feed with news filtered to show news filtered by the chosen category.
- **Top Headlines Carousel:** Showcase the top 5 trending articles in a horizontal scrollable section in the home screen.
- **Bookmark Articles:** Save favorite articles locally for later reading.
- **Embedded Browser:** Open the original article directly within the app from the article details screen.
- **Article View History:** Track and display previously viewed articles and have the ability to delete articles from the history as well.
- **Pull-to-Refresh:** Swipe down to refresh the news feed and load the latest updates.



## Tech Stack

### Development Environment

**IDE:** Android Studio Lady Bug

### Platform & Frameworks

- **Framework:** Flutter (SDK >= 3.2.0 < 4.0.0)
- **Programming Language:** Dart (for Flutter), Kotlin (for Android-specific project code)
- **Build Tools:** Gradle (v8.10.2)
- **JVM Version:** Java 21 (for Android development)

### Frontend
**UI Framework:** Flutter Material Design

### Backend (APIs & Local Database)

- **APIs:** https://newsapi.org/
- **Data Persistence & Storage:** shared_preferences package (v2.3.3) for lightweight key-value storage.

### Utilities

- **Network Requests:** http package (v1.2.2) for API calls.
- **Article Sharing:** share_plus package (v10.1.2) for sharing content to external apps.
- **Navigation State Management:** provider package (v6.1.2) for efficient state handling
- **Launching URLs:** url_launcher package (v6.3.1) for external browsers and webview_flutter package (v4.10.0) for embedded browser

### Testing Environment

- Tested on Android devices with API level 33 (Android 13).

