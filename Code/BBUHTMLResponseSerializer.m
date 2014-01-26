//
//  BBUHTMLResponseSerializer.m
//  BBUInstapaperNonAPI
//
//  Created by Boris Bügling on 26.01.14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "BBUHTMLResponseSerializer.h"

@implementation BBUHTMLResponseSerializer

-(NSSet *)acceptableContentTypes {
    return [NSSet setWithObject:@"text/html"];
}

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
