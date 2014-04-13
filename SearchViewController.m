//
//  SearchViewController.m
//  TestSSA
//
//  Created by Sergey Blednov on 4/9/14.
//  Copyright (c) 2014 ch.itomy. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>
#import "ImagesResultsViewController.h"
#import "TextResultsViewController.h"

static NSString * const ApiKey = @"AIzaSyDifmXY52XO_X3ov1Wtx99SypgrhuetfgM";
static NSString * const CustomSearchEngineID = @"017982966416851181032:z52ghvy5kke";
static NSString * const ImageSearchParameters = @"&searchType=image&imgSize=large&fields=items(title,link,image)";
static NSString * const TextSearchParameters = @"&fields=items(title,link,image)";

@interface SearchViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation SearchViewController


- (IBAction)searchTextPushed
{
    [self deleteOldSearchResults];
    [self.searchBar resignFirstResponder];
    [self performSearch:[self.searchBar text] withParameters:TextSearchParameters];
    
    TextResultsViewController *controller = [[TextResultsViewController alloc] initWithNibName:@"TextResultsViewController" bundle:nil];
    controller.managedObjectContext = self.managedObjectContext;
    [self presentViewController:controller animated:YES completion:nil];

}

- (IBAction)searchImagePushed
{
    [self deleteOldSearchResults];
//    [self.searchBar resignFirstResponder];
    [self performSearch:[self.searchBar text] withParameters:ImageSearchParameters];

    ImagesResultsViewController *controller = [[ImagesResultsViewController alloc] initWithNibName:@"ImagesResultsViewController" bundle:nil];
    controller.managedObjectContext = self.managedObjectContext;
    [self presentViewController:controller animated:YES completion:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchTextPushed];
}

- (void)performSearch:(NSString *)searchText withParameters:(NSString *)searchParameters
{
    NSString *formattedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([formattedSearchText length] > 0) {
        
        NSLog(@"The search text is: '%@'", formattedSearchText);

        NSString *googleUri = [NSString stringWithFormat:@"https://www.googleapis.com/customsearch/v1?key=%@&cx=%@&q=%@&num=10%@", ApiKey, CustomSearchEngineID, formattedSearchText, searchParameters];
        NSLog(@"The search URL is: '%@'", googleUri);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:googleUri parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            [self parseSearchResult:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
}

- (void)parseSearchResult:(NSDictionary *)dictionary
{
    NSLog(@"*** Parse method was invoked!!");
    SearchResult *searchResult = nil;
    
    NSArray *items = dictionary[@"items"];

    if (items == nil) {
        NSLog(@"The request is empty");
        return;
    }
    
    for (NSDictionary *resultDictionary in items) {
        
        searchResult = [NSEntityDescription insertNewObjectForEntityForName:@"SearchResult" inManagedObjectContext:self.managedObjectContext];
        searchResult.linkName = resultDictionary[@"title"];
        searchResult.linkURL = resultDictionary[@"link"];
        NSDictionary *image = resultDictionary[@"image"];
        searchResult.imageURL = image[@"thumbnailLink"];
        NSLog(@"Name: %@;\n link: %@;\n Image link: %@\n", searchResult.linkName, searchResult.linkURL, searchResult.imageURL);
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Fatal error Core Data: %@", error);
            return;
        }
    }
}

- (void)deleteOldSearchResults
{
    NSLog(@"*** Deleting all objects...");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    }
    if (![_managedObjectContext save:&error]) {
    	NSLog(@"Error deleting object - error:%@", error);
    }
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}


@end
