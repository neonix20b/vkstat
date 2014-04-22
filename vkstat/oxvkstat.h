//
//  oxvkstat.h
//  vkstat
//
//  Created by Maks on 24.03.14.
//  Copyright (c) 2014 Maks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKSdk.h" 

@interface oxvkstat : NSObject
{
    NSString *user_id;
}
@property NSDate *last_udate;
@property NSString *first_name;
@property NSString *last_name;
@property NSString *photo;
@property NSMutableArray *worlds;
@property NSInteger word_count;
@property NSInteger uniq_1000;

@property NSMutableArray *friend_array;
@property NSMutableArray *wall_msg;
@property UITableView *tableDB;
// NSMutableArray *worlds=[[NSMutableArray alloc] init];

-(id)init;
-(id)initWithUserId:(NSString*)user;
-(void)friends_list;
-(void)wall;
-(void)analize_wall;
-(NSString*)getIQ;
@end
