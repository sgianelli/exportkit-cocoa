# Introduction #

EXPikchur is a simple wrapper for the standard Pikchur.com API.  This class allows a user to authenticate with Pikchur without saving the user's password.  The original Pikchur documentation can be found <a href='http://groups.google.com/group/pikchur-api'>here</a>.

<br></br>
# Properties #

`@property(nonatomic,assign) id<EXPikchurDelegate> delegate`

_delegate_ - The receiver for the delegate methods declared in <a href='http://code.google.com/p/exportkit-cocoa/wiki/EXPikchur#EXPikchurDelegate'>EXPikchurDelegate</a>.

`@property(nonatomic,retain) NSString *userName`

_userName_ - The username that corresponds to the user's account with a service.

`@property(nonatomic,readonly) NSString *service`

_service_ - Service to authenticate the user with. Can be any of the following: Twitter, Posterous, FourSquare, Jaiku, Tumblr, FriendFeed, identi.ca, Plurk, Koornk, BrightKite, and Pikchur.

# Methods #


---


**`- (id)initWithUsername:(NSString *)user andPassword:(NSString *)pass forService:(EXPikchurServices)serv`**

**_Return Value_**

_nil_

**_Parameters_**

  * user_- The username that corresponds to the user's account with a service._

  * pass_- Password in which to authenticate the username with._

  * serv_- Service in which the user wishes to authenticate with._

**_Notes_**

This is the recommended initializer for EKPikchur, it will automatically authenticate with Pikchur.


---


**`- (void)authenticateWithPassword:(NSString *)pass`**

**_Return Value_**

_nil_

**_Parameters_**

  * pass_- Password in which to authenticate the username with._

**_Notes_**

This method automatically attempts to authenticate with Pikchur.


---


**`- (void)uploadPikchurData:(EXPikchurData *)data`**

**_Return Value_**

_nil_

**_Parameters_**

  * data_-_<a href='http://code.google.com/p/exportkit-cocoa/wiki/EXPikchurData'>EXPikchurData</a> object containing non-nil values for all required parameters.


---


**`+ (UIImage *)thumbnailForMediaID:(NSString *)mediaid isVideo:(BOOL)vid`**

**_Return Value_**

This returns a thumbnail image of the desired media, _nil_ if invalid mediaid or other failure.

**_Parameters_**

  * mediaid_- The media ID that is returned from an upload or parsed from a media URL._

  * vid_- Boolean value that tells whether or not the media ID is for a video, NO if it is for an image._

**_Notes_**

This method uses a synchronous request so it is recommended that you run this on a background thread.

<br></br>
# EXPikchurDelegate #


---


**_Required_**

**`- (void)pikchurDidAuthenticate:(EXPikchur *)source`**

  * source_- Object that is calling the delegate method._

**`- (void)pikchurFailedToAuthenticate:(EXPikchur *)source withErrorMessage:(NSError *)error`**

  * source_- Object that is calling the delegate method._

  * error_- Error associated with why Pikchur did not authenticate._

**`- (void)pikchur:(EXPikchur *)source didUploadData:(EXPikchurData *)data to:(NSURL *)url`**

  * source_- Object that is calling the delegate method._

  * data_- EXPikchurData object used to upload the file._

  * url_- The URL associated with the now uploaded image._

**_Notes_** - This can be modified from inside the source code to return various responses or the entire NSDictionary of responses from the connection.

**`- (void)pikchur:(EXPikchur *)source failedToUploadData:(EXPikchurData *)data withError:(NSError *)error`**

  * source_- Object that is calling the delegate method._

  * data_- EXPikchurData object used to upload the file._

  * error_- Error associated with why Pikchur did not successfully upload the data._

**`- (void)pikchurCompletedAllUploads:(EXPikchur *)source`**

  * source_- Object that is calling the delegate method._


---


**_Optional_**

**`- (void)pikchur:(EXPikchur *)source forData:(EXPikchurData *)data receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total`**

  * source_- Object that is calling the delegate method._

  * data_- EXPikchurData object used to upload the file._

  * bytes_- Bytes uploaded out of the total predicted size._

  * total_- Total number of bytes predicted for the upload._

<br />
# Constants Etc #


---


typedef enum {
> EXPikchurServicesTwitter = 1,
> EXPikchurServicesPosterous,
> EXPikchurServicesFourSquare,
> EXPikchurServicesJaiku,
> EXPikchurServicesTumblr,
> EXPikchurServicesFriendFeed,
> EXPikchurServicesIdentica,
> EXPikchurServicesPlurk,
> EXPikchurServicesKoornk,
> EXPikchurServicesBrightKite,
> EXPikchurServicesPikchur,
} **EXPikchurServices**;

This is the list of supported services and is used in the custom initializer for this class.

_#define kPikchurAPIKey_

This is where you will define your API key received from their server <a href='http://pikchur.com/api'>here</a>.