//
//  ROClassInfo.m
//  ROAnnotation
//
//  Created by Jianbin LIN
//  Released under a BSD-style license. See license.txt
//

#import "ROClassInfo.h"
#import "ROAnnotatedUnit.h"
#import "ROAnnotation.h"

@interface ROClassInfo()

@end

@implementation ROClassInfo

static NSMutableDictionary* allClassInfo = nil;

#pragma mark - 
#pragma mark Serialization and de deserialization

- (void) encodeWithCoder:(NSCoder*)encoder {
    
    @synchronized([NSCoder class]){
        
        [encoder encodeObject:self.annotatedUnitsOfTypeClass forKey:@"annotatedUnitsOfTypeClass"];
        [encoder encodeObject:self.annotatedUnitsOfTypeProperty forKey:@"annotatedUnitsOfTypeProperty"];
        [encoder encodeObject:self.annotatedUnitsOfTypeMethod forKey:@"annotatedUnitsOfTypeMethod"];
        [encoder encodeBool:self.shouldProcessAnnotations forKey:@"shouldProcessAnnotations"];

    }
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        
        @synchronized([NSCoder class]){
            self.annotatedUnitsOfTypeClass = [decoder decodeObjectForKey:@"annotatedUnitsOfTypeClass"];
            self.annotatedUnitsOfTypeProperty = [decoder decodeObjectForKey:@"annotatedUnitsOfTypeProperty"];
            self.annotatedUnitsOfTypeMethod = [decoder decodeObjectForKey:@"annotatedUnitsOfTypeMethod"];
            self.shouldProcessAnnotations = [decoder decodeBoolForKey:@"shouldProcessAnnotations"];
        }
    }
    return self;
}

#pragma mark -
#pragma mark instant methods

-(void)addAnnotatedUnit:(ROAnnotatedUnit*)unit{
    
    if(self.annotatedUnitsOfTypeClass == nil){
        self.annotatedUnitsOfTypeClass = [NSMutableDictionary dictionary];
    }
    
    if(self.annotatedUnitsOfTypeMethod == nil){
        self.annotatedUnitsOfTypeMethod = [NSMutableDictionary dictionary];
    }
    
    if(self.annotatedUnitsOfTypeProperty == nil){
        self.annotatedUnitsOfTypeProperty = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary* target = nil;
    
    if(unit.annotatedUnitType == AnnotatedUnitTypeClass){
        target = self.annotatedUnitsOfTypeClass;
    }
    else if(unit.annotatedUnitType == AnnotatedUnitTypeMethod){
        target = self.annotatedUnitsOfTypeMethod;
    }
    else{
        target = self.annotatedUnitsOfTypeProperty;
    }
    
    
    
    // Check if there already exists an unit with the same name
    ROAnnotatedUnit* oldUnit = [target objectForKey:unit.name];
    
    if(oldUnit == nil){
        [target setObject:unit forKey:unit.name];
    }
    else{
        for(ROAnnotation* a in unit.annotations){
            [oldUnit addAnnotation:a];
        }
    }
    
}


-(NSString*)className{
    
    NSString* className = [[self.headerPath lastPathComponent]stringByReplacingOccurrencesOfString:@".h" withString:@""];
    
    return className;
    
}

-(void)print{
    
    for(ROAnnotatedUnit* annotatedUnit in self.annotatedUnitsOfTypeClass.allValues){
        [annotatedUnit print];
    }
    
    for(ROAnnotatedUnit* annotatedUnit in self.annotatedUnitsOfTypeMethod.allValues){
        [annotatedUnit print];
    }
    
    for(ROAnnotatedUnit* annotatedUnit in self.annotatedUnitsOfTypeProperty.allValues){
        [annotatedUnit print];
    }
    
}

#pragma mark -
#pragma mark helpers

+(NSMutableDictionary*)allClassInfo{
    
    return allClassInfo;
}

+(BOOL)loadAnnotatedClassesFromFile:(NSString*)filePath{
    
    @synchronized(self){
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString* metaClassesPath = filePath;
        
        if(![fileManager fileExistsAtPath:metaClassesPath])
        {
            NSLog(@"Meta class data could not be found at path:%@", metaClassesPath);
            return false;
        }
        
        allClassInfo = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:metaClassesPath]];
        
        if(allClassInfo == nil){
            return false;
        }
        
        return true;
        
    }
}

+(ROClassInfo*)saveClassInfo:(ROClassInfo*)annotatedClass forClass:(NSString*)className{
    
    if(allClassInfo == nil){
        allClassInfo = [NSMutableDictionary dictionary];
    }
    
    [allClassInfo setObject:annotatedClass forKey:className];
    
    return annotatedClass;
}

+(ROClassInfo*)classInfoOfClass:(Class)class{
    
    @synchronized(self){
        if(allClassInfo == nil){
            [self loadAnnotatedClassesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%@", @"ROAnnotationData"] ofType:@""]];
        }
    }
    NSString* className = NSStringFromClass(class);
    
    @synchronized(allClassInfo){
        ROClassInfo* ac = [allClassInfo objectForKey:className];
        return ac;
    }
    
    
}


@end
