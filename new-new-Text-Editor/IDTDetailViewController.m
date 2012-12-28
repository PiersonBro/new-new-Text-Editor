//
//  IDTDetailViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//
#import "IDTDetailViewController.h"
#import "IDTWebViewController.h"
@interface IDTDetailViewController () <MFMailComposeViewControllerDelegate,UITextViewDelegate,UIDocumentInteractionControllerDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate>
- (void)configureView;
@property (nonatomic,strong)  IDTDocument *document;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) UIActivityViewController *actionSheet;

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
        self.textField.text = self.document.userText;
        

        if (success) {
            [self highlight];

        }
        else {            [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
        }
    }];

    self.textField.delegate = self;
}
#pragma mark textView Delagate
- (void)textViewDidChange:(UITextView *)textView {
    self.document.userText = textView.text;
    [self.document updateChangeCount:UIDocumentChangeDone];
    NSError *error;
    NSString *parse = [MMMarkdown HTMLStringWithMarkdown:self.document.userText error:&error];
    
    NSLog(@"parse is %@",parse);
    
}
#pragma mark view handling
- (void)viewDidLoad
{
    //Set up a UISegmentedControl and setup it's target.
    self.button.hidden = YES;
    NSArray *segmentControlText = @[@"Share",@"Email", @"Browser"];
    UISegmentedControl  *segmentControl = [[UISegmentedControl alloc]initWithItems:segmentControlText];
    segmentControl.momentary = YES;
    segmentControl.selectedSegmentIndex = 0;
	segmentControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentControl.frame = CGRectMake(0, 0, 400, 30.0);
	[segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentControl;
    // Attirbuted String for header label.
        
    NSMutableAttributedString *displayNameOfFile = [[NSMutableAttributedString alloc]initWithString:self.nameOfFile];
        [displayNameOfFile addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[displayNameOfFile length])];
        self.detailDescriptionLabel.attributedText = displayNameOfFile;

    
    [self.navigationItem.backBarButtonItem setAction:@selector(perform:)];
    [super viewDidLoad];
    [self configureView];
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {

    [self.document closeWithCompletionHandler:^(BOOL success) {
        if (success) {
        }else {
            [self notifyUserOfNegativeEventWithString:@"Sorry. The Document Failed to save! There is nothing you can do but wallow in your own misery and delete this stupid app. My apologies "];
        }
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
- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    //Call diffrent methods depending on which button was selected.
    if (segmentedControl.selectedSegmentIndex == 0) {
        
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.url];
        
        self.docInteractionController.delegate = self;
        
        if ([self.docInteractionController presentOptionsMenuFromRect:self.view.frame
                                                               inView:self.view animated:YES]){
        }
        else{
            [self notifyUserOfNegativeEventWithString:@"Sorry you don't have the proper apps installed to handle this file!"];
            
        }
        
    }
        if (segmentedControl.selectedSegmentIndex == 1) {
            [self mailPressed:self];
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
        NSLog(@"okay");
        [self performSegueWithIdentifier:@"goToWebView" sender:self];
    }
}

//When the email button is selected this code is executed.
- (IBAction)mailPressed:(id)sender {
    
    MFMailComposeViewController *compose = [[MFMailComposeViewController alloc]init];
    compose.mailComposeDelegate = self;
    [compose setModalPresentationStyle:UIModalPresentationCurrentContext
     ];
    //FIXME: This can casue a NSRangeException or NSRangeUnkown. if the text does not have a charecter at 41;
    
    NSString *subjectStr = [self.textField.text substringWithRange:NSMakeRange(1, 41)];
    [compose setSubject:subjectStr];
    [compose setMessageBody:self.textField.text isHTML:NO];
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
//It is a little slow.
-(void) highlight {
    self.textField.text = self.document.userText;

    [self.document stringMatch:self.textField.text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.textField.text];
  
    for (int i = 0; i < [self.document.rangesOfHighlight count]; i++) {
    

        NSRange range = [[self.document.rangesOfHighlight objectAtIndex:i]rangeValue];
        
       
    
        [attributedString  addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.7 green:0.2 blue:0.3 alpha:0.9] range:range];
    }
    self.textField.attributedText = attributedString;
   


    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"the identifier is %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"goToWebView"]) {
        NSLog(@"work");
        IDTWebViewController *webView = [segue destinationViewController];
        webView.stringForWebView = [MMMarkdown HTMLStringWithMarkdown:self.textField.text error:nil];
    }
    
}
#pragma mark dismisskeyboard 
//there Could be more touch code here in the future but I remain undecided.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    [self.textField resignFirstResponder];
    [self.view endEditing:YES];

}




@end
