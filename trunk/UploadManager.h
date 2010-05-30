//
//  UploadManager.h
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/23/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UploadManager;

@protocol UploadManagerDelegate

- (void)uploadCompleted:(UploadManager *)manager;
- (void)uploadFailed:(UploadManager *)manager withError:(NSError *)err;
- (void)upload:(UploadManager *)manager receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total;
- (void)upload:(UploadManager *)manager receivedResponse:(NSDictionary *)response;

- (NSData *)upload:(UploadManager *)manager receivedData:(NSData *)data;

@end


@interface UploadManager : NSObject {
	id<UploadManagerDelegate> delegate;
	NSURLConnection *connection;
	NSMutableDictionary *parsedContent;
	NSMutableString *currentElement;
	
	NSArray *parseKeys;
}

@property(nonatomic,assign) id<UploadManagerDelegate> delegate;

- (id)initWithParserKeys:(NSArray *)keys andDelegate:(id)del;
- (void)beginConnectionWithRequest:(NSURLRequest *)req;

- (void)parseXMLFileWithData:(NSData *)xml;
+ (void)parseXMLFileWithData:(NSData *)xml withKeys:(NSArray *)keys andDelegate:(id)del;

@end
