//
//  IDTFileData.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 1/17/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTFileData.h"

@implementation IDTFileData

-(id)fileName:(NSString *)fileName filePath:(NSString *)filePath {
    
    IDTFileData *newFileData = [super init];
    self.fileName = fileName;
    self.filePath = filePath;
    
    return newFileData;

}

@end
