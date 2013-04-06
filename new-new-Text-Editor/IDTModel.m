//
//  IDTModel.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 4/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTModel.h"
@interface IDTModel ()
@end

@implementation IDTModel
-(id)init {
    self = [super init];
    self.combinedArray = [[NSMutableArray alloc]initWithCapacity:100];
    self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];

    [self readFolder];
    return self;
}

- (NSArray *)readFolder {
    self.combinedArray = [[NSMutableArray alloc]initWithCapacity:2];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSArray *textFiles = [filemgr contentsOfDirectoryAtPath:self.docsDir error:&error];
    for (NSUInteger i = 0; i < [textFiles count]; i++) {
        NSString *string = [textFiles objectAtIndex:i];
        NSLog(@"what is the val of textFiles %@?",string);
        NSString *preval = [self.docsDir stringByAppendingString:@"/"];
        NSString *val = [preval stringByAppendingString:[textFiles objectAtIndex:i]];
        
        IDTDocument *document = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:val]];
        [self.combinedArray addObject:document];
    }
    
    //If no files exists, create one.
    if (![filemgr contentsOfDirectoryAtPath:self.docsDir error:nil]) {
        [self createFileWithText:@"Hello and welcome to my awesomely cool text editor! This is the list of stuff not yet implemented.  2. Syntax highlighting for HTML (uber difficult). 2.RTF implmentation (SUPER UBER difficult) " Name:@"Welcome!" AtIndex:0 isGist:NO];
    }
    if (error) NSLog(@"there was an %@", error);
    
    return self.combinedArray;
}
//None of the passed vars can be nil.
- (BOOL)createFileWithText:(NSString *)text Name:(NSString *)name AtIndex:(NSUInteger)indexPath isGist:(BOOL)isGist {
    assert(text != nil && name != nil);
    //This block of code checks too see if the Name of the file already exists if it does it will abort the operation. This feature is disabled during the rewrite...
    for (IDTDocument *document in self.combinedArray) {
        if ([document.name isEqualToString:name]) {
            return NO;
        }
    }
    BOOL returnValue;
    //This code actually creates the document.
    NSData *textData =  [text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *path = [self.docsDir stringByAppendingPathComponent:name];
    NSURL *newFile = [[NSURL alloc]initFileURLWithPath:path];
    NSError *error = nil;
    NSString *string = [NSHomeDirectory() stringByAppendingString:@"Documents/new.txt"];
    self.contactDocument = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:string]];
    returnValue = [self.contactDocument writeContents:textData toURL:newFile forSaveOperation:UIDocumentSaveForCreating originalContentsURL:nil error:&error];
    
    if (returnValue) {
       if (isGist) {
           self.githubEngine = [[UAGithubEngine alloc]initWithUsername:@"PiersonBro" password:@"[self 1github];" withReachability:NO];
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
    [self.combinedArray insertObject:document atIndex:indexPath];
    
    } else {
        //Abort.
        NSLog(@"The creation of the file failed.");
        returnValue = NO;
    }
    
    
    return returnValue;
}

//None of the passed vars can be nil.
- (BOOL)deleteFile:(NSString *)name AtIndex:(NSUInteger)index {
    NSString *path = [self.docsDir stringByAppendingPathComponent:name];
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager]removeItemAtPath:path error:&error]) {
        IDTDocument *document = [self.combinedArray objectAtIndex:index];
        if (document.isGist) {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, ^{
            
            [self.githubEngine deleteGist:document.gistID success:^(BOOL sucess) {
                NSLog(@"INCREIDBLE");
            } failure:^(NSError *error) {
                NSLog(@"ERRROR is %@",error);
            }];
        });
        }
        [self.combinedArray removeObjectAtIndex:index];

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
        NSLog(@"succes");
        self.combinedArray = nil;
        [self readFolder];
        
        
        
        } else if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)copyFileFromURL:(NSURL *)fromURL {
    NSError *error = Nil;
    NSString *toString = [fromURL absoluteString];
    NSString *nameOfFile = [toString lastPathComponent];
    NSString *pathString = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", nameOfFile];
    NSURL *toURL = [NSURL fileURLWithPath:pathString];
    BOOL success = [[NSFileManager defaultManager]copyItemAtURL:fromURL toURL:toURL error:&error];
    if (success) {
        [self readFolder];
    }
    NSError *deletionError = nil;
    NSString *finalString = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", @"Inbox"];
    NSURL *deleteURL = [NSURL fileURLWithPath:finalString];
    
    
    BOOL deleteSuccess = [[NSFileManager defaultManager]removeItemAtURL:deleteURL error:&deletionError];
    
    if (deleteSuccess) {
        NSLog(@"YAYAY");
        
        [self readFolder];
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
    [self.githubEngine gistsForUser:@"PiersonBro" success:^(id result) {
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








@end
