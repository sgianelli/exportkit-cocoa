# Introduction #

EXTwitPic is a simple wrapper that allows the user to create an object containing necessary login information, and upload images from it without having to resubmit credentials every time.  It also allows the user to submit single images via a class method.  The TwitPic API can be found <a href='http://twitpic.com/api.do'>here</a>.

<br></br>
# Properties #


---


`@property(nonatomic,retain) NSString *username`

_username_ - Username for the user's Twitter account.

`@property(nonatomic,retain) NSString *password`

_password_ - Password for the user's Twitter account: _username_.

`@property(nonatomic,assign) id<EXTwitPicDelegate> *delegate`

_delegate_ - The receiver for the delegate methods declared in <a href='http://code.google.com/p/exportkit-cocoa/wiki/EXTwitPic#EXTwitPicDelegate'>EXTwitPicDelegate</a>

<br></br>
# Methods #


---


**`- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password`**

**_Return Value_**

This method returns an EXTwitPic object with corresponding username and password.

**_Parameters_**

  * _username_ - The user's corresponding Twitter account name. _Required_

  * _password_ - The said Twitter account's password, both should be provided by the user. _Required_

**_Usage Notes_**

It is recommended that you use this as the initializer for the object for simplicity's sake.


---


**`- (void)uploadTwitPicImage:(UIImage *)image withMessage:(NSString *)message`**

**_Return Value_**

_nil_

**_Parameters_**

  * _image_ - UIImage representation of the image that you want to upload. _Required_
  * _message_ - NSString containing the message that will go along with the image. _Required_

**_Usage Notes_**

This method **only** uploads to TwitPic, it does **not** tweet the image on the users Twitter account.


---


**`- (void)postTwitPicImage:(UIImage *)image withMessage:(NSString *)message`**

**_Return Value_**

_nil_

**_Parameters_**

  * _image_ - UIImage representation of the image that you want to upload. _Required_
  * _message_ - NSString containing the message that will go along with the image. _Required_

**_Usage Notes_**

This method uploads the given image to TwitPic AND tweets the upload on Twitter.


---


**`+ (void)uploadTwitPicImage:(UIImage *)image withUsername:(NSString *)username password:(NSString *)password message:(NSString *)message andDelegate:(id)delegate`**


**_Return Value_**

_nil_

**_Parameters_**

  * _image_ - UIImage representation of the image that you want to upload. _Required_
  * _username_ - Twitter account of the user, requires accompanying password. _Required_
  * _password_ - The password for the above Twitter account, provided by the user. _Required_
  * _message_ - NSString containing the message that will go along with the image. _Required_
  * _delegate_ - The delegate to receive status messages, the delegate must implement EXTwitPicDelegate & its corresponding required methods.

**_Usage Notes_**

This method **only** uploads to TwitPic, it does **not** tweet the image on the users Twitter account.


---


**`+ (void)postTwitPicImage:(UIImage *)image withUsername:(NSString *)username password:(NSString *)password message:(NSString *)message andDelegate:(id)delegate`**


**_Return Value_**

_nil_

**_Parameters_**

  * _image_ - UIImage representation of the image that you want to upload. _Required_
  * _username_ - Twitter account of the user, requires accompanying password. _Required_
  * _password_ - The password for the above Twitter account, provided by the user. _Required_
  * _message_ - NSString containing the message that will go along with the image. _Required_
  * _delegate_ - The delegate to receive status messages, the delegate must implement EXTwitPicDelegate & its corresponding required methods.

**_Usage Notes_**

This method uploads the given image to TwitPic AND tweets the upload on Twitter.

<br></br>
# EXTwitPicDelegate #


---


**_Required_**

**`- (void)twitPicImage:(UIImage *)image wasSuccessfullyPostedAt:(NSURL *)location`**

  * image_- The image uploaded to TwitPic.
  * location_ - The URL to the image on TwitPic.

**Note** - In the source code, UploadManager actually returns a dictionary of responses from the upload's response that you can pull other details from but currently this seemed the only pertinent one that far up the line.

**`- (void)twitPicImage:(UIImage *)image failedToPost:(NSError *)error`**

  * image_- The image uploaded to TwitPic.
  * error_ - The error corresponding to why the upload failed.


---


**_Optional_**

**`- (void)twitPicImage:(UIImage *)image uploadedBytes:(NSInteger)bytes outOf:(NSInteger)total`**

  * image_- The image uploaded to TwitPic.
  * bytes_ - Number of bytes uploaded to TwitPic.
  * total_- Expected number of bytes to be uploaded._

**Note** - Use this in a progress bar to display the current upload state to the user.