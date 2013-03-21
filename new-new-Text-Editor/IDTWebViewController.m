//
//  IDTWebViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 12/24/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTWebViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface IDTWebViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation IDTWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //This load the string set by the detail view controller.
    [self.webView loadHTMLString:self.stringForWebView baseURL:nil];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareHTML:(id)sender {
    [self mailPressed:self];
}

- (IBAction)mailPressed:(id)sender {
    MFMailComposeViewController *compose = [[MFMailComposeViewController alloc]init];
    compose.mailComposeDelegate = self;
    [compose setModalPresentationStyle:UIModalPresentationCurrentContext
    ];
    //FIXME: This can casue a NSRangeException or NSRangeUnkown. if the text does not have a charecter at 41;

    [compose setMessageBody:self.stringForWebView isHTML:YES];
    [self presentViewController:compose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
