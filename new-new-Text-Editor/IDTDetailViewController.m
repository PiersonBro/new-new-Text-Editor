//
//  IDTDetailViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//
#import "IDTDetailViewController.h"
#import "IDTWebViewController.h"
@interface IDTDetailViewController () <MFMailComposeViewControllerDelegate,UITextViewDelegate,UIDocumentInteractionControllerDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,UIAlertViewDelegate> {
    UIBarButtonItem *barButton;
}
- (void)configureView;
@property (nonatomic,strong)  IDTDocument *document;
@property (nonatomic,strong) NSURL *url;

@property (retain,nonatomic)UIDocumentInteractionController* docInteractionController;

@end

@implementation IDTDetailViewController

#pragma mark - Managing the detail item


- (void)configureView
{
    // Update the user interface for the detail item.
      
     self.url = [[NSURL alloc]initFileURLWithPath:[self.detailItem description]];
    self.document = [[IDTDocument alloc]initWithFileURL:self.url];
    [self.document openWithCompletionHandler:^(BOOL success) {
        

        if (success) 
            [self highlight];

        
        else
            [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
    
    }];

    self.textView.delegate = self;
}
#pragma mark textView Delagate
- (void)textViewDidChange:(UITextView *)textView {
    self.document.userText = textView.text;
    [self.document updateChangeCount:UIDocumentChangeDone];
    
}
#pragma mark view handling
- (void)viewDidLoad
{
    self.segueButton.hidden = YES;
    self.segueButton.enabled = NO;
       
    

    barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action1:)];
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(action4:)];
        UIBarButtonItem *barButton3 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Telescope-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(action3:)];
        NSArray *barButtonItemArray = [[NSArray alloc]initWithObjects:barButton,barButton2,barButton3, nil];
    
    self.navigationItem.rightBarButtonItems = barButtonItemArray;
    // Attirbuted String for header label.
    NSMutableAttributedString *displayNameOfFile = [[NSMutableAttributedString alloc]initWithString:self.nameOfFile];
        [displayNameOfFile addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[displayNameOfFile length])];
        self.detailDescriptionLabel.attributedText = displayNameOfFile;

    
    [self.navigationItem.backBarButtonItem setAction:@selector(perform:)];
    if (self.darkModeEnabled == YES) {
       self.textView.textColor = [UIColor colorWithWhite:1 alpha:1];
       self.textView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1];
    }
    
    [super viewDidLoad];
    [self configureView];
}
//Not sure if this works but I am keeping it here just in case.
-(void) perform:(id)sender {
    
    //do your saving and such here
    NSLog(@"it kinda worked!");
    [self.document closeWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"PARTY");
        }
    }];
    [self.navigationController popViewControllerAnimated:NO];
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {

    [self.document closeWithCompletionHandler:^(BOOL success) {
        if (success) 
            NSLog(@"YES");
        else 
            [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
        
    }];
    }
    [super viewWillDisappear:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)notifyUserOfNegativeEventWithString:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:string delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark SegmentAction and Sharing 
-(IBAction)action1:(id)sender {
    self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.url];
    
            self.docInteractionController.delegate = self;
    if ([self.docInteractionController presentOptionsMenuFromBarButtonItem:barButton animated:YES]) 
        NSLog(@"Succes");
    
    else
        NSLog(@"faluire is not an option");
    
}
-(IBAction)action2:(id)sender {
   [self mailPressed:self];

    
}
-(IBAction)action3:(id)sender {
    [self performSegueWithIdentifier:@"goToWebView" sender:self];

    
}
-(IBAction)action4:(id)sender {
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

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark syntax highlighting
//This is the view controller conterpart to the model's stringMatch method.
-(void) highlight {
    
    self.textView.text = self.document.userText;

    [self.document stringMatch:self.textView.text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.textView.text];
  
    for (int i = 0; i < [self.document.rangesOfHighlight count]; i++) {
    

        NSRange range = [[self.document.rangesOfHighlight objectAtIndex:i]rangeValue];
        
       
    
        [attributedString  addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.7 green:0.2 blue:0.3 alpha:0.9] range:range];
    }
    self.textView.attributedText = attributedString;
   


    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToWebView"]) {
        
        IDTWebViewController *webView = [segue destinationViewController];
        NSError *error;
        webView.stringForWebView = [MMMarkdown HTMLStringWithMarkdown:self.textView.text error:&error];
        if (error)
            NSLog(@"error is %@",error);
        
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
        
        NSString *string = [[alertView textFieldAtIndex:0]text];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.textView.text];

       NSMutableArray *array =  [self.document findText:string inText:self.textView.text];
          for (int i = 0; i < [array count]; i++) {
            
        
              NSRange range = [[array objectAtIndex:i]rangeValue];
                    [attributedString  addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1 green:1 blue:0.0 alpha:1] range:range];
        }
        self.textView.attributedText = attributedString;
         
        

        
    }
}



@end
