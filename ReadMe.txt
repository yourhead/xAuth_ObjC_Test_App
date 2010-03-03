
xAuth Test Application
original source written by Isaiah Carew
© YourHead Software 2010 - All rights reserved.
http://yourhead.com
http://kiwi-app.net


I created this application to demonstrate a complete solution using the available open source libraries.

This is based on a similar project for OAuth, but with the addition of the xAuth parameters and simplifications for desktiop applications.



This is not meant to be a complete twitter client, just a helping hand to get through the xAuth step.



Example:
I've included a compiled example with Twitter application keys for Kiwi:  http://kiwi-app.net/
I did this so that you have an example of how the app should behave after you insert your own keys obtained from twitter.  You can download the example directly from github:
http://github.com/yourhead/xAuth_ObjC_Test_App/downloads



To Use:
You will need to create an OAuth applicaton registration on the Twitter site:
 http://twitter.com/oauth_clients/new
Use the key and secret info provided there to modify the constants at the top of YHOAuthTwitterEngine.m
You should also set up your callback url at the top of the YHTwitter.m



xAuth permission:
Twitter does not allow all applications to use xAuth.  You need to requst permission from Twitter to use the simplified xAuth work flow.  It is usually approved for desktop and mobile and usually denied for web-apps.  Send and email to api@twitter.com with your application details.



License:
Licenses for included libraries are listed below.  The rest of the code is entered into the public domain.  Enjoy.



Built using:
MGTwitterEngine by Matt Gemmell
http://mattgemmell.com
License:  http://mattgemmell.com/license
I have included 1.0.8 release of the MGTwitterEngine unchanged in this project.  
The goal is to create an easily builable project that has no dependancies.



OAuthConsumer Framework
Jon Crosby
http://code.google.com/p/oauth/
License:  http://www.apache.org/licenses/LICENSE-2.0
I have included a pre-built binary of the OAuthConsumer Framework unchanged in this project.  
The goal is to create an easily builable project that has no dependancies.



OAuth-MyTwitter
Chris Kimpton
http://github.com/kimptoc/MGTwitterEngine-1.0.8-OAuth-MyTwitter/tree/master
License:  Couldn't find one.  Will amend this if I do.
Some code from this project was used to create the YHOATwitterEngine subclass of MGTwitterEngine.
Thanks Chris, you made this project a simple!



Special thanks to:
@stevereynolds for explaining the workflow when no documentation yet existed.
@aral for producing a similar project for iPhone.
