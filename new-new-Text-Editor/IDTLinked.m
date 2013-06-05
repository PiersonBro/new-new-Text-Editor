//
//  IDTLinked.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 5/26/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTLinked.h"

@implementation IDTLinked
//This method assumes that the all documents are closed!
-(IDTLinked *)initWithThrower:(IDTDocument *)throwerDocument andReciever:(IDTDocument *)recieverDocument andType:(IDTLinkedType)type {
    self = [super init];
    if (self) {
        self.linkedDocumentThrower = throwerDocument;
        self.linkedDocumentReciever = recieverDocument;
        self.linkedType = type;
    }
    return self;
}

-(void)inherit {
   __block NSString *fillerString = nil;
    NSError *regexError = nil;
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    [defualts synchronize];
    NSString *regexForLinkingString = [defualts objectForKey:@"regexForLinking"];
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:regexForLinkingString options:NSRegularExpressionCaseInsensitive|NSRegularExpressionSearch error:&regexError];
    [self.linkedDocumentReciever openWithCompletionHandler:^(BOOL success) {
    [self.linkedDocumentThrower openWithCompletionHandler:^(BOOL success) {
        [self.linkedDocumentReciever.userText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [regex enumerateMatchesInString:line options:0 range:NSMakeRange(0, [line length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (!fillerString) {
            fillerString = [self.linkedDocumentThrower.userText stringByAppendingString:line];
        }else {
            fillerString = [fillerString stringByAppendingString:line];
        }
        
      
        self.linkedDocumentThrower.userText = fillerString;
        [self.linkedDocumentThrower updateChangeCount:UIDocumentChangeDone];
    
        }];
}];
}];
}];
    NSLog(@"linkedDocumentReciever is %@",self.linkedDocumentReciever);
//[self.linkedDocumentReciever closeWithCompletionHandler:^(BOOL success) {
//}];
}

-(BOOL)add {
    //HAHAHAHAHAHAHAHAHAH
    return YES;
}

-(BOOL)relationship {
    //HAHAHAHAHAHAHAHAHAH
    return YES;
}


@end
