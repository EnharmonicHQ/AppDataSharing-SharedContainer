//
//  ENHPersonDataStore.h
//  AppDataSharing
//
//  Created by Dillan Laughlin on 10/10/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ENHPerson;

@interface ENHPersonDataStore : NSObject

+(instancetype)sharedDataStore;

@property (nonatomic, strong) ENHPerson *person;

+(void)savePerson:(ENHPerson *)person
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure;

@end
