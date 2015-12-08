//
//  NowPlayingViewController.h
//  MPC
//
//  Created by Jongmin Kim on 11/12/15.
//  Copyright © 2015 Jongmin Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface NowPlayingViewController : UIViewController

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSString *songTitle;
@property (strong, nonatomic) UIImage *artwork;
@end
