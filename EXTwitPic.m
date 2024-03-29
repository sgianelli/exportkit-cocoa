//
//  EXTwitPic.m
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/8/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import "EXTwitPic.h"


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
	[tp postTwitPicImage:img withMessage:message];
}
+ (void)uploadTwitPicImage:(UIImage *)img withUsername:(NSString *)un password:(NSString *)pw message:(NSString *)message andDelegate:(id)del {
	EXTwitPic *tp = [[[EXTwitPic alloc] initWithUsername:un andPassword:pw] autorelease];
	tp.delegate = del;
	[tp uploadTwitPicImage:img withMessage:message];
}

- (id)initWithUsername:(NSString *)un andPassword:(NSString *)pw {
	if (self = [self init]) {
		username = [un copy];
		password = [pw copy];
	}
	
	return self;
}
- (id)init {
	if (self = [super init]) {
		delegate = nil;
		currentConnections = [[NSMutableArray alloc] init];
		
		twitPicKeys = [[NSArray alloc] initWithObjects:@"statusid",
					   @"userid",
					   @"mediaid",
					   @"mediaurl",
					   @"rsp",nil];
	}
	
	return self;
}

- (void)postTwitPicImage:(UIImage *)img withMessage:(NSString *)mes {
	[NSThread detachNewThreadSelector:@selector(_tweet:) toTarget:self withObject:[NSArray arrayWithObjects:img,mes,nil]];
}
- (void)_tweet:(NSArray *)arr {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self postImage:[arr objectAtIndex:0] withMessage:[arr count] > 1 ? (NSString *)[arr objectAtIndex:1] : nil atURL:[NSURL URLWithString:@"http://twitpic.com/api/uploadAndPost"]];
	[pool drain];
}

- (void)uploadTwitPicImage:(UIImage *)img withMessage:(NSString *)mes {
	[NSThread detachNewThreadSelector:@selector(_upload:) toTarget:self withObject:[NSArray arrayWithObjects:img,mes,nil]];
}
- (void)_upload:(NSArray *)arr {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self postImage:[arr objectAtIndex:0] withMessage:[arr count] > 1 ? (NSString *)[arr objectAtIndex:1] : nil
			  atURL:[NSURL URLWithString:@"http://twitpic.com/api/upload"]];
	[pool drain];
}

- (void)postImage:(UIImage *)img withMessage:(NSString *)message atURL:(NSURL *)url {
	NSData *imageData = UIImagePNGRepresentation(img);
	
	if ([imageData length] > 4 * 1024 * 1024) { //4 MB limit on twitpic, as far as I know atleast
		if ([(NSObject *)delegate respondsToSelector:@selector(twitPicImage:failedToPost:)]) {
			[delegate twitPicImage:img failedToPost:[NSError errorWithDomain:@"File exceeds 4 MB" code:0 userInfo:nil]];
		}
	}
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	[postRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = @"exportkittwitpicboundarycourtesyof4amsleepschedules";	
	NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];	
	[postRequest addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postBody = [NSMutableData data];

	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"media\"; filename=\"dummy.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		
	[postBody appendData:imageData];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:postBody];

	UploadManager *man = [[UploadManager alloc] initWithParserKeys:twitPicKeys andDelegate:self];	
	[currentConnections addObjectsFromArray:[NSArray arrayWithObjects:img,man,nil]];

	[man performSelectorOnMainThread:@selector(beginConnectionWithRequest:) withObject:postRequest waitUntilDone:NO];
}

+ (UIImage *)thumbnailForMediaID:(NSString *)mediaid {
	UIImage *returnImage = nil;
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitpic.com/show/thumb/%@",mediaid]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSData *connectionResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (error)
		return nil;
	
	if (connectionResponse)
		returnImage = [UIImage imageWithData:connectionResponse];
	
	return returnImage;
}

- (void)uploadFailed:(UploadManager *)manager withError:(NSError *)err {
	if (delegate)
		[delegate twitPicImage:[currentConnections objectAtIndex:[currentConnections indexOfObject:manager] - 1] failedToPost:err];
	
	[currentConnections removeObjectAtIndex:[currentConnections indexOfObject:manager] - 1];
	[currentConnections removeObjectAtIndex:[currentConnections indexOfObject:manager]];
	
	if (delegate && [currentConnections count] == 0)
		[delegate twitPicCompletedAllUploads];
	
	[manager release];
}
- (void)upload:(UploadManager *)manager receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total {
	if ([(NSObject *)delegate respondsToSelector:@selector(twitPicImage:uploadedBytes:outOf:)])
		[delegate twitPicImage:[currentConnections objectAtIndex:[currentConnections indexOfObject:manager] - 1] uploadedBytes:bytes outOf:total];
}
- (void)upload:(UploadManager *)manager receivedResponse:(NSDictionary *)response {
	if (delegate)
		[delegate twitPicImage:[currentConnections objectAtIndex:[currentConnections indexOfObject:manager] - 1] wasSuccessfullyPostedAt:[response objectForKey:@"mediaurl"]];	

	[currentConnections removeObjectAtIndex:[currentConnections indexOfObject:manager] - 1];
	[currentConnections removeObjectAtIndex:[currentConnections indexOfObject:manager]];
	
	[manager release];
	
	if (delegate && [currentConnections count] == 0)
		[delegate twitPicCompletedAllUploads];
}
- (NSData *)upload:(UploadManager *)manager receivedData:(NSData *)data {
	return data;
}

- (void)dealloc {
	[super dealloc];
	
	[username release];
	[password release];
	[currentConnections release];
	[twitPicKeys release];
}

@end
