//
//  ROAnnotatedUnit.h
//  ROAnnotation
//
//  Created by Jianbin LIN.
//  Released under a BSD-style license. See license.txt

/* An AnnotatedUnit represents a specific unit(can be a property, a method, a class) that has been annotated in a header or implementation file.
 It contains the info(name etc.) of unit itself, and an array of annotations */

#import <Foundation/Foundation.h>
@class ROAnnotation;

typedef enum {
    AnnotatedUnitTypeMethod = 0,
    AnnotatedUnitTypeProperty = 1,
    AnnotatedUnitTypeClass = 3,
} AnnotatedUnitType;

@interface ROAnnotatedUnit : NSObject <NSCoding>

@property(nonatomic, assign) AnnotatedUnitType annotatedUnitType;
@property(nonatomic, strong) NSString* name;


-(void)addAnnotation:(ROAnnotation*)annotation;

-(void)removeAnnotation:(ROAnnotation*)annotation;

-(ROAnnotation*)annotationWithType:(NSString*)type;

-(void)removeAnnotationWithType:(NSString*)type;

-(NSArray*)annotations;

-(void)print;

@end
