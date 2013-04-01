//
//  IDTHoardViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 1/27/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTHoardViewController.h"
#import "IDTDocument.h"
#import "IDTCollectionCell.h"
#import "IDTDetailViewController.h"
@interface IDTHoardViewController () {
    NSIndexPath *_path;
    NSArray *names;
    NSArray *paths;
}
@property (nonatomic,strong) IDTDocument *contactModel;
@end

@implementation IDTHoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    docsDir = [docsDir stringByAppendingString:@"/"];
    NSString *path = [docsDir stringByAppendingString:@"new.txt"];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    self.contactModel = [[IDTDocument alloc]initWithFileURL:url];
    self.collectionView.dataSource = self;
    names = [self.contactModel.combinedArray objectAtIndex:0];
    paths = [self.contactModel.combinedArray objectAtIndex:1];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [names count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IDTCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    cell.textView.userInteractionEnabled = NO;
        cell.textView.text = [names objectAtIndex:indexPath.row];

    return cell;
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToTextView"]) {
    
       IDTDetailViewController *contactDetailVC = [segue destinationViewController];
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems]lastObject];
        NSString *object = [paths objectAtIndex:indexPath.row];
        
        [[segue destinationViewController]setDetailItem:object];
        contactDetailVC.nameOfFile = [names objectAtIndex:indexPath.row];

    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

@end
