//
//  Created by Sanjay Madan on 1/29/17.
//  Copyright © 2017 mowglii.com. All rights reserved.
//

#import "PrefsVC.h"

@implementation PrefsVC
{
    NSToolbar *_toolbar;
    NSMutableArray<NSString *> *_toolbarIdentifiers;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toolbar = [[NSToolbar alloc] initWithIdentifier:@"Toolbar"];
        _toolbar.allowsUserCustomization = NO;
        _toolbar.delegate = self;
        _toolbarIdentifiers = [NSMutableArray new];
    }
    return self;
}

- (void)loadView
{
    self.view = [NSView new];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    if (self.view.window.toolbar == nil) {
        self.view.window.toolbar = _toolbar;
    }
}

- (void)setChildViewControllers:(NSArray<__kindof NSViewController *> *)childViewControllers
{
    [super setChildViewControllers:childViewControllers];
    for (NSViewController *childViewController in childViewControllers) {
        [_toolbarIdentifiers addObject:childViewController.title];
    }
    [self.view setFrame:(NSRect){0, 0, childViewControllers[0].view.fittingSize}];
    [childViewControllers[0].view setFrame:self.view.bounds];
    [self.view addSubview:childViewControllers[0].view];
    [_toolbar setSelectedItemIdentifier:_toolbarIdentifiers[0]];
}

- (void)toolbarItemClicked:(NSToolbarItem *)item
{
    NSViewController *toVC = [self viewControllerForItemIdentifier:item.itemIdentifier];
    if (toVC) {

        if (self.view.subviews[0] == toVC.view) return;

        NSWindow *window = self.view.window;
        NSRect contentRect = (NSRect){0, 0, toVC.view.fittingSize};
        NSRect contentFrame = [window frameRectForContentRect:contentRect];
        CGFloat windowHeightDelta = window.frame.size.height - contentFrame.size.height;
        NSPoint newOrigin = NSMakePoint(window.frame.origin.x, window.frame.origin.y + windowHeightDelta);
        NSRect newFrame = (NSRect){newOrigin, contentFrame.size};

        [toVC.view setAlphaValue: 0];
        [toVC.view setFrame:contentRect];
        [self.view addSubview:toVC.view];

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [context setDuration:0.2];
            [window.animator setFrame:newFrame display:NO];
            [toVC.view.animator setAlphaValue:1];
            [self.view.subviews[0].animator setAlphaValue:0];
        } completionHandler:^{
            [self.view.subviews[0] removeFromSuperview];
        }];
    }
}

- (NSViewController *)viewControllerForItemIdentifier:(NSString *)itemIdentifier
{
    for (NSViewController *vc in self.childViewControllers) {
        if ([vc.title isEqualToString:itemIdentifier]) return vc;
    }
    return nil;
}

#pragma mark -
#pragma mark NSToolbarDelegate

- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    item.label = itemIdentifier;
    item.image = [NSImage imageNamed:NSStringFromClass([[self viewControllerForItemIdentifier:itemIdentifier] class])];
    item.target = self;
    item.action = @selector(toolbarItemClicked:);
    return item;
}

- (NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return _toolbarIdentifiers;
}

- (NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return _toolbarIdentifiers;
}

- (NSArray<NSString *> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return _toolbarIdentifiers;
}

@end
