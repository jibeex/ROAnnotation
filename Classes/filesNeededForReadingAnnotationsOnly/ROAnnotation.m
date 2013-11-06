//
//  ROAnnotation.m
//  ROAnnotation
//
//  Created by Jianbin LIN.
//  Released under a BSD-style license. See license.txt

#import "ROAnnotation.h"
#import "ROClassInfo.h"
#import "ROAnnotatedUnit.h"
#import <objc/runtime.h>

@interface ROAnnotation()
@property(nonatomic, strong) NSMutableDictionary* properties;
@end

@implementation ROAnnotation

@dynamic value;

-(id)init{
    
    self = [super init];
    if(self){
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    
    @synchronized([NSCoder class]){
    
        [encoder encodeObject:self.properties forKey:@"properties"];
        [encoder encodeObject:self.type forKey:@"type"];
    }
    
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        
        @synchronized([NSCoder class]){
            self.properties = [decoder decodeObjectForKey:@"properties"];
            self.type = [decoder decodeObjectForKey:@"type"];
            _exists = YES;
        }
        
    }
    return self;
}

- (id)initWithProperties:(NSDictionary*)propertyDict{
    
    if (self = [super init]) {
        for (NSString* key in propertyDict) {
            NSString* value = [propertyDict objectForKey:key];
            [self setValue:value forAttribute:key];
        }
    }
    
    _exists = YES;
    return self;
}


-(void)setValue:(NSString*)value forAttribute:(NSString *)attribute{
    @synchronized(self.properties){
        [self.properties setObject:value forKey:attribute];

    }
}

-(NSString*)valueForAttribute:(NSString *)attribute{
    @synchronized(self.properties){
        return [self.properties objectForKey:attribute];
    }
}

/*
-(NSString*)value{
    return [self valueForAttribute:@"value"];
}

-(void)setValue:(NSString*)value{
    
    [self setValue:value forAttribute:@"value"];
}
 */


-(void)print{
    
    NSLog(@"Annotation:%@", self.type);
    for (NSString* key in self.properties) {
        NSLog(@"key:%@ value:%@", key, [self.properties objectForKey:key]);
    }
    
}


+ (BOOL) resolveInstanceMethod:(SEL)aSEL
{
    NSString *method = NSStringFromSelector(aSEL);
    
    if ([method hasPrefix:@"set"])
    {
        class_addMethod([self class], aSEL, (IMP) accessorSetter, "v@:@");
        return YES;
    }
    else
    {
        class_addMethod([self class], aSEL, (IMP) accessorGetter, "@@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

NSString* accessorGetter(id self, SEL _cmd)
{
    NSString *method = NSStringFromSelector(_cmd);
    // Return the value of whatever key based on the method name
    ROAnnotation* annotation = self;
    return [annotation valueForAttribute:method];
}

void accessorSetter(id self, SEL _cmd, NSString* newValue)
{
    NSString *method = NSStringFromSelector(_cmd);
    
    // remove set
    NSString *anID = [[[method stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""] lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    // Set value of the key anID to newValue
    ROAnnotation* annotation = self;
    [annotation setValue:newValue forAttribute:anID];
}

#pragma mark -
#pragma mark retrieve annotation

+(NSArray*)annotationsAtClass:(Class)class{
    
    ROAnnotatedUnit* unit = [self annotatedClassUnitWithClass:class];
    return [unit annotations];
    
}

+(NSArray*)annotationsAtMethod:(NSString*)method ofClass:(Class)class{
    
    ROAnnotatedUnit* unit = [self annotatedMethodUnitWithMethod:method withClass:class];
    return [unit annotations];
    
}

+(NSArray*)annotationsAtProperty:(NSString*)property ofClass:(Class)class{
    ROAnnotatedUnit* unit = [self annotatedPropertyUnitWithProperty:property withClass:class];
    return [unit annotations];
}

+(ROAnnotation*)annotationOfType:(NSString*)type atClass:(Class)class{
    
    ROAnnotatedUnit* unit = [self annotatedClassUnitWithClass:class];
    
    if(unit == nil){
        return nil;
    }
    
    return [unit annotationWithType:type];
    
}

+(ROAnnotation*)annotationOfType:(NSString*)type atMethod:(NSString*)method ofClass:(Class)class{
    ROAnnotatedUnit* unit = [self annotatedMethodUnitWithMethod:method withClass:class];
    return [unit annotationWithType:type];
}

+(ROAnnotation*)annotationOfType:(NSString*)type atProperty:(NSString*)property ofClass:(Class)class{
    
    ROAnnotatedUnit* unit = [self annotatedPropertyUnitWithProperty:property withClass:class];
    return [unit annotationWithType:type];
    
}

+(id)annotationWithProperties:(NSDictionary*)properties{
    
    ROAnnotation* annotation = [[ROAnnotation alloc]initWithProperties:properties];
    return annotation;
}


#pragma mark -
#pragma mark retrieve annotated unit

+(ROAnnotatedUnit*)annotatedClassUnitWithClass:(Class)class{
    
    ROClassInfo* ac = [ROClassInfo classInfoOfClass:class];
    
    NSString* className = NSStringFromClass(class);
    
    if(ac){
        @synchronized(ac.annotatedUnitsOfTypeClass){
            return [ac.annotatedUnitsOfTypeClass objectForKey:className];
        }
    }
    return nil;
}

+(ROAnnotatedUnit*)annotatedPropertyUnitWithProperty:(NSString*)property withClass:(Class)class{
    
    ROClassInfo* ac = [ROClassInfo classInfoOfClass:class];
    
    if(ac){
        @synchronized(ac.annotatedUnitsOfTypeProperty){
            return [ac.annotatedUnitsOfTypeProperty objectForKey:property];
        }
    }
    return nil;
    
    
}

+(ROAnnotatedUnit*)annotatedMethodUnitWithMethod:(NSString*)method withClass:(Class)class{
    
    ROClassInfo* ac = [ROClassInfo classInfoOfClass:class];
    
    if(ac){
        @synchronized(ac.annotatedUnitsOfTypeMethod){
            return [ac.annotatedUnitsOfTypeMethod objectForKey:method];
        }
    }
    return nil;
}

+(NSArray*)annotatedPropertyUnitsWithAnnotationOfType:(NSString*)type inClass:(Class)class{
    
    ROClassInfo* ac = [ROClassInfo classInfoOfClass:class];
    
    if(ac){
        NSMutableArray* ret = [NSMutableArray array];
        
        NSArray* values = nil;
        
        @synchronized(ac.annotatedUnitsOfTypeProperty){
            values = ac.annotatedUnitsOfTypeProperty.allValues;
        }
        
        for(ROAnnotatedUnit* unit in values){
            
            if([unit annotationWithType:type]){
                [ret addObject:unit];
            }
        }
        return ret;
    }
    return nil;
}

+(NSArray*)annotatedMethodUnitsWithAnnotationOfType:(NSString*)type inClass:(Class)class{
    
    ROClassInfo* ac = [ROClassInfo classInfoOfClass:class];
    
    if(ac){
        NSMutableArray* ret = [NSMutableArray array];
        
        NSArray* values = nil;
        
        @synchronized(ac.annotatedUnitsOfTypeMethod){
            values = ac.annotatedUnitsOfTypeMethod.allValues;
        }
        
        for(ROAnnotatedUnit* unit in values){
            
            if([unit annotationWithType:type]){
                [ret addObject:unit];
            }
        }
        
        return ret;
    }
    return nil;
}


@end
