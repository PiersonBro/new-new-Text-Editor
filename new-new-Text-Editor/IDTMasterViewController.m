//
//  IDTMasterViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTMasterViewController.h"

#import "IDTDetailViewController.h"
@interface IDTMasterViewController () <UIAlertViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>  {
    
    NSIndexPath *_indexOfFile;
    CGSize cellBounds;
    NSArray *paths;
    NSArray *names;
    
}
@property (nonatomic,strong) UISearchDisplayController *displayController;
@property (nonatomic,strong) NSString *textForFileName;
@property (nonatomic,strong) NSMutableArray *textFilesFiltered;

@property (nonatomic,strong) NSMutableArray *filteredTextFilesPaths;
@end

@implementation IDTMasterViewController
#pragma mark - Set up
- (void)awakeFromNib
{
    NSLog(@"HMM");
  [super awakeFromNib];
}
-(void)addFileFromURL:(NSURL *)fromURL  {
    self.contactModel = [[IDTDocument alloc]initWithFileURL:fromURL];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.contactModel readFolder];
    [self.contactModel copyFileFromURL:fromURL];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    

}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // This allocs and init's the model.
    if (self.contactModel == nil) {
        
    
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    docsDir = [docsDir stringByAppendingString:@"/"];
    NSString *path = [docsDir stringByAppendingString:@"new.txt"];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    self.contactModel = [[IDTDocument alloc]initWithFileURL:url];
    [self.contactModel readFolder];
    names = [self.contactModel.combinedArray objectAtIndex:0];
    paths = [self.contactModel.combinedArray objectAtIndex:1];

    }
    else {
        NSLog(@"self.contactModel is not nil!");
    }
         
    self.refreshControl  = [[UIRefreshControl alloc]init];

    self.refreshControl.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.5 alpha:1];
    [self.refreshControl addTarget:self action:@selector(reloadTableViewData:) forControlEvents:UIControlEventValueChanged];
    
    // This are the mutable arrays for the search view
    // FIXME: These don't use the proper API methods.
    self.textFilesFiltered = [[NSMutableArray alloc]initWithCapacity:[[self.contactModel.combinedArray objectAtIndex:0]count]];
    self.filteredTextFilesPaths = [[NSMutableArray alloc]initWithCapacity:[[self.contactModel.combinedArray objectAtIndex:1]count]];
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    
    self.tableView.bounds = newBounds;
    
    
    
    //Sets up the UIBarButtonItem, also sets up the selector.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.searchBar.delegate = self;
    self.displayController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchResultsDelegate = self;
    self.displayController.delegate = self;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popup:withText:)];
    UIBarButtonItem *switchButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonItemStylePlain target:self action:@selector(segueToOtherVC:)];
    self.navigationItem.rightBarButtonItems = @[addButton,switchButton];
 
    
    
    [self.tableView reloadData];

}
- (void)didReceiveMemoryWarning
{
    NSLog(@"Detail view did receive memeory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table insert and setup (non-delagte)
-(void) popup:(id)sender withText:(id)buttonText {
    ///Embarassing.
    if ([buttonText isEqual: @"Rename"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter File Name"
                                                            message:@"Enter the name of the file"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:buttonText, nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alertView textFieldAtIndex:0].text = [names objectAtIndex:_indexOfFile.row];
        [alertView show];
    }
    else {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter File Name"
                                                        message:@"Enter the name of the file"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Enter", nil];
    [alertView  setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
    }
   

    
}

- (void)insertNewObject:(id)sender
{
    BOOL succesOrFailure = [self.contactModel createFileWithText:@"Welcome to the green text editor"Name:self.textForFileName AtIndex:0];
    if(succesOrFailure == YES) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self notifyUserOfNegativeEventWithString:@"Oops something failed! The most likely reason is that you were trying to create a file that already exists! (has the same name) If so just change the name of the file and try again! "];
    }
}

#pragma mark - Table View (delagate)

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //The main (non search seque is setup in the storyboard thus no code is here.
    //PrepareForSegue is atuomaticly called.
    
    
    
    // Perform segue to text editor detail
    
    if (tableView == self.displayController.searchResultsTableView) {
    [self performSegueWithIdentifier:@"showDetail" sender:tableView];
    }
   

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.contactModel == nil) {
        NSLog(@"The model is nil! Abort! Abort!");
    }
    
    if (tableView == self.displayController.searchResultsTableView) {
        
        return [self.textFilesFiltered count];
    }
    else {
        [self.contactModel readFolder];
        return [names count];
        
    }
}
#pragma mark Rename Functionality.
-(void)handleLongPress:(UIGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
        
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Rename" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Rename",@"Fork", nil];
    CGPoint pressPoint = [longPress locationInView:self.tableView];
        CGRect rectFromPressPoint = {
            pressPoint,
            cellBounds
        };
    _indexOfFile = [self.tableView indexPathForRowAtPoint:pressPoint];
        
    [actionSheet showFromRect:rectFromPressPoint inView:self.tableView animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self popup:self withText:@"Rename"];
    }
    if (buttonIndex == 2) {
        
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    //cell label.
    NSString *cellLabel = nil;
   
    if (tableView != self.searchDisplayController.searchResultsTableView) {
       
        
        cellLabel = [names objectAtIndex:indexPath.row];
        
    }
    
    else {
        cellLabel = [self.textFilesFiltered objectAtIndex:indexPath.row];
    
    }
    cell.textLabel.text = cellLabel;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cellBounds = cell.frame.size;

    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setDelegate:self];
    gestureRecognizer.delaysTouchesBegan = 4.0;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *identify = [names objectAtIndex:indexPath.row];
        [self.contactModel deleteFileWithName:identify AtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}


#pragma mark UIAlertViewDelagate.
- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        
    

    if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Rename"] && buttonIndex == 1) {
        self.textForFileName = [[alertView textFieldAtIndex:0]text];
       
            
        
        
        NSUInteger uint = _indexOfFile.row;
        
       NSString *prevNameOfFile = [names objectAtIndex:uint];
        [self.contactModel renameFileName:prevNameOfFile withName:self.textForFileName atIndexPath:_indexOfFile];
        names = [self.contactModel.combinedArray objectAtIndex:0];
        paths = [self.contactModel.combinedArray objectAtIndex:1];
        [self.tableView reloadData];
    }

    
    if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Enter"] && buttonIndex == 1) {
        
        self.textForFileName = [[alertView textFieldAtIndex:0]text];
       
        if (self.textForFileName == nil) {
            //FIXME: I crash if there is already a file named like me.
            self.textForFileName = @"Blank";
        }
        [self insertNewObject:self];
        
        
    }
    }
}
-(void)notifyUserOfNegativeEventWithString:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark Segue.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSString *object = nil;
        NSIndexPath *indexPath = nil;

        if (sender == self.searchDisplayController.searchResultsTableView) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];

            object = [self.filteredTextFilesPaths objectAtIndex:indexPath.row];
        }
        else {
            indexPath = [self.tableView indexPathForSelectedRow];
            
            object = [paths objectAtIndex:indexPath.row];
        }
        
        IDTDetailViewController *contactDetailViewController = [segue destinationViewController];
        if (sender == self.searchDisplayController.searchResultsTableView) 
            contactDetailViewController.nameOfFile = [self.textFilesFiltered objectAtIndex:indexPath.row];

        
        else {
            
            contactDetailViewController.nameOfFile = [names objectAtIndex:indexPath.row];
        }
        [[segue destinationViewController] setDetailItem:object];
                                                    
                                                           
    }
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
   /*Hello future self! Cotent is filtered via the NSPredicate api and then those filterd arrays are set on two global properties: self.textFilesFiltered and
    self.filteredTextFilesPaths
*/
	
    // Remove all objects from the filtered search array
	[self.textFilesFiltered removeAllObjects];
    [self.filteredTextFilesPaths removeAllObjects];
 
   
	// Filter the array using NSPredicate
    
  // NSString *searchTextPathsString = [self.contactModel.docsDir stringByAppendingString:searchText];
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    for (NSString *string in paths) {
        NSString *addString = [string lastPathComponent];
        [mutableArray addObject:addString];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    NSPredicate *predicatePaths = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    NSArray *tempArray = [names filteredArrayUsingPredicate:predicate];
    
    
    NSArray *tempArrayPaths = [mutableArray filteredArrayUsingPredicate:predicatePaths];
    NSMutableArray *finalTempArrayPaths = [[NSMutableArray alloc]init];
    for (NSString *fileString in tempArrayPaths) {
        NSString *completeFileString = [self.contactModel.docsDir stringByAppendingPathComponent:fileString];
        [finalTempArrayPaths addObject:completeFileString];
    }
    
    
    
    self.textFilesFiltered = [NSMutableArray arrayWithArray:tempArray];
    self.filteredTextFilesPaths = [NSMutableArray arrayWithArray:finalTempArrayPaths];
    

}


#pragma mark UISearchDisplayDelagate 

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{

	// Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void)segueToOtherVC:(id)sender {
    NSLog(@"HELLO THERE!");
    
    [self performSegueWithIdentifier:@"showNewVC" sender:self];

}


//This is mainly here so that when Dropbox functionality is implmented it can reload the Dropbox data.
-(void)reloadTableViewData:(id)selector {
    [self.contactModel readFolder];
    [self.tableView  reloadData];
    [self.refreshControl endRefreshing];
}




@end
