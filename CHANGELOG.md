**[中文变更记录](CHANGELOG-Zh.md)**

v1.3.2
======

#### - Added Apple Privacy Manifest (PrivacyInfo.xcprivacy)

Added `PrivacyInfo.xcprivacy` to comply with Apple's privacy manifest requirements (introduced at WWDC23). The manifest declares that Masonry does not perform tracking, does not collect user data, and does not access any privacy-sensitive APIs. Both SPM (`Package.swift`) and CocoaPods (`Masonry.podspec`) now bundle this file automatically.

#### - Added Swift Code Snippets for Xcode

Three new Xcode code snippets are included in the `CodeSnippets/` directory for the Swift DSL:

| Completion Prefix | Description |
|---|---|
| `mas_swift_make` | `view.mas.makeConstraints { make in … }` |
| `mas_swift_remake` | `view.mas.remakeConstraints { make in … }` |
| `mas_swift_update` | `view.mas.updateConstraints { make in … }` |

Copy them to `~/Library/Developer/Xcode/UserData/CodeSnippets/` to enable auto-completion in Xcode.

#### - Modernised GitHub Issue Templates

Replaced the legacy `ISSUE_TEMPLATE.md` with structured GitHub YAML form templates (`bug_report.yml` and `feature_request.yml`), providing guided fields for platform, version, integration method, and reproduction steps.

#### - Changed `key` method signature from `NSString *` to `id`

The `.key()` method on `MASConstraint` now accepts `id _Nullable` instead of `NSString *`. This allows passing any object type (e.g. `NSNumber`, `NSURL`, custom objects) as a constraint debug key — the value is converted via `-description`. Passing `nil` is also safe and simply clears the key. The Swift-side `.key(_:)` method on `MASSwiftConstraintProxy` has been simplified accordingly.

```objc
// Before (1.3.1): only NSString
make.top.equalTo(superview).key(@"topPin");

// After (1.3.2): any object, including NSNumber
make.top.equalTo(superview).key(@"topPin");      // still works
make.top.equalTo(superview).key(@(340954));       // now also works — mas_key becomes "340954"
make.top.equalTo(superview).key(nil);             // safe, clears the key
```

#### - Cleaned up legacy files

Removed obsolete files that were left over from the pre-SPM era:
* `Masonry/Info.plist` — no longer needed; SPM generates bundle info automatically.
* `Tests/MasonryTestsLoader/` — legacy test host app, replaced by SPM test targets.
* `Tests/GcovTestObserver.m` — deprecated gcov integration for code coverage.
* `Tests/MasonryTests-Info.plist` — legacy test bundle plist.
* `Tests/NSObject+MASSubscriptSupport.h` — unused test helper.
* Removed redundant `TARGET_OS_IOS` / `TARGET_OS_TV` PCH macro definitions from the podspec.
* Deduplicated `.gitignore` entries.


v1.3.1
======

#### - Added MASConstraintConvertible protocol

Introduced `MASConstraintConvertible` as a formal protocol marking types that are valid constraint targets for `equalTo` / `greaterThanOrEqualTo` / `lessThanOrEqualTo`. Method signatures changed from bare `id` to `id<MASConstraintConvertible>`, giving `MASViewAttribute`, `UIView/NSView`, `NSValue/NSNumber`, and `NSArray` explicit compile-time declarations and improving type safety.

#### - Enhanced debug information

The `mas_equalTo()`, `mas_greaterThanOrEqualTo()`, and `mas_lessThanOrEqualTo()` macros now automatically embed the call-site file name and line number into the constraint's `mas_key`, so Xcode's "Unable to simultaneously satisfy constraints" log output points directly to the source line. New methods `equalToWithLocation:file:line:`, `greaterThanOrEqualToWithLocation:file:line:`, and `lessThanOrEqualToWithLocation:file:line:` are also exposed for advanced use.

On the Swift side, `equalTo(_:)`, `greaterThanOrEqualTo(_:)`, and `lessThanOrEqualTo(_:)` now automatically capture `#fileID` and `#line` for clearer runtime assertion messages.


v1.3.0
======

#### - MasonrySwift API aligned with SnapKit

Refactored the `MasonrySwift` module so its API style and attribute names match SnapKit, reducing the learning curve for projects that use both frameworks.

#### - Added equalToSuperView convenience method

Added `equalToSuperView` as a shortcut for the common "constrain equal to superview" pattern.

#### - Performance improvement

Optimised the internal traversal logic for constraint installation, based on community feedback ([SnapKit/Masonry#578](https://github.com/SnapKit/Masonry/issues/578)).

#### - Migrated to GitHub Actions

CI/CD pipeline migrated from Travis CI to GitHub Actions; the Example project was converted to Swift Package format.


v1.2.3
======

#### - Repository structure reorganisation

Reorganised the repository layout so public headers and source files are grouped more clearly.


v1.2.2
======

#### - Reduced cyclomatic complexity

Refactored methods with excessive cyclomatic complexity to improve maintainability.


v1.2.1
======

#### - Added MASAttributeOffset operator

Added the `MASAttributeOffset` operator to simplify constraints that include an offset value.

#### - Added SKILL.md

Added the Masonry constraint expert skill document.


v1.2.0
======

#### - Swift Package Manager support

Added SPM integration via `Package.swift`, shipping `Masonry` and `MasonrySwift` as two library products. Minimum deployment targets: iOS 16+ / macOS 13+ / tvOS 16+.

#### - Enhanced Swift support

Deepened the `MasonrySwift` module with a fully native Swift DSL including operator overloads (`==`, `>=`, `<=`, `~`) and the `view.mas.makeConstraints` entry point, replacing ObjC macros that are unavailable in Swift.

#### - Modernisation

Modernised ObjC code to use the Xcode-recommended `NSLayoutConstraint` activate/deactivate API.


v1.0.2
======

* Bug fix for array greaterThanOrEqualTo or lessthanOrEqualTo attributes ([#377](https://github.com/SnapKit/Masonry/pull/377))
* Bug fix for Podfile so examples work again ([#374](https://github.com/SnapKit/Masonry/pull/374))
* Improve view distribution performance ([#374](https://github.com/SnapKit/Masonry/pull/362))
* Unshare pod schemes ([#374](https://github.com/SnapKit/Masonry/pull/352))


v1.0.1
======

#### - Added support for first/last baselines

Two additional attributes `NSLayoutAttributeFirstBaseline` and `NSLayoutAttributeLastBaseline` are now supported

v1.0.0
======

#### - Officially v1.0.0

Fixes some issues with install/uninstall vs activate/deactivate and modernises the project files

v0.6.4
======

#### - Add support for tvOS

v0.6.3
======

#### - Add support for view distribution ([pingyourid](https://github.com/pingyourid))

https://github.com/SnapKit/Masonry/pull/225

v0.6.2
======

#### - Add support for iOS 8 margin attributes ([CraigSiemens](https://github.com/CraigSiemens))

https://github.com/SnapKit/Masonry/pull/163

#### - Add support for leading and trailing insets ([montehurd](https://github.com/montehurd))

https://github.com/SnapKit/Masonry/pull/168

#### - Add support for Cartage ([erichoracek](https://github.com/erichoracek))

https://github.com/SnapKit/Masonry/pull/182

#### - Fix memory usage of updateConstraints

v0.6.1
======

#### - Fix unused variable warning when compiled with NSAssert turned off

#### - Add aspect fit example ([kouky](https://github.com/kouky))

https://github.com/SnapKit/Masonry/pull/148

v0.6.0
======

#### - Improved support of iOS 8

As of iOS 8 there is `active` property of `NSLayoutConstraint` available, which allows to (de)activate constraint without searching closest common superview.

#### - Added support of iPhone 6 and iPhone 6+ to test project

v0.5.3
======

#### - Fixed compilation errors on xcode6 beta

https://github.com/Masonry/Masonry/pull/84


v0.5.2
======

#### - Fixed compilation warning with Shorthand view Additions

https://github.com/cloudkite/Masonry/issues/71

v0.5.1
======

#### - Fixed compilation error when using objective-c++ ([nickynick](https://github.com/nickynick))

https://github.com/cloudkite/Masonry/pull/69

v0.5.0
======

#### - Fixed bug in `mas_updateConstraints` ([Rolken](https://github.com/Rolken))

Was not checking that the constraint relation was equivalent
https://github.com/cloudkite/Masonry/pull/65

#### - Added `mas_remakeConstraints` ([nickynick](https://github.com/nickynick))

Similar to `mas_updateConstraints` however instead of trying to update existing constraints it Removes all constraints previously defined and installed for the view, allowing you to provide replacements without hassle.

https://github.com/cloudkite/Masonry/pull/63

#### - Added Autoboxing for scalar/struct attribute values ([nickynick](https://github.com/nickynick))

Autoboxing allows you to write equality relations and offsets by passing primitive values and structs
```obj-c
make.top.mas_equalTo(42);
make.height.mas_equalTo(20);
make.size.mas_equalTo(CGSizeMake(50, 100));
make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 10, 0));
make.left.mas_equalTo(view).mas_offset(UIEdgeInsetsMake(10, 0, 10, 0));
```
by default these autoboxing macros are prefix with `mas_`
If you want the unprefixed version you need to add `MAS_SHORTHAND_GLOBALS` before importing Masonry.h (ie in your Prefix.pch)

https://github.com/cloudkite/Masonry/pull/62

#### - Added ability to chain view attributes

Composites are great for defining multiple attributes at once. The following example makes top, left, bottom, right equal to `superview`.

```obj-c
make.edges.equalTo(superview).insets(padding);
```

However if only three of the sides are equal to `superview` then we need to repeat quite a bit of code
```obj-c
make.left.equalTo(superview).insets(padding);
make.right.equalTo(superview).insets(padding);
make.bottom.equalTo(superview).insets(padding);
// top needs to be equal to `otherView`
make.top.equalTo(otherView).insets(padding);
```

This change makes it possible to chain view attributes to improve readability
```obj-c
make.left.right.and.bottom.equalTo(superview).insets(padding);
make.top.equalTo(otherView).insets(padding);
```

https://github.com/cloudkite/Masonry/pull/56

v0.4.0
=======

#### - Fixed Xcode auto-complete support ([nickynick](https://github.com/nickynick))

***Breaking Changes***

If you are holding onto any instances of masonry constraints ie
```obj-c
// in public/private interface
@property (nonatomic, strong) id<MASConstraint> topConstraint;
```

You will need to change this to
```obj-c
// in public/private interface
@property (nonatomic, strong) MASConstraint *topConstraint;
```

Instead of using protocols Masonry now uses an abstract base class for constraints in order to get Xcode auto-complete support see http://stackoverflow.com/questions/14534223/

v0.3.2
=======

#### - Added support for Mac OSX animator proxy ([pfandrade](https://github.com/pfandrade))

```objective-c
self.leftConstraint.animator.offset(20);
```

#### - Added setter methods for NSLayoutConstraint constant proxies like `offset`, `centerOffset`, `insets`, `sizeOffset`.
now you can update these values using more natural syntax

```objective-c
self.edgesConstraint.insets(UIEdgeInsetsMake(20, 10, 15, 5));
```

can now be written as:

```objective-c
self.edgesConstraint.insets = UIEdgeInsetsMake(20, 10, 15, 5);
```


v0.3.1
=======

#### - Added way to specify the same set of constraints to multiple views in an array ([danielrhammond](https://github.com/danielrhammond))

```objective-c
[@[view1, view2, view3] mas_makeConstraints:^(MASConstraintMaker *make) {
    make.baseline.equalTo(superView.mas_centerY);
    make.width.equalTo(@100);
}];
```

v0.3.0
=======

#### - Added `- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *))block`
which will update existing constraints if possible, otherwise it will add them.  This makes it easier to use Masonry within the `UIView` `- (void)updateConstraints` method which is the recommended place for adding/updating constraints by apple.
#### - Updated examples for iOS7, added a few new examples.
#### - Added -isEqual: and -hash to MASViewAttribute [CraigSiemens].
