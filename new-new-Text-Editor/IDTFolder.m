//
//  IDTFolder.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 5/6/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTFolder.h"
#import "IDTDocument.h"
@implementation IDTFolder
-(IDTFolder *)initWithFilePath:(NSString *)filePath {
    self = [super init];
    self.filePath = filePath;
    self.name = [self.filePath lastPathComponent];
    return self;
}


- (NSMutableArray *)readFolder {
    NSMutableArray *documents = [[NSMutableArray alloc]initWithCapacity:40];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSArray *textFiles = [filemgr contentsOfDirectoryAtPath:self.filePath error:&error];
    
    for (NSUInteger i = 0; i < [textFiles count]; i++) {
        NSString *preval = [docsDir stringByAppendingString:@"/"];
        NSString *val = [preval stringByAppendingString:[textFiles objectAtIndex:i]];
        
        IDTDocument *document = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:val]];
        [documents addObject:document];
    }
    
    if (error) NSLog(@"there was an %@", error);
    
    return documents;
}

@end
