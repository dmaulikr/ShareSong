//
//  Searcher.m
//  ShareSong
//
//  Created by Vo1 on 31/07/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "Searcher.h"

@implementation Searcher

+ (NSArray *)searchTheNeededOneWith:(NSDictionary *)pred in:(NSArray *)src {
    
    NSArray *filterdByArtist = [[NSArray alloc] initWithArray:src];
    //    1. filter by artist
    if ([pred objectForKey:@"artist"]) {
    filterdByArtist = [Searcher filterBy:[pred objectForKey:@"artist"] forKey:@"artist" in:src];
    if (![filterdByArtist count]) {return nil;}
    }
    
//        2. filter by albums
    NSArray *filterByAlbum = [Searcher filterBySmallestMissing:[pred objectForKey:@"albumName"] forKey:@"albumName" in:filterdByArtist];
    
    
    //    3. filter by title
    NSArray *filterdByTitle = [Searcher filterBy:[pred objectForKey:@"title"] forKey:@"title" in:filterByAlbum];
    
    
    if ([filterdByTitle count] > 1) {
        for (NSDictionary *obj in filterdByTitle) {
            if ([Searcher isEqual:obj to:pred]) {
                return @[obj];
            }
        }
        
        filterdByTitle = [Searcher nearestSearchBy:[pred objectForKey:@"title"] forKey:@"title" in:filterdByTitle];
    }
    return filterdByTitle;
}

+ (NSArray *)filterBy:(NSString *)pred forKey:(NSString *)key in:(NSArray *)src {
    
    NSString *lowerCaseWithoutSpacePred = [Searcher prepareString:pred];
    
    
    NSMutableArray *grades = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in src) {
        NSString *str = [obj objectForKey:key];
        NSArray *components = [[Searcher removeAllSymbols:str] componentsSeparatedByString:@" "];
        
        int hitCounter = 0;
        
        for (NSString *comp in components) {
            if ([lowerCaseWithoutSpacePred containsString:[comp lowercaseString]]) {
                hitCounter += 1;
            }
        }
        [grades addObject:@(hitCounter)];
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    int counter = 1;
    int maxHits = (int)[[pred componentsSeparatedByString:@" "] count];
    
    for (; counter <= maxHits; ++counter) {
        for (int i = 0; i < [src count]; ++i) {
            if ([[grades objectAtIndex:i] integerValue] == counter) {
                [result addObject:[src objectAtIndex:i]];

            }
        }
    }
    if ([result count]) {
        return result;
    } else {
        return src;
    }
}
+ (NSArray *)filterBySmallestMissing:(NSString *)pred forKey:(NSString *)key in:(NSArray *)src {
    
    NSString *lowerCaseWithoutSpacePred = [Searcher prepareString:pred];
    NSMutableArray *grades = [[NSMutableArray alloc] init];
    // break strings to words
    int minMisses = 100;
    for (NSDictionary *obj in src) {
        NSString *str = [obj objectForKey:key];
        NSArray *components = [[Searcher removeAllSymbols:str] componentsSeparatedByString:@" "];
        
        int missesCounter = 0;
    // and check if they are contains in pred and filling array with grades
        for (NSString *comp in components) {
            NSLog(@"%@ in %@", comp, lowerCaseWithoutSpacePred);
            if (![lowerCaseWithoutSpacePred containsString:[comp lowercaseString]]) {
                missesCounter += 1;
                NSLog(@"NO");
            }
        }
        NSLog(@"%d", missesCounter);
        if (missesCounter <= minMisses) { minMisses = missesCounter; }
        [grades addObject:@(missesCounter)];
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [src count]; ++i) {
        if ([[grades objectAtIndex:i] integerValue] == minMisses) {
            [result addObject:[src objectAtIndex:i]];
        }
    }
    
    if ([result count]) {
        return result;
    } else {
        return src;
    }
    
    
    
    return [NSArray new];

}
+ (NSArray *)nearestSearchBy:(NSString *)pred forKey:(NSString *)key in:(NSArray *)src {
    
    NSString *lowerCaseWithoutSpacePred = [Searcher prepareString:pred];
    NSMutableArray *grades = [[NSMutableArray alloc] init];
    
    for (NSDictionary *obj in src) {
        NSString *target = [obj objectForKey:key];
        target = [Searcher prepareString:target];
        int hitCounter = 0;
        for (int i = 0; i < [target length]; ++i) {

            if (i == [lowerCaseWithoutSpacePred length]) {
                break;
            }
            if ([target characterAtIndex:i] == [lowerCaseWithoutSpacePred characterAtIndex:i]) {
                hitCounter += 1;
            } else {break;}
        }
        [grades addObject:@(hitCounter)];
    }
    int mostNear = 0;
    for (int i = 1; i < [grades count]; ++i) {
        if ([[grades objectAtIndex:mostNear] integerValue] < [[grades objectAtIndex:i] integerValue]) {
            mostNear = i;
            i = mostNear + 1;
        }
    }
    return @[[src objectAtIndex:mostNear]];
}

+ (BOOL)isEqual:(NSDictionary *)one to:(NSDictionary *)target {
    
    
    NSString *one1 = [[Searcher removeAllSymbols:[one objectForKey:@"title"]]
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *one2 = [[Searcher removeAllSymbols:[one objectForKey:@"artist"]]
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
    one1 = [one1 stringByAppendingString:one2];
    
    NSString *target1 = [[Searcher removeAllSymbols:[target objectForKey:@"title"]]
                         stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *target2 = [[Searcher removeAllSymbols:[target objectForKey:@"artist"]]
                         stringByReplacingOccurrencesOfString:@" " withString:@""];
    target1 = [target1 stringByAppendingString:target2];
    
    return [one1 isEqualToString:target1];
}
+ (NSString *)removeAllSymbols:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSMutableArray *arrOut = [[NSMutableArray alloc] init];
    NSMutableArray *arr = (NSMutableArray *)[str componentsSeparatedByString:@" "];
    for (int i = 0; i < [arr count]; ++i) {
        NSMutableString *word = arr[i];
        NSUInteger length = [word length];
        NSString *result = [[NSString alloc] init];
        
        for (NSUInteger j = 0; j < length; ++j) {
            
            NSString *charachter = [NSString stringWithFormat:@"%c", [word characterAtIndex:j]];
            
            NSRange symbolRange = [charachter rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]];
            NSRange punctuationRange = [charachter rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]];
            NSRange whitespaceRange = [charachter rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (symbolRange.location == NSNotFound &&
                punctuationRange.location == NSNotFound &&
                whitespaceRange.location == NSNotFound ) {
            result = [result stringByAppendingString:charachter];
            }
        }
        result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (![result isEqualToString:@""]) {
            [arrOut addObject:result];
        }
    }
    
    str = [arrOut componentsJoinedByString:@" "];
    
    return str;
}
+ (NSString *)prepareString:(NSString *)target {
    return [[[Searcher removeAllSymbols:target] lowercaseString]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSDictionary *)decodeData:(NSDictionary *)src {
    NSArray *keys = [src allKeys];
    NSArray *values = [src allValues];
    NSMutableArray *valuesNormal = [[NSMutableArray alloc] init];
    for (NSString *str in values) {
        [valuesNormal addObject:[str stringByReplacingOccurrencesOfString:@"+" withString:@" "]];
    }
    return [[NSDictionary alloc] initWithObjects:valuesNormal forKeys:keys];
}


@end
