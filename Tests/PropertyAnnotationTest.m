//
//  PropertyAnnotationTest.m
//  ROAnnotation
//
//  Created on 18/10/13.
//  Released under a BSD-style license. See license.txt.
//
//

#import <XCTest/XCTest.h>
#import "ROAnnotation.h"
#import "Person.h"

@interface PropertyAnnotationTest : XCTestCase

@end

@implementation PropertyAnnotationTest


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
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"CustomizedAnnotation" atProperty:@"name" ofClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation valueForAttribute:@"attribute1"]isEqualToString:@"123"], @"Error");

}

- (void)testAnnotationInImplementation
{
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"PropertyAnnotationInInplementation" atProperty:@"privateName" ofClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation valueForAttribute:@"key"]isEqualToString:@"value"], @"Error");
}

- (void)testAnnotationWithNoKey
{
    ROAnnotation* annotation = [ROAnnotation annotationOfType:@"PropertyAnnotationInHeader" atProperty:@"testProperty" ofClass:[Person class]];
    XCTAssertTrue(annotation != nil, @"Error");
    XCTAssertTrue([[annotation value]isEqualToString:@"attributeHavingOnlyValue"], @"Error");
}


@end
