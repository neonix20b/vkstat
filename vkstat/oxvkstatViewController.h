//
//  oxvkstatViewController.h
//  vkstat
//
//  Created by Maks on 17.03.14.
//  Copyright (c) 2014 Maks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKSdk.h" 
#import "oxvkstat.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface oxvkstatViewController : UIViewController <VKSdkDelegate, UITableViewDelegate, UITableViewDataSource>
@property NSMutableArray *tableData;

@property (weak, nonatomic) IBOutlet UITableView *tableDB;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *TopWorldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *user_image;
@property (weak, nonatomic) IBOutlet UILabel *all_word_count;
@property (weak, nonatomic) IBOutlet UILabel *uniq_word;
@property (weak, nonatomic) IBOutlet UILabel *iq;
- (IBAction)buttonLogin:(id)sender;
- (void)authUser;
- (IBAction)buttonfio:(id)sender;





@end
