//
//  ImageSearchResultCell.m
//  TestSSA
//
//  Created by Sergey Blednov on 4/11/14.
//  Copyright (c) 2014 ch.itomy. All rights reserved.
//

#import "ImageSearchResultCell.h"
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation ImageSearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.imageNameText.editable = NO;
    self.imageNameText.selectable = NO;
    [self.image setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureSearchResult:(SearchResult *)searchResult
{
    self.imageNameText.text = searchResult.linkName;
    NSURL *url = [NSURL URLWithString:searchResult.imageURL];
    [self.image setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageView cancelImageRequestOperation];
    self.imageNameText.text = nil;
}

@end
