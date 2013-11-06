
#import "AnnotateDemoAppDelegate.h"
#import "ROAnnotation.h"
#import "Person.h"
#import "CustomizedAnnotation.h"

@implementation AnnotateDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    
    NSLog(@"-----------------------------    Class annotation    ----------------------------");
    NSArray* classAnnotations = [ROAnnotation annotationsAtClass:[Person class]];
    
    for(ROAnnotation* a in classAnnotations){
        [a print];
    }
    
    
    NSLog(@"-----------------------------    Method annotation    ----------------------------");
    NSArray* methodAnnotations = [ROAnnotation annotationsAtMethod:@"canDoSomethingAwesomeWith:andAThing:" ofClass:[Person class]];
    
    for(ROAnnotation* a in methodAnnotations){
        [a print];
    }
    
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"methodAnnotationWithMultiLineMethodName" atMethod:@"reallyLongMethodName:andAnother:" ofClass:[Person class]];
    [annotation print];
    
    
    NSLog(@"-----------------------------    Property annotation    ----------------------------");
    NSArray* propertyAnnotations = [ROAnnotation annotationsAtProperty:@"name" ofClass:[Person class]];
    
    for(ROAnnotation* a in propertyAnnotations){
        NSLog(@"Annotation:%@", a.type);
        
        NSLog(@"key:%@ value:%@", @"key1",  [a valueForAttribute:@"key1"]);
    }
    
    annotation = [ROAnnotation annotationOfType:@"PropertyAnnotationInInplementation" atProperty:@"privateName" ofClass:[Person class]];
    [annotation print];
    
    annotation = [ROAnnotation annotationOfType:@"PropertyAnnotationInHeader" atProperty:@"testProperty" ofClass:[Person class]];
    NSLog(@"annotation value:%@", annotation.value);
    
    CustomizedAnnotation* customizedAnnotation = (CustomizedAnnotation*)[ROAnnotation annotationOfType:@"CustomizedAnnotation" atProperty:@"name" ofClass:[Person class]];
    
    NSLog(@"annotation attribute:%@", customizedAnnotation.attribute1);
    NSLog(@"annotation attribute:%@", customizedAnnotation.attribute2);
    NSLog(@"annotation attribute:%@", customizedAnnotation.attribute3);

    
}

@end
