# Introduction #

I created this class as a simpler manager for uploading a form.  My thoughts behind this was that it would allow you to upload multiple videos through one authenticated EXPikchur object simultaneously.  This class also allows the user to create multiple media objects as the data is presented to the program.

<br />
# Properties #


---


`@property(nonatomic,retain) NSData *media`

_media_ - Data representation of the image/video you wish to upload. (_Required_)

`@property EXMediaType mediaType`

_mediaType_ - The type of data inside of media, declared in `"UploadManager.h"`. (_Required_)

`@property(nonatomic,retain) NSString *statusMessage`

_statusMessage_ - Message to be uploaded alongside the post.

`@property(nonatomic,retain) NSString *generalLocation`

_generalLocation_ - Approximate location of where the post is coming from (ex: Cupertino, CA)

`@property(readwrite) BOOL privateUpload`

_privateUpload_ - YES to hide from the public where applicable, NO for public (default)

`@property(readwrite) BOOL shouldPost`

_shouldPost_ - YES will post this in the corresponding service's feed (default), NO will just upload the file.

`@property(nonatomic,retain) CLLocation *geoLocation`

_geoLocation_ - This will post exact geographic coordinates to Pikchur.

<br />
# Methods #


---


**`- (id)initWithMedia:(NSData *)data ofType:(EXMediaType)type andMessage:(NSString *)message`**

**_Return Value_**

This returns an EXPikchurData object with the corresponding parameters.

**_Parameters_**

  * data_- The media that you want upload (video or image)_

  * type_- EXMediaType that defines the type of media you are uploading._

  * message