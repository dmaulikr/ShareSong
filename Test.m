/// Put this two methods in SMKTransferingSong class
//- (void)testGo:(NSUInteger )counter :(NSArray *)src;
//+ (NSArray *)test;
/// And call then them in ViewController in ViewDidLoad
    //NSArray *arr = [SMKTransferingSong test];
    //[[SMKTransferingSong sharedTransfer] testGo:210 :arr];


/// Get a playlist on 500-600 songs from apple music
/// https://itunes.apple.com/ua/playlist/los-favoritos/idpl.3ab18e69e695466198c1110935f2e3fa
/// And prepare it to needed format
//+ (NSArray *)test {
//
//    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery playlistsQuery];
//    NSArray *playlists = [myPlaylistsQuery collections];
//    NSArray *songs = [[NSArray alloc] init];
//    NSMutableArray *test = [[NSMutableArray alloc] init];
//    MPMediaPlaylist *los;
//    for (MPMediaPlaylist *playlist in playlists) {
//        if ([[playlist valueForProperty:MPMediaPlaylistPropertyName] isEqualToString:@"Los Favoritos"]) {
//            los = playlist;
//            break;
//        }
//    }
//    songs = [los items];
//    for (MPMediaItem *song in songs) {
//        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
//        NSString *title = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSString *album = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
//
//        NSDictionary *dixt = @{@"artist": artist,
//                               @"title": title,
//                               @"album": album};
//        [test addObject:dixt];
//
//    }
//    return test;
//}

/// Test 500 songs for both music services
/// about 5-10% misses
/// < 5% cannot find track
/// < 10% found another song

// - (void)testGo:(NSUInteger )counter :(NSArray *)src {
//if (counter == [src count]) {NSLog(@"SUC: %d/%lu", succ_counter, (unsigned long)[src count]);return;}

    /// Test apple Music
//    [AppleMusicSearch makeDataWithDictionary:[src objectAtIndex:counter++]
//                            withFrontStoreID:self.appleMusicFrontStoreId
//                                   withBlock:^(NSDictionary* dict, bool success) {
//                                       if (success) {
//                                           succ_counter += 1;
//                                           [self testGo:counter :src];
//                                       } else {
//                                           NSLog(@"NO");
//                                           [self testGo:counter :src];
//                                       }
//                                   }];
//
    /// Test Spotift
//[SpotifySearch makeDataTaskWithTemp:[src objectAtIndex:counter++]
//                          withToken:self.tokenData
//                          withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
//                              if (counter > 200) {
//                                  NSLog(@"%@", [src objectAtIndex:counter-1]);
//                                  NSLog(@"%@", dict);
//                              }
//                              if (success) {
//                                  succ_counter += 1;
//                                  [self testGo:counter :src];
//                              } else {
//                                  [self testGo:counter :src];
//                              }
//                          }];
//}
