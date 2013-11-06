//
//  AnnotationParser.m
//  ROAnnotation
//
//  Created by Jianbin LIN.
//  Released under a BSD-style license. See license.txt
//

#import "AnnotationParser.h"
#import "ROClassInfo.h"
#import "ROAnnotation.h"
#import "ROAnnotatedUnit.h"

@implementation AnnotationParser

#pragma mark -
#pragma mark Helper Methods

static NSString *AnnotationFlag = @"//@generate";

+ (BOOL) shouldProcessAnnotationsForHeaderWithContents: (NSString *) contents
{
	return contents != nil && [contents rangeOfString:AnnotationFlag].location != NSNotFound;
}

+ (void) serializeAllClassInfoAtPath:(NSString*)path
{
    if([ROClassInfo allClassInfo] == nil){
        return;
    }
    
    NSString* metaDataFolder = path;
    
    NSString* metaClassPath = [NSString stringWithFormat:@"%@/ROAnnotationData", metaDataFolder];
	
	NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:[ROClassInfo allClassInfo]];
	
    [self writeData:encodedObject toFile:metaClassPath];
}


+ (id) classInfoWithHeaderPath: (NSString *) lHeaderPath implementationPath: (NSString *) lImplementationPath
{
	ROClassInfo* object = [ROClassInfo new];
	
	if (self != nil) {
		object.headerPath = lHeaderPath;
		object.implementationPath = lImplementationPath;
		
		object.headerContents = [self loadContentsOfFileAtPath: lHeaderPath];
		object.implementationContents = [self loadContentsOfFileAtPath: lImplementationPath];
		
		object.shouldProcessAnnotations = [self shouldProcessAnnotationsForHeaderWithContents: object.headerContents];
	}
	
	return object;
}

+ (NSString *) loadContentsOfFileAtPath: (NSString *) path
{
	NSError *error = nil;
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	
	if(fileContents == nil)
	{
		NSLog(@"couldn't load contents of file: %@ because of error: %@", path, [error localizedDescription]);
	}
	
	return fileContents;
}

+ (void) writeData:(NSData *)data toFile:(NSString *) filePath
{
    NSError *error = nil;
    
    BOOL success = [data writeToFile:filePath atomically:YES];
    
    if(!success)
    {
        NSLog(@"Unable to write file: %@ because of error: %@", filePath, [error localizedDescription]);
    }
}

#pragma mark -
#pragma mark Process Annotations

+ (void) processAnnotationsForClassInfo:(ROClassInfo*)classInfo{

    // Extract annotated classes
    NSArray* matches = [self matchAnnotatedClassBulks:classInfo.headerContents];
    for(NSTextCheckingResult* r in matches){
        NSRange range = r.range;
        NSString* matchedString = [classInfo.headerContents substringWithRange:range];
        //NSLog(@"Matched string:%@", matchedString);
        ROAnnotatedUnit* unit = [self annotatedUnitFromAnnotatedClassBulk:matchedString];
        [classInfo addAnnotatedUnit:unit];
        
    }
    matches = [self matchAnnotatedClassBulks:classInfo.implementationContents];
    for(NSTextCheckingResult* r in matches){
        NSRange range = r.range;
        NSString* matchedString = [classInfo.implementationContents substringWithRange:range];
        //NSLog(@"Matched string:%@", matchedString);
        ROAnnotatedUnit* unit = [self annotatedUnitFromAnnotatedClassBulk:matchedString];
        [classInfo addAnnotatedUnit:unit];
    }
    
    
    // Extract annotated properties
    matches = [self matchAnnotatedPropertyBulks:classInfo.headerContents];
    for(NSTextCheckingResult* r in matches){
        NSRange range = r.range;
        NSString* matchedString = [classInfo.headerContents substringWithRange:range];
        //NSLog(@"Matched string:%@", matchedString);
        ROAnnotatedUnit* unit = [self annotatedUnitFromAnnotatedPropertyBulk:matchedString];
        [classInfo addAnnotatedUnit:unit];
    }
    
    matches = [self matchAnnotatedPropertyBulks:classInfo.implementationContents];
    for(NSTextCheckingResult* r in matches){
        NSRange range = r.range;
        NSString* matchedString = [classInfo.implementationContents substringWithRange:range];
        //NSLog(@"Matched string:%@", matchedString);
        ROAnnotatedUnit* unit = [self annotatedUnitFromAnnotatedPropertyBulk:matchedString];
        [classInfo addAnnotatedUnit:unit];
    }
    
    // Extract annotated methods
    matches = [self matchAnnotatedMethodBulks:classInfo.headerContents];
    for(NSTextCheckingResult* r in matches){
        NSRange range = r.range;
        NSString* matchedString = [classInfo.headerContents substringWithRange:range];
        //NSLog(@"Matched string:%@", matchedString);
        ROAnnotatedUnit* unit = [self annotatedUnitFromAnnotatedMethodBulk:matchedString];
        [classInfo addAnnotatedUnit:unit];
    }
    
    matches = [self matchAnnotatedMethodBulks:classInfo.implementationContents];
    for(NSTextCheckingResult* r in matches){
        NSRange range = r.range;
        NSString* matchedString = [classInfo.implementationContents substringWithRange:range];
        //NSLog(@"Matched string:%@", matchedString);
        ROAnnotatedUnit* unit = [self annotatedUnitFromAnnotatedMethodBulk:matchedString];
        [classInfo addAnnotatedUnit:unit];
    }
    
}


#pragma mark -
#pragma mark Regex matcher

static NSString* whiteSpaces = nil;

static NSString* regexAnnotationType = nil;
static NSString* regexAnnotationAttributeKeyValuePair = nil;
static NSString* regexAnnotationAttributes = nil;
static NSString* regexAnnotationLine = nil;
static NSString* regexClassLine = nil;
static NSString* regexAnnotatedClassBulk = nil;

static NSString* regexPropertyAttribute = nil;
static NSString* regexPropertyAttributes = nil;
static NSString* regexPropertyLine = nil;
static NSString* regexAnnotatedPropertyBulk = nil;

static NSString* regexClassType = nil;
static NSString* regexMethodNameFirstPart = nil;
static NSString* regexMethodNameAdditionalPart = nil;
static NSString* regexMethodName = nil;
static NSString* regexMethod = nil;
static NSString* regexAnnotatedMethodBulk = nil;

+(void)initialize{
    
    whiteSpaces = @"(\\s)*";
    
    regexAnnotationType = [NSString stringWithFormat:@"//@([\\w]*)%@", whiteSpaces];
    regexAnnotationAttributeKeyValuePair = [NSString stringWithFormat:@"[\\s]*((\\w)+)[\\s]*([=][\\s]*((\\w)+|([\"].*[\"]))[\\s]*)?"];
    regexAnnotationAttributes = [NSString stringWithFormat:@"[(](%@[,])*%@[)]", regexAnnotationAttributeKeyValuePair, regexAnnotationAttributeKeyValuePair];
    regexAnnotationLine = [NSString stringWithFormat:@"%@((\\s)*)((%@)?)((\r)+[\\s]*)", regexAnnotationType, regexAnnotationAttributes];
    
    regexClassLine = @"@interface[\\s]*([\\w]+)";
    regexAnnotatedClassBulk = [NSString stringWithFormat:@"(%@)*%@", regexAnnotationLine, regexClassLine];
    
    regexPropertyAttribute = @"[\\s]*(\\w)+[\\s]*";
    regexPropertyAttributes = [NSString stringWithFormat:@"[(](%@[,])*%@[)]", regexPropertyAttribute, regexPropertyAttribute];
    regexPropertyLine = [NSString stringWithFormat:@"@(property[\\s]*%@[\\s]*[\\w]+[\\s]*[*]?[\\s]*)([\\w]+)[\\s]*[;]", regexPropertyAttributes];
    regexAnnotatedPropertyBulk = [NSString stringWithFormat:@"(%@)*%@", regexAnnotationLine, regexPropertyLine];
    
    regexClassType = @"[(][\\s]*(\\w)+[\\s]*[*]?[\\s]*[)]";
    regexMethodNameFirstPart = [NSString stringWithFormat:@"(\\w)+[\\s]*[:][\\s]*%@[\\s]*(\\w)+[\\s]*", regexClassType];
    regexMethodNameAdditionalPart = [NSString stringWithFormat:@"((\\w)+)?[\\s]*([:][\\s]*%@[\\s]*(\\w)+)?[\\s]*", regexClassType];
    regexMethodName = [NSString stringWithFormat:@"(%@)+", regexMethodNameAdditionalPart];
    regexMethod = [NSString stringWithFormat:@"[-+][\\s]*%@[\\s]*%@[;{]", regexClassType, regexMethodName];
    regexAnnotatedMethodBulk = [NSString stringWithFormat:@"(%@)*%@", regexAnnotationLine, regexMethod];
}

+(NSArray*)matchAnnotatedClassBulks:(NSString*)code{
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotatedClassBulk]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    return [regex matchesInString:code options:0 range:NSMakeRange(0, [code length])];
    
}

+(NSArray*)matchAnnotatedPropertyBulks:(NSString*)code{
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotatedPropertyBulk]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    return [regex matchesInString:code options:0 range:NSMakeRange(0, [code length])];
    
}

+(NSArray*)matchAnnotatedMethodBulks:(NSString*)code{
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotatedMethodBulk]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    return [regex matchesInString:code options:0 range:NSMakeRange(0, [code length])];
    
}

+(ROAnnotatedUnit*)annotatedUnitFromAnnotatedClassBulk:(NSString*)code{
    
    
    NSError *error = NULL;
    
    //Find class name
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexClassLine]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:code options:0 range:NSMakeRange(0, [code length])];
    // range at index 1 should be the class name
    NSRange range = [result rangeAtIndex:1];
    NSString* className = [code substringWithRange:range];
    
    ROAnnotatedUnit* unit = [ROAnnotatedUnit new];
    unit.annotatedUnitType = AnnotatedUnitTypeClass;
    unit.name = className;
    
    //NSLog(@"class name:%@", className);
    
    // Find annotation lines
    NSArray* annotations = [self annotationsFromCodeBulk:code];
    
    for (ROAnnotation* a in annotations) {
        [unit addAnnotation:a];
    }
    
    return unit;
}

+(ROAnnotatedUnit*)annotatedUnitFromAnnotatedPropertyBulk:(NSString*)code{
    
    
    NSError *error = NULL;
    
    //Find class name
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexPropertyLine]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:code options:0 range:NSMakeRange(0, [code length])];
    
    // Range at index [result numberOfRanges]-1 should be the property name
    NSRange range = [result rangeAtIndex:[result numberOfRanges]-1];
    NSString* propertyName = [code substringWithRange:range];
    
    ROAnnotatedUnit* unit = [ROAnnotatedUnit new];
    unit.annotatedUnitType = AnnotatedUnitTypeProperty;
    unit.name = propertyName;
    
    //NSLog(@"property name:%@", propertyName);
    
    // Find annotation lines
    NSArray* annotations = [self annotationsFromCodeBulk:code];
    
    for (ROAnnotation* a in annotations) {
        [unit addAnnotation:a];
    }
    
    return unit;
}

+(ROAnnotatedUnit*)annotatedUnitFromAnnotatedMethodBulk:(NSString*)code{
    
    
    NSError *error = NULL;
    
    //Find class name
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexMethod]
                                                                           options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSTextCheckingResult* result = [regex firstMatchInString:code options:0 range:NSMakeRange(0, [code length])];
    

    NSString* methodName = [code substringWithRange:result.range];
    
    // Replace parameters with ":"
    NSRegularExpression *parameterRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@":(\\s)*%@(\\s)*(\\w)+", regexClassType]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                                      error:&error];
    
    NSString* methodNameWithoutParameters = [parameterRegex stringByReplacingMatchesInString:methodName options:0 range:NSMakeRange(0, [methodName length]) withTemplate:@":"];
    
    
    // Remove return type
    NSRegularExpression *returnTypeRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"[-+](\\s)*%@(\\s)*", regexClassType]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                                       error:&error];
    
    NSString* methodNameWithoutReturnType = [returnTypeRegex stringByReplacingMatchesInString:methodNameWithoutParameters options:0 range:NSMakeRange(0, [methodNameWithoutParameters length]) withTemplate:@""];
    
    // Remove spaces, semicolons and parenthesises
    NSRegularExpression *spaceOrSemiColonOrParenthesisRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", @"(\\s)*[;{]?"]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                                                          error:&error];
    
    NSString* methodNameWithoutSpacesAndSemiColonsAndParenthesises = [spaceOrSemiColonOrParenthesisRegex stringByReplacingMatchesInString:methodNameWithoutReturnType options:0 range:NSMakeRange(0, [methodNameWithoutReturnType length]) withTemplate:@""];

    
    ROAnnotatedUnit* unit = [ROAnnotatedUnit new];
    unit.annotatedUnitType = AnnotatedUnitTypeMethod;
    unit.name = methodNameWithoutSpacesAndSemiColonsAndParenthesises;
    
    // Find annotation lines
    NSArray* annotations = [self annotationsFromCodeBulk:code];
    
    for (ROAnnotation* a in annotations) {
        [unit addAnnotation:a];
    }
    
    return unit;
}



+(NSArray*)annotationsFromCodeBulk:(NSString*)code{
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotationLine]
                                                                           options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSArray *results = [regex matchesInString:code options:0 range:NSMakeRange(0, [code length])];
    
    NSMutableArray* ret = [NSMutableArray array];
    
    for(NSTextCheckingResult* r in results){
        
        NSString* annotationLine = [code substringWithRange:r.range];
        ROAnnotation* annotation = [self annotationFromAnnotationLine:annotationLine];
        [ret addObject:annotation];
        
    }
    
    return ret;
}

+(ROAnnotation*)annotationFromAnnotationLine:(NSString*)code{
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotationLine]
                                                                           options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSTextCheckingResult *r = [regex firstMatchInString:code options:0 range:NSMakeRange(0, [code length])];
    
    ROAnnotation* annotation = [ROAnnotation new];
    
    NSString* annotationType = [code substringWithRange:[r rangeAtIndex:1]];
    annotation.type = annotationType;
    
    regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotationAttributes]
                                                      options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                        error:&error];
    
    r = [regex firstMatchInString:code options:0 range:NSMakeRange(0, [code length])];
    
    NSString* attributesCode = [code substringWithRange:r.range];
    
    regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", regexAnnotationAttributeKeyValuePair]
                                                      options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines
                                                        error:&error];
    
    NSArray *results = [regex matchesInString:attributesCode options:0 range:NSMakeRange(0, [attributesCode length])];
    
    for(NSTextCheckingResult* aResult in results){
        NSString* keyValuePair = [attributesCode substringWithRange:aResult.range];
        NSArray* components = [keyValuePair componentsSeparatedByString:@"="];
        
        if(components.count == 1){
            
            NSRegularExpression *keyOrValueRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(\\s)*[;{]?"]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines error:&error];
            
            NSString* value = [keyOrValueRegex stringByReplacingMatchesInString:[components objectAtIndex:0] options:0 range:NSMakeRange(0, [[components objectAtIndex:0] length]) withTemplate:@""];
            
            [annotation setValue:value];
            
        }
        else if(components.count == 2){
            
            NSRegularExpression *keyOrValueRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(^(\\s)*[\"]?)|([\"]?(\\s)*$)"]options:NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionAnchorsMatchLines error:&error];
            
            NSString* key = [keyOrValueRegex stringByReplacingMatchesInString:[components objectAtIndex:0] options:0 range:NSMakeRange(0, [[components objectAtIndex:0] length]) withTemplate:@""];
            
            
            NSString* valueComponent = [components objectAtIndex:1];
            
            NSString* value = [keyOrValueRegex stringByReplacingMatchesInString:valueComponent options:0 range:NSMakeRange(0, [valueComponent length]) withTemplate:@""];
            
            [annotation setValue:value forAttribute:key];
        }
        
    }
    return annotation;
}





@end
