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


//This property recieves it's value from the detial view segue
@property (strong, nonatomic) NSString *stringForWebView;

- (IBAction)shareHTML:(id)sender;

@end
