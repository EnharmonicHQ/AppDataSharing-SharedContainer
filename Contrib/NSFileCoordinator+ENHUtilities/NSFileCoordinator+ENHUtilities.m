//
//  NSFileCoordinator+ENHUtilities.m
//
//  Created by Dillan Laughlin on 10/10/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//
//  This code is largely inspired by Apple's Lister Sample Code.
//  See: https://developer.apple.com/library/prerelease/ios/samplecode/Lister/Introduction/Intro.html#//apple_ref/doc/uid/TP40014701

#import "NSFileCoordinator+ENHUtilities.h"

@implementation NSFileCoordinator (ENHUtilities)

+ (NSOperationQueue *)enh_fileCoordinationQueue {
    static NSOperationQueue *queue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });
    
    return queue;
}

+(void)enh_writeData:(NSData *)data
           toURL:(NSURL *)fileURL
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(data);
    NSParameterAssert(fileURL);
    
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
    NSFileAccessIntent *writingIntent = [NSFileAccessIntent writingIntentWithURL:fileURL options:NSFileCoordinatorWritingForReplacing];
    [fileCoordinator coordinateAccessWithIntents:@[writingIntent] queue:[self enh_fileCoordinationQueue] byAccessor:^(NSError *accessError) {
        if (accessError)
        {
            if (failure)
            {
                failure(accessError);
            }
            
            return;
        }
        
        NSError *error = nil;
        if ([data writeToURL:writingIntent.URL options:NSDataWritingAtomic error:&error])
        {
            if (success)
            {
                success();
            }
        }
        else if (failure)
        {
            failure(error);
        }
    }];
}

+(void)enh_dataWithContentsOfURL:(NSURL *)fileURL
                     success:(void (^)(NSData *data))success
                     failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(fileURL);
    
    BOOL successfulSecurityScopedResourceAccess = [fileURL startAccessingSecurityScopedResource];
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
    NSFileAccessIntent *readingIntent = [NSFileAccessIntent readingIntentWithURL:fileURL options:0];
    [fileCoordinator coordinateAccessWithIntents:@[readingIntent] queue:[self enh_fileCoordinationQueue] byAccessor:^(NSError *accessError) {
        if (accessError)
        {
            if (successfulSecurityScopedResourceAccess)
            {
                [fileURL stopAccessingSecurityScopedResource];
            }
            
            if (failure)
            {
                failure(accessError);
            }
            
            return;
        }
        
        NSError *readError = nil;
        NSData *data = [NSData dataWithContentsOfURL:readingIntent.URL options:NSDataReadingUncached error:&readError];
        
        if (successfulSecurityScopedResourceAccess)
        {
            [fileURL stopAccessingSecurityScopedResource];
        }
        
        if (data)
        {
            if (success)
            {
                success(data);
            }
        }
        else if (failure)
        {
            failure(readError);
        }
    }];
}

@end
