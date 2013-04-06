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
@interface IDTDetailViewController () <MFMailComposeViewControllerDelegate, UITextViewDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
    UIBarButtonItem *barButton;
    //IDTDocument *secondDocument;
}
@property (nonatomic, strong)  IDTDocument *document;
@property (nonatomic, strong) NSURL *url;
@property (strong, nonatomic) IBOutlet UIButton *segueButton;
@property (strong, nonatomic) UIPanGestureRecognizer *twoFingerswipe;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) UIDocumentInteractionController *docInteractionController;

@end

@implementation IDTDetailViewController

#pragma mark - Managing the detail item

- (void)configureView {
    self.document = [[IDTDocument alloc]initWithFileURL:self.detailItem];
      // secondDocument = [[IDTDocument alloc]initWithFileURL:url];
   NSOperationQueue *specialQueue = [[NSOperationQueue alloc]init];
//    [specialQueue addOperationWithBlock:^{
//        [secondDocument openWithCompletionHandler:^(BOOL success) {
//            NSLog(@"Success!");
//            NSLog(@"what is the value of userText (secondDocument) %@", secondDocument.userText);
//        }];
//    }];
    NSString *textViewString = [self.textView.text copy];
    [specialQueue addOperationWithBlock:^{
        //This prevents a threading warning.
        [self.document openWithCompletionHandler:^(BOOL success) {
            BOOL HTMLDoc;
            HTMLDoc = YES;

      
            if (success && HTMLDoc == YES) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    self.textView.text = self.document.userText;
                }];

                NSOperationQueue *queue = [[NSOperationQueue alloc]init];
                __block NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:textViewString];
                [queue setName:@"Data Processing Queue"];
                [queue addOperationWithBlock:^{
                    mutableAttributedString = [self highlightOnBackgroundThreadWithRegularExpression:@"(?i)<(?![BIP]\\b ).*?/?>" inString:self.document.userText withHighlightColor:[UIColor colorWithRed:0.7 green:0.2 blue:0.3 alpha:0.9]];

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
    self.document.userText = textView.text;
    [self.document updateChangeCount:UIDocumentChangeDone];
//    secondDocument.userText = textView.text;
//    [secondDocument updateChangeCount:UIDocumentChangeDone];
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
    NSArray *barButtonItemArray = [[NSArray alloc]initWithObjects:barButton, barButton2, barButton3, nil];

    self.navigationItem.rightBarButtonItems = barButtonItemArray;
    // Attirbuted String for header label.
    NSMutableAttributedString *displayNameOfFile = [[NSMutableAttributedString alloc]initWithString:self.nameOfFile];
    [displayNameOfFile addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [displayNameOfFile length])];
    self.detailDescriptionLabel.attributedText = displayNameOfFile;


    if (self.darkModeEnabled == YES) {
        self.textView.textColor = [UIColor colorWithWhite:1 alpha:1];
        self.textView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1];
        // [self highlightWithRegularExpression:@"(?i)<(?![BIP]\\b ).*?/?>" andColor:[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.2]];
    }




    self.twoFingerswipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(action2:)];
    self.twoFingerswipe.minimumNumberOfTouches = 2;
    [self.textView addGestureRecognizer:self.twoFingerswipe];
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.view addSubview:self.textView];
        [KOKeyboardRow applyToTextView:self.textView];
    }
}

//This saves the open document and dismisses popups. IT does work.
- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.document closeWithCompletionHandler:^(BOOL success) {
            if (!success) [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
        }];
    }
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Detail view did receive memeory warning");
    self.textView = nil;
    self.document = nil;
    [super didReceiveMemoryWarning];
}

- (void)notifyUserOfNegativeEventWithString:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark SegmentAction and Sharing
- (IBAction)action1:(id)sender {
    self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.url];

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

//This code is supposed to go back to main view
//}
//-(IBAction)action5:(id)sender {
//[self prepareForSegue:<#(UIStoryboardSegue *)#> sender:<#(id)#>]
//}


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
    NSMutableArray *mutableArray = [self.document stringMatchInString:string WithRegularExpr:regEx];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string];
    for (NSUInteger i = 0; i < [mutableArray count]; i++) {
        NSRange range = [[mutableArray objectAtIndex:i]rangeValue];


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
        webView.stringForWebView = [MMMarkdown HTMLStringWithMarkdown:self.textView.text error:&error];
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

@end
