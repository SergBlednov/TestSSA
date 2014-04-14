//
//  ImagesResultsViewController.m
//  TestSSA
//
//  Created by Sergey Blednov on 4/11/14.
//  Copyright (c) 2014 ch.itomy. All rights reserved.
//

#import "ImagesResultsViewController.h"
#import "ImageSearchResultCell.h"
#import "SearchResult.h"

static NSString * const ImageCellIdentifier = @"ImageSearchResultCell";

@interface ImagesResultsViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ImagesResultsViewController
{
    NSArray *_searchResults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (IBAction)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.rowHeight = 120;
    
    UINib *cellNib = [UINib nibWithNibName:ImageCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:ImageCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveParseNotification:) name:@"ParsingFinished" object:nil];
}

- (void)receiveParseNotification:(NSNotification *)notification
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"linkName" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSError *error;
    NSArray *foundsObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (foundsObjects == nil) {
        NSLog(@"Fatal core Data error %@", error);
        return;
    }
    _searchResults = foundsObjects;
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UINavigationBaDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"row quantity is %d", [_searchResults count]);
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ImageSearchResultCell *cell = (ImageSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier];

    SearchResult *searchResult = _searchResults[indexPath.row];
    [cell configureSearchResult:searchResult];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
