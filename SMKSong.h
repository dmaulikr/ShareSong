//
//  SMKSong.h
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface SMKSong : NSObject

- (instancetype)initWithTitle:(NSString*)title artist:(NSString *)artist albumCover:(UIImage *)img spotifyLink:(NSString *)spotifylink appleMusicLink:(NSString *)appleMusicLink;

@end
