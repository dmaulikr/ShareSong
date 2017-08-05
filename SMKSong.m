//
//  SMKSong.m
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKSong.h"


@interface SMKSong() <NSCoding>

@property (nonatomic) UIImage *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *spotifyLink;
@property (nonatomic, copy) NSString *appleMusicLink;
@property (nonatomic, copy) NSString *albumName;

@end

@implementation SMKSong

- (instancetype)initWithTitle:(NSString*)title artist:(NSString *)artist albumName:(NSString *)albumName
                   albumCover:(UIImage *)img spotifyLink:(NSString *)spotifyLink appleMusicLink:(NSString *)appleMusicLink {
    self = [super init];
    if (self) {
        self.title = title;
        self.artist = artist;
        self.spotifyLink = spotifyLink;
        self.appleMusicLink = appleMusicLink;
        self.img = img;
        self.albumName = albumName;
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.img = [aDecoder decodeObjectForKey:@"img"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.albumName = [aDecoder decodeObjectForKey:@"albumName"];
        self.artist = [aDecoder decodeObjectForKey:@"artist"];
        self.spotifyLink = [aDecoder decodeObjectForKey:@"spotifyLink"];
        self.appleMusicLink = [aDecoder decodeObjectForKey:@"appleMusicLink"];
        
    }
    return self;
}

- (UIImage *)albumCover {
    return self.img;
}
- (NSString *)title {
    return _title;
}
- (NSString *)artist {
    return _artist;
}
- (NSString *)spotifyLink {
    return _spotifyLink;
}
- (NSString *)appleMusicLink {
    return _appleMusicLink;
}
- (NSString *)albumName {
    return self.albumName;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"Title: %@\nArtist: %@\nSpotLink: %@\nAppMLink: %@\nImg: %@", self.title, self.artist, self.spotifyLink, self.appleMusicLink, self.img];
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.img forKey:@"img"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.artist forKey:@"albumName"];
    [aCoder encodeObject:self.spotifyLink forKey:@"spotifyLink"];
    [aCoder encodeObject:self.appleMusicLink forKey:@"appleMusicLink"];
    
}




@end
