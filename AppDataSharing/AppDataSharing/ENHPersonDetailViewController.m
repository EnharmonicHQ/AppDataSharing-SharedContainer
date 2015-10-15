//
//  ENHPersonDetailViewController.m
//  AppDataSharing
//
//  Created by Dillan Laughlin on 2/5/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHPersonDetailViewController.h"
#import "ENHPerson.h"
#import "NSDateFormatter+SimpleFormatter.h"

#import "ENHPersonDataStore.h"

static void * ENHPersonDetailViewControllerKVOContext = &ENHPersonDetailViewControllerKVOContext;

@interface ENHPersonDetailViewController ()

@property (readonly) ENHPerson *person;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOfBirthLabel;

@end

@implementation ENHPersonDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"Viewer", nil)];
    [self observeDataStore];
}

-(void)dealloc
{
    [self unobserveDataStore];
}

-(void)reloadData
{
    ENHPerson *person = [self person];
    
    NSString *name = @"";
    if ([person firstName])
    {
        name = [name stringByAppendingString:[person firstName]];
    }
    if ([name length] > 0)
    {
        name = [name stringByAppendingString:@" "];
    }
    if ([person lastName])
    {
        name = [name stringByAppendingString:[person lastName]];
    }
    [self.nameLabel setText:name];
    
    NSString *dateString = @"";
    if ([person dateOfBirth])
    {
        dateString = [[NSDateFormatter simpleFormatter] stringFromDate:[person dateOfBirth]];
    }
    [self.dateOfBirthLabel setText:dateString];
}

#pragma mark - KVO

-(void)observeDataStore
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    [dataStore addObserver:self
                forKeyPath:NSStringFromSelector(@selector(person))
                   options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                   context:ENHPersonDetailViewControllerKVOContext];
}

-(void)unobserveDataStore
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    [dataStore removeObserver:self
                   forKeyPath:NSStringFromSelector(@selector(person))
                      context:ENHPersonDetailViewControllerKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == ENHPersonDetailViewControllerKVOContext)
    {
        [self reloadData];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Accessors

-(ENHPerson *)person
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    ENHPerson *person = [dataStore person];
    
    return person;
}

@end
