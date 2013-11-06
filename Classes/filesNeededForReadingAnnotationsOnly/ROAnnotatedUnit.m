//
//  ROAnnotatedUnit.m
//  ROAnnotation
//
//  Created by Jianbin LIN.
//  Released under a BSD-style license. See license.txt
//

#import "ROAnnotatedUnit.h"
#import "ROAnnotation.h"

@interface ROAnnotatedUnit()

@property(nonatomic, strong) NSMutableDictionary* annotationDict;

@end

@implementation ROAnnotatedUnit

@synthesize annotatedUnitType;
@synthesize name;
@synthesize annotationDict;

-(id)init{
    
    self = [super init];
    if(self){
        self.annotationDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    
    // If parent class also adopts NSCoding, include a call to
    // [super encodeWithCoder:encoder] as the first statement.
    @synchronized([NSCoder class]){
        
        [encoder encodeObject:annotationDict forKey:@"annotationDict"];
        [encoder encodeObject:name forKey:@"name"];
        [encoder encodeInt:annotatedUnitType forKey:@"annotatedUnitType"];
    }
    
}

- (id) initWithCoder:(NSCoder*)decoder {
    
    if (self = [super init]) {
        
        @synchronized([NSCoder class]){
        // If parent class also adopts NSCoding, replace [super init]
        // with [super initWithCoder:decoder] to properly initialize.
        
        // NOTE: Decoded objects are auto-released and must be retained
            self.annotatedUnitType = [decoder decodeIntForKey:@"annotatedUnitType"];
            self.name = [decoder decodeObjectForKey:@"name"];
            self.annotationDict = [decoder decodeObjectForKey:@"annotationDict"];
        }
        
    }
    return self;
}



-(void)addAnnotation:(ROAnnotation*)annotation{
    if(annotation != nil && annotation.type != nil){
        @synchronized(self.annotationDict){
            [self.annotationDict setObject:annotation forKey:annotation.type];
        }
    }
}

-(void)removeAnnotation:(ROAnnotation*)annotation{
    if(annotation != nil && annotation.type != nil){
        @synchronized(self.annotationDict){
            [self.annotationDict removeObjectForKey:annotation.type];
        }
    }
}

-(ROAnnotation*)annotationWithType:(NSString*)type{
    if(type != nil){
        @synchronized(self.annotationDict){
            ROAnnotation* annotation = [self.annotationDict objectForKey:type];
            return annotation;
        }
    }
    return nil;
}

-(void)removeAnnotationWithType:(NSString*)type{
    if(type != nil){
        @synchronized(self.annotationDict){
            [self.annotationDict removeObjectForKey:type];
        }
    }
}

-(NSArray*)annotations{
    @synchronized(self.annotationDict){
        return [self.annotationDict allValues];
    }
}

-(void)print{
    NSLog(@"Annotation Unit:%@ type:%d", name, annotatedUnitType);
    NSArray* annotationArray = self.annotations;
    for(ROAnnotation* a in annotationArray){
        [a print];
    }
}

@end
