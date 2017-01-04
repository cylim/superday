# ![](https://raw.githubusercontent.com/toggl/superday/develop/teferi/Assets.xcassets/icSuperday.imageset/icSuperday.png) Superday's Architectural best practices

This document's goal is to list the good practices one should take into account when adding new code to Superday. Every new line of code added should comply to those rules. Adding new rules is encouraged and, when doing so, also open a new Pull Request that ensures the new rule is being followed throughout the existing codebase.

## Ensure

The following items are rules that *must* be followed by every contributor.

### ViewControllers do not depend on Services

ViewControllers should only depend on the `ViewModelLocator` or on a `ViewModel`. The ViewModel should have all dependencies the ViewController needs to work properly.

### ViewModels do not depend on anything UI related

A ViewModel should not know anything about ViewControllers, animations or anything that's meant to be kept in the View layer of the app. Drop that `import UIKit`

### Service protocols have no implementation specific dependencies on their API

A Service protocol must be agnostic and should not know anything about the implementation details. This allows the service to be easily replaced if needed.

## Avoid

Those are general suggestions of possible code smells that can _probably_ be improved.

### Having too many dependencies

ViewModels that depend on more than 5 services are good candidates to being split into multiple ViewModels.


### Simply forwarding Service methods in the ViewModel

The ViewModel is meant to abstract the services for the ViewController, not serve as a way to expose their API. The ViewModel should, within reason, wrap the Service's API and expose a different and more useful one to the ViewController, making the consumer's work a lot easier.