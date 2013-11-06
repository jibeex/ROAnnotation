//
//  MethodAnnotationTest.m
//  ROAnnotation
//
//  Created on 18/10/13.
//  Released under a BSD-style license. See license.txt.
//
//

#import <XCTest/XCTest.h>
#import "ROAnnotation.h"
#import "Person.h"

@interface MethodAnnotationTest : XCTestCase

@end

@implementation MethodAnnotationTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testAnnotationInHeader
{
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"MethodAnotationInHeader" atMethod:@"canDoSomethingAwesomeWith:andAThing:" ofClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation valueForAttribute:@"a"]isEqualToString:@"589"], @"Error");
}

- (void)testAnnotationInImplementation
{
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"methodAnnotationWithMultiLineMethodName" atMethod:@"reallyLongMethodName:andAnother:" ofClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation valueForAttribute:@"someAttribute2"]isEqualToString:@"value with spaces"], @"Error");
}

@end
