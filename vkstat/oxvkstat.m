//
//  oxvkstat.m
//  vkstat
//
//  Created by Maks on 24.03.14.
//  Copyright (c) 2014 Maks. All rights reserved.
//

#import "oxvkstat.h"

@implementation oxvkstat
@synthesize first_name, friend_array, wall_msg, photo, last_name, worlds, last_udate, word_count, uniq_1000, tableDB;

//--------------------------------------------------------------------------------------------------------------------------------
//    получение списка друзей

-(void)friends_list
{
    VKRequest * getFriends = [VKRequest requestWithMethod:@"friends.get" andParameters:@{@"uid" :user_id, @"fields" :@"uid,photo_medium",@"order" :@"hints" } andHttpMethod:@"GET"];
    [getFriends executeWithResultBlock:^(VKResponse * response)
     {
         NSDictionary *responceList = response.json;
         friend_array = [NSMutableArray array];
         friend_array=[responceList objectForKey:@"items"];
         NSLog(@"friend count: %@", response.json);
     }
     errorBlock:^(NSError * error) {
         if (error.code != VK_API_ERROR) {
             [error.vkError.request repeat];
         }
         else {
             NSLog(@"VK error: %@", error);
         }
     }];
    
}
//-----------------------------------------------------------------------------------------------------------------------------
// получение стены

-(void)wall{
    int a=abs([last_udate timeIntervalSinceNow]);
    if(a<60*60*23)return;
    last_udate =  [[NSDate date] dateByAddingTimeInterval:-60*60*24];
    VKRequest * getFriends = [VKRequest requestWithMethod:@"wall.get" andParameters:@{ @"owner_id" : user_id,@"count" : @"200", @"filter" : @"owner"} andHttpMethod:@"GET"];
    [getFriends executeWithResultBlock:^(VKResponse * response) {
        
        last_udate = [NSDate date];
        NSDictionary *responceList = response.json;
        NSMutableArray *Items = [NSMutableArray array];
        wall_msg = [NSMutableArray array];
        Items=[responceList objectForKey:@"items"];
        
        for(NSInteger i=0;i<[Items count];i++){
            NSDictionary *dict=[Items objectAtIndex:i];
            NSString *text=[dict objectForKey:@"text"];
            
            if(![text isEqual:@""]){
                [wall_msg addObject:text];
            }
            
            //[_label setText:text];
            
        }
        //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        [NSThread sleepForTimeInterval:0.5];
        [self getPrivateMessages];
        //[self analize_wall];
        // tableData = wall;
        NSLog(@"%@", response.json);
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
        
    }];
}
-(void)getPrivateMessages{
    VKRequest * getFriends = [VKRequest requestWithMethod:@"messages.getHistory" andParameters:@{ @"uid" : user_id,@"count" : @"200"} andHttpMethod:@"GET"];
    [getFriends executeWithResultBlock:^(VKResponse * response) {
        NSDictionary *responceList = response.json;
        NSMutableArray *Items = [NSMutableArray array];
        //wall_msg = [NSMutableArray array];
        Items=[responceList objectForKey:@"items"];
        
        for(NSInteger i=0;i<[Items count];i++){
            NSDictionary *dict=[Items objectAtIndex:i];
            NSString *text=[dict objectForKey:@"body"];
            
            if(![text isEqual:@""]){
                [wall_msg addObject:text];
            }
            
            //[_label setText:text];
            
        }
        [self analize_wall];
        // tableData = wall;
        NSLog(@"%@", response.json);
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
        
    }];
}
//-----------------------------------------------------------------------------------------------------------------------------
// анализ стены

-(void)analize_wall{
    NSString * messages = [[wall_msg componentsJoinedByString:@" "] lowercaseString];
        NSCharacterSet *charactersToRemove =
        [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        
        messages = [ [messages componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@" " ];
       NSMutableArray *worlds_in = [[messages componentsSeparatedByString:@" "] mutableCopy];
    
    [worlds removeAllObjects];
    for(NSInteger i=0;i<[worlds_in count]; i++)
    {
        NSString *tmp =[worlds_in objectAtIndex:i];
        if(tmp.length>3)
        {
            [worlds addObject: tmp];
        }
    }
    word_count=[worlds count];
    [self calc_iq:[worlds mutableCopy]];
   worlds = [worlds valueForKeyPath:@"@distinctUnionOfObjects.self"]; // оставляет в массиве только уникальные слова
    
    NSMutableArray *topWorlds = [[NSMutableArray alloc] init]; // часто встречаемые слова
    NSString *filepath = [[NSBundle mainBundle] pathForResource: @"worldsblack" ofType:@"txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    
    //NSString *thePath = [[NSBundle mainBundle] pathForResource:@"worlds_black" ofType:@"txt"];
    NSArray *black_world = [fileContents componentsSeparatedByString:@"; "];
    for(NSInteger i=0;i<[worlds count]; i++)
    {
        NSString *tmp =[worlds objectAtIndex:i];
       
        if (![black_world containsObject:tmp]) {
            NSInteger numberOfOccurrences = [[messages componentsSeparatedByString:tmp] count] - 1;
            NSDictionary *w=[[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithInteger:numberOfOccurrences],@"count",
                             tmp, @"world",
                             nil];
            
            
            [topWorlds addObject:w];
        }
        
    }
    
    NSSortDescriptor * sorter = [[NSSortDescriptor alloc] initWithKey: @"count" ascending: NO];
    
    NSArray * descriptors = [NSArray arrayWithObjects: sorter, nil];
    topWorlds = [[topWorlds sortedArrayUsingDescriptors: descriptors] mutableCopy];
    worlds=topWorlds;
    if(tableDB) [tableDB reloadData];
}
//-------------------------------------------------------------------------------------------------------------------------------
-(void)calc_iq:(NSMutableArray*)words1000{
    if([words1000 count]<1000){
        uniq_1000=0;
        return;
    }
    NSRange a;
    a.location=1000;
    a.length=[words1000 count]-1000;
    [words1000 removeObjectsInRange:a];
    words1000 = [words1000 valueForKeyPath:@"@distinctUnionOfObjects.self"];
    uniq_1000=[words1000 count];
}
-(NSString*)getIQ{
    NSString *ret=@"";
    if(uniq_1000==0)
        ret=@"Мало данных";
    else{
        ret=[NSString stringWithFormat:@"%ld", (long)uniq_1000];
    }
    return ret;
}
//---------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if(self){
        user_id=@"";
        last_udate =  [[NSDate date] dateByAddingTimeInterval:-60*60*24];
         worlds=[[NSMutableArray alloc] init];
        //инициализация вашего класса
    }
    return self;
}
-(id)initWithUserId:(NSString*)user{
    self = [super init];
    if(self){
        user_id=user;
         worlds=[[NSMutableArray alloc] init];
        last_udate =  [[NSDate date] dateByAddingTimeInterval:-60*60*24];
        //инициализация вашего класса
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self->first_name forKey:@"first_name"];
    [aCoder encodeObject:self->last_name forKey:@"last_name"];
    [aCoder encodeObject:self->photo forKey:@"photo"];
    [aCoder encodeObject:self->worlds forKey:@"worlds"];
    [aCoder encodeObject:self->friend_array forKey:@"friend_array"];
    [aCoder encodeObject:self->wall_msg forKey:@"wall_msg"];
    [aCoder encodeObject:self->user_id forKey:@"user_id"];
    [aCoder encodeObject:self->last_udate forKey:@"last_udate"];
    [aCoder encodeInteger:self->word_count forKey:@"word_count"];
    [aCoder encodeInteger:self->uniq_1000 forKey:@"uniq_1000"];

    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
       
        
        self->first_name=[aDecoder decodeObjectForKey:@"first_name"];
        self->last_name=[aDecoder decodeObjectForKey:@"last_name"];
        self->photo=[aDecoder decodeObjectForKey:@"photo"];
        self->worlds=[aDecoder decodeObjectForKey:@"worlds"];
        self->friend_array=[aDecoder decodeObjectForKey:@"friend_array"];
        self->wall_msg=[aDecoder decodeObjectForKey:@"wall_msg"];
        self->user_id=[aDecoder decodeObjectForKey:@"user_id"];
        self->last_udate=[aDecoder decodeObjectForKey:@"last_udate"];
        self->word_count=[aDecoder decodeIntegerForKey:@"word_count"];
        self->uniq_1000=[aDecoder decodeIntegerForKey:@"uniq_1000"];

        }
    return self;
}








@end


