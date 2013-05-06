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
@property (nonatomic, strong)  IDTDocument *fileDocument;

@property (strong, nonatomic) id nameOfFile;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic) BOOL darkModeEnabled;


- (void)configureView;
@end
