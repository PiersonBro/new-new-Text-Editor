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
    
}
@property (nonatomic,strong) IDTDocument *contactModel;
@property (nonatomic,strong) UISearchDisplayController *displayController;
@property (nonatomic,strong) NSString *textForFileName;
@property (nonatomic,strong) NSMutableArray *textFilesFiltered;

@property (nonatomic,strong) NSMutableArray *filteredTextFilesPaths;
@end

@implementation IDTMasterViewController
#pragma mark - Set up
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // This allocs and init's the model.
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    docsDir = [docsDir stringByAppendingString:@"/"];
    NSString *path = [docsDir stringByAppendingString:@"new.txt"];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    self.contactModel = [[IDTDocument alloc]initWithFileURL:url];
    
    [self.contactModel readFolder];
    // This are the mutable arrays for the search view
    self.textFilesFiltered = [[NSMutableArray alloc]initWithCapacity:[self.contactModel.fileData count]];
    self.filteredTextFilesPaths = [[NSMutableArray alloc]initWithCapacity:[self.contactModel.fileData count]];
    
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
    self.navigationItem.rightBarButtonItem = addButton;
 
    
    
    [[self tableView] reloadData];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table insert and setup (non-delagte)
-(void) popup:(id)sender withText:(id)buttonText {
    ///Embarassing.
    if (buttonText == @"Rename") {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter File Name"
                                                            message:@"Enter the name of the file"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:buttonText, nil];
        [alertView  setAlertViewStyle:UIAlertViewStylePlainTextInput];
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
    BOOL succesOrFailure = [self.contactModel createFile:@"Welcome to the green text editor":self.textForFileName :0];
    if(succesOrFailure == YES) {
        NSLog(@"DID NOT DO MY HOMEWORK %d",succesOrFailure);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self notifyUserOfNegativeEventWithString:@"Oops something failed! The most likely reason is that you were trying to create a file that already exists! (has the same name) If so just change the name of the file and try again! "];
        NSLog(@"FAIL AS in YES!!");
    }
}

#pragma mark - Table View (delagate)

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    if (tableView == self.displayController.searchResultsTableView) 
        return self.textFilesFiltered.count;
    
    else
    return self.contactModel.fileData.count;

    
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    //cell label.
    NSString *cellLabel = nil;
   
    if (tableView != self.searchDisplayController.searchResultsTableView) {
       
        
        cellLabel = [[self.contactModel.fileData objectAtIndex:indexPath.row]fileName];
        
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
        NSString *identify = [[self.contactModel.fileData objectAtIndex:indexPath.row]fileName];
        [self.contactModel deleteFile:identify :indexPath.row];
        
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
        NSLog(@"SUCCES");
        self.textForFileName = [[alertView textFieldAtIndex:0]text];
       
            
        
        
        NSUInteger uint = _indexOfFile.row;
        
       NSString *prevNameOfFile = [[self.contactModel.fileData objectAtIndex:uint]fileName];
        [self.contactModel renameFileName:prevNameOfFile withName:self.textForFileName atIndexPath:_indexOfFile];
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
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSString *object = nil;
        NSIndexPath *indexPath = nil;

        if (sender == self.searchDisplayController.searchResultsTableView) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];

            object = [self.filteredTextFilesPaths objectAtIndex:indexPath.row];
        }
        else {
             indexPath = [self.tableView indexPathForSelectedRow];

             object = [[self.contactModel.fileData objectAtIndex:indexPath.row]filePath];
        }
        
        IDTDetailViewController *contactDetailViewController = [segue destinationViewController];
        if (sender == self.searchDisplayController.searchResultsTableView) 
            contactDetailViewController.nameOfFile = [self.textFilesFiltered objectAtIndex:indexPath.row];

        
        else
            contactDetailViewController.nameOfFile = [[self.contactModel.fileData objectAtIndex:indexPath.row]fileName];
        
        [[segue destinationViewController] setDetailItem:object];
                                                    
                                                           
    }
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	
    // Remove all objects from the filtered search array
	[self.textFilesFiltered removeAllObjects];
    [self.filteredTextFilesPaths removeAllObjects];
    NSMutableArray *paths = [[NSMutableArray alloc]init];
    NSMutableArray *names = [[NSMutableArray alloc]init];
    for (NSUInteger i = 0; i < [self.contactModel.fileData count]; i++) {
        NSString *path = [[self.contactModel.fileData objectAtIndex:i]filePath];
        NSString *name = [[self.contactModel.fileData objectAtIndex:i]fileName];
        
        [paths addObject:path];
        [names addObject:name];
    }
   
	// Filter the array using NSPredicate
    
   // NSString *searchTextPathsString = [self.contactModel.docsDir stringByAppendingString:searchText];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    NSPredicate *predicatePaths = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    NSLog(@"predicatePaths %@ and predicate %@",predicatePaths,predicate);
    NSArray *tempArray = [names  filteredArrayUsingPredicate:predicate];
    
    NSArray *tempArrayPaths = [paths filteredArrayUsingPredicate:predicatePaths];
    NSLog(@"temparrayPaths is %@",tempArrayPaths);
        self.textFilesFiltered = [NSMutableArray arrayWithArray:tempArray];
    self.filteredTextFilesPaths = [NSMutableArray arrayWithArray:tempArrayPaths];
    

}


#pragma mark UISearchDisplayDelagate 

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
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



@end
