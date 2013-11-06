//
//  ROClassInfo.h
//  ROAnnotation
//
//  Created by Jianbin LIN
//  Released under a BSD-style license. See license.txt

@class ROAnnotatedUnit;

/*
	ROClassInfo represents a pairing of an interface and implementation for
	a specific class. It is linked to a .h and .m file and is responsible for 
	storing the content of the interface file, the implementation file and all annotations contained in them.
	
*/

@interface ROClassInfo : NSObject <NSCoding> {
	    
    
}

@property (nonatomic, strong) NSString *headerPath;
@property (nonatomic, strong) NSString *implementationPath;

@property (nonatomic, strong) NSString *headerContents;
@property (nonatomic, strong) NSString *implementationContents;

//Flag to indicate whether this class is annotated.
@property (nonatomic) BOOL shouldProcessAnnotations;

@property(nonatomic, strong)NSMutableDictionary* annotatedUnitsOfTypeClass;
@property(nonatomic, strong)NSMutableDictionary* annotatedUnitsOfTypeProperty;
@property(nonatomic, strong)NSMutableDictionary* annotatedUnitsOfTypeMethod;

-(NSString *) className;

-(void)addAnnotatedUnit:(ROAnnotatedUnit*)unit;

-(void) print;

+(NSMutableDictionary*)allClassInfo;

+(ROClassInfo*)classInfoOfClass:(Class)class;

+(ROClassInfo*)saveClassInfo:(ROClassInfo*)annotatedClass forClass:(NSString*)className;

@end
