//
//  EXPikchur.h
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/28/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadManager.h"

#define kPikchurAPIKey @"h+RkiTzgHL0Qfgynag5ZoQ"


/* IMPORTANT
 * 
 * Pikchur uses "services" to authenticate the user, making it more flexible
 * the issue with this though, is you need to know the service that they are
 * trying to authenticate with, the available services are:
 *
 * Twitter
 * Posterous
 * FourSquare
 * Jaiku
 * Tumblr
 * FriendFeed
 * identi.ca
 * Plurk
 * Koornk
 * BrightKite
 * Pikchur
 */

typedef enum {
	EXPikchurServicesTwitter = 1,
	EXPikchurServicesPosterous,
	EXPikchurServicesFourSquare,
	EXPikchurServicesJaiku,
	EXPikchurServicesTumblr,
	EXPikchurServicesFriendFeed,
	EXPikchurServicesIdentica,
	EXPikchurServicesPlurk,
	EXPikchurServicesKoornk,
	EXPikchurServicesBrightKite,
	EXPikchurServicesPikchur,
} EXPikchurServices;

@class EXPikchurData;
@class EXPikchur;


@protocol EXPikchurDelegate

@required
- (void)pikchurDidAuthenticate:(EXPikchur *)source;
- (void)pikchurFailedToAuthenticate:(EXPikchur *)source withErrorMessage:(NSError *)error;

- (void)pikchur:(EXPikchur *)source didUploadData:(EXPikchurData *)data to:(NSURL *)url;
- (void)pikchur:(EXPikchur *)source failedToUploadData:(EXPikchurData *)data withError:(NSError *)error;

- (void)pikchurCompletedAllUploads:(EXPikchur *)source;

@optional
- (void)pikchur:(EXPikchur *)source forData:(EXPikchurData *)data receivedBytes:(NSInteger)bytes ofTotal:(NSInteger)total;

@end


@interface EXPikchur : NSObject<UploadManagerDelegate> {
	id<EXPikchurDelegate> delegate;
	
	NSString *userName;
	NSString *authToken;
	
	NSString *service;
	
	NSMutableArray *currentUploads;
	
@private
	NSMutableDictionary *parsedContent;
	NSMutableString *currentElement;
	NSArray *parseKeys;
}

@property(nonatomic,assign) id<EXPikchurDelegate> delegate;
@property(nonatomic,retain) NSString *userName;

@property(nonatomic,readonly) NSString *service;

- (id)initWithUsername:(NSString *)user andPassword:(NSString *)pass forService:(EXPikchurServices)serv;
- (void)authenticateWithPassword:(NSString *)pw;

- (void)uploadPikchurData:(EXPikchurData *)data;

+ (UIImage *)thumbnailForMediaID:(NSString *)mediaid isVideo:(BOOL)vid; //NO for image, YES for video

@end


@interface EXPikchurData : NSObject {
	NSData *media; //required
	EXMediaType mediaType; //required
	
	NSString *statusMessage; //required
	NSString *generalLocation;
	
	BOOL privateUpload;
	BOOL shouldPost;
	
	CLLocation *geoLocation;
}

@property(nonatomic,retain) NSData *media;
@property EXMediaType mediaType;

@property(nonatomic,retain) NSString *statusMessage;
@property(nonatomic,retain) NSString *generalLocation;

@property(readwrite) BOOL privateUpload;
@property(readwrite) BOOL shouldPost;

@property(nonatomic,retain) CLLocation *geoLocation;

- (id)initWithMedia:(NSData *)data ofType:(EXMediaType)type andMessage:(NSString *)message;

@end
