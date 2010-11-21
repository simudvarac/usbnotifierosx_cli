#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#include <stdlib.h>

void MyInputCallback(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength)
{
    NSLog(@"MyInputCallback called");
    // process device response buffer (report) here 
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    const long productId = 0x1320;
    const long vendorId = 0x1294;
    size_t bufferSize = 5;
    char *inputBuffer = malloc(bufferSize);
    char *outputBuffer = malloc(bufferSize);
    int color = 0x00;
    
    //0) get color from command line
    if(argc > 1){
        color = atoi(argv[1]);
    } else {
        NSLog(@"Must be run with color argument");
    }
    

    //1) Setup your manager and schedule it with the main run loop:
    
    IOHIDManagerRef managerRef = IOHIDManagerCreate(kCFAllocatorDefault,
                                                    kIOHIDOptionsTypeNone);
    IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetMain(),
                                    kCFRunLoopDefaultMode);
    IOReturn ret = IOHIDManagerOpen(managerRef, 0L);
    
    //2) Get your device:
    

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLong:productId] forKey:[NSString
                                                                stringWithCString:kIOHIDProductIDKey encoding:NSUTF8StringEncoding]];
    [dict setObject:[NSNumber numberWithLong:vendorId] forKey:[NSString
                                                               stringWithCString:kIOHIDVendorIDKey encoding:NSUTF8StringEncoding]];
    IOHIDManagerSetDeviceMatching(managerRef, (CFMutableDictionaryRef)dict); NSSet *allDevices = [((NSSet *)IOHIDManagerCopyDevices(managerRef)) autorelease];
    NSArray *deviceRefs = [allDevices allObjects];
    IOHIDDeviceRef deviceRef = ([deviceRefs count]) ?
    (IOHIDDeviceRef)[deviceRefs objectAtIndex:0] : nil;
    
    //3) Setup your buffers (I'm making the assumption the input and output buffer sizes are 64 bytes):
    

    IOHIDDeviceRegisterInputReportCallback(deviceRef, (uint8_t *)inputBuffer, bufferSize, MyInputCallback, NULL);
    
    //4) Send your message to the device (I'm assuming report ID 0):
    
    // populate output buffer
    // ....
    outputBuffer[0] = color;
    outputBuffer[1] = 0x04;
    outputBuffer[2] = 0x04;
    outputBuffer[3] = 0x04;
    outputBuffer[4] = 0x04;
    //outputBuffer[5] = 0x1;
    //outputBuffer[6] = 0x1;
    //outputBuffer[7] = 0x1;
    
    IOReturn sendRet = IOHIDDeviceSetReport(deviceRef, kIOHIDReportTypeOutput, 0, (uint8_t *)outputBuffer, bufferSize);



    //5) Enter main run loop (which will call MyInputCallback when data has come back from the device):
    
    //[[NSRunLoop mainRunLoop] run];
    
    
    
    [pool drain];
    return 0;
}


