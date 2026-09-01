#import <Foundation/Foundation.h>
#import "FIDRootListController.h"

@implementation FIDRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
