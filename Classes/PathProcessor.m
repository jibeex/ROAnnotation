//
//  PathProcessor.m
//
//  Created by Dylan Bruzenak.
//  Modified by Jianbin LIN.
//  Released under a BSD-style license. See license.txt.
//

#import "PathProcessor.h"
#import "ROClassInfo.h"
#import "AnnotationParser.h"

@implementation PathProcessor

- (NSString *) pathForImplementationOfHeader: (NSString *) fullHeaderPath
{
	return [[fullHeaderPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m"];
}

- (BOOL) isHeaderFilePath: (NSString *) filePath
{
	return [[filePath pathExtension] isEqualToString:@"h"];
}

- (NSArray *) allClassInfoInPath: (NSString *) path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
	
	NSMutableArray *annotatedClasses = [NSMutableArray array];
	
	for(NSString *filePath in enumerator)
	{
		if(![self isHeaderFilePath: filePath])
		{
			continue;
		}
		
		NSString *fullHeaderPath = [path stringByAppendingPathComponent:filePath];
		NSString *fullImplementationPath = [self pathForImplementationOfHeader: fullHeaderPath];

		if(![fileManager fileExistsAtPath:fullImplementationPath])
		{
			continue;
		}
		
		ROClassInfo *annotatedClass = [AnnotationParser classInfoWithHeaderPath:fullHeaderPath implementationPath:fullImplementationPath];
		
		if(annotatedClass.shouldProcessAnnotations)
		{
			[annotatedClasses addObject:annotatedClass];
		}
	}
	
	return annotatedClasses;
}

- (NSDictionary *) allClassInfoFromMetaDataInPath: (NSString *) path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString* metaClassesPath = [NSString stringWithFormat:@"%@/ROAnnotationData", path];
    
    if(![fileManager fileExistsAtPath:metaClassesPath])
    {
        NSLog(@"No ROAnnotationData is found");
        return nil;
    }
    
    NSDictionary *annotatedClasses = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:metaClassesPath]];
	
	return annotatedClasses;
}

- (void) processSourcePath:(NSString *) sourcePath outputPath:(NSString*)outputPath
{
	NSArray *allClassInfo = [self allClassInfoInPath:sourcePath];
	
	for(ROClassInfo *classInfo in allClassInfo)
	{
		[AnnotationParser processAnnotationsForClassInfo:classInfo];
        [ROClassInfo saveClassInfo:classInfo forClass:classInfo.className];
	}
    
    [AnnotationParser serializeAllClassInfoAtPath:outputPath];
    
    NSDictionary *decodedAnnotatedClasses = [self allClassInfoFromMetaDataInPath:outputPath];
    if(decodedAnnotatedClasses.count > 0){
        for(ROClassInfo* a in decodedAnnotatedClasses.allValues){
            [a print];
        }
    }
}

@end
