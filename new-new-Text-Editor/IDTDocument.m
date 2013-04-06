//
//  IDTDocument.m
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTDocument.h"
@interface IDTDocument ()
@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, strong) NSMutableArray *nameArray;
@property (nonatomic,strong,readwrite) NSString *name;

@end

@implementation IDTDocument
#pragma mark Initalizer

- (id)initWithFileURL:(NSURL *)url {
    self = [super initWithFileURL:url];
    self.name = [url lastPathComponent];
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        self.githubEngine = [[UAGithubEngine alloc]initWithUsername:@"PiersonBro" password:@"[self 1github];" withReachability:NO];

        self.gistID = [self getGistIDFromName:self.name];
        if (self.gistID == Nil) {
           NSLog(@"Not a Gist");
            self.isGist = NO;
        }else {
          self.isGist = YES;
        }
    });
    return self;
}

#pragma mark UIDocument overrides
#pragma mark Model methods for Detail VC


// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
    if ([contents length] > 0)
        self.userText = [[NSString alloc] initWithBytes:[contents bytes]
                                                 length:[contents length]
                                               encoding:NSUTF8StringEncoding];

    else self.userText = @"Empty"; // When the note is created we assign some default content


    //I am keeping this here in the off chance that I will implment NSNotification  functionnality.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noteModified"
                                                        object:self];

    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    if ([self.userText length] == 0) {
        self.userText = @"Empty";
    }
    
    if (self.isGist) {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"self.GistID is %@",self.gistID);
        [self.githubEngine editGist:self.gistID withDictionary:[self createDictionaryRepresationOfFileWithContent:self.userText AndNameOfFile:self.name] success:^(id result) {
            NSLog(@"SUCCESS (in the edit gist place");
        } failure:^(NSError *error) {
            NSLog(@"Failure (in the edit gist place %@", error);
        } ];
    });
    }
    return [NSData dataWithBytes:[self.userText UTF8String]
                          length:[self.userText length]];
}

#pragma mark Basic String match.

- (NSMutableArray *)stringMatchInString:(NSString *)inString WithRegularExpr:(NSString *)regex {
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






#pragma mark Github



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
