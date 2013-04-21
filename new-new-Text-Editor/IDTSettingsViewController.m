//
//  IDTSettingsViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 4/11/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTSettingsViewController.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
@interface IDTSettingsViewController  () <UITextFieldDelegate>

@end

@implementation IDTSettingsViewController

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
    [[UIToolbar appearanceWhenContainedIn:[UIToolbar self], nil]setTintColor:[UIColor colorWithRed:0.1 green:0.5 blue:0.5 alpha:1]];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    NSError *error;
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.gistSwitch addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
     self.gistSwitch.on = [defaults boolForKey:@"enableGists"];
    SSKeychainQuery *query = [[SSKeychainQuery alloc]init];
    query.service = @"Github";
    query.account = [[NSUserDefaults standardUserDefaults]stringForKey:@"githubUsername"];
   [query fetch:&error];
    self.passwordField.text = query.password;
    self.usernameField.text = query.account;
    if (error) {
        NSLog(@"FAIL");
    }
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"YESSSS");
    }];
}
-(void)valueChanged {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.gistSwitch forKey:@"enableGists"];
    [defaults synchronize];

}



- (IBAction)doneButtonPressed:(id)sender {
    [self.passwordField endEditing:YES];
    [self.usernameField endEditing:YES];
    if ([SSKeychain setPassword:self.passwordField.text forService:@"Github" account:self.usernameField.text]) {
        NSLog(@"Successful save of password.");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.usernameField.text forKey:@"githubUsername"];
    }else {
        NSLog(@"failure did not have a sucessful save of password.");
    }
  

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.passwordField endEditing:YES];
    [self.usernameField endEditing:YES];
    return NO;
}
@end
