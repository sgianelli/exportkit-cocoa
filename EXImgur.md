# Introduction #

EXImgur is by far the simplest wrapper contained in this framework, it simply lets you upload images to imgur and delete said image using its corresponding delete hash.  The original web API for imgur can be found <a href='http://code.google.com/p/imgur-api/'>here</a>

# Properties #

_none_

# Methods #


---


**`+ (void)uploadImageToImgur:(UIImage *)image withDelegate:(id)delegate`**

**_Return Value_**

_nil_

**_Parameters_**

  * image_- The image that the user wants to upload to imgur._

  * delegate - The delegate to receive updates on the upload (can be _nil_), see <a href='http://code.google.com/p/exportkit-cocoa/wiki/EXImgur#EXImgurDelegate'>EXImgurDelegate</a>


---


**`+ (void)deleteImgurImageWithHash:(NSString *)hash withDelegate:(id)delegate`**

**_Return Value_**

_nil_

**_Parameters_**

  * hash_- A delete hash received from a previous upload, sent to the delegate initially._

  * delegate - The delegate to receive updates on the upload (can be _nil_), see <a href='http://code.google.com/p/exportkit-cocoa/wiki/EXImgur#EXImgurDelegate'> EXImgurDelegate</a>

<br></br>
# EXImgurDelegate #

**_Required_**

**`- (void)imgurSuccesfullyPostedImage:(UIImage *)image withURL:(NSURL *)url andDeleteHash:(NSString *)hash`**

  * _image_ - The image that was initially sent to the upload class method.

  * _url_ - The URL that the image is located at on imgur.

  * _hash_ - The delete hash returned from imgur; use this to delete the image later.

**`- (void)imgurFailedToPostImage:(UIImage *)image withError:(NSError *)error`**

  * _image_ - The image that was initially sent to the upload class method.

  * _error_ - The reason for the failure, usually due to network connectivity.


---


**_Optional_**

**`- (void)imgurImage:(UIImage *)image sentBytes:(NSInteger)bytes ofTotal:(NSInteger)total`**

  * _image_ - The image that was initially sent to the upload class method.

  * _bytes_ - Number of bytes uploaded to the server.

  * _total_ - Total estimated number of bytes in the upload.

**`- (void)imgurImageDeletedSuccesfullyWithHash:(NSString *)hash`**

  * _hash_ - The delete hash used to delete the image off of imgur.

**`- (void)imgurImageFailedToDeleteWithHash:(NSString *)hash`**

  * _hash_ - The delete hash used to delete the image off of imgur.