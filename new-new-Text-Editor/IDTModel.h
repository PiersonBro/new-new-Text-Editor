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
#import "IDTFolder.h"

@interface IDTModel : NSObject

-(instancetype)initWithFilePath:(NSString *)filePath;

@property (nonatomic,strong) NSMutableArray *documents;

-(NSMutableArray *)readFolder;
//Returns YES if successful, otherwise NO.
-(BOOL) deleteFile:(NSString *)name AtIndex:(NSUInteger)index;
//Returns YES if successful, otherwise NO.
-(BOOL) createFileWithText:(NSString *)text Name:(NSString *)name AtIndex:(NSUInteger)indexPath isGist:(BOOL)isGist;
//Returns YES if successful, otherwise NO.
-(BOOL)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath;
//Returns YES if successful, otherwise NO.
-(BOOL)copyFileFromURL:(NSURL *)fromURL;

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;
//For testing ONLY!
@property (nonatomic, strong, readonly) NSString *docsDir;


@end
