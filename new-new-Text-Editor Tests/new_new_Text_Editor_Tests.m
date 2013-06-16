//
//  new_new_Text_Editor_Tests.m
//  new-new-Text-Editor Tests
//
//  Created by E&Z Pierson on 6/11/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IDTModel.h"
#import "IDTDocument.h"
#import "IDTFolder.h"
@interface new_new_Text_Editor_Tests : XCTestCase
@end

@implementation new_new_Text_Editor_Tests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDocsDir
{
    IDTModel *testModel = [[IDTModel alloc]initWithFilePath:@"Documents/"];
    IDTModel *normalModel = [[IDTModel alloc]initWithFilePath:@"Documents/"];
    XCTAssertEqualObjects(testModel.docsDir, normalModel.docsDir, @"Docs equalled dir unsecussefully");
    
}

-(void)testDocuments
{
    IDTModel *testModel = [[IDTModel alloc]initWithFilePath:@"/Documents"];
    IDTModel *normalModel = [[IDTModel alloc]initWithFilePath:@"Documents/"];
    for (NSUInteger i = 0; i < [testModel.documents count]; i++) {
        IDTDocument *testDocument = nil;
        IDTDocument *normalDocument = nil;
        if (![[normalModel.documents objectAtIndex:i] isKindOfClass:[IDTFolder class]] && ![[testModel.documents objectAtIndex:i] isKindOfClass:[IDTFolder class]]) {
            testDocument = [testModel.documents objectAtIndex:i];
            normalDocument = [normalModel.documents objectAtIndex:i];
            XCTAssertEqualObjects([testDocument.fileURL absoluteString], [normalDocument.fileURL absoluteString], @"Failure documents are not equal.");
        }
    }
}

@end
