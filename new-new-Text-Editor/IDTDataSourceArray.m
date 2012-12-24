//
//  IDTDataSourceArray.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 12/17/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTDataSourceArray.h"

@implementation IDTDataSourceArray

+(id)arrayWithString:(NSString *)name url:(NSString *)url {
    
    IDTDataSourceArray *newArray = [[self alloc]init];
    [newArray setName:name];
    [newArray setUrlForName:url];
    
    
    return newArray;
}

@end
