//
//  BBUInstapaperArticleList.h
//  BBUInstapaperNonAPI
//
//  Created by Boris Bügling on 26.01.14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

typedef void(^BBUInstapaperLoginHandler)(BOOL success, NSError* error);
typedef void(^BBUInstapaperArticleListHandler)(NSArray* articles, NSError* error);

#import "AFHTTPSessionManager.h"

@interface BBUInstapaperArticle : NSObject

@property NSString* title;
@property NSURL* url;

@end

#pragma mark -

@interface BBUInstapaperArticleList : AFHTTPSessionManager

-(void)fetchArticlesWithCompletionHandler:(BBUInstapaperArticleListHandler)handler;
-(void)loginWithUsername:(NSString*)username password:(NSString*)password completionHandler:(BBUInstapaperLoginHandler)handler;

@end
