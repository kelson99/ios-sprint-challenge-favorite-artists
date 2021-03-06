//
//  LSIArtistController.m
//  FavoriteArtists
//
//  Created by Kelson Hartle on 8/2/20.
//  Copyright © 2020 Kelson Hartle. All rights reserved.
//

#import "LSIArtistController.h"
#import "LSIArtist.h"

static NSString *baseURLString = @"https://www.theaudiodb.com/api/v1/json/1/search.php";

@implementation LSIArtistController

// MARK: Public Functions

- (void)fetchArtistsWithArtistName:(NSString *)artistName
                   completionBlock:(LSIArtistFetcherCompletion)completionBlock {
    NSLog(@"FETCH 😐");

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:baseURLString];
    
    NSURLQueryItem *artistItem = [NSURLQueryItem queryItemWithName:@"s" value:artistName];
    
    urlComponents.queryItems = @[
    artistItem
    ];
    
    NSURL *url = urlComponents.URL;
    
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"URL: %@",url);
        
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        if (!data) {
            NSLog(@"No data was returned from server.");
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            completionBlock(nil,jsonError);
            return;
        }
        
        if ([dictionary[@"artists"] isKindOfClass:[NSNull class]]) {
            NSLog(@"artists not found.");
            
        }
        
        NSDictionary *artists = [[dictionary objectForKey:@"artists"] firstObject];
        if (artists == nil) {
            NSLog(@"NO artists found.");
            
        }
        LSIArtist *artist = [[LSIArtist alloc] initWithDictionary:artists];
        
        completionBlock(artist, nil);
    }];
    
    [task resume];
}

-(NSArray *)fetchSavedArtist; {
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [path objectAtIndex:0];
    NSArray *filePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directory error:nil];
    
    NSMutableArray *artists = [[NSMutableArray alloc] init];
    
    for (NSString *artist in filePaths) {
        NSString *artistDirpath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", artist];
        NSURL *artistURL = [NSURL fileURLWithPath:artistDirpath];
        NSData *artistData = [[NSData alloc] initWithContentsOfURL:artistURL];
        NSDictionary *artistDictionary = [NSJSONSerialization
                                          JSONObjectWithData:artistData options:0 error:nil];
        LSIArtist *artist = [[LSIArtist alloc] initWithDictionary:artistDictionary];
        [artists addObject:artist];
    }
    
    return artists;
    
}


@end
