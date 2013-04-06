//
//  IDTMasterViewController.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDTDocument.h"
#import "IDTModel.h"
@interface IDTMasterViewController : UITableViewController

//The SearchBar for the tableView.
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IDTModel *model;
@property (nonatomic) BOOL shouldReloadDataSource;

- (void)insertNewObject:(id)sender;
- (void)popup:(id)sender withText:(id)buttonText;

- (void)addFileFromURL:(NSURL *)fromURL;

@end
