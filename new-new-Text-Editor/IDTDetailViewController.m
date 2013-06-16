//
//  IDTDetailViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "KOKeyboardRow.h"
#import "IDTDetailViewController.h"
#import "IDTWebViewController.h"
#import "IDTModel.h"
#import "IDTMasterViewController.h"
#import "IDTChooseDocumentViewController.h"
#import "IDTLinked.h"
@interface IDTDetailViewController () <MFMailComposeViewControllerDelegate, UITextViewDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UIAlertViewDelegate,UIPopoverControllerDelegate,IDTDismissDelagate> {
    UIBarButtonItem *barButton;
    //IDTDocument *secondDocument;
}
@property (nonatomic, strong) NSURL *url;
@property (strong, nonatomic) IBOutlet UIButton *segueButton;
@property (strong, nonatomic) UIPanGestureRecognizer *twoFingerswipe;
@property (retain, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *linkDocumentButton;

@end

@implementation IDTDetailViewController

#pragma mark - Managing the detail item

- (void)configureView {
    if (self.fileDocument == nil) {
       NSString *string = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/hello.txt"];
        NSURL *url = [NSURL fileURLWithPath:string];
        self.fileDocument = [[IDTDocument alloc]initWithFileURL:url];
        self.nameOfFile = @"hello.txt";

    }
    
      // secondDocument = [[IDTDocument alloc]initWithFileURL:url];
//    [specialQueue addOperationWithBlock:^{
//        [secondDocument openWithCompletionHandler:^(BOOL success) {
//            NSLog(@"Success!");
//            NSLog(@"what is the value of userText (secondDocument) %@", secondDocument.userText);
//        }];
//    }];
    NSOperationQueue *specialQueue = [[NSOperationQueue alloc]init];
    //This prevents a threading warning.

    NSString *textViewString = [self.textView.text copy];
    [specialQueue addOperationWithBlock:^{
        [self.fileDocument openWithCompletionHandler:^(BOOL success) {
            BOOL HTMLDoc;
            HTMLDoc = YES;

      
            if (success && HTMLDoc == YES) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    self.textView.text = self.fileDocument.userText;
                }];

                NSOperationQueue *queue = [[NSOperationQueue alloc]init];
                __block NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:textViewString];
                [queue setName:@"Data Processing Queue"];
                [queue addOperationWithBlock:^{
                    mutableAttributedString = [self highlightOnBackgroundThreadWithRegularExpression:@"(?i)<(?![BIP]\\b ).*?/?>" inString:self.fileDocument.userText withHighlightColor:[UIColor colorWithRed:0.7 green:0.2 blue:0.3 alpha:0.9]];

                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        [self updateUIWithAttriubtedString:mutableAttributedString];
                    }];
                }]; //open failed.
            }else {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
    
                }];
            }
        }];
    }];
}

#pragma mark textView Delagate

- (void)textViewDidChange:(UITextView *)textView {
    self.fileDocument.userText = textView.text;
    [self.fileDocument updateChangeCount:UIDocumentChangeDone];
    

}
//Should be a model method.
-(void)linkWithDocument:(IDTDocument *)document {
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            document.userText = [document.userText stringByAppendingString:[NSString stringWithFormat:@"INFO: Document was linked with document %@",self.fileDocument.name]];
            [document updateChangeCount:UIDocumentChangeDone];

        
        [document closeWithCompletionHandler:^(BOOL success) {
            if (!success) [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
        }];
        }
    }];
}
#pragma mark view handling
- (void)viewDidLoad {
    self.textView.delegate = self;

    [super viewDidLoad];
    //This reads the file and applies the syntax highlighting.
    [self configureView];

    self.segueButton.hidden = YES;
    self.segueButton.enabled = NO;



    barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action1:)];
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(action4:)];
    UIBarButtonItem *barButton3 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Telescope-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(action3:)];
    NSArray *barButtonItemArray = @[barButton, barButton2, barButton3];

    self.navigationItem.rightBarButtonItems = barButtonItemArray;
    // Attirbuted String for header label.
    NSMutableAttributedString *displayNameOfFile = [[NSMutableAttributedString alloc]initWithString:self.nameOfFile];
    [displayNameOfFile addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [displayNameOfFile length])];
    self.detailDescriptionLabel.attributedText = displayNameOfFile;
    if ([UIDevice currentDevice].userInterfaceIdiom ==  UIUserInterfaceIdiomPad ) {
        self.navigationItem.title = self.nameOfFile;
    }


    if (self.darkModeEnabled == YES) {
        self.textView.textColor = [UIColor colorWithWhite:1 alpha:1];
        self.textView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1];
        // [self highlightWithRegularExpression:@"(?i)<(?![BIP]\\b ).*?/?>" andColor:[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.2]];
    }




    self.twoFingerswipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(action2:)];
    self.twoFingerswipe.minimumNumberOfTouches = 2;
    [self.textView addGestureRecognizer:self.twoFingerswipe];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [KOKeyboardRow applyToTextView:self.textView];
    }
}

//This saves the open document and dismisses popups. IT does work. It is not called when the MASTERVC is openn
- (void)viewWillDisappear:(BOOL)animated {
    [self.fileDocument closeWithCompletionHandler:^(BOOL success) {
        if (!success) [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
    }];
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Detail view did receive memeory warning!");
    //FIXME: Add a TSMessage.
    self.textView = nil;
    self.fileDocument = nil;
    [super didReceiveMemoryWarning];
}
 
- (void)notifyUserOfNegativeEventWithString:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark SegmentAction and Sharing
- (IBAction)action1:(id)sender {
    self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.fileDocument.fileURL];

    self.docInteractionController.delegate = self;
    if ([self.docInteractionController presentOptionsMenuFromBarButtonItem:barButton animated:YES]) NSLog(@"Succes");
    else NSLog(@"faluire is not an option");
}

- (IBAction)action2:(id)sender {
    [self mailPressed:self];
}

- (IBAction)action3:(id)sender {
    [self performSegueWithIdentifier:@"goToWebView" sender:self];
}

- (IBAction)action4:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Search" message:@"type in stuff to search text" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

    [alertView show];
}

//When the email button is selected this code is executed.
- (IBAction)mailPressed:(id)sender {
    MFMailComposeViewController *compose = [[MFMailComposeViewController alloc]init];
    compose.mailComposeDelegate = self;
    [compose setModalPresentationStyle:UIModalPresentationCurrentContext
    ];
    //FIXME: This can casue a NSRangeException or NSRangeUnkown. if the text does not have a charecter at 41;
    NSString *subjectStr = self.nameOfFile;
    [compose setSubject:subjectStr];
    [compose setMessageBody:self.textView.text isHTML:NO];
    [self presentViewController:compose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark syntax highlighting
//This is the view controller conterpart to the model's stringMatch method.
- (NSMutableAttributedString *)highlightOnBackgroundThreadWithRegularExpression:(NSString *)regEx inString:(NSString *)string withHighlightColor:(UIColor *)color {
    NSMutableArray *mutableArray = [self.fileDocument stringMatchInString:string WithRegularExpr:regEx];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string];
    for (NSUInteger i = 0; i < [mutableArray count]; i++) {
        NSRange range = [mutableArray[i]rangeValue];
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    }


    return attributedString;
}

- (void)updateUIWithAttriubtedString:(NSMutableAttributedString *)attributedString {
    self.textView.attributedText = attributedString;
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToWebView"]) {
        IDTWebViewController *webView = [segue destinationViewController];
        NSError *error;
        
        webView.stringForWebView = self.textView.text;
        
        
        if (error) NSLog(@"error is %@", error);
    }
}

#pragma mark dismisskeyboard
//there Could be more touch code here in the future but I remain undecided.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textView resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //ACCK this throws an exception when string is nil.
    if (buttonIndex == 1) {
        //Add threads to this to make it fast.
        __block NSString *searchString = [[alertView textFieldAtIndex:0]text];
        __block NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:self.textView.text];
        NSString *textViewString = [self.textView.text copy];
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [queue setName:@"Search Queue"];
        [queue addOperationWithBlock:^{
            mutableAttributedString = [self highlightOnBackgroundThreadWithRegularExpression:searchString inString:textViewString withHighlightColor:[UIColor colorWithRed:1 green:1 blue:0 alpha:1]];

            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [self updateUIWithAttriubtedString:mutableAttributedString];
            }];
        }];
    }
}
- (IBAction)showPopup:(id)sender {
    [self.textView resignFirstResponder];
    IDTChooseDocumentViewController *chooseDocumentVC = [[IDTChooseDocumentViewController alloc]initWithStyle:UITableViewStylePlain];
    chooseDocumentVC.delegate = self;
    self.documentPopover = [[UIPopoverController alloc]initWithContentViewController:chooseDocumentVC];
    [self.documentPopover presentPopoverFromBarButtonItem:self.linkDocumentButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];


}
-(void)didTap {
    [self.documentPopover dismissPopoverAnimated:YES];
    IDTChooseDocumentViewController *chooseDocumentVC = (IDTChooseDocumentViewController *)self.documentPopover.contentViewController;
    NSLog(@"The Value of document is %@",chooseDocumentVC.document);
   // [self linkWithDocument:chooseDocumentVC.document];
    IDTLinked *linked = [[IDTLinked alloc]initWithThrower:self.fileDocument andReciever:chooseDocumentVC.document andType:nil];
    [self.fileDocument updateChangeCount:UIDocumentChangeDone];
    [self.fileDocument closeWithCompletionHandler:^(BOOL success) {
        if (success) {
            [linked inherit];
            self.textView.text = linked.linkedDocumentThrower.userText;
        }
    }];
}











@end
