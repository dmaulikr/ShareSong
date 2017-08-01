//
//  Searcher.m
//  ShareSong
//
//  Created by Vo1 on 31/07/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "Searcher.h"

@implementation Searcher

+ (void)test {
    
    NSArray *arr = @[
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"OMG"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"SIgn"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionf22ruit feat me"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionf22ruit feat me"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionf22ruit feat me"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passion"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionf22ruit feat me"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionfruit feat me"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Matt Franco",@"Passionfruit - Piano Version"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Karaoke Freaks",@"Passionfruit (Originally Performed by Drake) [Instrumental Version]"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Karaoke Freaks",@"Passionfruit (Originally Performed by Drake) - Instrumental Version"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Isabella Perone",@"Passionfruit - Tribute Drake"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"2017 Dynamo Hitz",@"Passionfruit (Originally performed by Drake)"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"2017 Dynamo Hitz",@"Passionfruit"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"L'Orchestra Cinematique",@"Passionfruit (Originally Performed By Drake) [Piano Instrumental]"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"L'Orchestra Cinematique",@"Passionfruit (Originally Performed By Drake) [Piano Instrumental]"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Karaoke Station",@"Passionfruit (Karaoke Version) (Originally Performed by Drake)"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Pass1ionfruit"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Karaoke Station",@"Passionfruit (Karaoke Version) (Originally Performed by Drake)"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"2017 Dynamo Hitz",@"Passionfruit (Originally performed by Drake)"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionfruit"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"2017 Dynamo Hitz",@"Passionfruit"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Karaoke Pro",@"Passionfruit (Originally Performed by Drake) [Instrumental Version]"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[ @"Karaoke Pro",@"Passionfruit (Originally Performed by Drake) - Instrumental Version"] forKeys:@[@"artist",@"title"]],
                     [[NSDictionary alloc] initWithObjects:@[@"Isabella Perone",@"Passionfruit - Tribute Drake"] forKeys:@[@"artist",@"title"]]
                     ];
    
    NSLog(@"%@",[Searcher searchTheNeededOneWith:[[NSDictionary alloc] initWithObjects:@[@"Drake",@"Passionfruit"] forKeys:@[@"artist",@"title"]] in:arr]);
    
}
+ (NSArray *)searchTheNeededOneWith:(NSDictionary *)pred in:(NSArray *)src {
    
    NSArray *filterdByArtist = [[NSArray alloc] initWithArray:src];
    //    1. filter by artist
    if ([pred objectForKey:@"artist"]) {
    filterdByArtist = [Searcher filterBy:[pred objectForKey:@"artist"] forKey:@"artist" in:src];
    if (![filterdByArtist count]) {return nil;}
    }
    
    //    2. filter by title
    NSArray *filterdByTitle = [Searcher filterBy:[pred objectForKey:@"title"] forKey:@"title" in:filterdByArtist];
    
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

// after preparing predicate for filtering sort all items by best hitting
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
    NSLog(@"%@", grades);
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
    
    
    NSString *one1 = [[Searcher removeAllSymbols:[one objectForKey:@"title"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *one2 = [[Searcher removeAllSymbols:[one objectForKey:@"artist"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    one1 = [one1 stringByAppendingString:one2];
    
    NSString *target1 = [[Searcher removeAllSymbols:[target objectForKey:@"title"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *target2 = [[Searcher removeAllSymbols:[target objectForKey:@"artist"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    target1 = [target1 stringByAppendingString:target2];
    
    return [one1 isEqualToString:target1];
}


// need to fix this method, it makes problems with symbols in names
+ (NSString *)removeAllSymbols:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSMutableArray *arr = (NSMutableArray *)[str componentsSeparatedByString:@" "];
    for (int i = 0; i < [arr count]; ++i){
        
        NSRange punctuationRange = [arr[i] rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]];
//        NSString *temp = arr[i];
//        @try {
//                NSLog(@"TEMP: %@", temp);
        NSLog(@"%@",arr[i]);
            if (punctuationRange.location != NSNotFound) {
//                NSLog(@"LOCATION %lu", (unsigned long)punctuationRange.location);
//                arr[i] = [arr[i] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
//                [arr[i] characterAtIndex:punctuationRange.location] = @"";
                NSMutableString *mutable = arr[i];
//                [mutable replaceCharactersInRange:punctuationRange withString:@""];
                [mutable stringByReplacingCharactersInRange:NSMakeRange(punctuationRange.location, 1) withString:@""];
                arr[i] = mutable;
            }
        NSLog(@"%@",arr[i]);
//        } @catch (NSException *exception) {
//            
//            NSLog(@"%@", exception);
//            arr[i] = temp;
//        }
        
        
        NSRange whiteSpaceRange = [arr[i] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if (whiteSpaceRange.location != NSNotFound) {
            NSMutableString *mutable = arr[i];
//            [mutable replaceCharactersInRange:whiteSpaceRange withString:@""];
            [mutable stringByReplacingCharactersInRange:NSMakeRange(whiteSpaceRange.location, 1) withString:@""];
            arr[i] = mutable;
            
//            arr[i] = [arr[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        NSLog(@"%@",arr[i]);
        if ([arr[i] length] == 0) {
            [arr removeObjectAtIndex:i];
        }
    }
    str = [arr componentsJoinedByString:@" "];
    return str;
}
+ (NSString *)prepareString:(NSString *)target {
    return [[[Searcher removeAllSymbols:target] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
}


@end
