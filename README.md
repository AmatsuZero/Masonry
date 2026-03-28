# Masonry [![CI](https://github.com/AmatsuZero/Masonry/actions/workflows/ci.yml/badge.svg)](https://github.com/AmatsuZero/Masonry/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/AmatsuZero/Masonry/branch/master/graph/badge.svg)](https://codecov.io/gh/AmatsuZero/Masonry) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![Pod Version](https://img.shields.io/cocoapods/v/Masonry.svg?style=flat)

**[中文文档](README-Zh.md)** | **[变更记录（中文）](CHANGELOG-Zh.md)**

Masonry is a lightweight layout framework that wraps AutoLayout with a nicer syntax. It provides a chainable DSL for describing `NSLayoutConstraints`, resulting in layout code that is more concise and readable.

Masonry supports **iOS**, **macOS**, and **tvOS**, and ships with a native **Swift DSL** via the `MasonrySwift` module.

## Why Masonry?

Creating constraints with raw `NSLayoutConstraint` API is verbose and hard to read:

```obj-c
[superview addConstraints:@[
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:padding.top],
    // ... three more constraints just for edges
]];
```

With Masonry, the same layout is expressed in a single line:

```obj-c
[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).with.insets(padding);
}];
```

Masonry also handles `translatesAutoresizingMaskIntoConstraints` and constraint installation automatically.

## Installation

### Swift Package Manager (Recommended)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AmatsuZero/Masonry.git", from: "1.3.2")
]
```

Two library products are available:
- **`Masonry`** — Objective-C core
- **`MasonrySwift`** — Swift native DSL (depends on `Masonry`)

### CocoaPods

```ruby
# Objective-C only
pod 'Masonry'

# Objective-C + Swift DSL
pod 'Masonry/Swift'
```

### Carthage

```
github "AmatsuZero/Masonry"
```

## Privacy Manifest

Starting with v1.3.2, Masonry ships with an Apple **Privacy Manifest** (`PrivacyInfo.xcprivacy`). The manifest declares that Masonry does **not** collect any data, does **not** use any required-reason APIs, and does **not** track users. Both SPM and CocoaPods integrate the manifest automatically — no extra configuration is needed.

## Xcode Code Snippets

The repository includes ready-to-use Xcode code snippets in the `CodeSnippets/` directory. Copy them to `~/Library/Developer/Xcode/UserData/CodeSnippets/` to enable quick autocompletion:

| Shortcut | Language | Description |
|----------|----------|-------------|
| `mas_make` | Objective-C | `mas_makeConstraints` block |
| `mas_update` | Objective-C | `mas_updateConstraints` block |
| `mas_remake` | Objective-C | `mas_remakeConstraints` block |
| `mas_swift_make` | Swift | `mas.makeConstraints` closure |
| `mas_swift_update` | Swift | `mas.updateConstraints` closure |
| `mas_swift_remake` | Swift | `mas.remakeConstraints` closure |

## Usage (Objective-C)

### Creating Constraints

```obj-c
UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);

[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.mas_top).with.offset(padding.top);
    make.left.equalTo(superview.mas_left).with.offset(padding.left);
    make.bottom.equalTo(superview.mas_bottom).with.offset(-padding.bottom);
    make.right.equalTo(superview.mas_right).with.offset(-padding.right);
}];
```

Or more concisely:

```obj-c
[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).with.insets(padding);
}];
```

### Equality Relations

| Method | NSLayoutRelation |
|--------|-----------------|
| `.equalTo` | `NSLayoutRelationEqual` |
| `.lessThanOrEqualTo` | `NSLayoutRelationLessThanOrEqual` |
| `.greaterThanOrEqualTo` | `NSLayoutRelationGreaterThanOrEqual` |

These accept the following argument types:

#### 1. MASViewAttribute

```obj-c
make.centerX.lessThanOrEqualTo(view2.mas_left);
```

| MASViewAttribute | NSLayoutAttribute |
|-----------------|-------------------|
| `view.mas_left` | `NSLayoutAttributeLeft` |
| `view.mas_right` | `NSLayoutAttributeRight` |
| `view.mas_top` | `NSLayoutAttributeTop` |
| `view.mas_bottom` | `NSLayoutAttributeBottom` |
| `view.mas_leading` | `NSLayoutAttributeLeading` |
| `view.mas_trailing` | `NSLayoutAttributeTrailing` |
| `view.mas_width` | `NSLayoutAttributeWidth` |
| `view.mas_height` | `NSLayoutAttributeHeight` |
| `view.mas_centerX` | `NSLayoutAttributeCenterX` |
| `view.mas_centerY` | `NSLayoutAttributeCenterY` |
| `view.mas_baseline` | `NSLayoutAttributeBaseline` |

#### 2. UIView / NSView

```obj-c
// These two constraints are exactly the same
make.left.greaterThanOrEqualTo(label);
make.left.greaterThanOrEqualTo(label.mas_left);
```

#### 3. NSNumber

```obj-c
// width >= 200 && width <= 400
make.width.greaterThanOrEqualTo(@200);
make.width.lessThanOrEqualTo(@400);
```

For alignment attributes, passing an `NSNumber` creates a constraint relative to the superview:

```obj-c
// creates view.left = view.superview.left + 10
make.left.lessThanOrEqualTo(@10);
```

#### Autoboxing with Primitives

Use `mas_` prefixed macros to pass primitives and structs directly:

```obj-c
make.top.mas_equalTo(42);
make.height.mas_equalTo(20);
make.size.mas_equalTo(CGSizeMake(50, 100));
make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 10, 0));
```

> Define `MAS_SHORTHAND_GLOBALS` before importing Masonry to use unprefixed versions.

#### 4. NSArray

```obj-c
make.height.equalTo(@[view1.mas_height, view2.mas_height]);
make.left.equalTo(@[view1, @100, view3.right]);
```

### Attribute Chaining

```obj-c
// Set left, right, and bottom to superview, top to another view
make.left.right.and.bottom.equalTo(superview);
make.top.equalTo(otherView);
```

### Priority

```obj-c
make.left.greaterThanOrEqualTo(label.mas_left).with.priorityLow();
make.top.equalTo(label.mas_top).with.priority(600);
```

### Updating & Remaking Constraints

```obj-c
// Update existing constraints (or create if not found)
[view1 mas_updateConstraints:^(MASConstraintMaker *make) {
    make.leading.equalTo(superview).offset(newPadding);
}];

// Remove all existing constraints and create new ones
[view1 mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).insets(newPadding);
}];
```

### Holding Constraint References

```obj-c
@property (nonatomic, strong) MASConstraint *topConstraint;

[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    self.topConstraint = make.top.equalTo(superview.mas_top).with.offset(padding.top);
    make.left.equalTo(superview.mas_left).with.offset(padding.left);
}];

// Later, update the constraint
[self.topConstraint uninstall];
```

### Debugging

The `mas_equalTo()`, `mas_greaterThanOrEqualTo()`, and `mas_lessThanOrEqualTo()` macros automatically embed the call-site file name and line number into the constraint's `mas_key`. This makes Xcode's "Unable to simultaneously satisfy constraints" log output point directly to the source line:

```obj-c
// mas_key is automatically set to "<file>:<line>" — no manual tagging needed
make.top.mas_equalTo(superview.mas_top).offset(20);

// You can still add an explicit key when needed (accepts any type, not just NSString)
make.top.equalTo(superview.mas_top).offset(20).key(@"topPin");
make.width.equalTo(@200).key(@(340954));  // NSNumber as key — stored as its description
// Or tag multiple views at once:
MASAttachKeys(titleLabel, avatarView);
```

## Usage (Swift)

The `MasonrySwift` module provides a type-safe, Swift-native DSL that replaces ObjC macros:

```swift
import MasonrySwift

view.mas.makeConstraints { make in
    make.top.equalTo(superview.mas_top).offset(20)
    make.left.right.equalTo(superview).inset(16)
    make.height.equalTo(44)
}

// Update constraints
view.mas.updateConstraints { make in
    make.top.equalTo(superview).offset(newValue)
}

// Remake constraints
view.mas.remakeConstraints { make in
    make.edges.equalTo(superview).inset(padding)
}
```

### Swift Operators

The Swift module also supports operator-based constraint creation:

```swift
view.mas.makeConstraints { make in
    make.top == superview.mas_top + 20
    make.left >= superview.mas_left + 16
    make.width <= 200
    make.height == 44 ~ .defaultHigh  // with priority
}
```

## Examples

Check out the **Examples.swiftpm** Swift Playground project in the repository for interactive examples covering:

- Basic constraints
- Animations
- Scroll views
- Aspect fit
- Safe area layout guides
- View distribution
- And more

Open it with Xcode:

```bash
open Examples.swiftpm
```

## License

Masonry is released under the MIT License. See [LICENSE](LICENSE) for details.