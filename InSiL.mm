//
//  helloFilter.m
//  hello
//
//  Copyright (c) 2019 chunyu. All rights reserved.
//

#import "helloFilter.h"
#import "OsiriXAPI/DICOMExport.h"
#import "OsiriXAPI/DicomDatabase.h"
//#import "imebra.h"

@implementation MFPController

- (DicomImage*) convertImageToDICOM:(NSString *)path source:(DicomImage *)src
{
   
  
    DicomImage *createdDicomImage = nil;
    
    NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
    
    //if we have an image  get the info we need from the imageRep.
    if (image)
    {
        NSBitmapImageRep *rep = (NSBitmapImageRep*) [image bestRepresentationForDevice:nil];
        
        if ([rep isMemberOfClass: [NSBitmapImageRep class]])
        {
            [e setPixelNSImage:(NSImage*) src];
            
            int bpp = [rep bitsPerPixel]/[rep samplesPerPixel];
            int spp = [rep samplesPerPixel];
            
            if( [rep bitsPerPixel] == 32 && spp == 3)
            {
                bpp = 8;
                spp = 4;
            }
            
            [e setPixelData: [rep bitmapData] samplesPerPixel: spp bitsPerSample: bpp width:[rep pixelsWide] height:[rep pixelsHigh]];
            
            if( [rep isPlanar])
                NSLog( @"********** DCMJpegImportFilter Planar is not yet supported....");
            
            NSString *createdFile = [e writeDCMFile: nil];
            
            if( createdFile)
            {
                DicomDatabase *db = [[BrowserController currentBrowser] database];
                
                NSArray *objects = [db addFilesAtPaths: [NSArray arrayWithObject: createdFile]
                                     postNotifications: YES
                                             dicomOnly: YES
                                   rereadExistingItems: YES
                                     generatedByOsiriX: YES];
                
                NSArray *images = [db objectsWithIDs: objects];
                
                if( images.count)
                    createdDicomImage = [images objectAtIndex: 0];
            }
        }
    }
    
    return createdDicomImage;
}
- (void) configureImages:(DCMPix *) curpic
{
    
    NSWindowController *window=[[NSWindowController alloc]initWithWindowNibName:@"view"
                                                                          owner:self];
    [window showWindow:self];
    
    NSImage         *leftImage   = [curpic image];
    
    [leftImageView setImage:leftImage];
    
    
    
    @try
    {
        
        
        DicomImage *sourceImage = [curpic imageObj];
        id sourceStudy = nil;
        
      
            selectedStudyAvailable = YES;
        
        
     
        
        if( e == nil)
            e = [[DICOMExport alloc] init];
        
        int seriesNumber = 86532 + [[NSCalendarDate date] minuteOfHour] + [[NSCalendarDate date] secondOfMinute];
        [e setSeriesNumber: seriesNumber];
        
        BOOL supportCustomMetaData = NO;
        
        if( [e respondsToSelector: @selector( metaDataDict)])
            supportCustomMetaData = YES;
        
        if( selectedStudyAvailable == NO)
        {
            if( supportCustomMetaData == NO)
            {
                NSRunAlertPanel( @"JPEG to DICOM", @"First, select a study in the database where to put the image.", @"OK", nil, nil);
                //return -1;
            }
            
            [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey: @"JPEGtoDICOMMetaDataTag"];
        }
        
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        
        [openPanel setCanChooseDirectories: YES];
        [openPanel setAllowsMultipleSelection: YES];
        [openPanel setTitle:NSLocalizedString( @"Import", nil)];
        [openPanel setMessage:NSLocalizedString( @"Select image or folder of images to convert to DICOM", nil)];
        
        if( supportCustomMetaData)
        {
            [openPanel setAccessoryView: accessoryView];
            
            if( [self hasOSXElCapitan])
                openPanel.accessoryViewDisclosed = YES;
        }
        
        if( [openPanel runModalForTypes:[NSImage imageFileTypes]] == NSOKButton)
        {
            BOOL valid = YES;
            
            if( supportCustomMetaData && ([[NSUserDefaults standardUserDefaults] integerForKey: @"JPEGtoDICOMMetaDataTag"] == 0 || (sourceImage == nil && [[NSUserDefaults standardUserDefaults] integerForKey: @"JPEGtoDICOMMetaDataTag"] == 1 && sourceStudy != nil)))
            {
                sourceImage = nil;
                
                NSMutableDictionary *metaData = e.metaDataDict;
                
                if( [[NSUserDefaults standardUserDefaults] integerForKey: @"JPEGtoDICOMMetaDataTag"] == 1)
                {
                    [metaData setValue: [sourceStudy valueForKey: @"name"] forKey: @"patientsName"];
                    [metaData setValue: [sourceStudy valueForKey: @"name"] forKey: @"patientName"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"patientID"] forKey: @"patientID"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"dateOfBirth"] forKey: @"patientsBirthdate"];
                    [metaData setValue: [sourceStudy valueForKey: @"dateOfBirth"] forKey: @"patientBirthdate"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"patientSex"] forKey: @"patientsSex"];
                    [metaData setValue: [sourceStudy valueForKey: @"patientSex"] forKey: @"patientSex"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"date"] forKey: @"studyDate"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"studyName"] forKey: @"studyDescription"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"modality"] forKey: @"modality"];
                    
                    [metaData setValue: [sourceStudy valueForKey: @"studyInstanceUID"] forKey: @"studyUID"];
                    [metaData setValue: [sourceStudy valueForKey: @"studyID"] forKey: @"studyID"];
                }
                else
                {
                    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
                    
                    [metaData setValue: [d valueForKey: @"JPEGtoDICOMPatientsName"] forKey: @"patientsName"];
                    [metaData setValue: [d valueForKey: @"JPEGtoDICOMPatientsName"] forKey: @"patientName"];
                    
                    [metaData setValue: [d valueForKey: @"JPEGtoDICOMPatientsID"] forKey: @"patientID"];
                    
                    [metaData setValue: [d objectForKey: @"JPEGtoDICOMPatientsDOB"] forKey: @"patientsBirthdate"];
                    [metaData setValue: [d objectForKey: @"JPEGtoDICOMPatientsDOB"] forKey: @"patientBirthdate"];
                    
                    if( [d integerForKey: @"JPEGtoDICOMPatientsSex"])
                    {
                        [metaData setValue: @"F" forKey: @"patientsSex"];
                        [metaData setValue: @"F" forKey: @"patientSex"];
                    }
                    else
                    {
                        [metaData setValue: @"M" forKey: @"patientsSex"];
                        [metaData setValue: @"M" forKey: @"patientSex"];
                    }
                    
                    [metaData setValue: [d objectForKey: @"JPEGtoDICOMStudyDate"] forKey: @"studyDate"];
                    
                    [metaData setValue: [d valueForKey: @"JPEGtoDICOMStudyDescription"] forKey: @"studyDescription"];
                    
                    [metaData setValue: [d valueForKey: @"JPEGtoDICOMModality"] forKey: @"modality"];
                }
                
                [e setModalityAsSource: YES];
            }
            else
                [e setModalityAsSource: NO];
            
            if( valid)
            {
                imageNumber = 0;
                BOOL seriesDescriptionSet = NO;
                
                for( NSString *fpath in [openPanel filenames])
                {
                    BOOL isDir;
                    if( [[NSFileManager defaultManager] fileExistsAtPath:fpath isDirectory:&isDir])
                    {
                        if (isDir)
                        {
                            [e setSeriesDescription: [[fpath lastPathComponent] stringByDeletingPathExtension]];
                            [e setSeriesNumber: seriesNumber++];
                            
                            NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: fpath];
                            NSString *path;
                            while( path = [dirEnumerator nextObject])
                                if( [[NSImage imageFileTypes] containsObject: [path pathExtension]]
                                   || [[NSImage imageFileTypes] containsObject: NSFileTypeForHFSTypeCode( [[[[NSFileManager defaultManager] attributesOfFileSystemForPath: path error: nil] objectForKey: NSFileHFSTypeCode] longValue])])
                                {
                                    DicomImage *f = [self convertImageToDICOM:[fpath stringByAppendingPathComponent:path] source: sourceImage];
                                    
                                    if( sourceImage == nil)
                                        sourceImage = f;
                                }
                        }
                        else
                        {
                            if( seriesDescriptionSet == NO)
                            {
                                [e setSeriesDescription: [[fpath lastPathComponent] stringByDeletingPathExtension]];
                                seriesDescriptionSet = YES;
                            }
                            
                            DicomImage *f = [self convertImageToDICOM: fpath source: sourceImage];
                            
                            if( sourceImage == nil)
                                sourceImage = f;
                        }
                    }
                }
            }
        }
    }
    @catch ( NSException *ex) {
        NSLog( @"%@", ex);
    }
    @finally {
        [e release];
        e = nil;
    }

        
    

    
}
@end


@implementation helloFilter

- (void) initPlugin
{
    
    
}

- (long) filterImage:(NSString*) menuName
{
	
    NSWindowController *window=[[NSWindowController alloc]initWithWindowNibName:@"Hello_BMR_Panel"
                                                                          owner:self];
    [window showWindow:self];
    
    
    return 0;
    
}
/*
- (void) processSeries:(DicomSeries*) series {
    NSLog(@"processSeries: %@", [series name]);
    NSLog(@"processSeries: %@", [series name]);
    
    for (id image in [series sortedImages]) {
        NSLog(@"path:  %@",[image completePath]);
        NSLog(@"frame: %@", [[image frameID] stringValue]);
        
        // Load DICOM Object
        DCMObject *dcmObject  = [DCMObject objectWithContentsOfFile:
                                 [image completePath] decodingPixelData:false];
        
        // Patient ID
        NSString *patID   = [[dcmObject attributeForTag:
                              [DCMAttributeTag tagWithGroup:0x10 element:0x20]] value];
        NSLog(@"patID: %@",patID);
        
        // Acquistion Date & Time
        DCMCalendarDate *acqDateTime = [[dcmObject attributeForTag:
                                         [DCMAttributeTag tagWithGroup:0x8 element:0x2A]] value];
        if (acqDateTime == nil) {
            DCMCalendarDate *acqDate = [[dcmObject attributeForTag:
                                         [DCMAttributeTag tagWithGroup:0x8 element:0x22]] value];
            DCMCalendarDate *acqTime = [[dcmObject attributeForTag:
                                         [DCMAttributeTag tagWithGroup:0x8 element:0x32]] value];
            
            acqDateTime = [DCMCalendarDate dicomDateTimeWithDicomDate:acqDate
                                                            dicomTime:acqTime];
        }
        
        NSLog(@"Acquisition DateTime: %@",acqDateTime);
        
        // Get information on energy windows
        int energyWindowUsed = 0;
        
        NSNumber *numOfEnergyWin = [[dcmObject attributeForTag:
                                     [DCMAttributeTag tagWithGroup:0x54 element:0x11]] value];
        NSLog(@"numOfEnergyWin: %@", numOfEnergyWin);
        
        NSArray *energyWinVec = [[dcmObject attributeForTag:
                                  [DCMAttributeTag tagWithGroup:0x54 element:0x10]] values];
        NSLog(@"energyWinVec %@", energyWinVec);
        
        if (energyWinVec != nil) {
            int frameNo = 0;
            if ([image frameID] != nil)
                frameNo = [[image frameID] intValue];
            
            if (frameNo >= [energyWinVec count])
                frameNo = 0;
            
            energyWindowUsed = [[energyWinVec objectAtIndex:frameNo] intValue]-1;
        }
        
        
        // Energy Window Information Sequence
        DCMSequenceAttribute *energyWinInfoSeq = (DCMSequenceAttribute*)
        [dcmObject attributeForTag:
         [DCMAttributeTag tagWithGroup:0x54 element:0x12]];
        
        DCMObject *energyWinInfoItem = [[energyWinInfoSeq sequence]
                                        objectAtIndex:energyWindowUsed];
        DCMSequenceAttribute *energyWinRangeSeq = (DCMSequenceAttribute*)
        [energyWinInfoItem attributeForTag:
         [DCMAttributeTag tagWithGroup:0x54 element:0x13]];
        
        for (DCMObject *energyWinRangeItem in [energyWinRangeSeq sequence])
            NSLog(@"EnergyWindowLowerLimit: %@, EnergyWindowUpperLimit: %@",
                  [[energyWinRangeItem attributeForTag:
                    [DCMAttributeTag tagWithGroup:0x54 element:0x14]] values],
                  [[energyWinRangeItem attributeForTag:
                    [DCMAttributeTag tagWithGroup:0x54 element:0x15]] values]);
    }
}
 */
/**
- (void)threadAction: (float[181][51][8]) Dic,(float[11800][8]) pictures{
    @autoreleasepool {
        //新线程不会干扰到主线程
        [[NSThread currentThread].threadDictionary setObject:@(false) forKey:@"isEixt"];
       
            if ([[[NSThread currentThread].threadDictionary valueForKey:@"isEixt"]boolValue]) {
                return;
            }
            //在新线程中调用
        int x=60000;
        int zSize=8;
        for (int i=0;i<x;i++){
            //for each pixel in 11 pictures
            for (int j=0;j<zSize;j++){
                pixels[j]=pictures[j][i];
                //NSLog(@"pixel:%f",pixels[j]);
                int sign=1;
                //if(cos (( pictures1[j][i]-pictures1[4][i]) /4096*pi)<0){
                //  sign=-1;
                //}
                pixels[j]=sign*pixels[j];
                //NSLog(@"pixelNo.%d: %f",j,pixels[j]);
            }
            float finalT=0;
            float finalCost=0;
            //遍历dictionary
            for (int m=0;m<181;m++){
                
                for (int n=0;n<50;n++){
                    
                    
                    
                    //求m0;
                    float sum1=0;
                    float sum2=0;
                    for(int x=0;x<N;x++){
                        sum1=sum1+Dic[m][n][x]*pixels[x];
                        
                        sum2=sum2+Dic[m][n][x]*Dic[m][n][x];
                    }
                    
                    m0=sum1/sum2;
                    //NSLog(@"T1:%d",T[m]);
                    //NSLog(@"c:%f",C[n]);
                    //NSLog(@"optimzed m0: %f",m0);
                    
                    
                    float cost;
                    cost=0;
                    for(int x=0;x<N;x++){
                        //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                        cost=cost+(Dic[m][n][x]*m0-pixels[x])*(Dic[m][n][x]*m0-pixels[x]);
                        
                    }
                    //NSLog(@"COST:%f",cost);
                    if(finalT==0){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    else if(finalCost>cost){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    
                    
                    //NSLog(@"finalT:%f",finalT);
                    // NSLog(@"finalCost:%f",finalCost);
                    
                }
                
                
            }
            NSLog(@"finalNO.%d,T1:%f",i,finalT);
            //NSLog(@"finalT:%f",finalT);
            T_pic[i]=finalT;
            
        }
        
    }
}

*/

- (IBAction) doCalculation: (id)sender
{
  //  NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadAction) object:nil];
 //   [thread start];
       //开启线程
   
    
    
    
    NSLog(@"doCalculation!!!");
    NSLog(@"doCalculation!!!");
    NSLog(@"doCalculation!!!");
    NSLog(@"doCalculation!!!");
    
    //[myWindow orderOut:sender];
    //[NSApp endSheet:myWindow returnCode:[sender tag]];
    int schemes[3]={5,3,3};
    float Tall[3]={100,180,260};
    float theta=0.96;
    
    int        lows       = [lowsche intValue];
    int         mids      = [midsche intValue];
    int         highs        = [highsche intValue];
    int period =[periodic intValue];
    if(lows!=0){
        schemes[0]=lows;
        NSLog(@"schemes0:%d",schemes[0]);
    }
    if(mids!=0){
        schemes[1]=mids;
        NSLog(@"schemes1:%d",schemes[1]);
    }
    if(highs!=0&&period==3){
        schemes[2]=highs;
         NSLog(@"schemes2:%d",schemes[2]);
    }

    
    float        low       = [lowTime floatValue];
    float        step       = [midTime floatValue];
    
    if(low!=0){
        Tall[0]=low;
         NSLog(@"Tall0:%f",Tall[0]);
    }
    if(step!=0){
        Tall[1]=low+step;
         NSLog(@"Tall1:%f",Tall[1]);
    }
    if(period==3){
        Tall[2]=low+step*2;
         NSLog(@"Tall2:%f",Tall[2]);
    }
     //pixList1=[[NSMutableArray alloc] initWithCapacity:0];
      //theta      = [thetaGetter floatValue];
 /**
    BrowserController *currentBrowser = [BrowserController currentBrowser];
    
    NSArray *selectedItems = [currentBrowser databaseSelection];

    if ([selectedItems count] == 0) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@"No studies/series selected!"];
        [alert runModal];
        
       
    }
    NSMutableArray        *pixList,*pixList1;
    pixList=[[NSMutableArray alloc] initWithCapacity:0];
    pixList1=[[NSMutableArray alloc] initWithCapacity:0];
    int count=0;
    NSLog(@"count:%lu",[selectedItems count]);
    if([selectedItems count]==2){
    for (id item in selectedItems) {
        if(count==0){
        if ([item isKindOfClass:[DicomStudy class]]) {
            DicomStudy *study = (DicomStudy*) item;
            
            for (DicomSeries *series in [study imageSeries]){
                NSLog(@"processSeries_study: %@", [series name]);
                
                for (id image in [series sortedImages])
                    NSLog(@"image: %@", [[image frameID] stringValue]);
            
            }
                
            
        } else if ([item isKindOfClass:[DicomSeries class]]){
            NSLog(@"processSeries_normal: %@", [(DicomSeries*) item name]);
            //对于每个目录下的每个图片，输出路径等，现在生成一个DCMpix是我的目标！！！！！！！！！！！
            for (id image in [(DicomSeries*) item sortedImages]){
                NSLog(@"image: %@", [image completePath] );
                DCMPix *cur;
                cur=[[DCMPix alloc] initWithImageObj:(DicomImage*)image];
                [pixList addObject: cur];
              //  cur = [[DCMPix alloc] initWithPath:dicomImage.completePath :0 :1 :nil :frameNo :0 isBonjour:NO imageObj:dicomImage];
            }
        }
            count++;
        }else{
            if ([item isKindOfClass:[DicomStudy class]]) {
                DicomStudy *study = (DicomStudy*) item;
                
                for (DicomSeries *series in [study imageSeries]){
                    NSLog(@"processSeries_study: %@", [series name]);
                    
                    for (id image in [series sortedImages])
                        NSLog(@"image: %@", [[image frameID] stringValue]);
                    
                }
                
                
            } else if ([item isKindOfClass:[DicomSeries class]]){
                NSLog(@"processSeries_normal: %@", [(DicomSeries*) item name]);
                //对于每个目录下的每个图片，输出路径等，生成一个DCMpix是我的目标！！！！！！！！！！！
                for (id image in [(DicomSeries*) item sortedImages]){
                    NSLog(@"image: %@", [image completePath] );
                    DCMPix *cur;
                    cur=[[DCMPix alloc] initWithImageObj:(DicomImage*)image];
                    [pixList1 addObject: cur];
                    //  cur = [[DCMPix alloc] initWithPath:dicomImage.completePath :0 :1 :nil :frameNo :0 isBonjour:NO imageObj:dicomImage];
                }
        }
        
    }
    }
    }
    else if([selectedItems count]==1){
        int cc=0;
        for (id item in selectedItems) {
        if ([item isKindOfClass:[DicomStudy class]]) {
            DicomStudy *study = (DicomStudy*) item;
            
            for (DicomSeries *series in [study imageSeries]){
                NSLog(@"processSeries_study: %@", [series name]);
                
                for (id image in [series sortedImages])
                    NSLog(@"image: %@", [[image frameID] stringValue]);
                
            }
            
            
        } else if ([item isKindOfClass:[DicomSeries class]]){
            NSLog(@"processSeries_normal: %@", [(DicomSeries*) item name]);
            //对于每个目录下的每个图片，输出路径等，现在生成一个DCMpix是我的目标！！！！！！！！！！！
            for (id image in [(DicomSeries*) item sortedImages]){
                NSLog(@"image: %@", [image completePath] );
                DCMPix *cur;
                cur=[[DCMPix alloc] initWithImageObj:(DicomImage*)image];
                if(cc%2==0){
                [pixList addObject: cur];
                }
                else{
                    [pixList1 addObject: cur];
                }
                cc++;
                //  cur = [[DCMPix alloc] initWithPath:dicomImage.completePath :0 :1 :nil :frameNo :0 isBonjour:NO imageObj:dicomImage];
            }
            NSLog(@"cc:%d",cc);
        }
    }
    }
    
    
    
    */
    NSArray         *pixListSum = [viewerController pixList];
    int count=[pixListSum count];
    NSLog(@"数量:%d",count);
    int card=[cardinal intValue];
    int bl=[blood intValue];
    DCMPix *cur=[pixListSum objectAtIndex:0];
    int x            = [cur pheight] * [cur pwidth];
    
    if(count==11 || (count>11&& count<16)){
        int zSize=11;
        float times[zSize];
        float *pictures[zSize];
        setSize(zSize);
       
        for (int i = 0; i < zSize; i++)
        {
            //选择一个2d图像
            NSArray *pixList=pixListSum;
            DCMPix  *curPix        = [pixList        objectAtIndex:i];
            // curPixNew   = [pixListNew   objectAtIndex:i];
            float *f=[curPix fImage];
            pictures[i]=f;
            NSString        *file_path = [curPix sourceFile];
            /**
            if(i==0){
                NSString        *dicomTag = @"0020,0011";
                DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
                
                DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
                if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
                
                NSString        *val;
                DCMAttribute    *attr;
                
                if (tag && tag.group && tag.element)
                {
                    attr = [dcmObj attributeForTag:tag];
                    
                    val = [[attr value] description];
                    
                }
                serial = [val floatValue];
            }
             
             */
            NSString        *dicomTag = @"0008,0032";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            //NSLog(@"tt: %@",val);
            
            float time = [val floatValue];
            
            
            //NSLog(@"zhuanhuan: %f",time);
            
            
            times[i]=time;
        }
        
        
        
        
        //sort
        float tmp;
        float *p;
        for(int i = 0 ; i < zSize ; i++){
            
            for(int j = i+1 ; j <zSize; j++){
                
                if(times[i] > times[j]){
                    tmp=times[i];
                    times[i]=times[j];
                    times[j]=tmp;
                    
                    
                    p=pictures[i];
                    pictures[i]=pictures[j];
                    pictures[j]=p;
                    
                    
                }
            }
        }
        
        float intervals[zSize+2];
       
            for (int i=0;i<zSize+2;i++){
                if(i==0){
                    intervals[0]=Tall[0];
                }
                else if(i==schemes[0]){
                    intervals[i]=(times[i]-times[i-1])*1000-Tall[1];
                }
                else if (i==schemes[0]+1){
                    intervals[i]=Tall[1];
                }
                else if (i==schemes[0]+schemes[1]+1){
                    intervals[i]=(times[i-1]-times[i-2])*1000-Tall[2];
                }
                else if (i==schemes[0]+schemes[1]+2){
                    intervals[i]=Tall[2];
                }
                else if(i<schemes[0]){
                    intervals[i]=(times[i]-times[i-1])*1000;
                    
                }
                else if (i<schemes[0]+schemes[1]+1){
                    intervals[i]=(times[i-1]-times[i-2])*1000;
                }
                else {
                    intervals[i]=(times[i-2]-times[i-3])*1000;
                }
                NSLog(@"intervals: %f",intervals[i]);
            }
        setInter(intervals);
        float pixels[zSize];
        float T_pic[x];
        if(card==1){
            theta=0.96;
        }
        else if (bl==1){
            theta=1;
        }
        setTheta(theta);
        //图像在pictures里面，时间在intervals里面
        /*
        int T[181];
        int count1=0;
        for(int i=200;i<=2000;i=i+10){
            T[count1]=i;
            count1++;
        }
        NSLog(@"count1: %d",count1);
        
        float C[10];
        int count2=0;
        for (float o=0;o<0.5;o=o+0.05){
            C[count2]=o;
            count2++;
        }
        
        NSLog(@"count2: %d",count2);
        //定义dictionary
        int P=3;
        int N=0;
        
        for(int i=0;i<P;i++){
            N=N+schemes[i];
        }
        float m0;
        float pixels[zSize];
        if(card==1){
            theta=0.96;
        }
        else if (bl==1){
            theta=1;
        }
        float T_pic[x];
        float Dic[181][10][zSize];
        
        for (int m=0;m<181;m++){
            
            for (int n=0;n<10;n++){
                int  count=0;
                int res_point=0;
                float res=0;
                m0=1;
                float mall_before=13;
                mall_before=-1*theta*m0;
                
                for(int q=0;q<P;q++){
                    int t=count;
                    for (int r=t;r<t+schemes[q];r++){
                        
                        res=(m0+(mall_before-m0)*exp(-(intervals[r]/T[m])));
                        
                        mall_before=(1-C[n])*res;
                        if(res<0){
                        Dic[m][n][res_point]=-res;
                        }else{
                             Dic[m][n][res_point]=res;
                        }
                        
                        
                        res_point++;
                        count=count+1;
                    }
                    if(count<P+N-1){
                        m0=(m0+(mall_before-m0)*exp(-(intervals[count])/T[m]));
                        mall_before=(-1*theta)*m0;
                        count=count+1;
                    }
                }
            }}
        //i=46376
        */
        setpixels(pictures);
        
        for (int i=0;i<=x;i++){
            //for each pixel in 11 pictures
            /*
            for (int j=0;j<zSize;j++){
                pixels[j]=pictures[j][i];
                //NSLog(@"pixel:%f",pixels[j]);
                int sign=1;
                //if(cos (( pictures1[j][i]-pictures1[4][i]) /4096*pi)<0){
                  //  sign=-1;
                //}
                pixels[j]=sign*pixels[j];
                //NSLog(@"pixelNo.%d: %f",j,pixels[j]);
            }
             */
            setIndex(i);
            //NSLog(@" %f",test());
            hello();
            float T=0;
            /*
            float finalT=0;
            float finalCost=0;
            //遍历dictionary
            for (int m=0;m<181;m++){
                
                for (int n=0;n<10;n++){
                    
                    
                    
                    //求m0;
                    float sum1=0;
                    float sum2=0;
                    for(int x=0;x<N;x++){
                        sum1=sum1+Dic[m][n][x]*pixels[x];
                        
                        sum2=sum2+Dic[m][n][x]*Dic[m][n][x];
                    }
                    
                    m0=sum1/sum2;
                    //NSLog(@"T1:%d",T[m]);
                    //NSLog(@"c:%f",C[n]);
                    //NSLog(@"optimzed m0: %f",m0);
                    
                    
                    float cost;
                    cost=0;
                    for(int x=0;x<N;x++){
                        //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                        cost=cost+(Dic[m][n][x]*m0-pixels[x])*(Dic[m][n][x]*m0-pixels[x]);
                        
                    }
                    //NSLog(@"COST:%f",cost);
                    if(finalT==0){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    else if(finalCost>cost){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    
                    
                    //NSLog(@"finalT:%f",finalT);
                    // NSLog(@"finalCost:%f",finalCost);
                    
                }
                
                
            }
            NSLog(@"finalNO.%d,T1:%f",i,finalT);
            //NSLog(@"finalT:%f",finalT);
             */
            NSLog(@"finalNO.%d,T1:%f",i,T);
            T_pic[i]=T;
            
        }
        
        cur        = [pixListSum        objectAtIndex:0];
        
         float *f        = [cur       fImage];
         
         for (int j=0;j<x;j++){
         //fImageNew[j]=-fImage[j];
         f[j]=T_pic[j];
         
         }
        
        NSMutableData   *volumeData     = [[NSMutableData alloc] initWithLength:0];
        NSMutableArray  *pix        = [[NSMutableArray alloc] initWithCapacity:0];
        
        int sliceCount      = 1;
        int pixWidth        = [cur pheight], pixHeight = [cur pwidth];
        
        float   pixelSpacingX = 1, pixelSpacingY = 1;
        float   originX = 0, originY = 0, originZ = 0;
        int     colorDepth = 32;
        
        long mem            = pixWidth * pixHeight * sliceCount * 4; // 4 Byte = 32 Bit Farbwert
        float *fVolumePtr   =(float *) malloc(mem);
        
        
        for( int i = 0; i < sliceCount; i++)
        {
            
            long size = sizeof( float) * pixWidth * pixHeight;
            float *imagePtr = (float *)malloc( size);
            DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
            free( imagePtr);
            [pix addObject: cur];
            
        }
        
        if( fVolumePtr)
        {
            volumeData = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
        }
        
        NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
        
        ViewerController *Viewer = [viewerController newWindow:pix :newFileArray :volumeData];
        
        
        
        
    }
    
    else if (count>=22){
        int zSize=11;
        setSize(zSize);
        setMode(1);
        float times[zSize];
        float *pictures[zSize];
        
        NSMutableArray *pixList=[[NSMutableArray alloc] initWithCapacity:0];;
        NSMutableArray *pixList1=[[NSMutableArray alloc] initWithCapacity:0];;
        for (int i = 0; i < count; i++)
        {
            //选择一个2d图像
            if(i%2==1)
                [pixList addObject:[pixListSum objectAtIndex: i]];
            else if (i%2==0){
                [pixList1 addObject:[pixListSum objectAtIndex: i]];
            }
        }
        
        
        float serial;
        for (int i = 0; i < zSize; i++)
        {
            //选择一个2d图像
            
            DCMPix  *curPix        = [pixList        objectAtIndex:i];
            // curPixNew   = [pixListNew   objectAtIndex:i];
            float *f=[curPix fImage];
            pictures[i]=f;
            NSString        *file_path = [curPix sourceFile];
            
             if(i==0){
             NSString        *dicomTag = @"0020,0011";
             DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
             
             DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
             if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
             
             NSString        *val;
             DCMAttribute    *attr;
             
             if (tag && tag.group && tag.element)
             {
             attr = [dcmObj attributeForTag:tag];
             
             val = [[attr value] description];
             
             }
             serial = [val floatValue];
             }
             
             
            NSString        *dicomTag = @"0008,0032";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            //NSLog(@"tt: %@",val);
            
            float time = [val floatValue];
            
            
            //NSLog(@"zhuanhuan: %f",time);
            
            
            times[i]=time;
        }
        
        
        
        
        //sort
        float tmp;
        float *p;
        for(int i = 0 ; i < zSize ; i++){
            
            for(int j = i+1 ; j <zSize; j++){
                
                if(times[i] > times[j]){
                    tmp=times[i];
                    times[i]=times[j];
                    times[j]=tmp;
                    
                    
                    p=pictures[i];
                    pictures[i]=pictures[j];
                    pictures[j]=p;
                    
                    
                }
            }
        }
        float times1[zSize];
        float *pictures1[zSize];
        float serial1;
        for (int i = 0; i < zSize; i++)
        {
            //选择一个2d图像
            DCMPix *curPix        = [pixList1        objectAtIndex:i];
            // curPixNew   = [pixListNew   objectAtIndex:i];
            float *f=[curPix fImage];
            pictures1[i]=f;
            NSString        *file_path = [curPix sourceFile];
            
            if(i==0){
                NSString        *dicomTag = @"0020,0011";
                DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
                
                DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
                if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
                
                NSString        *val;
                DCMAttribute    *attr;
                
                if (tag && tag.group && tag.element)
                {
                    attr = [dcmObj attributeForTag:tag];
                    
                    val = [[attr value] description];
                    
                }
                serial1 = [val floatValue];
            }
            
            
            NSString        *dicomTag = @"0008,0032";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            //NSLog(@"tt: %@",val);
            
            float time = [val floatValue];
            
            
            //NSLog(@"zhuanhuan: %f",time);
            
            
            times1[i]=time;
        }
        
        
        
        
        //sort
        for(int i = 0 ; i < zSize ; i++){
            
            for(int j = i+1 ; j <zSize; j++){
                
                if(times1[i] > times1[j]){
                    tmp=times1[i];
                    times1[i]=times1[j];
                    times1[j]=tmp;
                    
                    
                    p=pictures1[i];
                    pictures1[i]=pictures1[j];
                    pictures1[j]=p;
                    
                    
                }
            }
        }
       
        NSLog(@"serial1:%f",serial);
        NSLog(@"serial2:%f",serial1);
        float *tmpp[zSize];
        if(serial>serial1){
            for(int i=0;i<zSize;i++){
                tmpp[i]=pictures1[i];
                pictures1[i]=pictures[i];
                pictures[i]=tmpp[i];
            }
        }
        
        float intervals[zSize+2];
        
        for (int i=0;i<zSize+2;i++){
            if(i==0){
                intervals[0]=Tall[0];
            }
            else if(i==schemes[0]){
                intervals[i]=(times[i]-times[i-1])*1000-Tall[1];
            }
            else if (i==schemes[0]+1){
                intervals[i]=Tall[1];
            }
            else if (i==schemes[0]+schemes[1]+1){
                intervals[i]=(times[i-1]-times[i-2])*1000-Tall[2];
            }
            else if (i==schemes[0]+schemes[1]+2){
                intervals[i]=Tall[2];
            }
            else if(i<schemes[0]){
                intervals[i]=(times[i]-times[i-1])*1000;
                
            }
            else if (i<schemes[0]+schemes[1]+1){
                intervals[i]=(times[i-1]-times[i-2])*1000;
            }
            else {
                intervals[i]=(times[i-2]-times[i-3])*1000;
            }
            NSLog(@"intervals: %f",intervals[i]);
        }
        setInter(intervals);
        setextrapixels(pictures1);
        setpixels(pictures);
        /*
        //图像在pictures里面，时间在intervals里面
        int T[181];
        int count1=0;
        for(int i=200;i<=2000;i=i+10){
            T[count1]=i;
            count1++;
        }
        NSLog(@"count1: %d",count1);
        
        float C[50];
        int count2=0;
        for (float o=0;o<=0.5;o=o+0.01){
            C[count2]=o;
            count2++;
        }
        
        NSLog(@"count2: %d",count2);
         */
        //定义dictionary
        if(card==1){
            theta=0.96;
        }
        else if (bl==1){
            theta=1;
        }
        setTheta(theta);
        float T_pic[x];
        /*
        int P=3;
        int N=0;
        
        for(int i=0;i<P;i++){
            N=N+schemes[i];
        }
        float m0;
        float pixels[zSize];
        
        float T_pic[x];
        float Dic[181][50][zSize];
        
        for (int m=0;m<181;m++){
            
            for (int n=0;n<50;n++){
                int  count=0;
                int res_point=0;
                float res=0;
                m0=1;
                float mall_before=13;
                mall_before=-1*theta*m0;
                
                for(int q=0;q<P;q++){
                    int t=count;
                    for (int r=t;r<t+schemes[q];r++){
                        
                        res=(m0+(mall_before-m0)*exp(-(intervals[r]/T[m])));
                        
                        mall_before=(1-C[n])*res;
                        
                        Dic[m][n][res_point]=res;
                        
                        
                        
                        res_point++;
                        count=count+1;
                    }
                    if(count<P+N-1){
                        m0=(m0+(mall_before-m0)*exp(-(intervals[count])/T[m]));
                        mall_before=(-1*theta)*m0;
                        count=count+1;
                    }
                }
            }}
         */
        //i=46376
        float pixels[zSize];
        for (int i=0;i<x;i++){
            //for each pixel in 11 pictures
            setIndex(i);
            float T=test();
            float finalT=T;
            
            /*
            //遍历dictionary
            for (int m=0;m<181;m++){
                
                for (int n=0;n<50;n++){
                    
                    
                    
                    //求m0;
                    float sum1=0;
                    float sum2=0;
                    for(int x=0;x<N;x++){
                        sum1=sum1+Dic[m][n][x]*pixels[x];
                        
                        sum2=sum2+Dic[m][n][x]*Dic[m][n][x];
                    }
                    
                    m0=sum1/sum2;
                    //NSLog(@"T1:%d",T[m]);
                    //NSLog(@"c:%f",C[n]);
                    //NSLog(@"optimzed m0: %f",m0);
                    
                    
                    float cost;
                    cost=0;
                    for(int x=0;x<N;x++){
                        //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                        cost=cost+(Dic[m][n][x]*m0-pixels[x])*(Dic[m][n][x]*m0-pixels[x]);
                        
                    }
                    //NSLog(@"COST:%f",cost);
                    if(finalT==0){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    else if(finalCost>cost){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    
                    
                    //NSLog(@"finalT:%f",finalT);
                    // NSLog(@"finalCost:%f",finalCost);
                    
                }
                
                */
            
            NSLog(@"finalNO.%d,T1:%f",i,finalT);
            //NSLog(@"finalT:%f",finalT);
            T_pic[i]=finalT;
            
        }
        
        cur        = [pixListSum        objectAtIndex:0];
        
        float *f        = [cur       fImage];
        
        for (int j=0;j<x;j++){
            //fImageNew[j]=-fImage[j];
            f[j]=T_pic[j];
            
        }
        
        NSMutableData   *volumeData     = [[NSMutableData alloc] initWithLength:0];
        NSMutableArray  *pix        = [[NSMutableArray alloc] initWithCapacity:0];
        
        int sliceCount      = 1;
        int pixWidth        = [cur pheight], pixHeight = [cur pwidth];
        
        float   pixelSpacingX = 1, pixelSpacingY = 1;
        float   originX = 0, originY = 0, originZ = 0;
        int     colorDepth = 32;
        
        long mem            = pixWidth * pixHeight * sliceCount * 4; // 4 Byte = 32 Bit Farbwert
        float *fVolumePtr   = (float *)malloc(mem);
        
        
        for( int i = 0; i < sliceCount; i++)
        {
            
            long size = sizeof( float) * pixWidth * pixHeight;
            float *imagePtr = (float *)malloc( size);
            DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
            free( imagePtr);
            [pix addObject: cur];
            
        }
        
        if( fVolumePtr)
        {
            volumeData = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
        }
        
        NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
        
        ViewerController *Viewer = [viewerController newWindow:pix :newFileArray :volumeData];
        
    }
    /*
    else if (count==8|| (count>8&&count<11)){
        int zSize=8;
        float times[zSize];
        float *pictures[zSize];
        
        
        for (int i = 0; i < zSize; i++)
        {
            //选择一个2d图像
            NSArray *pixList=pixListSum;
            DCMPix  *curPix        = [pixList        objectAtIndex:i];
            // curPixNew   = [pixListNew   objectAtIndex:i];
            float *f=[curPix fImage];
            pictures[i]=f;
            NSString        *file_path = [curPix sourceFile];
     
            NSString        *dicomTag = @"0008,0032";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            //NSLog(@"tt: %@",val);
            
            float time = [val floatValue];
            
            
            //NSLog(@"zhuanhuan: %f",time);
            
            
            times[i]=time;
        }
        
        
        
        
        //sort
        float tmp;
        float *p;
        for(int i = 0 ; i < zSize ; i++){
            
            for(int j = i+1 ; j <zSize; j++){
                
                if(times[i] > times[j]){
                    tmp=times[i];
                    times[i]=times[j];
                    times[j]=tmp;
                    
                    
                    p=pictures[i];
                    pictures[i]=pictures[j];
                    pictures[j]=p;
                    
                    
                }
            }
        }
        float intervals[zSize+1];
        for (int i=0;i<zSize+1;i++){
            if(i==0){
                intervals[0]=Tall[0];
            }
            else if(i==schemes[0]){
                intervals[i]=(times[i]-times[i-1])*1000-Tall[1];
            }
            else if (i==schemes[0]+1){
                intervals[i]=Tall[1];
            }
            
            else if(i<schemes[0]){
                intervals[i]=(times[i]-times[i-1])*1000;
                
            }
            else if (i<schemes[0]+schemes[1]+1){
                intervals[i]=(times[i-1]-times[i-2])*1000;
            }
            
            
        }

        
        
        
        //图像在pictures里面，时间在intervals里面
        int T[181];
        int count1=0;
        for(int i=200;i<=2000;i=i+10){
            T[count1]=i;
            count1++;
        }
        NSLog(@"count1: %d",count1);
        
        float C[50];
        int count2=0;
        for (float o=0;o<=0.5;o=o+0.01){
            C[count2]=o;
            count2++;
        }
        
        NSLog(@"count2: %d",count2);
        //定义dictionary
        int P=3;
        int N=0;
        
        for(int i=0;i<P;i++){
            N=N+schemes[i];
        }
        float m0;
        float pixels[zSize];
        if(card==1){
            theta=0.96;
        }
        else if (bl==1){
            theta=1;
        }
        float T_pic[x];
        float Dic[181][50][zSize];
        
        for (int m=0;m<181;m++){
            
            for (int n=0;n<50;n++){
                int  count=0;
                int res_point=0;
                float res=0;
                m0=1;
                float mall_before=13;
                mall_before=-1*theta*m0;
                
                for(int q=0;q<P;q++){
                    int t=count;
                    for (int r=t;r<t+schemes[q];r++){
                        
                        res=(m0+(mall_before-m0)*exp(-(intervals[r]/T[m])));
                        
                        mall_before=(1-C[n])*res;
                        if(res<0){
                            Dic[m][n][res_point]=-res;
                        }else{
                            Dic[m][n][res_point]=res;
                        }
                        
                        
                        res_point++;
                        count=count+1;
                    }
                    if(count<P+N-1){
                        m0=(m0+(mall_before-m0)*exp(-(intervals[count])/T[m]));
                        mall_before=(-1*theta)*m0;
                        count=count+1;
                    }
                }
            }}
        //i=46376
        
       // NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadAction) object:Dic,pictures];
     //      [thread start];
        
        for (int i=0;i<x;i++){
            //for each pixel in 11 pictures
            for (int j=0;j<zSize;j++){
                pixels[j]=pictures[j][i];
                //NSLog(@"pixel:%f",pixels[j]);
                int sign=1;
                //if(cos (( pictures1[j][i]-pictures1[4][i]) /4096*pi)<0){
                //  sign=-1;
                //}
                pixels[j]=sign*pixels[j];
                //NSLog(@"pixelNo.%d: %f",j,pixels[j]);
            }
            float finalT=0;
            float finalCost=0;
            //遍历dictionary
            for (int m=0;m<181;m++){
                
                for (int n=0;n<50;n++){
                    
                    
                    
                    //求m0;
                    float sum1=0;
                    float sum2=0;
                    for(int x=0;x<N;x++){
                        sum1=sum1+Dic[m][n][x]*pixels[x];
                        
                        sum2=sum2+Dic[m][n][x]*Dic[m][n][x];
                    }
                    
                    m0=sum1/sum2;
                    //NSLog(@"T1:%d",T[m]);
                    //NSLog(@"c:%f",C[n]);
                    //NSLog(@"optimzed m0: %f",m0);
                    
                    
                    float cost;
                    cost=0;
                    for(int x=0;x<N;x++){
                    //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                        cost=cost+(Dic[m][n][x]*m0-pixels[x])*(Dic[m][n][x]*m0-pixels[x]);
                        
                    }
                    //NSLog(@"COST:%f",cost);
                    if(finalT==0){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    else if(finalCost>cost){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    
                    
                    //NSLog(@"finalT:%f",finalT);
                    // NSLog(@"finalCost:%f",finalCost);
                    
                }
                
                
            }
            NSLog(@"finalNO.%d,T1:%f",i,finalT);
            //NSLog(@"finalT:%f",finalT);
            T_pic[i]=finalT;
            
        }
        
        cur        = [pixListSum        objectAtIndex:0];
        
        float *f        = [cur       fImage];
        
        for (int j=0;j<x;j++){
            //fImageNew[j]=-fImage[j];
            f[j]=T_pic[j];
            
        }
        
        NSMutableData   *volumeData     = [[NSMutableData alloc] initWithLength:0];
        NSMutableArray  *pix        = [[NSMutableArray alloc] initWithCapacity:0];
        
        int sliceCount      = 1;
        int pixWidth        = [cur pheight], pixHeight = [cur pwidth];
        
        float   pixelSpacingX = 1, pixelSpacingY = 1;
        float   originX = 0, originY = 0, originZ = 0;
        int     colorDepth = 32;
        
        long mem            = pixWidth * pixHeight * sliceCount * 4; // 4 Byte = 32 Bit Farbwert
        float *fVolumePtr   = malloc(mem);
        
        
        for( int i = 0; i < sliceCount; i++)
        {
            
            long size = sizeof( float) * pixWidth * pixHeight;
            float *imagePtr = malloc( size);
            DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
            free( imagePtr);
            [pix addObject: cur];
            
        }
        
        if( fVolumePtr)
        {
            volumeData = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
        }
        
        NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
        
        ViewerController *Viewer = [viewerController newWindow:pix :newFileArray :volumeData];
        
        
    }
    else if (count==16||(count>16&&count<22)){
        int zSize=8;
        float times[zSize];
        float *pictures[zSize];
        
        NSMutableArray *pixList=[[NSMutableArray alloc] initWithCapacity:0];;
        NSMutableArray *pixList1=[[NSMutableArray alloc] initWithCapacity:0];;
        for (int i = 0; i < count; i++)
        {
            //选择一个2d图像
            if(i%2==1)
            [pixList addObject:[pixListSum objectAtIndex: i]];
            else if (i%2==0){
                [pixList1 addObject:[pixListSum objectAtIndex: i]];
            }
        }
        
        
        
        for (int i = 0; i < zSize; i++)
        {
            //选择一个2d图像
            
            DCMPix  *curPix        = [pixList        objectAtIndex:i];
            // curPixNew   = [pixListNew   objectAtIndex:i];
            float *f=[curPix fImage];
            pictures[i]=f;
            NSString        *file_path = [curPix sourceFile];
     
            NSString        *dicomTag = @"0008,0032";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            //NSLog(@"tt: %@",val);
            
            float time = [val floatValue];
            
            
            //NSLog(@"zhuanhuan: %f",time);
            
            
            times[i]=time;
        }
        
        
        
        
        //sort
        float tmp;
        float *p;
        for(int i = 0 ; i < zSize ; i++){
            
            for(int j = i+1 ; j <zSize; j++){
                
                if(times[i] > times[j]){
                    tmp=times[i];
                    times[i]=times[j];
                    times[j]=tmp;
                    
                    
                    p=pictures[i];
                    pictures[i]=pictures[j];
                    pictures[j]=p;
                    
                    
                }
            }
        }
        float times1[zSize];
        float *pictures1[zSize];
        for (int i = 0; i < zSize; i++)
        {
            //选择一个2d图像
            DCMPix *curPix        = [pixList1        objectAtIndex:i];
            // curPixNew   = [pixListNew   objectAtIndex:i];
            float *f=[curPix fImage];
            pictures1[i]=f;
            NSString        *file_path = [curPix sourceFile];
            
            
            
            NSString        *dicomTag = @"0008,0032";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            //NSLog(@"tt: %@",val);
            
            float time = [val floatValue];
            
            
            //NSLog(@"zhuanhuan: %f",time);
            
            
            times1[i]=time;
        }
        
        
        
        
        //sort
        for(int i = 0 ; i < zSize ; i++){
            
            for(int j = i+1 ; j <zSize; j++){
                
                if(times1[i] > times1[j]){
                    tmp=times1[i];
                    times1[i]=times1[j];
                    times1[j]=tmp;
                    
                    
                    p=pictures1[i];
                    pictures1[i]=pictures1[j];
                    pictures1[j]=p;
                    
                    
                }
            }
        }
        for (int i=0;i<zSize;i++){
            NSLog(@"time:%f",times[i]);
            NSLog(@"time1:%f",times1[i]);
        }
        
        
        float intervals[zSize+1];
        for (int i=0;i<zSize+1;i++){
            if(i==0){
                intervals[0]=Tall[0];
            }
            else if(i==schemes[0]){
                intervals[i]=(times[i]-times[i-1])*1000-Tall[1];
            }
            else if (i==schemes[0]+1){
                intervals[i]=Tall[1];
            }
            
            else if(i<schemes[0]){
                intervals[i]=(times[i]-times[i-1])*1000;
                
            }
            else if (i<schemes[0]+schemes[1]+1){
                intervals[i]=(times[i-1]-times[i-2])*1000;
            }
            
            
        }
        //for (int i=0;i<zSize+1;i++){
        //    NSLog(@"intervals:%f",intervals[i]);
       // }
        
        
        //图像在pictures里面，时间在intervals里面
        int T[181];
        int count1=0;
        for(int i=200;i<=2000;i=i+10){
            T[count1]=i;
            count1++;
        }
       // NSLog(@"count1: %d",count1);
        
        float C[50];
        int count2=0;
        for (float o=0;o<=0.5;o=o+0.01){
            C[count2]=o;
            count2++;
        }
        
        //NSLog(@"count2: %d",count2);
        //定义dictionary
        int P=2;
        int N=0;
        
        for(int i=0;i<P;i++){
            N=N+schemes[i];
        }
        float m0;
        float pixels[zSize];
        if(card==1){
            theta=0.96;
        }
        else if (bl==1){
            theta=1;
        }
        float T_pic[x];
        float Dic[181][50][zSize];
        
        for (int m=0;m<181;m++){
            
            for (int n=0;n<50;n++){
                int  count=0;
                int res_point=0;
                float res=0;
                m0=1;
                float mall_before=13;
                mall_before=-1*theta*m0;
                
                for(int q=0;q<P;q++){
                    int t=count;
                    for (int r=t;r<t+schemes[q];r++){
                        
                        res=(m0+(mall_before-m0)*exp(-(intervals[r]/T[m])));
                        
                        mall_before=(1-C[n])*res;
                        
                        Dic[m][n][res_point]=res;
                        
                        
                        
                        res_point++;
                        count=count+1;
                    }
                    if(count<P+N-1){
                        m0=(m0+(mall_before-m0)*exp(-(intervals[count])/T[m]));
                        mall_before=(-1*theta)*m0;
                        count=count+1;
                    }
                }
            }}
        //i=46376
        for (int i=0;i<x;i++){
            //for each pixel in 11 pictures
            for (int j=0;j<zSize;j++){
                pixels[j]=pictures[j][i];
                //NSLog(@"pixel:%f",pixels[j]);
                int sign=1;
                if(cos (( pictures1[j][i]-pictures1[4][i]) /4096*pi)<0){
                 sign=-1;
                }
                pixels[j]=sign*pixels[j];
                //NSLog(@"pixelNo.%d: %f",j,pixels[j]);
            }
            float finalT=0;
            float finalCost=0;
            //遍历dictionary
            for (int m=0;m<181;m++){
                
                for (int n=0;n<50;n++){
                    
                    
                    
                    //求m0;
                    float sum1=0;
                    float sum2=0;
                    for(int x=0;x<N;x++){
                        sum1=sum1+Dic[m][n][x]*pixels[x];
                        
                        sum2=sum2+Dic[m][n][x]*Dic[m][n][x];
                    }
                    
                    m0=sum1/sum2;
                    //NSLog(@"T1:%d",T[m]);
                    //NSLog(@"c:%f",C[n]);
                   // NSLog(@"optimzed m0: %f",m0);
                    
                    
                    float cost;
                    cost=0;
                    for(int x=0;x<N;x++){
                        //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                        cost=cost+(Dic[m][n][x]*m0-pixels[x])*(Dic[m][n][x]*m0-pixels[x]);
                        
                    }
                    //NSLog(@"COST:%f",cost);
                    if(finalT==0){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    else if(finalCost>cost){
                        finalT=T[m];
                        finalCost=cost;
                    }
                    
                    
                    //NSLog(@"finalT:%f",finalT);
                    // NSLog(@"finalCost:%f",finalCost);
                    
                }
                
                
            }
            NSLog(@"finalNO.%d,T1:%f",i,finalT);
            //NSLog(@"finalT:%f",finalT);
            T_pic[i]=finalT;
            
        }
        
        cur        = [pixListSum        objectAtIndex:0];
        
        float *f        = [cur       fImage];
        
        for (int j=0;j<x;j++){
            //fImageNew[j]=-fImage[j];
            f[j]=T_pic[j];
            
        }
        
        NSMutableData   *volumeData     = [[NSMutableData alloc] initWithLength:0];
        NSMutableArray  *pix        = [[NSMutableArray alloc] initWithCapacity:0];
        
        int sliceCount      = 1;
        int pixWidth        = [cur pheight], pixHeight = [cur pwidth];
        
        float   pixelSpacingX = 1, pixelSpacingY = 1;
        float   originX = 0, originY = 0, originZ = 0;
        int     colorDepth = 32;
        
        long mem            = pixWidth * pixHeight * sliceCount * 4; // 4 Byte = 32 Bit Farbwert
        float *fVolumePtr   = malloc(mem);
        
        
        for( int i = 0; i < sliceCount; i++)
        {
            
            long size = sizeof( float) * pixWidth * pixHeight;
            float *imagePtr = malloc( size);
            DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
            free( imagePtr);
            [pix addObject: cur];
            
        }
        
        if( fVolumePtr)
        {
            volumeData = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
        }
        
        NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
        
        ViewerController *Viewer = [viewerController newWindow:pix :newFileArray :volumeData];
        
    }
 
    /**
    
    int x, zSize;
    float        *fImage, *fImageNew;
    float      *f;
    NSArray         *pixListNew;
    DCMPix        *curPix, *curPixNew,*cur;
    
    //pixList        = [viewerController pixList];//当前图集里面的图像列表
//pixListNew    = [new2DViewer pixList];//新图集里面的图像列表
    zSize       = [pixList count];//列表数量
   // ViewerController    *view;
    float times1[zSize];
    float *pictures1[zSize];
    float serial1=0;
    for (int i = 0; i < zSize; i++)
    {
        //选择一个2d图像
        curPix        = [pixList1        objectAtIndex:i];
        // curPixNew   = [pixListNew   objectAtIndex:i];
        f=[curPix fImage];
        pictures1[i]=f;
        NSString        *file_path = [curPix sourceFile];
        
        
        if(i==0){
            NSString        *dicomTag = @"0020,0011";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
            serial1 = [val floatValue];
        }
        NSString        *dicomTag = @"0008,0032";
        DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
        
        DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
        if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
        
        NSString        *val;
        DCMAttribute    *attr;
        
        if (tag && tag.group && tag.element)
        {
            attr = [dcmObj attributeForTag:tag];
            
            val = [[attr value] description];
            
        }
        //NSLog(@"tt: %@",val);
        
        float time = [val floatValue];
        
        
        //NSLog(@"zhuanhuan: %f",time);
        
        
        times1[i]=time;
    }
    
    
    
    float tmp;
    float *p;
    //sort
    for(int i = 0 ; i < zSize ; i++){
        
        for(int j = i+1 ; j <zSize; j++){
            
            if(times1[i] > times1[j]){
                tmp=times1[i];
                times1[i]=times1[j];
                times1[j]=tmp;
                
                
                p=pictures1[i];
                pictures1[i]=pictures1[j];
                pictures1[j]=p;
                
                
            }
        }
    }
   
    for (int i=0;i<zSize;i++){
        NSLog(@"time:%f",times1[i]);
    }
    //
    
    
    
    
   // view = [self duplicateCurrent2DViewerWindow];
    cur        = [pixList        objectAtIndex:0];
    x            = [cur pheight] * [cur pwidth];
    float h=[cur pheight];
    NSLog(@"height%f",h);
    NSLog(@"pixelsSUM= %d",x);
    f        = [cur       fImage];
    float times[zSize];
    float *pictures[zSize];
    float serial;
    for (int i = 0; i < zSize; i++)
    {
        //选择一个2d图像
        curPix        = [pixList        objectAtIndex:i];
       // curPixNew   = [pixListNew   objectAtIndex:i];
        f=[curPix fImage];
        pictures[i]=f;
        NSString        *file_path = [curPix sourceFile];
        if(i==0){
            NSString        *dicomTag = @"0020,0011";
            DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
            
            DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
            if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
            
            NSString        *val;
            DCMAttribute    *attr;
            
            if (tag && tag.group && tag.element)
            {
                attr = [dcmObj attributeForTag:tag];
                
                val = [[attr value] description];
                
            }
             serial = [val floatValue];
        }
        NSString        *dicomTag = @"0008,0032";
        DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
        
        DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
        if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
        
        NSString        *val;
        DCMAttribute    *attr;
        
        if (tag && tag.group && tag.element)
        {
            attr = [dcmObj attributeForTag:tag];
            
            val = [[attr value] description];
            
        }
        //NSLog(@"tt: %@",val);
        
        float time = [val floatValue];
       
        
        //NSLog(@"zhuanhuan: %f",time);
        
        
        times[i]=time;
    }
    

    
    
   //sort
    for(int i = 0 ; i < zSize ; i++){
        
        for(int j = i+1 ; j <zSize; j++){
            
            if(times[i] > times[j]){
                tmp=times[i];
                times[i]=times[j];
                times[j]=tmp;
                
                
                p=pictures[i];
                pictures[i]=pictures[j];
                pictures[j]=p;
                
                
                }
        }
    }
    NSLog(@"serial1:%f",serial);
    NSLog(@"serial2:%f",serial1);
    float *tmpp[zSize];
    if(serial>serial1){
        for(int i=0;i<zSize;i++){
            tmpp[i]=pictures1[i];
            pictures1[i]=pictures[i];
            pictures[i]=tmpp[i];
        }
    }
    float intervals[zSize+2];
    if(period==3){
    
    for (int i=0;i<zSize+2;i++){
        if(i==0){
            intervals[0]=Tall[0];
        }
        else if(i==schemes[0]){
            intervals[i]=(times[i]-times[i-1])*1000-Tall[1];
        }
        else if (i==schemes[0]+1){
            intervals[i]=Tall[1];
        }
        else if (i==schemes[0]+schemes[1]+1){
            intervals[i]=(times[i-1]-times[i-2])*1000-Tall[2];
        }
        else if (i==schemes[0]+schemes[1]+2){
            intervals[i]=Tall[2];
        }
        else if(i<schemes[0]){
            intervals[i]=(times[i]-times[i-1])*1000;
            
        }
        else if (i<schemes[0]+schemes[1]+1){
            intervals[i]=(times[i-1]-times[i-2])*1000;
        }
        else {
            intervals[i]=(times[i-2]-times[i-3])*1000;
        }
        NSLog(@"intervals: %f",intervals[i]);
    }
    }
    else{
        // float intervals[zSize+1];
         for (int i=0;i<zSize+1;i++){
        if(i==0){
            intervals[0]=Tall[0];
        }
        else if(i==schemes[0]){
            intervals[i]=(times[i]-times[i-1])*1000-Tall[1];
        }
        else if (i==schemes[0]+1){
            intervals[i]=Tall[1];
        }
        
        else if(i<schemes[0]){
            intervals[i]=(times[i]-times[i-1])*1000;
            
        }
        else if (i<schemes[0]+schemes[1]+1){
            intervals[i]=(times[i-1]-times[i-2])*1000;
        }
        
        
         }
    }
 //图像在pictures里面，时间在intervals里面
    int T[181];
    int count1=0;
    for(int i=200;i<=2000;i=i+10){
        T[count1]=i;
        count1++;
    }
    NSLog(@"count1: %d",count1);
   
    float C[50];
    int count2=0;
    for (float o=0;o<=0.5;o=o+0.01){
        C[count2]=o;
        count2++;
    }
    
    NSLog(@"count2: %d",count2);
   //定义dictionary
    int P=period;
    int N=0;
    
    for(int i=0;i<P;i++){
        N=N+schemes[i];
    }
    float m0;
    float pixels[zSize];
   
    float T_pic[x];
    float Dic[181][50][zSize];
    
    for (int m=0;m<181;m++){
        
        for (int n=0;n<50;n++){
            int  count=0;
            int res_point=0;
            float res=0;
            m0=1;
            float mall_before=13;
            mall_before=-1*theta*m0;
            
            for(int q=0;q<P;q++){
                int t=count;
                for (int r=t;r<t+schemes[q];r++){
                    
                    res=(m0+(mall_before-m0)*exp(-(intervals[r]/T[m])));
                   
                    mall_before=(1-C[n])*res;
                    Dic[m][n][res_point]=res;
                    
                    
                    
                    res_point++;
                    count=count+1;
                }
                if(count<P+N-1){
                    m0=(m0+(mall_before-m0)*exp(-(intervals[count])/T[m]));
                    mall_before=(-1*theta)*m0;
                    count=count+1;
                }
            }
        }}
    //i=46376
    for (int i=46376;i<=46476;i++){
        //for each pixel in 11 pictures
        for (int j=0;j<zSize;j++){
            pixels[j]=pictures[j][i];
            //NSLog(@"pixel:%f",pixels[j]);
            int sign=1;
            if(cos (( pictures1[j][i]-pictures1[4][i]) /4096*pi)<0){
                sign=-1;
            }
            pixels[j]=sign*pixels[j];
            //NSLog(@"pixelNo.%d: %f",j,pixels[j]);
        }
        float finalT=0;
        float finalCost=0;
        //遍历dictionary
        for (int m=0;m<181;m++){
            
            for (int n=0;n<50;n++){
                
                
                
                //求m0;
                float sum1=0;
                float sum2=0;
                for(int x=0;x<N;x++){
                    sum1=sum1+Dic[m][n][x]*pixels[x];
                    
                    sum2=sum2+Dic[m][n][x]*Dic[m][n][x];
                }
                
                m0=sum1/sum2;
                //NSLog(@"T1:%d",T[m]);
                //NSLog(@"c:%f",C[n]);
                //NSLog(@"optimzed m0: %f",m0);
                
               
                float cost;
                cost=0;
                for(int x=0;x<N;x++){
                    //NSLog(@"predict:%f,actual:%f",Dic[m][n][x]*m0,pixels[x]);
                    cost=cost+(Dic[m][n][x]*m0-pixels[x])*(Dic[m][n][x]*m0-pixels[x]);
                    
                }
                //NSLog(@"COST:%f",cost);
                if(finalT==0){
                    finalT=T[m];
                    finalCost=cost;
                }
                else if(finalCost>cost){
                    finalT=T[m];
                    finalCost=cost;
                }
                
                    
               //NSLog(@"finalT:%f",finalT);
              // NSLog(@"finalCost:%f",finalCost);
                
            }
            
            
        }
        NSLog(@"finalNO.%d,T1:%f",i,finalT);
        //NSLog(@"finalT:%f",finalT);
        T_pic[i]=finalT;
        
    }
    
    cur        = [pixList        objectAtIndex:0];
    /*
    f        = [cur       fImage];
    
    for (int j=0;j<x;j++){
        //fImageNew[j]=-fImage[j];
            f[j]=T_pic[j];
        
    }
   
    DICOMExport *xport = [[[DICOMExport alloc] init] autorelease];
    
    [xport setSourceFile: [cur sourceFile]];
    
   // [xport setPixelData: (unsigned char*)[cur fImage] samplesPerPixel: 1 bitsPerSample: sizeof( float) * 8 width: [cur pwidth] height: [cur pheight]];
  
    [xport setPixelNSImage: [cur image]];
    //[xport setSourceDicomImage: [cur imageObj]];
    NSString *file = [xport writeDCMFile: nil];
    
    if( file)
        [BrowserController.currentBrowser.database addFilesAtPaths: [NSArray arrayWithObject: file]
                                                 postNotifications: YES
                                                         dicomOnly: YES
                                               rereadExistingItems: YES
                                                 generatedByOsiriX: YES];
    
    //NSString *newDCM = [[[BrowserController currentBrowser] database] uniquePathForNewDataFileWithExtension: @"dcm"];
    
   // [DicomStudy transformPdfAtPath: [fpath stringByAppendingPathComponent:path] toDicomAtPath: newDCM usingSourceDicomAtPath: source];
    
   
    
    
    
    MFPController *controller=[MFPController new];
    [controller configureImages:cur];
  */
    /**
    NSMutableData   *volumeData     = [[NSMutableData alloc] initWithLength:0];
    NSMutableArray  *pix        = [[NSMutableArray alloc] initWithCapacity:0];
    
    int sliceCount      = 1;
    int pixWidth        = [curPix pheight], pixHeight = [curPix pwidth];
    
    float   pixelSpacingX = 1, pixelSpacingY = 1;
    float   originX = 0, originY = 0, originZ = 0;
    int     colorDepth = 32;
    
    long mem            = pixWidth * pixHeight * sliceCount * 4; // 4 Byte = 32 Bit Farbwert
    float *fVolumePtr   = malloc(mem);
    
    
    for(int i = 0; i < sliceCount; i++)
    {
        
        long size = sizeof( float) * pixWidth * pixHeight;
        float *imagePtr = malloc( size);
        DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
        free( imagePtr);
        [pix addObject: cur];
        
    }
    
    if( fVolumePtr)
    {
        volumeData = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
    }
    
    NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
    
 
    
    DICOMExport *e;
    
    e = [[DICOMExport alloc] init];
    NSString *string=@"Tr-1624_Hu_19771009";
    [e setSeriesDescription: [[string lastPathComponent] stringByDeletingPathExtension]];
    NSImage *l;
   
    l=[cur image];
   
    NSString *path= [cur sourceFile];
    
    
    NSLog(@"path: %@",path);
    //[e setPixelSpacing:[curp pheight] :[curp pwidth]];
    //[e setPixelNSImage: l];
    //[e setSourceFile:path];
    //[e setSeriesNumber:47];
    //[e respondsToSelector: @selector( metaDataDict)];
    //[e setModalityAsSource: YES];
    //[e setSourceDicomImage: l];
    NSString *fileName1 = [path stringByDeletingPathExtension];
    NSLog(@"fileName: %@",fileName1);
    NSString *fileName = [fileName1 stringByAppendingString:@".jpg"];
    NSLog(@"fileName: %@",fileName);
    
    NSData *imageData = [l  TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
    
 
    [e setPixelSpacing:[cur pheight] :[cur pwidth]];
    //[e setPixelNSImage: l];
    NSString *createdFile = [e writeDCMFile: nil];
    
    if( createdFile)
    {
        DicomDatabase *db = [[BrowserController currentBrowser] database];
        [db uniquePathForNewDataFileWithExtension: @"dcm"];
        NSArray *objects = [db addFilesAtPaths: [NSArray arrayWithObject: createdFile]
                             postNotifications: YES
                                     dicomOnly: YES
                           rereadExistingItems: YES
                             generatedByOsiriX: YES];
        
        
        
        
    }
    
    [e release];
    //[e setSourceFile:path];
    //[e setSeriesNumber:47];
    //[e respondsToSelector: @selector( metaDataDict)];
    //[e setModalityAsSource: YES];
    //[e setSourceDicomImage: l];
     
    /**
    NSBitmapImageRep *rep = (NSBitmapImageRep*) [l bestRepresentationForDevice:nil];
    
    if ([rep isMemberOfClass: [NSBitmapImageRep class]])
    {
        
        [e setSourceDicomImage: l];
        int bpp = [rep bitsPerPixel]/[rep samplesPerPixel];
        int spp = [rep samplesPerPixel];
        
        if( [rep bitsPerPixel] == 32 && spp == 3)
        {
            bpp = 8;
            spp = 4;
        }
        
    [e setPixelData: [rep bitmapData] samplesPerPixel: spp bitsPerSample: bpp width:[rep pixelsWide] height:[rep pixelsHigh]];
        
    }
    
    NSString *createdFile = [e writeDCMFile: nil];
    
    if( createdFile)
    {
        DicomDatabase *db = [[BrowserController currentBrowser] database];
        [db uniquePathForNewDataFileWithExtension: @"dcm"];
        NSArray *objects = [db addFilesAtPaths: [NSArray arrayWithObject: createdFile]
                             postNotifications: YES
                                     dicomOnly: YES
                           rereadExistingItems: YES
                             generatedByOsiriX: YES];
        
        
        
        
    }
    
    [e release];
     
    */
    //ViewerController *Viewer = [viewerController newWindow:pix :newFileArray :volumeData];
    //[Viewer showWindow:self];
   
    
    /**
     NSArray         *pixList = [viewerController pixList: 0];
     long            curSlice = [[viewerController imageView] curImage];
     DCMPix          *curPix = [pixList objectAtIndex: curSlice];
     NSString        *file_path = [curPix sourceFile];
     
     NSString        *dicomTag = @"0008,0032";
     
     DCMObject       *dcmObj = [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
     
     DCMAttributeTag *tag = [DCMAttributeTag tagWithName:dicomTag];
     if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
     
     NSString        *val;
     DCMAttribute    *attr;
     
     if (tag && tag.group && tag.element)
     {
     attr = [dcmObj attributeForTag:tag];
     
     val = [[attr value] description];
     
     }
     //val is the time
     NSRunInformationalAlertPanel(@"Metadata",
     [NSString stringWithFormat:
     @"Tag Name:%@\nTag ID:%04x,%04x\nTag VR:%@\nValue:%@",
     tag.name, tag.group, tag.element, tag.vr, val],
     @"OK", 0L, 0L);
     
     */
    /**
     BrowserController *currentBrowser = [BrowserController currentBrowser];
     NSArray *selectedItems = [currentBrowser databaseSelection];
     
     if ([selectedItems count] == 0) {
     NSAlert *alert = [[[NSAlert alloc] init] autorelease];
     [alert setMessageText:@"No studies/series selected!"];
     [alert runModal];
     
     
     }
     
     for (id item in selectedItems) {
     if ([item isKindOfClass:[DicomStudy class]]) {
     DicomStudy *study = (DicomStudy*) item;
     
     for (DicomSeries *series in [study imageSeries])
     [self processSeries:series];
     
     } else if ([item isKindOfClass:[DicomSeries class]])
     [self processSeries:(DicomSeries*) item];
     }
     
     
     */
  /**
    
    NSMutableData   *volumeData     = [[NSMutableData alloc] initWithLength:0];
    NSMutableArray  *pix        = [[NSMutableArray alloc] initWithCapacity:0];
    
    int sliceCount      = 1;
    int pixWidth        = [curPix pheight], pixHeight = [curPix pwidth];
    
    float   pixelSpacingX = 1, pixelSpacingY = 1;
    float   originX = 0, originY = 0, originZ = 0;
    int     colorDepth = 32;
    
    long mem            = pixWidth * pixHeight * sliceCount * 4; // 4 Byte = 32 Bit Farbwert
    float *fVolumePtr   = malloc(mem);
    
    
    for( i = 0; i < sliceCount; i++)
    {
        
        long size = sizeof( float) * pixWidth * pixHeight;
        float *imagePtr = malloc( size);
        DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
        free( imagePtr);
        [pix addObject: cur];
        
    }
    
    if( fVolumePtr)
    {
        volumeData = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
    }
    
    NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
    
    ViewerController *Viewer = [viewerController newWindow:pix :newFileArray :volumeData];
    */
    //NSLog(@"Acquisition Time: %@",val);
    /**NSRunInformationalAlertPanel(@"Metadata",
     [NSString stringWithFormat:
     @"Tag Name:%@\nTag ID:%04x,%04x\nTag VR:%@\nValue:%@",
     tag.name, tag.group, tag.element, tag.vr, val],
     @"OK", 0L, 0L);
     */
    
    
    
    
    // fImage is a pointer on the pixels, ALWAYS represented in float (float*) or in ARGB (unsigned char*)
    /***
     fImage        = [curPix        fImage];//当前图像的指针
     //fImageNew    = [curPixNew    fImage];
     x            = [curPix pheight] * [curPix pwidth];
     
     for (int j=0;j<x;j++){
     //fImageNew[j]=-fImage[j];
     if(i==0){
     f[j]=fImage[j];
     }
     else{
     f[j]+=fImage[j];
     }
     if(i==zSize-1){
     f[j]=f[j]/zSize;
     }
     }
     */
    [myWindow close];
    }

@end
