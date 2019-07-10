//
//  CameraViewController.h
//  josinstagram
//
//  Created by josemurillo on 7/9/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControllerDelegate

- (void)didPost:(Post *)post;

@end


@interface CameraViewController : UIViewController

@property (nonatomic, weak) id <CameraControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
