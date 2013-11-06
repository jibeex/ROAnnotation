//@generate

#import <Cocoa/Cocoa.h>

//Note that this class has been built to show off all of the capabilities of the annotation framework and
//therefore the code is more cluttered than the usual implementation.

//@classAnnotationInHeader( source = simpleValue, output = "value with spaces")
//@testAnnotate
@interface Person : NSObject {
	
	NSString *name;
}

//@PropertyAnnotationInHeader(key1=value1)
//@CustomizedAnnotation(attribute1 = 123, attribute2 = 456, attribute3 = 759)
@property (nonatomic, retain) NSString *name;
//@PropertyAnnotationInHeader(attributeHavingOnlyValue)
@property (nonatomic, retain) NSString *testProperty;

//@MethodAnotationInHeader(a=589)
- (void) canDoSomethingAwesomeWith: (NSString *) aName andAThing: (id) thing;
- (void) reallyLongMethodName: (CGPoint) withWrappedParameters andAnother: (NSString *) one;

@end
