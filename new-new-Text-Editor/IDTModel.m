//
// IDTModel.m
// new-new-Text-Editor
//
// Created by E&Z Pierson on 4/2/13.
// Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTModel.h"
@interface IDTModel ()
@property (nonatomic, strong) NSString *docsDir;
@property (nonatomic,strong) IDTDocument *contactDocument;

@property (nonatomic,strong) UAGithubEngine *githubEngine;


@end

@implementation IDTModel
-(instancetype)initWithFilePath:(NSString *)filePath {
  self = [super init];
  self.documents = [[NSMutableArray alloc]initWithCapacity:100];
  self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:filePath];

  [self readFolder];
  return self;
}

- (NSMutableArray *)readFolder {
  if (self.documents == nil) {
  self.documents = [[NSMutableArray alloc]initWithCapacity:50];
  }
 
  NSFileManager *filemgr = [NSFileManager defaultManager];
 
  NSError *error = nil;
 
  NSArray *textFiles = [filemgr contentsOfDirectoryAtPath:self.docsDir error:&error];
  for (NSUInteger i = 0; i < [textFiles count]; i++) {
  NSString *preval = [self.docsDir stringByAppendingString:@"/"];
  NSString *filePath = [preval stringByAppendingString:[textFiles objectAtIndex:i]];
  BOOL isDirectory = nil;
  [filemgr fileExistsAtPath:filePath isDirectory:&isDirectory];
  if (isDirectory) {
  IDTFolder *folder = [[IDTFolder alloc]initWithFilePath:filePath];
  [self.documents addObject:folder];

  } else {
  IDTDocument *document = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:filePath]];
  [self.documents addObject:document];
  }
  }
  //If no files exists, create one.
  if (![filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]) {
  [self createFileWithText:@"Hello and welcome to my awesomely cool text editor! This is the list of stuff not yet implemented. 2. Syntax highlighting for HTML (uber difficult). 2.Github Repo implmentation (SUPER UBER difficult) " Name:@"Welcome!" AtIndex:0 isGist:NO];
  }
  if (error) NSLog(@"there was an %@", error);
 
  return self.documents;
}
//None of the method arguments can be nil.
- (BOOL)createFileWithText:(NSString *)text Name:(NSString *)name AtIndex:(NSUInteger)indexPath isGist:(BOOL)isGist {
  assert(text != nil && name != nil);
  //Checks too see if the Name of the file already exists if it does it will abort the operation.
  for (IDTDocument *document in self.documents) {
  if ([document.name isEqualToString:name]) {
  return NO;
  }
  }
  BOOL returnValue;
  //This code actually creates the document.
  NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
  NSString *path = [self.docsDir stringByAppendingPathComponent:name];
  NSURL *newFile = [[NSURL alloc]initFileURLWithPath:path];
  NSError *error = nil;
  NSString *string = [NSHomeDirectory() stringByAppendingString:@"Documents/new.txt"];
  self.contactDocument = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:string]];
  returnValue = [self.contactDocument writeContents:textData toURL:newFile forSaveOperation:UIDocumentSaveForCreating originalContentsURL:nil error:&error];
 
  if (returnValue) {
  if (isGist) {
  NSLog(@"Aha!");
  // self.githubEngine = [UAGithubEngine sharedGithubEngine];
  self.githubEngine = [UAGithubEngine sharedGithubEngine];
  dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
  dispatch_async(queue, ^{
 
 
  [self.githubEngine createGist:[self createDictionaryRepresationOfFileWithContent:nil AndNameOfFile:name] success:^(id result) {
  NSLog(@"Success %@",result);
  NSDictionary *dictionary = [result objectAtIndex:0];
  NSString *gistID = [dictionary objectForKey:@"id"];
  NSLog(@"%@",gistID);
  } failure:^(NSError *error) {
  NSLog(@"CREATE failed with error %@", error);
  }];
  });
  }
  //After creating the file insert them into our datasource for the table View.
  IDTDocument *document = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:path]];
  [self.documents insertObject:document atIndex:indexPath];
 
  } else {
  //Abort.
  NSLog(@"The creation of the file failed.");
  returnValue = NO;
  }
 
 
  return returnValue;
}

//None of the method arguments can be nil.
- (BOOL)deleteFile:(NSString *)name AtIndex:(NSUInteger)index {
  NSString *path = [self.docsDir stringByAppendingPathComponent:name];
  NSError *error = nil;
 
  if ([[NSFileManager defaultManager]removeItemAtPath:path error:&error]) {
  IDTDocument *document = [self.documents objectAtIndex:index];
  if (document.isGist) {
  dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
  dispatch_async(queue, ^{
  self.githubEngine = [UAGithubEngine sharedGithubEngine];
  [self.githubEngine deleteGist:document.gistID success:^(BOOL sucess) {
 
  } failure:^(NSError *error) {
  NSLog(@"ERRROR is %@",error);
 
  }];
  });
  }
  [self.documents removeObjectAtIndex:index];

  return TRUE;
  } else {
  return FALSE;
  }
  //Basic error functionality.
  if (error != nil) NSLog(@"%@", error);
}
//FIXME: No gist rename ability.
- (BOOL)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath {
  NSString *path = [self.docsDir stringByAppendingPathComponent:name];
  NSString *newPath = [self.docsDir stringByAppendingPathComponent:newFileName];
 
  NSError *error = nil;
 
  if ([[NSFileManager defaultManager]moveItemAtPath:path toPath:newPath error:&error]) {
  NSURL *url = [NSURL fileURLWithPath:newPath];
  IDTDocument *document = [[IDTDocument alloc]initWithFileURL:url];
  [self.documents replaceObjectAtIndex:indexPath.row withObject:document];
  //Some gist rename attempt... FIXME: Understand this code.
  [document openWithCompletionHandler:^(BOOL success) {
  self.githubEngine = [UAGithubEngine sharedGithubEngine];
  [self.githubEngine editGist:newFileName withDictionary:[self createDictionaryRepresationOfFileWithContent:document.userText AndNameOfFile:newFileName] success:^(id result){
  NSLog(@"Rename succeded");
  //No Banner is needed here as telling the user that an editGist was successful is not a good UX.
  } failure:^(NSError * error) {
  NSLog(@"error is %@",error);
  }];
 
  }];
 
 
 
  } else if (error) {
  NSLog(@"%@", error);
  return NO;
  }
 
  return YES;
}
//This (sadly) isn't a copy mechanism it simply is a Model back-end for 'Open in'.
- (BOOL)copyFileFromURL:(NSURL *)fromURL {
  NSError *error = Nil;
  NSString *toString = [fromURL absoluteString];
  NSString *nameOfFile = [toString lastPathComponent];
  NSString *pathString = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", nameOfFile];
  NSURL *toURL = [NSURL fileURLWithPath:pathString];
  BOOL success = [[NSFileManager defaultManager]moveItemAtURL:fromURL toURL:toURL error:&error];
 
  if (success) {
  NSLog(@"Delete Success!");
 
  IDTDocument *document = [[IDTDocument alloc]initWithFileURL:toURL];

  [self.documents insertObject:document atIndex:0];
  NSLog(@"The count of self.documents is %d",self.documents.count);
  NSURL *url = [fromURL URLByDeletingLastPathComponent];
  NSLog(@"The count of self.documents is %d",self.documents.count);
  [[NSFileManager defaultManager]removeItemAtURL:url error:nil];

  }
 
 
  if (error) {
  NSLog(@"error %@", error);
  }
 
 
 
  return success;
}


- (NSDictionary *)createDictionaryRepresationOfFileWithContent:(NSString *)content AndNameOfFile:(NSString *)nameOfFile {
  if (content == nil) {
  content = @"This is the filler string you SHOULD NOT see this!";
  }
  NSDictionary *firstDictionary = @{ @"content": content };
  //The key here is the name of the file. The subdictionary is the content of the file.
  NSDictionary *secondDictionary = @{ nameOfFile: firstDictionary };
  NSDictionary *creationDictionary = @{ @"description": @"This is a gist that was created via an API!", @"public": @"true", @"files": secondDictionary };
 
 
  return creationDictionary;
}

- (NSArray *)getGists {
  __block NSArray *returnDict = [[NSArray alloc]init];
  self.githubEngine = [UAGithubEngine sharedGithubEngine];
  [self.githubEngine gistsForUser:self.githubEngine.username success:^(id result) {
  //No Banner is needed here as telling the user that an gistForUser was successful is not a good UX.
  returnDict = [NSArray arrayWithArray:result];
  } failure:^(NSError *error) {
  NSLog(@"The getGists method failed with error: %@", error);
  }];
 
  return returnDict;
}

- (NSString *)getGistIDFromName:(NSString *)name {
  NSArray *array = [self getGists];
  NSString *IDString = nil;
  for (NSDictionary *fileDictionary in array) {
  NSDictionary *dictionary = [fileDictionary valueForKey:@"files"];
 
  NSEnumerator *enumerator = [dictionary keyEnumerator];
  id value;
  NSString *valueKeyString = [[NSString alloc]init];
  while (value = [enumerator nextObject])
  valueKeyString = value;
  if ([name isEqualToString:valueKeyString]) {
  NSLog(@"SUCCESSSSSSSSSSSSSSSSSSSSSSSSSS");
  IDString = [fileDictionary objectForKey:@"id"];
  }
  }
 
 
  return IDString;
}



#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
  /*Hello future self! Cotent is filtered via the NSPredicate api and then those filterd arrays are set on two properties: self.textFilesFiltered and
  self.filteredTextFilesPaths
  */
  //MAJOR API CHANGE: self.documents is depercated in fact in won't work. self.documents is filtered directly. YEAH!!!! No more unnessscary duplication!
  NSUInteger count = [self.documents count];
  NSMutableArray *undocuments = [self.documents copy];
  self.documents = [[NSMutableArray alloc]initWithCapacity:count];
// it's called document but it's actually either a document or folder.
  for (id *document in undocuments) {
  if ([document.name rangeOfString:searchText].location != NSNotFound) {
  [self.documents addObject:document];
  }
  }
}









@end