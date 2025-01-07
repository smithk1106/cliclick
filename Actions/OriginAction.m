#import "OriginAction.h"
#include <unistd.h>

@implementation OriginAction

#pragma mark - ActionProtocol

+ (NSString *)commandShortcut {
    return @"o";
}

+ (NSString *)commandDescription {
    return @"  o:x,y   Will change the origin with the given coordinates.\n"
    "          Example: “o:10,10” will set the origin with x coordinate 10\n"
    "          and y coordinate 10 for all mouse actions.\n"
    "          *This action only can be used with -f";
}

#pragma mark - MouseBaseAction

- (NSString *)actionDescriptionString:(NSString *)locationDescription {
    return [NSString stringWithFormat:@"Origin %@", locationDescription];
}

- (void)performActionAtPoint:(CGPoint) p {
    [self setOrigin:p];
}

#pragma mark - ActionProtocol

- (void)performActionWithData:(NSString *)data withOptions:(struct ExecutionOptions)options {
    CGPoint p;
    NSString *shortcut = [[self class] commandShortcut];
    NSString *verboseLoc;

    if ([data isEqualToString:@""]) {
        [NSException raise:@"InvalidCommandException"
                    format:@"Missing argument to command “%@”: Expected two coordinates (separated by a comma) or “.”. Examples: “%@:123,456” or “%@:.” or regular expression",
                           shortcut, shortcut, shortcut];
    } else if ([data isEqualToString:@"."]) {
        // Use current location
        CGEventRef ourEvent = CGEventCreate(NULL);
        CGPoint currentLocation = CGEventGetLocation(ourEvent);
        CFRelease(ourEvent);
        
        p.x = (int)currentLocation.x;
        p.y = (int)currentLocation.y;
        verboseLoc = [NSString stringWithFormat:@"current location(%.0f,%.0f)", p.x, p.y];
    } else {
        NSArray *coords = [data componentsSeparatedByString:@","];

        if ([coords count] != 2 ||
            [[coords objectAtIndex:0] isEqualToString:@""] ||
            [[coords objectAtIndex:1] isEqualToString:@""])
        {
            WindowInfo *winInfo = [MouseBaseAction getWindowInfo:data];
            if (winInfo != nil) {
                p = winInfo->bounds.origin;
                verboseLoc = [NSString stringWithFormat:@"%@(%.0f,%.0f)", data, p.x, p.y];
//                [NSWorkspace.sharedWorkspace launchApplication:winInfo->title];
//                NSWindow *w = [NSApp windowWithWindowNumber:winInfo->number];
//                if (w != nil) {
//                    [w orderFrontRegardless];
//                }
            } else {
                p.x = 0;
                p.y = 0;
                verboseLoc = [NSString stringWithFormat:@"%.0f,%.0f", p.x, p.y];
            }
        } else {
            p.x = [[self class] getCoordinate:[coords objectAtIndex:0] forAxis:XAXIS];
            p.y = [[self class] getCoordinate:[coords objectAtIndex:1] forAxis:YAXIS];
            
            verboseLoc = [NSString stringWithFormat:@"%@,%@", [coords objectAtIndex:0], [coords objectAtIndex:1]];
        }
    }

    if (MODE_REGULAR != options.mode) {
        [options.verbosityOutputHandler write:[self actionDescriptionString:verboseLoc]];
    }

    if (MODE_TEST == options.mode) {
        return;
    }

    [self performActionAtPoint:p];
}

@end
