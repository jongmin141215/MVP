//
//  NowPlayingViewController.m
//  MPC
//
//  Created by Jongmin Kim on 11/12/15.
//  Copyright © 2015 Jongmin Kim. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "CentralViewController.h"

@interface NowPlayingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleValue;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;

@end

@implementation NowPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CentralViewController * prevController = [self backViewController];
    self.titleValue.text = prevController.songToPlayTitle;
    self.artworkImage.image  = prevController.songToPlayArtwork;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

- (IBAction)playToggle:(id)sender {
    CentralViewController * prevController = [self backViewController];
    if (prevController.isPlaying) {
        [[prevController player] pause];
        prevController.isPlaying = NO;
    } else {
        [[prevController player] play];
        prevController.isPlaying = YES;
    }
    
}


@end
