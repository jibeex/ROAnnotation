ROAnnotation (Java style Runtime annotation for Objective-C)
=============================================================


What is ROAnnotation
-------------------------------------------------------------
ROAnnotation is a compile time Class/Property/Method metadata parser and a set of toolkits that gives your application access to those metadata at runtime.

As Objective-C provides no supports for customized Class/Property/Method metadata, ROAnnotation uses formatted comments to store metadata.

The metadata format defined by ROAnnotation is similar to Java style annotation. Each metadata unit consist of an annotation type and a set of key-value pairing attributes.

```obj-c
//@annotationType( attribute = attributeValue, attribute2 = "attribute value with spaces")
```

Origin
-------------------------------------------------------------
ROAnnotation is inspired by another objective-C annotation project called ObjCAnnotate(https://bitbucket.org/dylanbruzenak/objectivecannotate/wiki/Home). What ObjCAnnotate is doing is parsing predefined annotations in the source files and generates new block of codes.

Though ROAnnotation uses a similar annotation format with ObjCAnnotate, it is doing things in another direction. Instead of generating codes, ROAnnotation parses any customized annotations(no need to define annotation) at class/method/property, collects and saves them as a file. Developer can then read annotation content from this file and do real cool stuff with them.


The executable ROAnnotation
-------------------------------------------------------------
ROAnnotation is the executable thats parses source files and generates an annotation data file:ROAnnotationData.

It accepts two parameters, namely source_folder_path and out_put_folder path.

ROAnnotation(executable at OSX10.6+) is already included under the root folder of the project. You can also generate it by releasing a product from the ROAnnotation project.

The annotation data file:ROAnnotationData
-------------------------------------------------------------
ROAnnotationData is the annotation data file that is generated as result of ROAnnotation(executable)'s source parsing.
It should be included as bundle resource of your project so that you can read annotations from it at runtime.


The @generate annotation
-------------------------------------------------------------
```obj-c
//@generate
```

Only classes containing the //@generate annotation in the header file will be parsed by ROAnnotation. Classes that do not contains this annotation will be ignored.


Annotation format
-------------------------------------------------------------

Annotation starts with
```obj-c
//@
```

followed by annotation type, followed by key value pairing attributes in a parenthesis

```obj-c
//@annotationType( attribute = attributeValue, attribute2 = "attribute value with spaces")
```

If there is an attribute having no key, it will be treated as having a key "value"
```obj-c
//@annotationType(attributeValueWithoutKey)
```

Add annotation to Class/Property/Method
```obj-c
//@classAnnotationInHeader( someAttribute = simpleValue, someAttribute2 = "value with spaces")
//@testAnnotate
@interface Person : NSObject {
	
	NSString *name;
}

//@PropertyAnnotationInHeader(key=value)
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *testProperty;

//@MethodAnotationInHeader(a=589)
- (void) canDoSomethingAwesomeWith: (NSString *) aName andAThing: (id) thing;
```

Basic way to retrieve annotation at runtime
-------------------------------------------------------------

Retrieve annotation (s)

```obj-c
NSArray* classAnnotations = [ROAnnotation annotationsAtClass:[Person class]];
NSArray* methodAnnotations = [ROAnnotation annotationsAtMethod:@"canDoSomethingAwesomeWith:andAThing:" ofClass:[Person class]];
ROAnnotation* annotation = [ROAnnotation annotationOfType:@"methodAnnotationWithMultiLineMethodName" atMethod:@"reallyLongMethodName:andAnother:" ofClass:[Person class]];
annotation = [ROAnnotation annotationOfType:@"PropertyAnnotationInImplementation" atProperty:@"privateName" ofClass:[Person class]];

```
Read attribute values from annotation

```obj-c
ROAnnotation* annotation = [ROAnnotation annotationOfType:@"methodAnnotationWithMultiLineMethodName" atMethod:@"reallyLongMethodName:andAnother:" ofClass:[Person class]];
NSString value = [annotation valueForAttribute:@"key1"];
```

Customized way to retrieve annotation at runtime
-------------------------------------------------------------

* Put annotations as usual

```obj-c
//@PropertyAnnotationInHeader(key1=value1)
//@CustomizedAnnotation(attribute1 = 123, attribute2 = 456, attribute3 = 759)
@property (nonatomic, retain) NSString *name;
```

* Define a subclass of ROAnnotation

CustomizedAnnotation.h
```obj-c
@interface CustomizedAnnotation : ROAnnotation
@property(nonatomic, strong)NSString* attribute1;
@property(nonatomic, strong)NSString* attribute2;
@property(nonatomic, strong)NSString* attribute3;
@end
```

CustomizedAnnotation.m
```obj-c
@implementation CustomizedAnnotation
@dynamic attribute1;
@dynamic attribute2;
@dynamic attribute3;
@end
```

The fancy way to get annotation attributes

```obj-c
  CustomizedAnnotation* customizedAnnotation = (CustomizedAnnotation*)[ROAnnotation annotationOfType:@"CustomizedAnnotation" atProperty:@"name" ofClass:[Person class]];
  NSLog(@"annotation attribute:%@", customizedAnnotation.attribute1);
  NSLog(@"annotation attribute:%@", customizedAnnotation.attribute2);
  NSLog(@"annotation attribute:%@", customizedAnnotation.attribute3);
```


Get Started
-------------------------------------------------------------
1.Get the source.

    git clone https://github.com/jibeex/ROAnnotation.git
    
2.Copy the executable file ROAnnotation(from the root folder of this project) into your project

3.Include all files under folder Class/filesNeededForReadingAnnotationsOnly into your project

4.Add new aggregate target into your project

5.Select the new aggregate target, add build phase by Editor -> Add Build Phase -> Add run script phase

6.Add script under tab "Build Phases" of the new target to run the executable file ROAnnotation

For example:
    
    ROAnnotation Classes Classes/meta

6.Select you main target, go to Build Phases and add the script target in Target Dependencies so the script will run each time before you run the main target

7.Add annotations to your source files(Don't forget //@generate in the header file)

8.Run your main target. Now if everything is fine, the script would have parsed you source files and generated a file named "ROAnnotationData" in the output folder, say, Classes/meta.

9.Include the "ROAnnotationData" as bundle resource of your project

10.Start using ROAnnotation APIs to read annotations from "ROAnnotationData"


API
-------------------------------------------------------------

### [To get annotation]
TODO


Demo Project
-------------------------------------------------------------

A demo project is available under the Examples directory.

Support
-------------------------------------------------------------

Bugs or advices, send emails to jibeex@gmail.com

LICENSE and Copyright
-------------------------------------------------------------

These licenses only cover the framework itself, not including any file generated by it. So the generated annotation data file belongs to you.

ROAnnotation is inspired and derived from a talent project called ObjAnnotate by Dylan Bruzenak. As ROAnnotation is not going to generate any code like what ObjAnnotate does, only a small part(around 10%) of the code comes from ObjCAnnoate which is licensed under the BSD license. 

ROAnnotation is licensed under the BSD license below:
Copyright (c) 2013, Jianbin LIN
All rights reserved.

ObjCAnnotate is licensed under the BSD license below:
Copyright (c) 2010, Dylan Bruzenak
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
