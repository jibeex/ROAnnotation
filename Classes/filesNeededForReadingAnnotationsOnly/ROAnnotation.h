//
//  ROAnnotation.h
//  ROAnnotation
//
//  Created by Jianbin LIN.
//  Released under a BSD-style license. See license.txt
//

#import <Foundation/Foundation.h>
#import "ROAnnotatedUnit.h"

@interface ROAnnotation : NSObject <NSCoding>

@property(nonatomic, strong) NSString* type;
@property(nonatomic, readonly) BOOL exists;
@property(nonatomic, strong) NSString* value;


-(void)setValue:(NSString*)value forAttribute:(NSString *)attribute;

-(NSString*)valueForAttribute:(NSString *)attribute;

/*
-(NSString*)value;

-(void)setValue:(NSString*)value;
 */

-(void)print;

//Retrieve annoatation

+(NSArray*)annotationsAtClass:(Class)class;

+(NSArray*)annotationsAtMethod:(NSString*)method ofClass:(Class)class;

+(NSArray*)annotationsAtProperty:(NSString*)property ofClass:(Class)class;

+(ROAnnotation*)annotationOfType:(NSString*)type atClass:(Class)class;

+(ROAnnotation*)annotationOfType:(NSString*)type atMethod:(NSString*)method ofClass:(Class)class;

+(ROAnnotation*)annotationOfType:(NSString*)type atProperty:(NSString*)property ofClass:(Class)class;

//Retrieve annoatated unit

+(ROAnnotatedUnit*)annotatedClassUnitWithClass:(Class)class;

+(ROAnnotatedUnit*)annotatedPropertyUnitWithProperty:(NSString*)property withClass:(Class)class;

+(ROAnnotatedUnit*)annotatedMethodUnitWithMethod:(NSString*)method withClass:(Class)class;

+(NSArray*)annotatedPropertyUnitsWithAnnotationOfType:(NSString*)type inClass:(Class)class;

+(NSArray*)annotatedMethodUnitsWithAnnotationOfType:(NSString*)type inClass:(Class)class;

+(id)annotationWithProperties:(NSDictionary*)properties;

@end
