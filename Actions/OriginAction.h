#import <Cocoa/Cocoa.h>
#import "ActionProtocol.h"
#import "MouseBaseAction.h"

@interface OriginAction : MouseBaseAction <ActionProtocol> {

}

+ (NSString *)commandShortcut;

+ (NSString *)commandDescription;

- (NSString *)actionDescriptionString:(NSString *)locationDescription;

- (void)performActionAtPoint:(CGPoint) p;

- (void)performActionWithData:(NSString *)data withOptions:(struct ExecutionOptions)options;

@end
