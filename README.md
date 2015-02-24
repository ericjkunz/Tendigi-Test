# Tendigi-Test

Thank you again for this opportunity. Let's get into my app!

![alt tag](https://raw.githubusercontent.com/ericjkunz/Tendigi-Test/master/TDTestScreenshot.PNG?token=AG5RqqALQiNiGZ_suJwjtfQnYIsgpHzbks5U9fx7wA%3D%3D =50x)


I decided to use a UITableView since it fits viewing a Twitter feed well. The main UITableView implements its refreshControl in order to request for the latest tweets and reload the view. 

Since Tendigi's tweets are usually about cool articles and news stories I made it so that tapping anywhere on a tweet will open a UIWebView with the link found in the tweet. The link is found in the tweet's text using NSDataDetector. An action button is present when viewing a webpage so that it can be shared via any of the services the user has installed on their device.

The Local button will bring you to another UITableView but this time it displays tweets relevant to Dumbo and within 1 mile of Tendigi's office.

Making requests to Twitter's API is done in the TDTwitterCommunicator class. Making requests, sending requests, and even displaying tweets was done through the TwitterKit framework. Requests are made without having the user sign in since viewing Tendigi's timeline and searching for tweets can be done while logged in as a guest.

Congratulations on the app launch! I look forward to hearing your feedback soon.

Best,
Eric
