//
//  NSString+NSStringCat.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 10/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "NSString+NSStringCat.h"

@implementation NSString (NSStringCat)
-(BOOL)containsString:(NSString *)aString{
    return [self rangeOfString:aString].location != NSNotFound;

}

@end
