//
//  IDTDocument.m
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTDocument.h"
@implementation IDTDocument

#pragma mark UIDocument overrides 
#pragma mark Model methods for Detail VC


// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    
    if ([contents length] > 0) 
        self.userText = [[NSString alloc] initWithBytes:[contents bytes]
                                                    length:[contents length]
                                                  encoding:NSUTF8StringEncoding];
        
     else
        self.userText = @"Empty"; // When the note is created we assign some default content
    
   
    //I am keeping this here in the off chance that I will implment NSNotification functionnality.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noteModified"
                                                        object:self];
    
    return YES;
    
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    
    if ([self.userText length] == 0) {
        self.userText = @"Empty";
    }
    //Error handling
    

    return [NSData dataWithBytes:[self.userText UTF8String]
                          length:[self.userText length]];
    
}

#pragma mark Model methods for Master VC

//Read the Documents directory of the app and create a new mutableArray that holds the paths to files. also populates the array for the tableView
//The procces of reading the documents directory is broken up into two parts: 1. The array that the tableView uses to display the names and the paths of those files.
-(NSArray *) readFolder {

    [self general];
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *error;
    if ([filemgr contentsOfDirectoryAtPath:self.docsDir error:&error])
        
    
        self.textFiles = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]mutableCopy];
        

    
    else  [self createFile:@"Hello and welcome to my awesomely cool text editor! This is the list of stuff not yet implemented.  2. Syntax highlighting for HTML (uber difficult). 2.RTF implmentation (SUPER UBER difficult) " :@"Welcome!" :0];
        self.textFiles = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]mutableCopy];
    
    
    if (error)
        NSLog(@"there was an %@",error);
    
    
    self.textFilesPaths = [[NSMutableArray alloc]init];
    for (int i = 0; i<[self.textFiles count]; i++) {
        NSString *preVal = [[NSString alloc] initWithString:self.docsDir];
        NSString *val = [preVal stringByAppendingString:[self.textFiles objectAtIndex:i]];
        
        [self.textFilesPaths addObject:val];
                
        
    }
      
    
    
    
    return self.textFiles;
}



#pragma mark Basic String match.

-(NSMutableArray *) stringMatch:(NSString *)string {
       NSError *error = nil; 
    
        NSRegularExpression *squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:@"(?i)<(?![BIP]\\b ).*?/?>"
 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionSearch error:&error];
    
        
    
    self.rangesOfHighlight = [[NSMutableArray alloc]initWithCapacity:50];
        //FIXME: If string is nil it will throw an exception
       [squeezeNewlines enumerateMatchesInString:string options:0 range:[string rangeOfString:string] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                          
               
          NSRange textMatchRange = [result rangeAtIndex:0];
          [self.rangesOfHighlight addObject:[NSValue valueWithRange:textMatchRange]];
           
      }];
  
    

      return self.rangesOfHighlight;
      
}

-(NSMutableArray *)findText:(NSString *)text inText:(NSString*)inText {
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    
    NSError *error = nil;
    
    NSRegularExpression *findRangesWithReEx = [[NSRegularExpression alloc]initWithPattern:text options:0 error:&error];
    
    [findRangesWithReEx enumerateMatchesInString:inText options:0 range:NSMakeRange(0, inText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange textMatchRange = [result rangeAtIndex:0];
        [matches addObject:[NSValue valueWithRange:textMatchRange]];
    }];
    return matches;
}



#pragma General File Management
//sets up self.docsDir and self.path

-(void) general {
    self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    self.docsDir = [self.docsDir stringByAppendingString:@"/"];
    if (self.path == nil)
        self.path = [self.docsDir stringByAppendingString:@"text.txt"];
    
    
}

//None of the passed vars can be nil.
-(NSString *) createFile:(NSString *)text:(NSString *)name:(NSUInteger)indexPath {
  
    NSData *textData =  [text dataUsingEncoding:NSUTF8StringEncoding];
    self.path = [self.docsDir stringByAppendingPathComponent:name];

    [[NSFileManager defaultManager]createFileAtPath:self.path contents:textData attributes:nil];
    
    //After creating the file insert them into our arrays for the table View.
    [self.textFiles insertObject:name atIndex:indexPath];
    [self.textFilesPaths insertObject:self.path atIndex:indexPath];
    return self.path;
    
}

//None of the passed vars can be nil.
-(NSString *) deleteFile:(NSString *)name:(NSUInteger)indexPath {
    self.path = [self.docsDir stringByAppendingPathComponent:name];
    NSError *error;
    [[NSFileManager defaultManager]removeItemAtPath:self.path error:&error];
    [self.textFiles removeObjectAtIndex:indexPath];
    [self.textFilesPaths removeObjectAtIndex:indexPath];
    
    //Basic error functionality.
    
    if (error != nil)
        NSLog(@"%@",error);
    
    
    return self.path;
    
    
    
}
-(NSString *)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath {
    [self general];
    self.path = [self.docsDir stringByAppendingPathComponent:name];
    NSString * newPath = [self.docsDir stringByAppendingPathComponent:newFileName];
    
    NSError *error;
    
    if ([[NSFileManager defaultManager]moveItemAtPath:self.path toPath:newPath error:&error])
        NSLog(@"succes");
    NSUInteger interger = indexPath.row;
    [self.textFiles removeObjectAtIndex:interger];
    [self.textFilesPaths removeObjectAtIndex:interger];
    [self.textFiles insertObject:newFileName atIndex:interger];
    [self.textFilesPaths insertObject:newPath atIndex:interger];
    //Basic error functionality.
    
    if (error)
        NSLog(@"%@",error);
    

    
    return self.path;
}




@end
