//
//  IDTDataSourceArray.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 12/17/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTDataSourceArray : NSObject

@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * urlForName;
+(id)arrayWithString:(NSString *)name url:(NSString *)url;


@end
