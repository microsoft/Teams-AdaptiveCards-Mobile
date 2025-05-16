//
//  AppDelegate.h
//  ADCIOSVisualizer
//
//  Created by jwoo on 6/2/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

// Controls whether the Swift implementation is used for Adaptive Cards
@property (nonatomic, assign) BOOL useSwiftImplementation;

- (void)saveContext;


@end
