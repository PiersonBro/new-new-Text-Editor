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

@property (strong, nonatomic) id detailItem;
@property (strong,nonatomic) id nameOfFile;

@property (strong, nonatomic) IBOutlet UIButton *button;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
