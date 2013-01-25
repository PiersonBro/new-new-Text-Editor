//
//  IDTDocument.h
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDTFileData.h"
@interface IDTDocument : UIDocument

#pragma mark Properties 

//The general file manange ment properties
@property (nonatomic,strong)  NSString *path;
@property (nonatomic,strong) NSString *docsDir;

//These properties are only used in the MasterVC

//This is the dataSource for the tableView
@property (strong, nonatomic) NSMutableArray *fileData;
//FIXME This should be a private property 
@property (strong, nonatomic) IDTFileData *contactFileData;


//These properties are used in the DetailVC.
@property (nonatomic) NSMutableArray *rangesOfHighlight;
@property (strong,nonatomic) NSString * userText;



#pragma mark Public methods

//These methods are used in the MasterVC
-(NSArray *) readFolder;

-(BOOL) createFile:(NSString *)text:(NSString *)name:(NSUInteger)indexPath;

-(BOOL) deleteFile:(NSString *)name:(NSUInteger)indexPath;



//Alpha String matching returns a Mutable array full of the ranges of matched strings.
-(NSMutableArray *) stringMatchInString:(NSString *)inString  WithRegularExpr:(NSString *)regex;

-(BOOL)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath;

@end
