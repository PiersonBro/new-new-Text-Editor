//
//  IDTDocument.h
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAGithubEngine.h"
@interface IDTDocument : UIDocument

#pragma mark Properties 
- (id)initWithFileURL:(NSURL *)url;

@property (nonatomic,strong) UAGithubEngine *githubEngine;

@property (strong,nonatomic) NSMutableArray *rangesOfHighlight;

@property (strong,nonatomic) NSString * userText;


@property (nonatomic) BOOL isGist;

@property (nonatomic,strong,readonly) NSString *name;

@property (nonatomic,strong) NSString *gistID;



#pragma mark Public methods

- (NSMutableArray *)stringMatchInString:(NSString *)inString WithRegularExpr:(NSString *)regex;





@end
