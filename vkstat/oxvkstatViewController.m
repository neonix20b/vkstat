//
//  oxvkstatViewController.m
//  vkstat
//
//  Created by Maks on 17.03.14.
//  Copyright (c) 2014 Maks. All rights reserved.
//

#import "oxvkstatViewController.h"

@interface oxvkstatViewController ()

@end

@implementation oxvkstatViewController

@synthesize tableData;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Initialize table data
    
    [VKSdk initializeWithDelegate:self andAppId:@"4255517"];
    if([VKSdk wakeUpSession]){
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"userstat"];
        if(data==nil)
            tableData = [[NSMutableArray alloc]init];
        else{
            tableData = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
            for(int i=0;i<[tableData count];i++)
                [[tableData objectAtIndex:i] wall];
            [_tableDB reloadData];
        }
    }
    else{
        tableData = [[NSMutableArray alloc]init];
        [self authUser];
    }
    
    
}
//----------------------------------------------------------------------------------------------
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError{
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken{
    [VKSdk authorize:nil];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Ошибка доступа" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller{
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)vkSdkDidReceiveNewToken:(VKAccessToken *)newToken{
    // [self startWorking];
}
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
    
}
- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token{
    //[self startWorking];
}
//------------------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonLogin:(id)sender {
    [self authUser];
}

-(void)authUser
{
    // [_label setText:@"kk"];
    [VKSdk authorize:@[VK_PER_NOTIFY, VK_PER_STATUS, VK_PER_WALL, VK_PER_GROUPS, VK_PER_MESSAGES, VK_PER_AUDIO, VK_PER_NOHTTPS, VK_PER_OFFLINE] revokeAccess:YES forceOAuth:YES inApp:YES display:VK_DISPLAY_MOBILE];
    //[VKSdk authorize:@[VK_PER_NOTIFY, VK_PER_STATUS, VK_PER_WALL, VK_PER_GROUPS, VK_PER_MESSAGES, VK_PER_AUDIO, VK_PER_NOHTTPS, VK_PER_OFFLINE]];
    //[VKSdk authorize:scope revokeAccess:YES];
    //[VKSdk authorize:scope revokeAccess:YES forceOAuth:YES];
}

- (IBAction)buttonfio:(id)sender {
    
       //-----------------------------------------------------------------------------------------------------------------------
    // получить аудиозаписи
    
    // VKRequest * getFriends = [VKRequest requestWithMethod:@"audio.get" andParameters:@{@"count" : @"100"} andHttpMethod:@"GET"];
    // [getFriends executeWithResultBlock:^(VKResponse * response) {
    //   NSDictionary *responceList = response.json;
    
    // NSLog(@"friend count: %@", response.json);
    //} errorBlock:^(NSError * error) {
    //  if (error.code != VK_API_ERROR) {
    //    [error.vkError.request repeat];
    //  }
    // else {
    //NSLog(@"VK error: %@", error);
    //  }
    //}];
    //-----------------------------------------------------------------------------------------------------------------------
    //заполнить таблицу друзей
    [tableData removeAllObjects];
    oxvkstat * iam = [[oxvkstat alloc] initWithUserId:@""];
    [iam friends_list];
    while (!iam.friend_array) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    NSMutableArray *Items=iam.friend_array;
    [_tableDB reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,(unsigned long)NULL), ^(void) {
    for(NSInteger i=0;i<[Items count];i++){
        NSDictionary *dict=[Items objectAtIndex:i]; //хеш      id first_name last_name online photo
        NSString *uid=[dict objectForKey:@"id"];
        NSString *first_name=[dict objectForKey:@"first_name"];
        NSString *last_name=[dict objectForKey:@"last_name"];
        NSString *photo=[dict objectForKey:@"photo_medium"];
        
        oxvkstat * user = [[oxvkstat alloc] initWithUserId:uid];
        user.first_name=first_name;
        user.last_name=last_name;
        user.photo=photo;
        user.tableDB=_tableDB;
        
        [user wall];
        //[user friends_list];
        [tableData addObject:user];
        
        
        //[_label setText:text];
        //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [NSThread sleepForTimeInterval:1];
        [_tableDB reloadData];
    }
    });
    
    
    //------------------------------------------------------------------------------------------------------------------------
}


//-------при нажатии на поле таблицы
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    oxvkstat * tmp = [tableData
                      objectAtIndex:indexPath.row];
    [_user_image setImageWithURL:[NSURL URLWithString: tmp.photo]
                   placeholderImage:[UIImage imageNamed:@"placeholder.gif"]];
    
    [_all_word_count setText:[NSString stringWithFormat:@"%ld", (long)tmp.word_count]];
    [_uniq_word setText:[NSString stringWithFormat:@"%ld", (long)[tmp.worlds count]]];
    [_iq setText: [tmp getIQ]];
    
    
    
    [_label setText:[NSString stringWithFormat:@"%@ %@", tmp.first_name,tmp.last_name]];
    NSMutableArray *words= [[NSMutableArray alloc] init];
    for(int i=0; i<[tmp.worlds count] && i<10;i++){
        NSDictionary *one=[tmp.worlds objectAtIndex:i];
        
        [words addObject:[one objectForKey:@"world"] ];
    }
    [_TopWorldLabel setText:[NSString stringWithFormat:@"%@", [words componentsJoinedByString:@", " ]]];
    //[_TopWorldLabel setNumberOfLines:5];
    //[_TopWorldLabel sizeToFit];
    
    [self savestat];
}

//---------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier =
    @"SimpleTableItem";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:simpleTableIdentifier];
    }
    oxvkstat * tmp = [tableData
                      objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", tmp.first_name,tmp.last_name];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Слов: %ld",(long)[tmp.worlds count]];
    [cell.imageView setImageWithURL:[NSURL URLWithString: tmp.photo]
placeholderImage:[UIImage imageNamed:@"placeholder.gif"]];
    
    return cell;
}


-(void) savestat{
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tableData];
[defaults setObject:data forKey:@"userstat"];
[defaults synchronize];
}






@end
