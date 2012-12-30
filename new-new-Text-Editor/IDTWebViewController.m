//
//  IDTWebViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 12/24/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTWebViewController.h"

@interface IDTWebViewController ()

@end

@implementation IDTWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    //This load the string set by the detail view controller.
    [self.webView loadHTMLString:self.stringForWebView baseURL:nil];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
