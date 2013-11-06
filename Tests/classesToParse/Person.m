
#import "Person.h"

//@classAnnotationInInplementation( someAttribute = simpleValue, someAttribute2 = "value with spaces")
@interface Person ()

//@PropertyAnnotationInInplementation(key=value)
@property (nonatomic, retain) NSString *privateName;
@property (nonatomic) BOOL privateRememberedToPayTaxes;
@property (assign) NSObject *aPrivateProperty;


- (void) testAPrivateMethod: (NSString *) withAParam;

@end

@implementation Person

@synthesize name;
@synthesize privateName;
@synthesize privateRememberedToPayTaxes;
@synthesize aPrivateProperty;

//@methodAnnotationWithTwoParametersInInplementation(k1=v1, k2 = "value with spaces")
- (void) canDoSomethingAwesomeWith: (NSString *) aName andAThing: (id) thing
{
}

//@methodAnnotationWithMultiLineMethodName( someAttribute = simpleValue, someAttribute2 = "value with spaces")
- (void) reallyLongMethodName: 
(CGPoint) withWrappedParameters andAnother:
(NSString *) one
{
	
}

//@methodAnnotationWithProperties(k1=v1, k2 = "value with spaces")
- (void) testAPrivateMethod: (NSString *) withAParam
{
	
}

@end
