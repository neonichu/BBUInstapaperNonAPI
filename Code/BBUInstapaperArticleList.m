//
//  BBUInstapaperArticleList.m
//  BBUInstapaperNonAPI
//
//  Created by Boris Bügling on 26.01.14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <CHCSVParser/CHCSVParser.h>

#import "BBUHTMLResponseSerializer.h"
#import "BBUInstapaperArticleList.h"

@implementation BBUInstapaperArticle

+(instancetype)articleWithURLString:(NSString*)urlString title:(NSString*)title {
    BBUInstapaperArticle* article = [self new];
    article.title = title;
    article.url = [NSURL URLWithString:urlString];
    return article;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.title, self.url];
}

@end

#pragma mark -

@interface BBUInstapaperArticleList () <CHCSVParserDelegate>

@property NSMutableArray* articles;
@property NSString* title;
@property NSString* urlString;

@end

#pragma mark -

@implementation BBUInstapaperArticleList

-(void)fetchArticlesWithCompletionHandler:(BBUInstapaperArticleListHandler)handler {
    NSAssert(handler, @"No completion handler specified!");
    
    [self GET:@"/user/export" parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSError* error = nil;
          NSRegularExpression* expr = [NSRegularExpression regularExpressionWithPattern:@"<input id=\"form_key\" .*? value=\"(.*?)\" />" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
          
          if (!expr) {
              handler(nil, error);
              return;
          }
          
          NSTextCheckingResult* result = [[expr matchesInString:responseObject options:0 range:NSMakeRange(0, [responseObject length])] firstObject];
          if (result.numberOfRanges > 1) {
              NSString* formKey = [responseObject substringWithRange:[result rangeAtIndex:1]];
              [self POST:@"/export/csv"
              parameters:@{ @"form_key": formKey }
                 success:^(NSURLSessionDataTask *task, id responseObject) {
                     if (![responseObject hasPrefix:@"URL,Title,Selection,Folder"]) {
                         handler(@[], nil);
                         return;
                     }
                     
                     NSMutableArray* articles = [@[] mutableCopy];
                     
                     for (NSString* line in [responseObject componentsSeparatedByString:@"\r\n"]) {
                         if (![line hasPrefix:@"http"]) {
                             continue;
                         }
                         
                         NSArray* fields = [line componentsSeparatedByString:@","];
                         [articles addObject:[BBUInstapaperArticle articleWithURLString:fields[0] title:fields[1]]];
                     }
                     
                     handler([articles copy], nil);
                     return;
                     
                     // TODO: Rip this out as it doesn't appear to work.
                     
                     self.articles = [@[] mutableCopy];
                     self.title = nil;
                     self.urlString = nil;
                     
                     CHCSVParser* parser = [[CHCSVParser alloc] initWithCSVString:responseObject];
                     parser.delegate = self;
                     [parser parse];
                     
                     handler([self.articles copy], nil);
                     
                     self.articles = nil;
                     self.title = nil;
                     self.urlString = nil;
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     handler(nil, error);
                 }];
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          handler(nil, error);
      }];
}

-(id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://www.instapaper.com"]];
    if (self) {
        self.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[ [BBUHTMLResponseSerializer new] ]];
    }
    return self;
}

-(void)loginWithUsername:(NSString*)username password:(NSString*)password completionHandler:(BBUInstapaperLoginHandler)handler {
    NSAssert(handler, @"No completion handler specified!");
    
    [self POST:@"/user/login"
    parameters:@{ @"username": username, @"password": password }
       success:^(NSURLSessionDataTask *task, id responseObject) {
           handler(YES, nil);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           handler(NO, error);
       }];
}

#pragma mark - CHCSVParserDelegate

-(void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (self.urlString) {
        [self.articles addObject:[BBUInstapaperArticle articleWithURLString:self.urlString title:self.title]];
    }
}

-(void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    switch (fieldIndex) {
        case 0:
            if ([field hasPrefix:@"http"]) {
                self.urlString = field;
            }
            break;
        case 1:
            self.title = field;
            break;
    }
}

@end
