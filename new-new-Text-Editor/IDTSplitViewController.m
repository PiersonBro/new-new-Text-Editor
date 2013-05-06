//
//  IDTSplitViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 4/29/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTSplitViewController.h"

@interface IDTSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation IDTSplitViewController

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
    self.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
}

@end
