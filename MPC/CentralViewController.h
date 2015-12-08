//
//  CentralViewController.h
//  MPC
//
//  Created by Jongmin Kim on 11/11/15.
//  Copyright © 2015 Jongmin Kim. All rights reserved.
//  This is so working!!!

#import "ViewController.h"
#import "AppDelegate.h"
@import AVFoundation;

@interface CentralViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (strong, nonatomic) NSMutableData *bufferedSongData;
@property (strong, nonatomic) NSDictionary *testData;
@property NSUInteger songSize;
@property (strong, nonatomic) NSArray *songTitles;
@property (strong, nonatomic) NSArray *artworks;
@property (strong, nonatomic) NSString *songToPlayTitle;
@property (strong, nonatomic) UIImage *songToPlayArtwork;
@property (strong, nonatomic) NSString *selectedSong;
@property (strong, nonatomic) NSString *currentPlayingSong;
@property (nonatomic) BOOL playingSong;
@property (nonatomic) BOOL *isPlaying;

@end
