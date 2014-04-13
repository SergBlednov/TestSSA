//
//  ImageSearchResultCell.h
//  TestSSA
//
//  Created by Sergey Blednov on 4/11/14.
//  Copyright (c) 2014 ch.itomy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

@interface ImageSearchResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *imageNameText;

- (void)configureSearchResult:(SearchResult *)searchResult;

@end
