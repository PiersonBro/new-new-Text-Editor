//
//  IDTFileData.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 1/17/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTFileData : NSObject
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;




-(id)fileName:(NSString *)fileName filePath:(NSString *)filePath;

@end
