//
// IDTMasterViewController.m
// new-new-Text-Editor
//
// Created by E&Z Pierson on 9/26/12.
// Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTMasterViewController.h"
#import "IDTDetailViewController.h"
@interface IDTMasterViewController () <UIAlertViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate> {
  NSIndexPath *_indexOfFile;
  CGSize cellBounds;
}
@property (nonatomic, strong) UISearchDisplayController *displayController;
@property (nonatomic, strong) NSString *textForFileName;
@end

@implementation IDTMasterViewController

#pragma mark - Set up
- (void)awakeFromNib {
   [super awakeFromNib];
}
//Called when a Users is using IOS's open in feature.
- (void)addFileFromURL:(NSURL *)fromURL {
  self.model = [[IDTModel alloc]initWithFilePath:@"Documents/"];

  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.model copyFileFromURL:fromURL];

  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self reloadTableViewData:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  if (self.model == nil) {
        if (self.startingFilePath) {
            NSString *fixer = [self.startingFilePath stringByAppendingString:@"//"];
            self.model = [[IDTModel alloc]initWithFilePath:fixer];
        } else {
            self.model = [[IDTModel alloc]initWithFilePath:@"Documents/"];
            
        }
  }

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
  IDTDocument *document = self.model.documents[_indexOfFile.row];
 
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
  [self notifyUserOfNegativeEventWithString:@"Oops something failed! The most likely reason is that you were trying to create a file that already exists! (has the same name) If so just change the name of the file and try again! "];
  }
}

#pragma mark - Table View (delagate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //The main (non search seque is setup in the storyboard thus no code is here. For iPhone. Not iPad...
  //PrepareForSegue is atuomaticly called.
  // Perform segue to text editor detail
    if ([self.model.documents[indexPath.row] isKindOfClass:[IDTFolder class]]) {
        [self performSegueWithIdentifier:@"segueToFolderView" sender:tableView];
        
    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:tableView];

    }
  if (tableView == self.displayController.searchResultsTableView) {
  if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
      if ([self.model.documents[indexPath.row] isKindOfClass:[IDTFolder class]]) {
      [self performSegueWithIdentifier:@"segueToFolderView" sender:tableView];
      } else {
      [self performSegueWithIdentifier:@"ipadSegueToDetailView" sender:tableView];
    }
  }else {
      if ([self.model.documents[indexPath.row] isKindOfClass:[IDTFolder class]]) {
          [self performSegueWithIdentifier:@"segueToFolderView" sender:tableView];
          
      } else {
      }
    }
  }
  else if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      [self performSegueWithIdentifier:@"ipadSegueToDetailView" sender:tableView];

  }
 
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.model == nil) {
  NSLog(@"The model is nil! Abort! Abort!");
  self.model = [[IDTModel alloc]initWithFilePath:@"Documents/"];
  }

  if (tableView == self.displayController.searchResultsTableView) {
  return [self.model.documents count];
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
  //Woe is me!!!!!!!!!!!!!!!!!!!!!!!! X10

  if (tableView != self.searchDisplayController.searchResultsTableView) {
  IDTDocument *document = self.model.documents[indexPath.row];
  cellLabel = document.name;
  } else {
  cellLabel = ((IDTDocument *)self.model.documents[indexPath.row]).name; }
  cell.textLabel.text = cellLabel;
  [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
  cellBounds = cell.frame.size;
  if (((IDTDocument *)self.model.documents[indexPath.row]).isGist) {
  cell.imageView.image = [UIImage imageNamed:@"HasGistCellImage@2X.png"];
 
  }
  
  UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
  [cell addGestureRecognizer:gestureRecognizer];
  [gestureRecognizer setDelegate:self];
  gestureRecognizer.delaysTouchesBegan = 4.0;

  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
  NSString *identify;

  if (tableView == self.searchDisplayController.searchResultsTableView) {
  identify = ((IDTDocument *)self.model.documents[indexPath.row]).name;
  [self.model.documents removeObjectAtIndex:indexPath.row];
  } else {
  identify = ((IDTDocument *)self.model.documents[indexPath.row]).name;
  }

  [self.model deleteFile:identify AtIndex:indexPath.row];
  if (tableView == self.searchDisplayController.searchResultsTableView) {
  [self reloadTableViewData:self];
  }

  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  [self reloadTableViewData:self];

  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
  }
}

#pragma mark UIAlertViewDelagate.
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
  if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Rename"] && buttonIndex == 1) {
  self.textForFileName = [alertView textFieldAtIndex:0].text;
  NSUInteger uint = _indexOfFile.row;

  NSString *prevNameOfFile = ((IDTDocument *)self.model.documents[uint]).name;
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
      document = self.model.documents[indexPath.row];
  } else {
      
      indexPath = [self.tableView indexPathForSelectedRow];
      document = self.model.documents[indexPath.row];
  }
      IDTDetailViewController *contactDetailViewController = [segue destinationViewController];
  
      if (sender == self.searchDisplayController.searchResultsTableView)
          contactDetailViewController.nameOfFile = document.name;
      else {
          contactDetailViewController.nameOfFile = document.name;
      }
      ((IDTDetailViewController *)[segue destinationViewController]).fileDocument = document;
  } else if ([segue.identifier isEqualToString:@"segueToFolderView"]) {
      //FIXME: Fix this
      if (sender == self.searchDisplayController.searchResultsTableView) {
          NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
          IDTFolder *folder = self.model.documents[indexPath.row];
          IDTMasterViewController *mvc = [segue destinationViewController];
          mvc.startingFilePath = folder.name;
      }
      else {
          NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
          IDTFolder *folder = self.model.documents[indexPath.row];
          IDTMasterViewController *mvc = [segue destinationViewController];
          mvc.startingFilePath = folder.name;

        }
      }
}

#pragma mark Content Filtering

#pragma mark UISearchDisplayDelagate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self.model filterContentForSearchText:searchString scope:nil];

  return YES;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
  [self.model readFolder];
}
//This is mainly here so that when Dropbox functionality is implmented it can reload the Dropbox data.
- (void)reloadTableViewData:(id)selector {
  [self.tableView reloadData];
  [self.refreshControl endRefreshing];
}
-(void) beginSequeToSettingsView {
  
  [self performSegueWithIdentifier:@"settingsSegue" sender:self];
 
}


@end
