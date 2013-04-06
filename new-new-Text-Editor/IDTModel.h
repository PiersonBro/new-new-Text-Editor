//
//  IDTModel.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 4/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAGithubEngine.h"
#import "IDTDocument.h"

@interface IDTModel : NSObject

@property (nonatomic,strong) IDTDocument *contactDocument;

@property (nonatomic,strong) UAGithubEngine *githubEngine;

@property (nonatomic,strong) NSMutableArray *combinedArray;

@property (nonatomic, strong) NSString *docsDir;

-(NSArray *) readFolder;


-(BOOL) deleteFile:(NSString *)name AtIndex:(NSUInteger)index;

-(BOOL) createFileWithText:(NSString *)text Name:(NSString *)name AtIndex:(NSUInteger)indexPath isGist:(BOOL)isGist;

-(BOOL)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath;


-(BOOL)copyFileFromURL:(NSURL *)fromURL;

@end
