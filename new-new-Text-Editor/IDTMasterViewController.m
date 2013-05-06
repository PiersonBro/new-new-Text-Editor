//
//  IDTMasterViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTMasterViewController.h"
#import "TSMessage.h"
#import "IDTDetailViewController.h"
@interface IDTMasterViewController () <UIAlertViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>  {
    NSIndexPath *_indexOfFile;
    CGSize cellBounds;
}
@property (nonatomic, strong) UISearchDisplayController *displayController;
@property (nonatomic, strong) NSString *textForFileName;
@end

@implementation IDTMasterViewController

#pragma mark - Set up
- (void)awakeFromNib {
    if (self.model == nil) {
        self.model = [[IDTModel alloc]init];
    }
    [super awakeFromNib];
}
//Called when a Users is using IOS's open in feature.
- (void)addFileFromURL:(NSURL *)fromURL  {
    self.model = [[IDTModel alloc]init];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.model copyFileFromURL:fromURL];

    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadTableViewData:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];


    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.5 alpha:1];
    [self.refreshControl addTarget:self action:@selector(reloadTableViewData:) forControlEvents:UIControlEventValueChanged];

    //Sets up the UIBarButtonItem, also sets up the selector.
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(beginSequeToSettingsView)];
    self.navigationItem.leftBarButtonItems = @[self.editButtonItem,settingsBarButtonItem];
    self.searchBar.delegate = self;
    self.displayController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchResultsDelegate = self;
    self.displayController.delegate = self;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popup:withText:)];
    self.navigationItem.rightBarButtonItems = @[addButton,];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showErrorMessege:) name:@"IDTGistError" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showSuccessMessage:) name:@"IDTGistSuccess" object:nil];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Detail view did receive memeory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table insert and setup (non-delagte)
- (void)popup:(id)sender withText:(id)buttonText {
    ///Embarassing.
    if ([buttonText isEqual:@"Rename"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter File Name"
                                                            message:@"Enter the name of the file"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:buttonText, nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        IDTDocument *document = [self.model.documents objectAtIndex:_indexOfFile.row];
        
        [alertView textFieldAtIndex:0].text = document.name;
        [alertView show];
    } else {  
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter File Name"
                                                            message:@"Enter the name of the file"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Enter", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView show];
    }
}

- (void)insertNewObject:(id)sender {
    //FIXME:Change isGist val too something user settable.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isGist = [defaults boolForKey:@"enableGists"];
    NSLog(@"The val of is gist is %d",isGist);
    BOOL succesOrFailure = [self.model createFileWithText:@"Welcome to the green text editor"Name:self.textForFileName AtIndex:0 isGist:isGist];
    if (succesOrFailure == YES) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self notifyUserOfNegativeEventWithString:@"Oops something failed! The most likely reason is that you were  trying to create a file that already exists! (has the same name) If so just change the name of the file and try again! "];
    }
}

#pragma mark - Table View (delagate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //The main (non search seque is setup in the storyboard thus no code is here. For iPhone. Not iPad...
    //PrepareForSegue is atuomaticly called.
    // Perform segue to text editor detail

    if (tableView == self.displayController.searchResultsTableView) {
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            [self performSegueWithIdentifier:@"ipadSegueToDetailView" sender:tableView];
        }else {
            [self performSegueWithIdentifier:@"showDetail" sender:tableView];
        }
    } else if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self performSegueWithIdentifier:@"ipadSegueToDetailView" sender:tableView];
        

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.model == nil) {
        NSLog(@"The model is nil! Abort! Abort!");
    }

    if (tableView == self.displayController.searchResultsTableView) {
        return [self.model.filteredDocuments count];
    } else {
        return [self.model.documents count];
    }
}

#pragma mark Rename Functionality.
- (void)handleLongPress:(UIGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateEnded) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Rename" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Rename", @"Fork", nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }


    //cell label.
    NSString *cellLabel = nil;

    if (tableView != self.searchDisplayController.searchResultsTableView) {
       IDTDocument *document = [self.model.documents objectAtIndex:indexPath.row];
        cellLabel = document.name;
    } else {
        cellLabel = ((IDTDocument *)[self.model.filteredDocuments objectAtIndex:indexPath.row]).name;    }
    cell.textLabel.text = cellLabel;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cellBounds = cell.frame.size;
    if (((IDTDocument *)[self.model.documents objectAtIndex:indexPath.row]).isGist) {
        cell.imageView.image = [UIImage imageNamed:@"HasGistCellImage@2X.png"];
        
    }
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setDelegate:self];
    gestureRecognizer.delaysTouchesBegan = 4.0;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *identify;

        if (tableView == self.searchDisplayController.searchResultsTableView) {
            identify = ((IDTDocument *)[self.model.filteredDocuments objectAtIndex:indexPath.row]).name;
            [self.model.filteredDocuments removeObjectAtIndex:indexPath.row];
        } else {
            identify = ((IDTDocument *)[self.model.documents objectAtIndex:indexPath.row]).name;
        }

        [self.model deleteFile:identify AtIndex:indexPath.row];
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            [self reloadTableViewData:self];
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self reloadTableViewData:self];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
       // NSLog(@"Hello)!");
    }
}

#pragma mark UIAlertViewDelagate.
- (void)            alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Rename"] && buttonIndex == 1) {
            self.textForFileName = [alertView textFieldAtIndex:0].text;




            NSUInteger uint = _indexOfFile.row;

            NSString *prevNameOfFile = ((IDTDocument *)[self.model.documents objectAtIndex:uint]).name;
            [self.model renameFileName:prevNameOfFile withName:self.textForFileName atIndexPath:_indexOfFile];
            [self.tableView reloadData];
        }


        if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Enter"] && buttonIndex == 1) {
            self.textForFileName = [alertView textFieldAtIndex:0].text;

            if (self.textForFileName == nil) {
                self.textForFileName = @"Blank";
            }
            [self insertNewObject:self];
        }
    }
}

- (void)notifyUserOfNegativeEventWithString:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark Segue.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"] || [segue.identifier isEqualToString:@"ipadSegueToDetailView"] ) {
        NSIndexPath *indexPath = nil;
        IDTDocument *document = nil;
        if (sender == self.searchDisplayController.searchResultsTableView) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];

            document = [self.model.filteredDocuments objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
        
            document = [self.model.documents objectAtIndex:indexPath.row];
        }

        IDTDetailViewController *contactDetailViewController = [segue destinationViewController];
        if (sender == self.searchDisplayController.searchResultsTableView)
            contactDetailViewController.nameOfFile = document.name;


        else {

            contactDetailViewController.nameOfFile = document.name;
        }
        ((IDTDetailViewController *)[segue destinationViewController]).fileDocument = document;
    }

}

#pragma mark Content Filtering

#pragma mark UISearchDisplayDelagate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.model filterContentForSearchText:searchString scope:nil];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self.model filterContentForSearchText:self.searchDisplayController.searchBar.text scope:nil];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

//This is mainly here so that when Dropbox functionality is implmented it can reload the Dropbox data.
- (void)reloadTableViewData:(id)selector {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}
-(void) beginSequeToSettingsView {
    
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
    
}



-(void)showErrorMessege:(NSNotification *)errorNotification {
    NSLog(@"Showing Error TSMessege");
    NSDictionary *dictionary = errorNotification.userInfo;
    NSLog(@"dictionary %@",dictionary);
    [TSMessage showNotificationInViewController:self withTitle:@"ERROR" withMessage:@"Something Gist related was ERRORED out.!" withType:kNotificationError withDuration:4.0];
    
}
-(void)showSuccessMessage:(NSNotification *)successNotification {
     //FIXME: Does not tell user what was successful!
    NSLog(@"Showing Success TSMessege");

    [TSMessage showNotificationInViewController:self withTitle:@"Success" withMessage:@"Something Gist related was successful!" withType:kNotificationSuccessful withDuration:4.0];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
