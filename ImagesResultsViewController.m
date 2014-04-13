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

@interface ImagesResultsViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ImagesResultsViewController
{
    NSFetchedResultsController *_fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"linkName" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        [fetchRequest setFetchBatchSize:10];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
        
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
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
    [self performFetch];
}

- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fatal core Data error %@", error);
        return;
    }
}

- (void)dealloc
{
    _fetchedResultsController.delegate = nil;
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ImageSearchResultCell *cell = (ImageSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier];

    SearchResult *searchResult = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureSearchResult:searchResult];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//    NSLog(@"*** controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
//            NSLog(@"*** NSFetchedResultsChangeInsert (object)");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            NSLog(@"*** NSFetchedResultsChangeDelete (object)");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
            [self.tableView cellForRowAtIndexPath:indexPath] ;
            break;
            
        case NSFetchedResultsChangeMove:
//            NSLog(@"*** NSFetchedResultsChangeMove (object)");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}

@end
