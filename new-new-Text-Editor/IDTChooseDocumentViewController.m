//
//  IDTChooseDocumentViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 5/24/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTChooseDocumentViewController.h"
@interface IDTChooseDocumentViewController ()

@end

@implementation IDTChooseDocumentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.model = [[IDTModel alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.model) {
        self.model = [[IDTModel alloc]init];
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"chooseCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.model.documents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"chooseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IDTDocument *document = [self.model.documents objectAtIndex:indexPath.row];
    cell.textLabel.text = document.name;
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.document = [self.model.documents objectAtIndex:indexPath.row];
    [self.delegate didTap];
    
}

@end
