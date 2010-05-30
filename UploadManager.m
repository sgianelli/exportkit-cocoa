//
//  UploadManager.m
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/23/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import "UploadManager.h"

#define kCacheDirectory(x) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:x]


@implementation UploadManager

@synthesize delegate;

- (id)initWithParserKeys:(NSArray *)keys andDelegate:(id)del {
	if (self = [super init]) {
		self.delegate = del;
		parseKeys = [keys copy];
	}
	
	return self;
}

- (void)beginConnectionWithRequest:(NSURLRequest *)req {
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	[connection start];
	NSLog(@"beginning connection");
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)data {
	//[data writeToFile:kCacheDirectory(@"response.txt") atomically:YES];
	NSLog(@"RESPONSE: %@",[NSString stringWithCString:[data bytes] length:[data length]]);
	
	if (delegate)
		[self parseXMLFileWithData:[delegate upload:self receivedData:data]];
	else
		[self parseXMLFileWithData:data];
}
- (void)connection:(NSURLConnection *)_connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	[delegate upload:self receivedBytes:totalBytesWritten ofTotal:totalBytesExpectedToWrite];
}
- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
	[delegate uploadFailed:self withError:error];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[delegate uploadCompleted:self];
}

+ (void)parseXMLFileWithData:(NSData *)xml withKeys:(NSArray *)keys andDelegate:(id)del {
	UploadManager *man = [[[UploadManager alloc] initWithParserKeys:keys andDelegate:del] autorelease];
	man.delegate = del;
	[man parseXMLFileWithData:xml];
}
- (void)parseXMLFileWithData:(NSData *)xml {
	[connection release];
	
	parsedContent = [[NSMutableDictionary alloc] init];
	
	NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
	
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[xmlParser setDelegate:self];
	
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	
	[xmlParser parse];
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"found file and started parsing");
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {	
	NSString * errorString = [NSString stringWithFormat:@"Error: %@", [parseError localizedDescription]];
	NSLog(@"error parsing XML: %@", errorString);
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
	
/*	if([currentElement isEqualToString:@"statusid"])
		[parsedContent setObject:string forKey:@"statusid"];
	else if([currentElement isEqualToString:@"userid"])
		[parsedContent setObject:string forKey:@"userid"];
	else if([currentElement isEqualToString:@"mediaid"])
		[parsedContent setObject:string forKey:@"mediaid"];
	else if ([currentElement isEqualToString:@"mediaurl"])
		[parsedContent setObject:string forKey:@"mediaurl"];
	else if([currentElement isEqualToString:@"status_id"])
		[parsedContent setObject:string forKey:@"status_id"];
	else if([currentElement isEqualToString:@"user_id"])
		[parsedContent setObject:string forKey:@"user_id"];
	else if([currentElement isEqualToString:@"token"])
		[parsedContent setObject:string forKey:@"token"];
	else if ([currentElement isEqualToString:@"playlist"])
		[parsedContent setObject:string forKey:@"playlist"];
	else if ([currentElement isEqualToString:@"media_id"])
		[parsedContent setObject:string forKey:@"media_id"];
	else if ([currentElement isEqualToString:@"media_url"])
		[parsedContent setObject:string forKey:@"media_url"];
	else if ([currentElement isEqualToString:@"user_tags"])
		[parsedContent setObject:string forKey:@"user_tags"];
	else if ([currentElement isEqualToString:@"vidResponse_parent"])
		[parsedContent setObject:string forKey:@"vidResponse_parent"];
	else if ([currentElement isEqualToString:@"geo_latitude"])
		[parsedContent setObject:string forKey:@"geo_latitude"];
	else if ([currentElement isEqualToString:@"geo_longitude"])
		[parsedContent setObject:string forKey:@"geo_longitude"];
	else if ([currentElement isEqualToString:@"message"])
		[parsedContent setObject:string forKey:@"message"];
	else if ([currentElement isEqualToString:@"last_byte"])
		[parsedContent setObject:string forKey:@"last_byte"];*/
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	if (currentElement)
		[currentElement release];
	
	[delegate upload:self receivedResponse:parsedContent];
}

	
@end
