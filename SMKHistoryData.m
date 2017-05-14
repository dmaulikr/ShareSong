//
//  SMKHistoryData.m
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKHistoryData.h"
#import "SMKSong.h"

@interface SMKHistoryData()

@property (nonatomic) NSMutableArray *songs;

@end

@implementation SMKHistoryData

- (instancetype)init {
    if (self = [super init]) {
        self.songs = [[NSMutableArray alloc] init];
    }
    return self;
}
- (SMKSong*)songAtIndex:(NSUInteger)index {
    return [self.songs objectAtIndex:index];
}
- (NSInteger)countOfSongs {
    return [self.songs count];
}

- (BOOL)isMemberWithLink:(NSString *)link {
    for (SMKSong *song in self.songs) {
        if ([[song spotifyLink] containsString:link] || [[song appleMusicLink] containsString:link]) {
            return YES;
        }
    }
    return NO;
}
- (void)addSongWithDict:(NSDictionary *)data {
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[data objectForKey:@"imgLink"]]]];
    SMKSong *song = [[SMKSong alloc] initWithTitle:[data objectForKey:@"title"] artist:[data objectForKey:@"artist"] albumCover:img spotifyLink:[data objectForKey:@"spotifyLink"] appleMusicLink:[data objectForKey:@"appleLink"]];
    if ([self.songs count] >= 50) {
        [self.songs removeLastObject];
    }
    [self.songs insertObject:song atIndex:0];
}
@end
