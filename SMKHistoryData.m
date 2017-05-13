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
@end
