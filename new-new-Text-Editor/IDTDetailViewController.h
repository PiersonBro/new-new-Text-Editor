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
#import "IDTChooseDocumentViewController.h"

@interface IDTDetailViewController : UIViewController  <UISplitViewControllerDelegate>
//These properties are perhaps the only ones that should be public.
@property (nonatomic, strong)  IDTDocument *fileDocument;

@property (strong, nonatomic) id nameOfFile;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic) BOOL darkModeEnabled;
@property (nonatomic,strong) UIPopoverController *documentPopover;

@property (strong, nonatomic) IBOutlet UITextView *textView;


- (void)configureView;
@end
