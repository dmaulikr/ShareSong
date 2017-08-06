//
//  Test.m
//  ShareSong
//
//  Created by Vo1 on 06/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "Test.h"

@interface Test()

@property (nonatomic) NSArray *songs;

@end

@implementation Test

- (instancetype)initWith:(NSArray *)src {
    if (![super init]) {return nil;}
    
    self.songs = src;
    
    return self;
}


@end
