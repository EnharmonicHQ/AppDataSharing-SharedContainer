//
//  ENHPersonDataStore.m
//  AppDataSharing
//
//  Created by Dillan Laughlin on 10/10/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

static NSString * const kENHPersonDataStoreSharedContainerIdentifier = @"group.com.enharmonichq.PersonData";

#import "ENHPersonDataStore.h"
#import "AAPLDirectoryMonitor.h"
#import "ENHPerson.h"
#import "NSFileCoordinator+ENHUtilities.h"

@interface ENHPersonDataStore () <AAPLDirectoryMonitorDelegate>

@property (nonatomic, strong) AAPLDirectoryMonitor *directoryMonitor;

@end

@implementation ENHPersonDataStore

+(instancetype)sharedDataStore
{
    static dispatch_once_t onceQueue;
    static ENHPersonDataStore *sharedDataStore = nil;
    
    dispatch_once(&onceQueue, ^{
        sharedDataStore = [[self alloc] init];
    });
    
    return sharedDataStore;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _directoryMonitor = [[AAPLDirectoryMonitor alloc] initWithURL:[self.class appGroupSharedContainerDirectoryURL]];
        [_directoryMonitor setDelegate:self];
        [_directoryMonitor startMonitoring];
        [self reloadPersonData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUIApplicationWillEnterForegroundNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)reloadPersonData
{
    NSURL *personFileURL = [self.class personDataFileURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:personFileURL.path])
    {
        __weak __typeof(self)weakSelf = self;
        [self.class loadPersonDataAtURL:personFileURL
                                success:^(ENHPerson *person) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf setPerson:person];
                                    });
                                } failure:^(NSError *error) {
                                    NSLog(@"Data Loading Error: %@", error);
                                }];
    }
}

#pragma mark -

+(void)loadPersonDataAtURL:(NSURL *)personFileURL
                    success:(void (^)(ENHPerson *person))success
                         failure:(void (^)(NSError *error))failure;
{
    [NSFileCoordinator enh_dataWithContentsOfURL:personFileURL
                                         success:^(NSData *data) {
                                             ENHPerson *person = [ENHPerson personWithData:data];
                                             if (success)
                                             {
                                                 success(person);
                                             }
                                         } failure:^(NSError *error) {
                                             if (failure)
                                             {
                                                 failure(error);
                                             }
                                         }];
}

+(void)savePerson:(ENHPerson *)person
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure;
{
    NSURL *personFileURL = [self personDataFileURL];
    NSLog(@"-[%@ %@] path: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), personFileURL.path);
    NSData *data = [person dataRepresentation];
    [NSFileCoordinator enh_writeData:data
                               toURL:personFileURL
                             success:^{
                                 if (success)
                                 {
                                     success();
                                 }
                             } failure:^(NSError *error) {
                                 if (failure)
                                 {
                                     failure(error);
                                 }
                             }];
}

#pragma mark - AAPLDirectoryMonitorDelegate

- (void)directoryMonitorDidObserveChange:(AAPLDirectoryMonitor *)directoryMonitor
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf reloadPersonData];
    });
}

#pragma mark - Notification Handling

-(void)handleUIApplicationWillEnterForegroundNotification:(NSNotification *)note
{
    [self reloadPersonData];
}

#pragma mark - URLs

+(NSURL *)personDataFileURL
{
    static NSURL *personDataFileURL = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *appGroupSharedContainerDirectoryURL = [self appGroupSharedContainerDirectoryURL];
        personDataFileURL = [appGroupSharedContainerDirectoryURL URLByAppendingPathComponent:@"Person.enhp"];
    });
    
    return personDataFileURL;
}

+(NSURL *)appGroupSharedContainerDirectoryURL
{
    static NSURL *sharedContainerDirectoryURL = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedContainerDirectoryURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kENHPersonDataStoreSharedContainerIdentifier];
        
        NSAssert(sharedContainerDirectoryURL != nil, @"sharedContainerDirectoryURL cannot be nil. This typically happens when you need to setup the shared app group entitlements in the developer portal. See: https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW61");
        
#if DEBUG
        NSLog(@"Shared Container Directory: %@", sharedContainerDirectoryURL.path);
#endif
    });
    
    return sharedContainerDirectoryURL;
}

@end
