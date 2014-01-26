//
//  BBUArticlesViewController.m
//  BBUInstapaperNonAPI
//
//  Created by Boris Bügling on 26.01.14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "BBUArticlesViewController.h"
#import "BBUInstapaperArticleList.h"

static NSString* const kInstapaperUser      = @"boris@icculus.org";
static NSString* const kInstapaperPassword  = @"Lequeic4eedee4Ir";

@interface BBUArticlesViewController ()

@property NSArray* articles;
@property BBUInstapaperArticleList* list;

@end

#pragma mark -

@implementation BBUArticlesViewController

-(id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Instapaper Articles", nil);
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

-(void)refresh {
    self.list = [BBUInstapaperArticleList new];
    [self.list loginWithUsername:kInstapaperUser
                        password:kInstapaperPassword
               completionHandler:^(BOOL success, NSError *error) {
                   if (!success) {
                       NSLog(@"Error: %@", error.localizedDescription);
                       return;
                   }
                   
                   [self.list fetchArticlesWithCompletionHandler:^(NSArray *articles, NSError *error) {
                       self.articles = articles;
                       [self.tableView reloadData];
                   }];
               }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [self.articles[indexPath.row] title];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

@end
