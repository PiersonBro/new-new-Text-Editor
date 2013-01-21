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
    NSMutableArray *nameArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSError *error = nil;
        
    
        self.textFiles = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]mutableCopy];
    for (int iOne = 0; iOne < [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]count]; iOne++) {

         NSString *nameString = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:&error]objectAtIndex:iOne];
        [nameArray addObject:nameString];
    
    }

       
    
    self.textFilesPaths = [[NSMutableArray alloc]init];
    for (int iTwo = 0; iTwo<[self.textFiles count]; iTwo++) {
        NSString *preVal = [[NSString alloc] initWithString:self.docsDir];
        NSString *val = [preVal stringByAppendingString:[self.textFiles objectAtIndex:iTwo]];
        self.contactFileData = [[IDTFileData alloc]init];
        [self.contactFileData fileName:[nameArray objectAtIndex:iTwo] filePath:val];
               
        [self.fileData addObject:self.contactFileData];
        [self.textFilesPaths addObject:val];
        
 
        
    
    
    }
      //  NSLog(@"the data is %@ and %@",self.contactFileData.fileName,self.contactFileData.filePath);

    
    //Error Handling.
    if (![filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]) {
        [self createFile:@"Hello and welcome to my awesomely cool text editor! This is the list of stuff not yet implemented.  2. Syntax highlighting for HTML (uber difficult). 2.RTF implmentation (SUPER UBER difficult) " :@"Welcome!" :0];
        self.textFiles = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]mutableCopy];
        
    }
    if (error)
        NSLog(@"there was an %@",error);

    return self.textFiles;
}



#pragma mark Basic String match.

-(NSMutableArray *) stringMatchInString:(NSString *)inString WithRegularExpr:(NSString *)regex{
       NSError *error = nil; 
    
        NSRegularExpression *squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:regex
 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionSearch error:&error];
    
        
    
    self.rangesOfHighlight = [[NSMutableArray alloc]initWithCapacity:50];
        //FIXME: If string is nil it will throw an exception
       [squeezeNewlines enumerateMatchesInString:inString options:0 range:[inString rangeOfString:inString] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                          
               
          NSRange textMatchRange = [result rangeAtIndex:0];
          [self.rangesOfHighlight addObject:[NSValue valueWithRange:textMatchRange]];
           
      }];
  
    

      return self.rangesOfHighlight;
      
}




#pragma General File Management
//sets up self.docsDir and self.path

-(void) general {
    self.fileData = [[NSMutableArray alloc]init];
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
    self.fileData = [[NSMutableArray alloc]init];
    
    self.fileData = nil;
    [self readFolder];
    self.contactFileData = [[IDTFileData alloc]init];
    
    [self.contactFileData fileName:name filePath:self.path];
    
    [self.fileData insertObject:self.contactFileData atIndex:indexPath];
    
    return self.path;
    
}

//None of the passed vars can be nil.
-(NSString *) deleteFile:(NSString *)name:(NSUInteger)indexPath {
    
    
    self.path = [self.docsDir stringByAppendingPathComponent:name];
    NSError *error;
    [[NSFileManager defaultManager]removeItemAtPath:self.path error:&error];
    [self.textFiles removeObjectAtIndex:indexPath];
    [self.textFilesPaths removeObjectAtIndex:indexPath];
    
    [self.fileData removeObjectAtIndex:indexPath];
    
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
    
    
    self.contactFileData = [[IDTFileData alloc]init];
    [self.contactFileData fileName:newFileName filePath:newPath];
   
    
    [self.fileData removeObjectAtIndex:interger];
    [self.fileData insertObject:self.contactFileData atIndex:interger];
    
    
    //Basic error functionality.
    
    if (error)
        NSLog(@"%@",error);
    

    
    return self.path;
}


@end
