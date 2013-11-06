//
//  AnnotationParser.h
//  ROAnnotation
//
//  Created by Jianbin LIN.
//  Released under a BSD-style license. See license.txt

#import <Foundation/Foundation.h>

@class ROClassInfo;

@interface AnnotationParser : NSObject

+ (id) classInfoWithHeaderPath: (NSString *) lHeaderPath implementationPath: (NSString *) lImplementationPath;

+ (void) processAnnotationsForClassInfo:(ROClassInfo*)classInfo;

+ (void) serializeAllClassInfoAtPath:(NSString*)path;

@end
