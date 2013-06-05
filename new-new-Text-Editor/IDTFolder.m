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
-(IDTFolder *)initWithName:(NSString *)name andURL:(NSURL *)url {
    self = [super init];
    self.name = name;
    self.folderURL = url;
    [self readFolder];
    return self;
}


- (NSMutableArray *)readFolder {
    if (self.documents == nil) {
        self.documents = [[NSMutableArray alloc]initWithCapacity:50];
    }
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSArray *textFiles = [filemgr contentsOfDirectoryAtPath:[self.folderURL path] error:&error];
    
    for (NSUInteger i = 0; i < [textFiles count]; i++) {
        NSString *preval = [docsDir stringByAppendingString:@"/"];
        NSString *val = [preval stringByAppendingString:[textFiles objectAtIndex:i]];
        
        IDTDocument *document = [[IDTDocument alloc]initWithFileURL:[NSURL fileURLWithPath:val]];
        [self.documents addObject:document];
    }
    
    if (error) NSLog(@"there was an %@", error);
    
    return self.documents;
}

@end
