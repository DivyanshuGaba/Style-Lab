# Style Lab

Native SwiftUI iPhone app that helps pick a visual style for an app and exports a design handoff.

Build and run:
1. `brew install xcodegen` (once), then `xcodegen generate` to create StyleLab.xcodeproj from project.yml.
2. Open StyleLab.xcodeproj, set your own team and bundle identifier (currently com.divyanshu.StyleLab), run on iPhone or iPad. iOS 17 or later.
3. Tests: Cmd+U. Golden handoff files live in StyleLabTests/Goldens. Delete one and run the tests to see the new output printed as base64.

No third party packages, no network. Only permission requested: add-only Photos access when saving screenshots.
