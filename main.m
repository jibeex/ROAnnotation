//
//  main.m
//
//  Created by Dylan Bruzenak.
//  Modified by Jianbin LIN.
//  Released under a BSD-style license. See license.txt


#import <Foundation/Foundation.h>
#import "PathProcessor.h"

bool createDirectory(NSString *directory)
{
	NSError *error = nil;
	
	BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: directory withIntermediateDirectories: YES attributes: nil error: &error];
	
	if(!success)
	{
		NSLog(@"unable to create directory: %@ because of error: %@", directory, [error localizedDescription]);
	}
	
	return success;
}

bool checkPaths(NSString *sourcePath, NSString *outputPath)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL sourcePathIsDirectory = NO;
	
	if(![fileManager fileExistsAtPath: sourcePath isDirectory: &sourcePathIsDirectory])
	{
		NSLog(@"Source path not found: %@", sourcePath);
		
		return NO;
	}
	
	if(!sourcePathIsDirectory)
	{
		NSLog(@"Source path must be a directory.");
		
		return NO;
	}
	
	BOOL outputPathIsDirectory = NO;
	
	if(![fileManager fileExistsAtPath: outputPath isDirectory: &outputPathIsDirectory])
	{
		return createDirectory(outputPath);
        
	}else if(!outputPathIsDirectory){
		NSLog(@"Output path must be a directory.");
		return NO;	
	}
	return YES;
}

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        if(argc < 2 || argc > 3)
        {
            NSString *usageString = @"Usage: ROAnnotation source_directory [output_directory]\n\n"
            @"source_directory: The directory that contains the source files to process.\n\n"
            @"output_directory: Optional parameter, where the output file would be generated(overwrite if needed). If not provided the annotation output will be put in the source directory.\n";
            
            NSLog(@"%@", usageString);
            
            return 1;
        }
        
        NSString *sourcePath = [NSString stringWithCString: argv[1] encoding: NSUTF8StringEncoding];
        
        NSString *outputPath = sourcePath;
        
        if(argc == 3)
        {
            outputPath = [NSString stringWithCString: argv[2] encoding: NSUTF8StringEncoding];
        }
        
        if(!checkPaths(sourcePath, outputPath))
        {
            return 1;
        }
        
        PathProcessor *pathProcessor = [[PathProcessor alloc] init];
        [pathProcessor  processSourcePath:sourcePath outputPath:outputPath];

        return 0;
    }

	
}