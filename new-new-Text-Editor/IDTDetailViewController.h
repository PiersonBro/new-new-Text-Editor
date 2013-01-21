//
//  IDTDetailViewController.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 9/26/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>
#import "IDTDocument.h"
#import "MMMarkdown.h"

@interface IDTDetailViewController : UIViewController
//These properties are perhaps the only ones that should be public.
@property (strong, nonatomic) id detailItem;
@property (strong,nonatomic) id nameOfFile;
@property (nonatomic,strong) UIPanGestureRecognizer * OneFinger;


//FIXME: Properties should be private.
@property (strong, nonatomic) IBOutlet UIButton *segueButton;
@property(strong, nonatomic) UIPanGestureRecognizer * twoFingerswipe;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic) BOOL darkModeEnabled;

@end
