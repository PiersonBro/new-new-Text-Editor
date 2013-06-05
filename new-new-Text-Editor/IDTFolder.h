//
//  IDTFolder.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 5/6/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTFolder : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSURL *folderURL;
//FIXME: Will this create confusion? I don't know.
@property (nonatomic,strong) NSMutableArray *documents;
@end
