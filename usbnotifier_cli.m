#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#include <stdlib.h>

#define OFF 0x00
#define BLUE 0x01
#define RED 0x02
#define GREEN 0x03
#define LTBLUE 0x04
#define PURPLE 0x05
#define YELLOW 0x06
#define WHITE 0x07

void MyInputCallback(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength)
{
    NSLog(@"MyInputCallback called");
    // process device response buffer (report) here 
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    IOReturn sendRet;
    IOReturn ret;
    const long productId = 0x1320;
    const long vendorId = 0x1294;
    size_t bufferSize = 5;
    //char *inputBuffer = malloc(bufferSize);
    char *outputBuffer = malloc(bufferSize);
    memset(outputBuffer, 0, bufferSize);
	NSMutableArray *pattern = [[NSMutableArray alloc] init];
    
    //0) get colors from command line
	for(int i = 1; i < argc; i++){
		[pattern addObject:[NSNumber numberWithInt:atoi(argv[i])]];
	}
    
	/*  
     *
     * This code borrows heavily (pretty much completely) from http://osdir.com/ml/usb/2009-09/msg00019.html 
     *
     */
	
    //1) Setup your manager and schedule it with the main run loop:
    
    IOHIDManagerRef managerRef = IOHIDManagerCreate(kCFAllocatorDefault,
                                                    kIOHIDOptionsTypeNone);
    IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetMain(),
                                    kCFRunLoopDefaultMode);
    ret = IOHIDManagerOpen(managerRef, 0L);
    
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
    

    //IOHIDDeviceRegisterInputReportCallback(deviceRef, (uint8_t *)inputBuffer, bufferSize, MyInputCallback, NULL);
    
    //4) Send your message to the device (I'm assuming report ID 0):
    
    // populate output buffer
    // ....
   
	for (NSNumber *n in [pattern objectEnumerator]){
		outputBuffer[0] = [n integerValue];
		sendRet = IOHIDDeviceSetReport(deviceRef, kIOHIDReportTypeOutput, 0, (uint8_t *)outputBuffer, bufferSize);
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
	}   

    //5) Enter main run loop (which will call MyInputCallback when data has come back from the device):
    
    //[[NSRunLoop mainRunLoop] run];
    
    
    
    [pool drain];
    return 0;
}


