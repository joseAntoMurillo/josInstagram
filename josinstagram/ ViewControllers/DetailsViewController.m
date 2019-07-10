//
//  DetailsViewController.m
//  josinstagram
//
//  Created by josemurillo on 7/9/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *postCaption;
@property (weak, nonatomic) IBOutlet UILabel *postDate;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshData];
}

- (void)refreshData {
    
    [self.post.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!data) {
            return NSLog(@"%@", error);
        }
        // Do something with the image
        self.postImage.image = [UIImage imageWithData:data];
    }];
    
    self.postCaption.text = self.post.caption;
    self.postDate.text = [self getDate];
}

- (NSString *)getDate {
  
    NSDate *createdAt = [self.post createdAt];
    NSDate *todayDate = [NSDate date];
    double ti = [createdAt timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    
    if(ti < 1) {
        return @"never";
    } else  if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 120) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minute ago", diff];
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 7200) {
        int diff = round(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d hour ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 172800) {
        int diff = round(ti / 60 / 60 / 24);
        return [NSString stringWithFormat:@"%d days ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return [NSString stringWithFormat:@"%d days ago", diff];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        // Convert Date to String
        return [formatter stringFromDate:createdAt];
    }
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
