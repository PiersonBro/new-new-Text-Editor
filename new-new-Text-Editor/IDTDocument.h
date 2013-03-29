//
//  IDTDocument.h
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAGithubEngine.h"
#import "IDTFileData.h"
@interface IDTDocument : UIDocument

#pragma mark Properties 
- (id)initWithFileURL:(NSURL *)url;
//The general file manange ment properties
@property (nonatomic,strong)  NSString *path;
@property (nonatomic,strong) NSString *docsDir;

//These properties are only used in the MasterVC

@property (nonatomic,strong) UAGithubEngine *githubEngine;


//These properties are used in the DetailVC.
@property (strong,nonatomic) NSMutableArray *rangesOfHighlight;
@property (strong,nonatomic) NSString * userText;

@property (nonatomic,strong) NSMutableArray *combinedArray;

#pragma mark Public methods

//These methods are used in the MasterVC
-(NSArray *) readFolder;


-(BOOL) deleteFile:(NSString *)name AtIndex:(NSUInteger)index;

-(BOOL) createFileWithText:(NSString *)text Name:(NSString *)name AtIndex:(NSUInteger)indexPath;

//Alpha String matching returns a Mutable array full of the ranges of matched strings.
-(NSMutableArray *) stringMatchInString:(NSString *)inString  WithRegularExpr:(NSString *)regex;

-(BOOL)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath;


-(BOOL)copyFileFromURL:(NSURL *)fromURL;


//hi this is a test. 


@end
