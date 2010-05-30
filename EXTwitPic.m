//
//  EXTwitPic.m
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/8/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import "EXTwitPic.h"

#define kCacheDirectory(x) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:x]


@interface EXTwitPic (private)

- (void)postImage:(UIImage *)img withMessage:(NSString *)message atURL:(NSURL *)url;

- (void)receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total fromConnection:(NSURLConnection *)con;
- (void)uploadFailedFromConnection:(NSURLConnection *)connection withError:(NSError *)error;
- (void)dataParsedFromConnection:(NSURLConnection *)connection withURL:(NSURL *)url;

@end

@implementation EXTwitPic

@synthesize delegate,username,password;

+ (void)postTwitPicImage:(UIImage *)img withUsername:(NSString *)un password:(NSString *)pw message:(NSString *)message andDelegate:(id)del {
	EXTwitPic *tp = [[[EXTwitPic alloc] initWithUsername:un andPassword:pw] autorelease];
	tp.delegate = del;
	[tp tweetImage:img withMessage:message];
}
+ (void)uploadTwitPicImage:(UIImage *)img withUsername:(NSString *)un password:(NSString *)pw message:(NSString *)message andDelegate:(id)del {
	EXTwitPic *tp = [[[EXTwitPic alloc] initWithUsername:un andPassword:pw] autorelease];
	tp.delegate = del;
	[tp uploadTwitPicImage:img withMessage:message];
}

- (id)initWithUsername:(NSString *)un andPassword:(NSString *)pw {
	if (self = [super init]) {
		username = [un copy];
		password = [pw copy];
		delegate = nil;
		currentConnections = [[NSMutableArray alloc] init];
		
		twitPicKeys = [[NSArray alloc] initWithObjects:@"statusid",
					   @"userid",
					   @"mediaid",
					   @"mediaurl",nil];
	}
	
	return self;
}

- (void)postTwitPicImage:(UIImage *)img withMessage:(NSString *)mes {
	[NSThread detachNewThreadSelector:@selector(_tweet:) toTarget:self withObject:[NSArray arrayWithObjects:img,mes,nil]];
}
- (void)_tweet:(NSArray *)arr {
	[self postImage:[arr objectAtIndex:0] withMessage:[arr count] > 1 ? (NSString *)[arr objectAtIndex:1] : nil atURL:[NSURL URLWithString:@"http://twitpic.com/api/uploadAndPost"]];
}

- (void)uploadTwitPicImage:(UIImage *)img withMessage:(NSString *)mes {
	NSLog(@"img: %@ mes: %@",img,mes);
	[NSThread detachNewThreadSelector:@selector(_upload:) toTarget:self withObject:[NSArray arrayWithObjects:img,mes,nil]];
//	[self performSelector:@selector(_upload:) withObject:[NSArray arrayWithObjects:img,mes,nil]];
//	[self postImage:img withUsername:username password:password andUrl:[NSURL URLWithString:@"http://twitpic.com/api/upload"]];
}
- (void)_upload:(NSArray *)arr {
	[self postImage:[arr objectAtIndex:0] withMessage:[arr count] > 1 ? (NSString *)[arr objectAtIndex:1] : nil atURL:[NSURL URLWithString:@"http://twitpic.com/api/upload"]];
}

- (void)postImage:(UIImage *)img withMessage:(NSString *)message atURL:(NSURL *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// create the connection
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	// change type to POST (default is GET)
	[postRequest setHTTPMethod:@"POST"];
	
	// just some random text that will never occur in the body
	NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
	
	// header value
	NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
								stringBoundary];
	
	// set header
	[postRequest addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postBody = [NSMutableData data];

	// username part
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// password part
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// message part
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// media part
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"media\"; filename=\"dummy.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *imageData = UIImagePNGRepresentation(img);
	
	if ([imageData length] > 4194304) { //4 MB limit on twitpic, as far as I know atleast
		if ([(NSObject *)delegate respondsToSelector:@selector(picture:failedToPost:)]) {
			[delegate picture:img failedToPost:[NSError errorWithDomain:@"File exceeds 4 MB" code:0 userInfo:nil]];
		}
	}
	
	// add it to body
	[postBody appendData:imageData];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

	// final boundary
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// add body to post
	[postRequest setHTTPBody:postBody];
	
	//NSLog(@"postbody: %@",[NSString stringWithCString:[postBody bytes] length:[postBody length]]);
	
	// synchronous filling of data from HTTP POST response
	//NSData *responseData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];

	UploadManager *man = [[UploadManager alloc] initWithParserKeys:twitPicKeys andDelegate:self];
	
	[currentConnections addObjectsFromArray:[NSArray arrayWithObjects:img,man,nil]];
	[man performSelectorOnMainThread:@selector(beginConnectionWithRequest:) withObject:postRequest waitUntilDone:NO];
//	[self performSelectorOnMainThread:@selector(startConnectionController:) withObject:[NSArray arrayWithObjects:man,postRequest,nil] waitUntilDone:NO];
	
//	NSLog(@"connection did start: %@ \n request: %@",connection,[postRequest HTTPBody]);
	
/*	if (error != nil) {
		NSLog(@"ERROR %@",[error localizedDescription]);
		if (delegate)
			[delegate picture:img failedToPost:error];
		
		[pool drain];		
		return;
	}
	
	// convert data into string
	NSString *responseString = [[[NSString alloc] initWithBytes:[responseData bytes]
														 length:[responseData length]
													   encoding:NSUTF8StringEncoding] autorelease];
	
	// see if we get a welcome result
	NSLog(@"RESPONSE %@",responseString);
	
	NSString *mediaURL = nil;
	if (responseString.length > 0) {
		NSArray *result = [responseString componentsSeparatedByString:@"<mediaurl>"];
		NSArray *result2 = [(NSString *)[result objectAtIndex:1] componentsSeparatedByString:@"</mediaurl>"];
		mediaURL = [result2 objectAtIndex:0];
		
		NSLog(@"mediaURL is %@", mediaURL);
	}
	
	if (delegate)
		[delegate picture:img wasSuccessfullyPostedAt:[NSURL URLWithString:mediaURL]];*/

	[pool drain];
}

- (void)uploadCompleted:(UploadManager *)manager {
}
- (void)uploadFailed:(UploadManager *)manager withError:(NSError *)err {
	if (delegate)
		[delegate picture:[currentConnections objectAtIndex:[currentConnections indexOfObject:manager] - 1] failedToPost:err];
}
- (void)upload:(UploadManager *)manager receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total {
	if ([(NSObject *)delegate respondsToSelector:@selector(picture:uploadedBytes:outOf:)])
		[delegate picture:[currentConnections objectAtIndex:[currentConnections indexOfObject:manager] - 1] uploadedBytes:bytes outOf:total];
}
- (void)upload:(UploadManager *)manager receivedResponse:(NSDictionary *)response {
	if (delegate)
		[delegate picture:[currentConnections objectAtIndex:[currentConnections indexOfObject:manager] - 1] wasSuccessfullyPostedAt:[response objectForKey:@"mediaurl"]];	
}
- (NSData *)upload:(UploadManager *)manager receivedData:(NSData *)data {
	return data;
}


@end
