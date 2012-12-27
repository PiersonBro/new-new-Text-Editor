//
//  IDTWebViewController.h
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 12/24/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDTWebViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webView;


//These properties are prototypey.
@property (strong, nonatomic) NSString *stringForWebView;
@property (strong, nonatomic) NSURL *URLForWebView;

@end
