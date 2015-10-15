//
//  ENHViewController.m
//  AppDataSharing
//
//  Created by Dillan Laughlin on 2/5/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHPersonEditorViewController.h"
#import "ENHPerson.h"

// Data
#import "ENHPersonDataStore.h"

static NSString *kViewerURLScheme = @"com.EnharmonicHQ.Viewer";
static void * ENHPersonEditorViewControllerKVOContext = &ENHPersonEditorViewControllerKVOContext;

@interface ENHPersonEditorViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;

@property (readonly) ENHPerson *person;

@end

@implementation ENHPersonEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setTitle:NSLocalizedString(@"Person Editor", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTapGestureRecognizer:)];
    [self.view addGestureRecognizer:tap];
    
    [self observeDataStore];
}

-(void)dealloc
{
    [self unobserveDataStore];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self savePerson];
}

-(void)reloadData
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    ENHPerson *person = [dataStore person];
    if (!person)
    {
        person = [[ENHPerson alloc] init];
        [dataStore setPerson:person];
    }
    
    [self.firstNameTextField setText:person.firstName];
    [self.lastNameTextField setText:person.lastName];
    if ([person dateOfBirth])
    {
        [self.birthDatePicker setDate:person.dateOfBirth animated:YES];
    }
}

-(void)savePerson
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    if ([dataStore person])
    {
        [ENHPersonDataStore savePerson:dataStore.person
                               success:^{
                                   //
                               } failure:^(NSError *error) {
                                   NSString *message = [NSString stringWithFormat:@"Unable to save.\n%@", error.localizedDescription];
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Save Error"
                                                                                                            message:message
                                                                                                     preferredStyle:(UIAlertControllerStyleAlert)];
                                   [self presentViewController:alertController animated:YES completion:nil];
                               }];
    }
}

#pragma mark - Actions

-(IBAction)saveButtonTapped:(id)sender
{
    [self savePerson];
}

-(IBAction)datePickerValueChanged:(id)sender
{
    [self dismissKeyboard];
    NSDate *date = [self.birthDatePicker date];
    [self.person setDateOfBirth:date];
}

-(void)handleBackgroundTapGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    [self dismissKeyboard];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self firstNameTextField])
    {
        [self.lastNameTextField becomeFirstResponder];
    }
    else if (textField == [self lastNameTextField])
    {
        [self.lastNameTextField resignFirstResponder];
    }
    
    return YES;
}

-(void)textDidChange:(NSNotification *)notification
{
    [self.person setFirstName:self.firstNameTextField.text];
    [self.person setLastName:self.lastNameTextField.text];
}

-(void)dismissKeyboard
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
}

#pragma mark - KVO

-(void)observeDataStore
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    [dataStore addObserver:self
                forKeyPath:NSStringFromSelector(@selector(person))
                   options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                   context:ENHPersonEditorViewControllerKVOContext];
}

-(void)unobserveDataStore
{
    ENHPersonDataStore *dataStore = [ENHPersonDataStore sharedDataStore];
    [dataStore removeObserver:self
                   forKeyPath:NSStringFromSelector(@selector(person))
                      context:ENHPersonEditorViewControllerKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == ENHPersonEditorViewControllerKVOContext)
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
