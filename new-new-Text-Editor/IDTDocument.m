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
    NSLog(@"THe val of contents is %@",contents);
    if ([contents length] > 0) 
        self.userText = [[NSString alloc] initWithBytes:[contents bytes]
                                                    length:[contents length]
                                                  encoding:NSUTF8StringEncoding];
        
     else
        self.userText = @"Empty"; // When the note is created we assign some default content
    
   
    //I am keeping this here in the off chance that I will implment NSNotification  functionnality.
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
        
    NSArray *textFiles = [filemgr contentsOfDirectoryAtPath:self.docsDir error:nil];
    for (NSUInteger iOne = 0; iOne < [textFiles count]; iOne++) {

         NSString *nameString = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:&error]objectAtIndex:iOne];
        [nameArray addObject:nameString];
        [self.nameArray addObject:nameString];
    
    }

       
    
    for (NSUInteger iTwo = 0; iTwo < [textFiles count]; iTwo++) {
        NSString *preVal = [[NSString alloc] initWithString:self.docsDir];
        NSString *val = [preVal stringByAppendingString:[textFiles objectAtIndex:iTwo]];
        [self.fileArray addObject:val];
        self.contactFileData = [[IDTFileData alloc]init];
        [self.contactFileData fileName:[nameArray objectAtIndex:iTwo] filePath:val];
               
        [self.fileData addObject:self.contactFileData];
        
 
        
    
    
    }
    [self.combinedArray addObject:self.nameArray];
    [self.combinedArray addObject:self.fileArray];
      //  NSLog(@"the data is %@ and %@",self.contactFileData.fileName,self.contactFileData.filePath);
    
    
    //If no files exists, create one.
    if (![filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]) {
        [self createFileWithText:@"Hello and welcome to my awesomely cool text editor! This is the list of stuff not yet implemented.  2. Syntax highlighting for HTML (uber difficult). 2.RTF implmentation (SUPER UBER difficult) " Name:@"Welcome!" AtIndex:0];
        
    }
    if (error)
        NSLog(@"there was an %@",error);

    return self.fileData;
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
    self.fileArray = [[NSMutableArray alloc]init];
    self.nameArray = [[NSMutableArray alloc]init];
    self.combinedArray = [[NSMutableArray alloc]init];
    self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    self.docsDir = [self.docsDir stringByAppendingString:@"/"];
    if (self.path == nil)
        self.path = [self.docsDir stringByAppendingString:@"text.txt"];
    
    
}

//None of the passed vars can be nil.
-(BOOL) createFileWithText:(NSString *)text Name:(NSString *)name AtIndex:(NSUInteger)indexPath {
    
    assert(text != nil && name != nil);
    //This block of code checks too see if the Name of the file already exists if it does it will abort the operation.
    NSMutableArray *names = [[NSMutableArray alloc]initWithCapacity:self.fileData.count];
    
    for (NSUInteger i = 0; i < [self.fileData count]; i++) {
        NSString *currentName = [[self.fileData objectAtIndex:i]fileName];
        
        [names addObject:currentName];
    }
    //Once the array has been built: We test it. If it returns true we abort.
    if ([names containsObject:name]) {
        //Abort.
        return NO;
    }
    //End abort block.
    
    BOOL returnValue;
    //This code actually creates the document.
     NSData *textData =  [text dataUsingEncoding:NSUTF8StringEncoding];
    self.path = [self.docsDir stringByAppendingPathComponent:name];
    NSURL *newFile = [[NSURL alloc]initFileURLWithPath:self.path];
    returnValue = [self writeContents:textData toURL:newFile forSaveOperation:UIDocumentSaveForCreating originalContentsURL:nil error:nil];
    
    
    
    if (returnValue) {
        
    

    //After creating the file insert them into our datasource for the table View.
    self.contactFileData = [[IDTFileData alloc]init];
        
    self.contactFileData.fileName = name;
        
    self.contactFileData.filePath = self.path;
        
    [self.fileData insertObject:self.contactFileData atIndex:indexPath];
    } else {
        //Abort.
        NSLog(@"The creation of the file failed.");
        returnValue = NO;
    }
        
    
   return returnValue;
}

//None of the passed vars can be nil.
-(BOOL) deleteFileWithName:(NSString *)name AtIndex:(NSUInteger)indexPath {
    
    
    self.path = [self.docsDir stringByAppendingPathComponent:name];
    NSError *error = nil;
    
    if([[NSFileManager defaultManager]removeItemAtPath:self.path error:&error]) {
        
    
   
    
       [self.fileData removeObjectAtIndex:indexPath];
       return TRUE;
    }
    else {
        return FALSE;
    }
    //Basic error functionality.
    if (error != nil)
        NSLog(@"%@",error);
    
    
    
    
    
}
-(BOOL)renameFileName:(NSString *)name withName:(NSString *)newFileName atIndexPath:(NSIndexPath *)indexPath {
    [self general];
    [self readFolder];
    self.path = [self.docsDir stringByAppendingPathComponent:name];
    NSString * newPath = [self.docsDir stringByAppendingPathComponent:newFileName];
    
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager]moveItemAtPath:self.path toPath:newPath error:&error])
        NSLog(@"succes");
    NSUInteger interger = indexPath.row;
  
    
    
    self.contactFileData = [[IDTFileData alloc]init];
    [self.contactFileData fileName:newFileName filePath:newPath];
   
    
    [self.fileData removeObjectAtIndex:interger];
    [self.fileData insertObject:self.contactFileData atIndex:interger];
    
    
    //Basic error functionality.
    
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }

    
    return YES;
}

-(BOOL)copyFileFromURL:(NSURL *)fromURL {
    
    NSError *error = Nil;
    NSString *toString = [fromURL absoluteString];
    NSString *nameOfFile = [toString lastPathComponent];
    NSString *string = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",nameOfFile];
    NSURL *toURL = [NSURL fileURLWithPath:string];
   BOOL success = [[NSFileManager defaultManager]copyItemAtURL:fromURL toURL:toURL error:&error];
       if (success) {
        NSLog(@"The value of my array is %d",[self.fileData count]);
        IDTFileData *fileData = [[IDTFileData alloc]init];
        [fileData fileName:nameOfFile filePath:string];
        [self.fileData insertObject:fileData atIndex:0];
    }
    
    NSError *deletionError = nil;
    
    
    NSString *finalString = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",@"Inbox"];
    NSURL *deleteURL = [NSURL fileURLWithPath:finalString];
    
    
    BOOL deleteSuccess = [[NSFileManager defaultManager]removeItemAtURL:deleteURL error:&deletionError];
    
    if (deleteSuccess) {
        NSLog(@"YAYAY");
        [self readFolder];
        
    }

    
       if (error ) {
        NSLog(@"error %@",error);
    }
    
    
    
    return success;
}







@end
