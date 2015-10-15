//
//  NSFileCoordinator+ENHUtilities.h
//  AppDataSharing
//
//  Created by Dillan Laughlin on 10/10/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileCoordinator (ENHUtilities)

+(void)enh_writeData:(NSData *)data
           toURL:(NSURL *)fileURL
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;

+(void)enh_dataWithContentsOfURL:(NSURL *)fileURL
                     success:(void (^)(NSData *data))success
                     failure:(void (^)(NSError *error))failure;

@end
