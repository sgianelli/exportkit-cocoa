//
//  EXTwitPic.h
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/8/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXConversions.h"
#import "UploadManager.h"



@protocol EXTwitPicDelegate

@required
- (void)picture:(UIImage *)img wasSuccessfullyPostedAt:(NSURL *)location;
- (void)picture:(UIImage *)img failedToPost:(NSError *)err;

@optional
- (void)picture:(UIImage *)img uploadedBytes:(NSInteger)up outOf:(NSInteger)total;

@end

@interface EXTwitPic : NSObject<UploadManagerDelegate> {
	id<EXTwitPicDelegate> delegate;
	NSString *username;
	NSString *password;
	
	@private
	NSMutableArray *currentConnections;
	NSArray *twitPicKeys;
}

@property(assign) id<EXTwitPicDelegate> delegate;
@property(nonatomic,retain,readwrite) NSString *username;
@property(nonatomic,retain,readwrite) NSString *password;

- (id)initWithUsername:(NSString *)un andPassword:(NSString *)pw;

- (void)tweetImage:(UIImage *)img withMessage:(NSString *)mes;
- (void)uploadTwitPicImage:(UIImage *)img withMessage:(NSString *)mes;

+ (void)tweetImage:(UIImage *)img withUsername:(NSString *)un password:(NSString *)pw message:(NSString *)message andDelegate:(id)del;
+ (void)uploadTwitPicImage:(UIImage *)img withUsername:(NSString *)un password:(NSString *)pw message:(NSString *)message andDelegate:(id)del;

@end
