//
//  helloFilter.h
//  hello
//
//  Copyright (c) 2019 chunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

#import <OsiriXAPI/BrowserController.h>
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/DicomImage.h>
#import <DCMObject.h>
#import <DCMAttribute.h>
#import <DCMAttributeTag.h>
#import <DCMSequenceAttribute.h>
#import <DCMCalendarDate.h>
#import <method.hpp>

@interface helloFilter : PluginFilter {
    IBOutlet NSWindow *myWindow;
    IBOutlet NSTextField    *lowsche;
    IBOutlet NSTextField *midsche;
    IBOutlet NSTextField *highsche;
    IBOutlet NSTextField    *lowTime;
    IBOutlet NSTextField *midTime;
    
    IBOutlet NSTextField    *periodic;
    IBOutlet NSButton    *cardinal;
    IBOutlet NSButton    *blood;
    
}

- (long) filterImage:(NSString*) menuName;

- (IBAction) doCalculation: (id)sender;


@end
@interface MFPController : NSWindowController  {
    @public
   
    IBOutlet NSImageView         *leftImageView;
    int imageNumber;
    DICOMExport *e;
    IBOutlet NSView *accessoryView;
    BOOL selectedStudyAvailable;
}

- (void) configureImages: (DCMPix *) curpic;
- (DicomImage*) convertImageToDICOM:(NSString *)path source:(DicomImage *)src;
@end

