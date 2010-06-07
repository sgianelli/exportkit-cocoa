//
//  EXPikchur.m
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/28/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import "EXPikchur.h"

#define kCacheDirectory(x) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:x]



@interface EXPikchur (private)

- (void)addString:(NSString *)str forAPI:(NSString *)api toData:(NSMutableData *)data;
- (void)parseXMLFileWithData:(NSData *)xml;

@end


@implementation EXPikchur

@synthesize delegate,userName,service;

- (id)initWithUsername:(NSString *)user andPassword:(NSString *)pass forService:(EXPikchurServices)serv {
	if (user == nil || pass == nil || serv == 0)
		return nil;
	
	if (self = [super init]) {
		switch (serv) {
			case EXPikchurServicesTwitter:		service = [[NSString alloc] initWithString:@"twitter"];		break;
			case EXPikchurServicesPosterous:	service = [[NSString alloc] initWithString:@"posterous"];	break;
			case EXPikchurServicesFourSquare:	service = [[NSString alloc] initWithString:@"fourSquare"];	break;
			case EXPikchurServicesJaiku:		service = [[NSString alloc] initWithString:@"jaiku"];		break;
			case EXPikchurServicesTumblr:		service = [[NSString alloc] initWithString:@"tumblr"];		break;
			case EXPikchurServicesFriendFeed:	service = [[NSString alloc] initWithString:@"friendfeed"];	break;
			case EXPikchurServicesIdentica:		service = [[NSString alloc] initWithString:@"identi.ca"];	break;
			case EXPikchurServicesPlurk:		service = [[NSString alloc] initWithString:@"plurk"];		break;
			case EXPikchurServicesKoornk:		service = [[NSString alloc] initWithString:@"koornk"];		break;
			case EXPikchurServicesBrightKite:	service = [[NSString alloc] initWithString:@"brightkite"];	break;
			case EXPikchurServicesPikchur:		service = [[NSString alloc] initWithString:@"pikchur"];		break;
			default:	break;
		}
		
		NSLog(@"service: %d string: %@",serv,service);
		
		authToken = nil;	
		
		userName = [user copy];
		
		currentUploads = [[NSMutableArray alloc] init];
		
		[self performSelectorInBackground:@selector(authenticateWithPassword:) withObject:pass];
	}
	
	return self;
}
- (void)authenticateWithPassword:(NSString *)pw {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSURL *url = [NSURL URLWithString:@"https://api.pikchur.com/auth/xml"];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	[postRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = @"sjdevsmostwonderfulofboundrylinesforexportkitTHANKYOUFORUSING";	
	NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	
	[postRequest addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postBody = [NSMutableData data];
	
	[self addString:userName forAPI:@"data[api][username]" toData:postBody];
	[self addString:pw forAPI:@"data[api][password]" toData:postBody];
	[self addString:kPikchurAPIKey forAPI:@"data[api][key]" toData:postBody];
	[self addString:service forAPI:@"data[api][service]" toData:postBody];
	
	[postRequest setHTTPBody:postBody];
	
	NSData *connectionResponse = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:nil error:nil];
	
	if (connectionResponse != nil) {
		parseKeys = [[NSArray alloc] initWithObjects:@"auth_key",@"user_id",@"message",@"error",nil];
		[self parseXMLFileWithData:connectionResponse];
	}
	
	[pool drain];
}

- (void)uploadPikchurData:(EXPikchurData *)data {
	[self performSelectorInBackground:@selector(uploadData:) withObject:data];
}
- (void)uploadData:(EXPikchurData *)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (authToken == nil || data.media == nil || data.statusMessage == nil) {
		if (delegate)
			[delegate pikchur:self failedToUploadData:data withError:[NSError errorWithDomain:@"auth, media, or status message nil" code:0 userInfo:nil]];
		
		[pool drain];
		return;
	}	
	
	NSString *mediaType;
	switch (data.mediaType) {
		case EXMediaTypePNG:
			mediaType = @"image/png";
			break;
		case EXMediaTypeJPEG:
			mediaType = @"image/jpeg";
			break;
		case EXMediaTypeGIF:
			mediaType = @"image/gif";
			break;
		case EXMediaTypeMP4:
			mediaType = @"video/mp4";
			break;
		default:
			break;
	}
		
	NSURL *url = [NSURL URLWithString:@"http://api.pikchur.com/post/xml"];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	[postRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = @"sjdevsmostwonderfulofboundrylinesforexportkitTHANKYOUFORUSING";	
	NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	
	[postRequest addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
		
	NSMutableData *postBody = [NSMutableData data];
		
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"dataAPIimage\"; filename=\"vid.mp4\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n",mediaType] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:data.media];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//required parameters
	[self addString:authToken forAPI:@"data[api][auth_key]" toData:postBody];
	[self addString:data.statusMessage forAPI:@"data[api][status]" toData:postBody];
	[self addString:kPikchurAPIKey forAPI:@"data[api][key]" toData:postBody];
	
	//optional parameters
	if (data.geoLocation) {
		[self addString:[NSString stringWithFormat:@"%f",data.geoLocation.coordinate.latitude] forAPI:@"data[api][geo][lat]" toData:postBody];
		[self addString:[NSString stringWithFormat:@"%f",data.geoLocation.coordinate.longitude] forAPI:@"data[api][geo][lon]" toData:postBody];
	}	
	if (data.generalLocation)	[self addString:data.generalLocation forAPI:@"data[api][geo][location]" toData:postBody];	
	
	if (data.privateUpload)		[self addString:@"YES" forAPI:@"data[api][private]" toData:postBody];	
	else						[self addString:@"NO" forAPI:@"data[api][private]" toData:postBody];	
	
	if (data.shouldPost)		[self addString:@"YES" forAPI:@"data[api][upload_only]" toData:postBody];
	else						[self addString:@"NO" forAPI:@"data[api][upload_only]" toData:postBody];
	
	
	[postRequest setHTTPBody:postBody];
	
	NSArray *keys = [[NSArray alloc] initWithObjects:@"id",
					 @"note",
					 @"url",
					 @"status",
					 @"type",nil];
	
	UploadManager *man = [[UploadManager alloc] initWithParserKeys:keys andDelegate:self];
	[currentUploads addObjectsFromArray:[NSArray arrayWithObjects:man,data,nil]];
	
	[man performSelectorOnMainThread:@selector(beginConnectionWithRequest:) withObject:postRequest waitUntilDone:NO];
	
	[keys release];
	
	[pool drain];
}

- (void)addString:(NSString *)str forAPI:(NSString *)api toData:(NSMutableData *)data {
	NSString *stringBoundary = @"sjdevsmostwonderfulofboundrylinesforexportkitTHANKYOUFORUSING";
	
	[data appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",api] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)uploadCompleted:(UploadManager *)manager {
}
- (void)uploadFailed:(UploadManager *)manager withError:(NSError *)err {
	if (delegate)
		[delegate pikchurFailedToAuthenticate:self withErrorMessage:err];
	
	[currentUploads removeObjectAtIndex:[currentUploads indexOfObject:manager] + 1];
	[currentUploads removeObjectAtIndex:[currentUploads indexOfObject:manager]];
	
	if (delegate && [currentUploads count] == 0)
		[delegate pikchurCompletedAllUploads:self];
}
- (void)upload:(UploadManager *)manager receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total {
	if ([(NSObject *)delegate respondsToSelector:@selector(pikchur:forData:receivedBytes:ofTotal:)])
		[delegate pikchur:self forData:[currentUploads objectAtIndex:[currentUploads indexOfObject:manager] + 1] receivedBytes:bytes ofTotal:total];
}
- (void)upload:(UploadManager *)manager receivedResponse:(NSDictionary *)response {	
	if (delegate && [currentUploads count] == 0)
		[delegate pikchurCompletedAllUploads:self];
	
	[currentUploads removeObjectAtIndex:[currentUploads indexOfObject:manager] + 1];
	[currentUploads removeObjectAtIndex:[currentUploads indexOfObject:manager]];
}
- (NSData *)upload:(UploadManager *)manager receivedData:(NSData *)data {
	NSString *response = [NSString stringWithCString:[data bytes] length:[data length]];
	response = [response substringFromIndex:[response rangeOfString:@"<?xml"].location];
	
	return [response dataUsingEncoding:NSUTF8StringEncoding];
}

+ (UIImage *)thumbnailForMediaID:(NSString *)mediaid isVideo:(BOOL)vid {
	UIImage *returnImage = nil;
	
	NSURL *url;
	
	if (vid)
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vid.pikchur.com/vid_%@_t.jpg",mediaid]]; //changing the t at the end to s,m, or l will produce other sizes of images
	else
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.pikchur.com/pic_%@_t.jpg",mediaid]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	NSData *connectionResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (error)
		return nil;
	
	if (connectionResponse)
		returnImage = [UIImage imageWithData:connectionResponse];
	
	return returnImage;
}

- (void)parseXMLFileWithData:(NSData *)xml {
	parsedContent = [[NSMutableDictionary alloc] init];
	
	NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
	
	[xmlParser setDelegate:self];
	
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	
	[xmlParser parse];
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {	
	[parsedContent release];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{ 
	currentElement = [elementName copy];
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName { 
	currentElement = nil;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([parseKeys containsObject:currentElement])
		[parsedContent setObject:string forKey:currentElement];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {	
	if ([parsedContent objectForKey:@"auth_key"]) {
		authToken = [(NSString *)[parsedContent objectForKey:@"auth_key"] copy];
		
		if (delegate)
			[delegate pikchurDidAuthenticate:self];
	} else if (delegate)
		[delegate pikchurFailedToAuthenticate:self withErrorMessage:[NSError errorWithDomain:[parsedContent objectForKey:@"message"] code:0 userInfo:nil]];
	
	if (parsedContent)
		[parsedContent release];
	if (currentElement)
		[currentElement release];
	
	[parseKeys release];
}

- (void)dealloc {
	[super dealloc];
	
	self.delegate = nil;
	
	[userName release];
	[authToken release];
	[service release];
	[currentUploads release];
	
	[currentElement release];
	[parseKeys release];
	[parsedContent release];
}

@end


@implementation EXPikchurData

@synthesize media,mediaType,statusMessage,generalLocation,privateUpload,shouldPost,geoLocation;

- (id)initWithMedia:(NSData *)data ofType:(EXMediaType)type andMessage:(NSString *)message {
	if (self = [self init]) {
		self.media = [data copy];
		self.mediaType = type;
		self.statusMessage = [message copy];
	}
	
	return self;
}

- (id)init {
	if (self = [super init]) {		
		self.media = nil;
		self.mediaType = 0;
		self.statusMessage = nil;		
		self.generalLocation = nil;
		self.privateUpload = NO;
		self.shouldPost = YES;
		self.geoLocation = nil;
	}
	
	return self;
}

@end
