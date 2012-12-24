//
//  IDTDocument.h
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDTDocument : UIDocument

#pragma mark Properties 

//The general file manange ment properties
@property (nonatomic,strong)  NSString *path;
@property (nonatomic,strong) NSString *docsDir;

//These properties are only used in the MasterVC
@property (nonatomic,strong) NSMutableArray *textFiles;
@property (nonatomic,strong) NSMutableArray *textFilesPaths;

//These properties are used in the DetailVC.
@property (nonatomic) NSMutableArray *rangesOfHighlight;
@property (strong,nonatomic) NSString * userText;



#pragma mark Public methods

//These methods are used in the MasterVC
-(NSArray *) readFolder;

-(NSString *) createFile:(NSString *)text:(NSString *)name:(NSUInteger)indexPath;

-(NSString *) deleteFile:(NSString *)name:(NSUInteger)indexPath;



//Alpha String matching returns a Mutable array full of the ranges of matched strings.
-(NSMutableArray *) stringMatch:(NSString *)string;


@end