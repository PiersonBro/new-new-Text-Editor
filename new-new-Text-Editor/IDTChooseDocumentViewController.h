//
//  IDTChooseDocumentViewController.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 5/24/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDTModel.h"
#import "IDTDocument.h"

@protocol IDTDismissDelagate <NSObject>

-(void)didTap;

@end
@interface IDTChooseDocumentViewController : UITableViewController 


@property (nonatomic,strong) id<IDTDismissDelagate> delegate;
@property (nonatomic,strong) IDTModel *model;
@property (nonatomic,strong) IDTDocument *document;


@end
