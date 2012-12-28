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
// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    
    if ([contents length] > 0) {
        self.userText = [[NSString alloc] initWithBytes:[contents bytes]
                                                    length:[contents length]
                                                  encoding:NSUTF8StringEncoding];
        
    } else {
        self.userText = @"Empty"; // When the note is created we assign some default content
    }
    
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
    
    return [NSData dataWithBytes:[self.userText UTF8String]
                          length:[self.userText length]];
    
}

#pragma mark Model methods for Master VC

//Read the Documents directory of the app and create a new mutableArray that holds the paths to files. also populates the array for the tableView
//The procces of reading the documents directory is broken up into two parts: 1. The array that the tableView uses to display the names and the paths of those files.
-(NSArray *) readFolder {

    [self general];
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr contentsOfDirectoryAtPath:self.docsDir error:nil])
        
    {
        self.textFiles = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]mutableCopy];

    }
    else { [self createFile:@"Hello and welcome to my awesomely cool text editor! This is the list of stuff not yet implemented. 1. Markdwon renderer. 2. Syntax highlighting for HTML (uber difficult). 2.RTF implmentation (SUPER UBER difficult) " :@"Welcom" :0];
        self.textFiles = [[filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]mutableCopy];
    }
    
   
    
    self.textFilesPaths = [[NSMutableArray alloc]init];
    for (int i = 0; i<[self.textFiles count]; i++) {
        NSString *preVal = [[NSString alloc] initWithString:self.docsDir];
        NSString *val = [preVal stringByAppendingString:[self.textFiles objectAtIndex:i]];
        
        [self.textFilesPaths addObject:val];
        [self.textFilesPaths removeObject:0];
        
        
    }
    
    
    
    return self.textFiles;
}






#pragma mark Model methods for Detail VC

-(NSMutableArray *) stringMatch:(NSString *)string {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HTMLNames" ofType:@"plist"];
    NSArray *namesToHighlight = [[NSArray alloc]initWithContentsOfFile:path];
    self.rangesOfHighlight = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [namesToHighlight count]; i++) {
        NSRegularExpression *squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:[namesToHighlight objectAtIndex:i] options:0 error:nil];
        if (string == nil) {
            return nil;
        }
        else {
        NSArray *matches = [squeezeNewlines matchesInString:string options:0 range:[string rangeOfString:string]];
        
        
        for (NSTextCheckingResult *textMatch in matches) {
            
            NSRange textMatchRange = [textMatch rangeAtIndex:0];
            [self.rangesOfHighlight addObject:[NSValue valueWithRange:textMatchRange]];
            NSLog(@"The rangeArray is %@",self.rangesOfHighlight);
            
            
        }
    }
    return self.rangesOfHighlight;


    }
    return self.rangesOfHighlight;
}
#pragma View Controller agnostic methods
//sets up self.docsDir and self.path

-(void) general {
    self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    self.docsDir = [self.docsDir stringByAppendingString:@"/"];
    if (self.path == nil) {
        self.path = [self.docsDir stringByAppendingString:@"text.txt"];
    }
    
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
    [[NSFileManager defaultManager]removeItemAtPath:self.path error:nil];
    [self.textFiles removeObjectAtIndex:indexPath];
    [self.textFilesPaths removeObjectAtIndex:indexPath];
    return self.path;
    
    
}


- (NSString *)flattenHTML:(NSString *)html {
    
    NSString *text = nil;
    
    NSScanner *thescanner = [NSScanner scannerWithString:html];
    
    while ([thescanner isAtEnd] == false) {
        
        // find start of tag
        [thescanner scanUpToString:@"<" intoString:nil];
        
        // find end of tag
        [thescanner scanUpToString:@">" intoString:nil];
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", text] withString:@" "];
                    
    } // while //
    
    return html;
    
}



@end
