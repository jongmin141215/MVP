//
//  CentralViewController.m
//  MPC
//
//  Created by Jongmin Kim on 11/11/15.
//  Copyright © 2015 Jongmin Kim. All rights reserved.
//  MVP!! Bug fixed  Now can play more than 1 songs!!!

#import "CentralViewController.h"
@import MultipeerConnectivity;
@import AVFoundation;

@interface CentralViewController ()
@property (weak, nonatomic) IBOutlet UITableView *playlist;

@end

@implementation CentralViewController

//- (IBAction)sendAndPlayTest:(id)sender {
//    
//    NSError *error;
//
//    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:_testData];
//    
//    [self.appDelegate.mpcHandler.session sendData:myData
//                                          toPeers:@[self.appDelegate.mpcHandler.session.connectedPeers[0]]
//                                         withMode:MCSessionSendDataReliable
//                                            error:&error];
//}
//


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _playlist.delegate = self;
//    _testData = @{@"song":@"Cedarwood Road"};
//    _songToPlayTitle = [[NSString alloc]init];
    
//    self.playButton.enabled = NO;
    
    self.selectedSong = [[NSString alloc]init];
    self.currentPlayingSong = [[NSString alloc]init];
    self.playingSong = NO;
    self.bufferedSongData = [NSMutableData data];
    self.pendingRequests = [NSMutableArray array];
    
    self.appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [self.appDelegate.mpcHandler setupPeerWithDisplayName:[UIDevice currentDevice].name];
    [self.appDelegate.mpcHandler setupSession];
    [self.appDelegate.mpcHandler advertiseSelf:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:@"MPCDemo_DidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStreamDataWithNotification:)
                                                 name:@"MPCDemo_DidReceiveStreamData"
                                               object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.mpcHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.mpcHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleReceivedDataWithNotification:(NSNotification *)notification {
    NSLog(@"handleReceivedData");
    // Get the user info dictionary that was received along with the notification.
    NSDictionary *userInfoDict = [notification userInfo];
    NSData *sentData = [userInfoDict objectForKey:@"data"];
    // Convert the received data into a NSString object.
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:sentData];

//    NSLog(@"Value 1 is %@",[myDictionary objectForKey:@"songList"][0]);
//    NSLog(@"Value 2 is %@",[myDictionary objectForKey:@"songList"][1]);
//    NSLog(@"Value 3 is %@",[myDictionary objectForKey:@"songList"][2]);
    
    if ([[myDictionary objectForKey:@"play"]  isEqual: @"No"]){
        
        self.songTitles = [myDictionary objectForKey:@"songList"];
        
        NSLog(@"This is the list of songs not a file size to play a song!");
        NSLog(@"Value 1 is %@",self.songTitles[0]);
//        NSLog(@"Value 2 is %@",self.songTitles[1]);
//        NSLog(@"Value 3 is %@",self.songTitles[2]);
        [self.playlist reloadData];
        return;
        
    }
    
    
//    if ([[myDictionary objectForKey:@"play"]  isEqual: @"Yes"]) {
//        NSLog(@"initialize player and get ready to play the song!");
//        return;
//    }
    
    
    NSData *fullSongData = [userInfoDict objectForKey:@"data"];
    [fullSongData getBytes:&_songSize length:sizeof(_songSize)];
    
    NSLog(@"Recv. %lu bytes", (unsigned long)_songSize);
    
    if(self.player == nil) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:@"streaming-file:///"] options:nil];
        [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        
        self.pendingRequests = [NSMutableArray array];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        NSLog(@"Play audio!!!");
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    
    // Keep the sender's peerID and get its display name.
    //    MCPeerID *senderPeerID = [userInfoDict objectForKey:@"peerID"];
    //    NSString *senderDisplayName = senderPeerID.displayName;
}
- (void)handleStreamDataWithNotification:(NSNotification *)notification {
    NSLog(@"handleStreamData");
    NSDictionary *userInfoDict = [notification userInfo];
    
    NSData *data = [userInfoDict objectForKey:@"data"];
    [_bufferedSongData appendData:data];
    [self processPendingRequests];
    
    NSLog(@"Recv. %lu bytes", (unsigned long)data.length);
    NSLog(@"Total recv: %lu", (unsigned long)_bufferedSongData.length);
}











#pragma mark - AVURLAsset resource loading

- (void)processPendingRequests
{
    //    NSLog(@"processPendingRequests");
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests)
    {
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        if (didRespondCompletely)
        {
            [requestsCompleted addObject:loadingRequest];
            
            [loadingRequest finishLoading];
            
            NSLog(@"Finished processing loading request!");
        }
    }
    
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest
{
    //    NSLog(@"fillInContentInformation");
    if (contentInformationRequest == nil)
    {
        return;
    }
    
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = @"com.apple.m4a-audio";
    contentInformationRequest.contentLength = _songSize;
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest
{
    //    NSLog(@"respondWithDataForRequest");
    long long startOffset = dataRequest.requestedOffset;
    //    NSLog(@"Requested offset: %i", dataRequest.requestedOffset);
    if (dataRequest.currentOffset != 0)
    {
        //        NSLog(@"dataRequest.currentOffset <> 0");
        startOffset = dataRequest.currentOffset;
        //        NSLog(@"New startOffeset = %i", dataRequest.currentOffset);
    }
    
    // Don't have any data at all for this request
    if (self.bufferedSongData.length == 0 || self.bufferedSongData.length < startOffset)
    {
        NSLog(@"Not enough data for the request; wanted startOffset %lli, only have %lu bytes of data", startOffset, (unsigned long)self.bufferedSongData.length);
        return NO;
    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.bufferedSongData.length - (NSUInteger)startOffset;
    //    NSLog(@"Unread bytes: %i", unreadBytes);
    
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    NSLog(@"==> Responding with bytes: %lu", (unsigned long)numberOfBytesToRespondWith);
    
    [dataRequest respondWithData:[self.bufferedSongData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)]];
    
    NSLog(@"----------------------");
    NSLog(@"Cur offset: %lli", dataRequest.currentOffset);
    NSLog(@"----------------------");
    BOOL didRespondFully = (dataRequest.currentOffset - dataRequest.requestedOffset) >= dataRequest.requestedLength;
    
    return didRespondFully;
}


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //    NSLog(@"shouldWaitForLoadingOfRequestedResource");
    [self.pendingRequests addObject:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //    NSLog(@"didCancelLoadingRequest");
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        NSLog(@"READY TO PLAY");
        [self.player play];
//        self.playButton.enabled = YES;
        
    }
}

- (IBAction)searchForPeers:(id)sender {
    if (self.appDelegate.mpcHandler.session != nil) {
        [[self.appDelegate mpcHandler] setupBrowser];
        [[[self.appDelegate mpcHandler] browser] setDelegate:self];
        
        [self presentViewController:self.appDelegate.mpcHandler.browser
                           animated:YES
                         completion:nil];
    }

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CentralCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *current = [self.songTitles objectAtIndex:indexPath.row];
    
    cell.textLabel.text = current;
//    cell.detailTextLabel.text = [current valueForProperty:MPMediaItemPropertyAlbumArtist];
    
//    MPMediaItemArtwork *artwork = [current valueForProperty:MPMediaItemPropertyArtwork];
    
//    UIImage *artworkImage = [artwork imageWithSize: CGSizeMake (44, 44)];
//    
//    if (artworkImage) {
//        cell.imageView.image = artworkImage;
//    } else {
//        cell.imageView.image = [UIImage imageNamed:@"No-artwork-albums.png"];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell is selected!!!!");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int rowNo = indexPath.row;
    _selectedSong = _songTitles[rowNo];
    NSLog(@"%@ was selected.", _selectedSong);
    
    
    if (_playingSong && _selectedSong == _currentPlayingSong) {
        [self.player pause];
        _playingSong = NO;
        NSLog(@"pause called");
        return;
    }
    
    if (!_playingSong && _selectedSong == _currentPlayingSong) {
        [self.player play];
        _playingSong = YES;
        NSLog(@"resume play called");
        return;
    }
    

    
    
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:@"streaming-file:///"] options:nil];
//    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
//    
//    self.pendingRequests = [NSMutableArray array];
//    
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
//    NSLog(@"Play audio!!!");
//    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

    
    
//    AVAsset *asset = [AVURLAsset URLAssetWithURL:url1 options:nil];
//    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
//    if (player != nil)
    [self.player pause];
//        [self.player removeObserver:self forKeyPath:@"status"];
    
//    player = [AVPlayer playerWithPlayerItem:anItem];
//    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [[self.player currentItem] removeObserver:self forKeyPath:@"status"];
    
//    if (player != nil && [player currentItem] != nil)
//        [[player currentItem] removeObserver:self forKeyPath:@"timedMetadata"];
//    AVPlayerItem *item = player.currentItem;
//    [item addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionInitial|     NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld| NSKeyValueObservingOptionPrior context:nil];
//    [player play];
//    
    
    self.player = nil;
    self.bufferedSongData = nil;
    self.bufferedSongData = [NSMutableData data];
    NSError *error;
    NSDictionary * playSongTitle = @{@"song": _selectedSong};
    _currentPlayingSong = _selectedSong;
    _playingSong = YES;
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject: playSongTitle];
    
    [self.appDelegate.mpcHandler.session sendData:myData
                                          toPeers:@[self.appDelegate.mpcHandler.session.connectedPeers[0]]
                                         withMode:MCSessionSendDataReliable
                                            error:&error];

    
    
}




@end
