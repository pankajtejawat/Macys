//
//  ViewController.m
//  Macys
//
//  Created by Pankaj on 10/19/15.
//  Copyright © 2015 Pankaj. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController () <UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *dictionaryTableView ;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar ;

@property (nonatomic, strong) NSArray *arrDict ;

@end

@implementation ViewController

- (void)setArrDict:(NSArray *)arrDict {
    _arrDict = arrDict ;
    
    [self.dictionaryTableView reloadData];
}

- (void)getAbbreviationData:(NSString *)data {
    if([[data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *urlStirng = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@", data];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
        jsonReponseSerializer.acceptableContentTypes = nil;
        manager.responseSerializer = jsonReponseSerializer;
        
        [manager GET:urlStirng parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if([responseObject isKindOfClass:[NSArray class]])
                self.arrDict = [responseObject lastObject][@"lfs"];
            else if([responseObject isKindOfClass:[NSDictionary class]])
                self.arrDict = responseObject[@"lfs"] ;
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alertController presentViewController:alertController animated:YES completion:nil];

            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self getAbbreviationData:searchBar.text];
}

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" "; //[NSString stringWithFormat:@"%d", section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrDict.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [self.arrDict[section][@"vars"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DictionaryTableViewCellIdentifier"];
    
    NSDictionary *dictionary = nil;
    if(indexPath.row)
        dictionary = self.arrDict[indexPath.section][@"vars"][indexPath.row - 1];
    else
        dictionary = self.arrDict[indexPath.section];
    
    NSString *formattedString = [NSString stringWithFormat:@"%@, Freq: %@, Since: %@", dictionary[@"lf"], dictionary[@"freq"], dictionary[@"since"]];
    cell.textLabel.text = formattedString ;
    return cell ;
}



@end
