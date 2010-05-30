//
//  EXImgur.h
//  ExportKit-Demo
//
//  Created by Shane Gianelli on 5/26/10.
//  Copyright 2010 SJ Development LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadManager.h"

#define kImgurAPIKey @"0f5d64640066bfcb507244108c0e8de9"


@protocol EXImgurDelegate

- (void)imgurPostImage:(UIImage *)image withURL:(NSURL *)url;
- (void)imgurFailedToPostImage:(UIImage *)image withError:(NSError *)error;

@optional
- (void)imgurImage:(UIImage *)image sentBytes:(NSInteger)bytes ofTotal:(NSInteger)total;
- (void)imgurImageDeletedSuccesfullyWithHash:(NSString *)hash;
- (void)imgurImageFailedToDeleteWithHash:(NSString *)hash;

@end

@interface EXImgur : NSObject {
@private
	id<EXImgurDelegate> delegate;
	UIImage *uploadingImage;
}

+ (void)uploadImageToImgur:(UIImage *)image withDelegate:(id)del;
+ (void)deleteImgurImageWithHash:(NSString *)hash withDelegate:(id)del;

@end
