#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

int main(int argc, const char * argv[]) {
    int ret = 0;
    @autoreleasepool {
        TISInputSourceRef currentInputSource = TISCopyCurrentKeyboardInputSource();
        NSString *sourceId = (__bridge NSString *)(TISGetInputSourceProperty(currentInputSource, kTISPropertyInputSourceID));
        printf("%s", [sourceId UTF8String]);
        if (argc > 1) {
            NSString *inputSource = [NSString stringWithUTF8String:argv[1]];
            NSDictionary *filter = [NSDictionary dictionaryWithObject:inputSource forKey:(NSString *)kTISPropertyInputSourceID];
            CFArrayRef keyboards = TISCreateInputSourceList((__bridge CFDictionaryRef)filter, false);
            if (keyboards) {
                TISInputSourceRef selected = (TISInputSourceRef)CFArrayGetValueAtIndex(keyboards, 0);
                // Switch to the selected keyboard only if it is different from the current one,
                // This is to avoid too many notifications to user.
                if (sourceId != (__bridge NSString *)(TISGetInputSourceProperty(selected, kTISPropertyInputSourceID))) {
                    ret = TISSelectInputSource(selected);
                }
                CFRelease(keyboards);
            } else {
                ret = 1;
            }
        }
        CFRelease(currentInputSource);
    }
    return ret;
}
