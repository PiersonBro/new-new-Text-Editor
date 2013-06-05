//
//  IDTLinked.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 5/26/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDTDocument.h"
typedef enum IDTLinkedType{
    IDTLinkedTypeAdding,
    IDTLinkedTypeInheritance,
    IDTLinkedTypeRelationship,
}IDTLinkedType;


@interface IDTLinked : NSObject

@property (nonatomic,strong) IDTDocument *linkedDocumentThrower;

@property (nonatomic,strong) IDTDocument *linkedDocumentReciever;

@property (nonatomic) IDTLinkedType *linkedType;

-(IDTLinked *)initWithThrower:(IDTDocument *)throwerDocument andReciever:(IDTDocument *)recieverDocument andType:(IDTLinkedType)type;

-(BOOL)add;

-(void)inherit;

-(BOOL)relationship;

@end
