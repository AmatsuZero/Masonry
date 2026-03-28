//
//  ViewController+MASAdditionsSpec.m
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "XCTest+Spec.h"
#import "MASUtilities.h"
#import "MASTestExpectation.h"

#import "ViewController+MASAdditions.h"
#import "View+MASAdditions.h"

SpecBegin(ViewController_MASAdditions)

- (void)testLayoutGuideConstraints {
#ifdef MAS_VIEW_CONTROLLER
    MAS_VIEW_CONTROLLER *vc = [MAS_VIEW_CONTROLLER new];
    MAS_VIEW *view = [MAS_VIEW new];
    
    [vc.view addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        make.top.equalTo(vc.mas_topLayoutGuide);
        make.bottom.equalTo(vc.mas_bottomLayoutGuide);
#pragma clang diagnostic pop
    }];
    
    expect(vc.view.constraints).to.haveCountOf(6);
#endif
}

SpecEnd