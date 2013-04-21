//
//  IDTSettingsViewController.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 4/11/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDTSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *gistSwitch;
- (IBAction)dismiss:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)doneButtonPressed:(id)sender;

@end
