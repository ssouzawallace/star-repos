# ⭐ GitHub Star Repos

An iOS app that displays the most starred Swift repositories on GitHub, built with a reactive MVVM architecture.

## Overview

GitHub Star Repos fetches and displays Swift repositories from the [GitHub Search API](https://docs.github.com/en/rest/search/search#search-repositories), sorted by star count. The list supports infinite scrolling with automatic pagination and pull-to-refresh.

Each repository entry shows:

- **Repository name**
- **Owner username and avatar**
- **Star count**

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern with reactive bindings powered by RxSwift.

```
Github Star Repos/
├── Application/          # AppDelegate and app entry point
├── Model/                # Data models (Repo, RepoOwner)
├── Modules/
│   └── RepoList/         # Main feature module
│       ├── RepoListViewController.swift   # View layer
│       ├── RepoListViewModel.swift        # Business logic & state management
│       ├── ListItem.swift                 # Enum for table view items
│       └── Cells/                         # Custom UITableViewCell subclasses
├── WebService/           # Networking layer (Endpoint, Response models)
├── Extensions/           # UITableView convenience extensions
├── Resources/            # Assets and storyboards
└── Result/               # Generic Result type
```

## Tech Stack

| Category | Library |
|---|---|
| Reactive programming | [RxSwift](https://github.com/ReactiveX/RxSwift) / [RxCocoa](https://github.com/ReactiveX/RxSwift) |
| Table view data sources | [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) |
| Auto Layout | [Cartography](https://github.com/robb/Cartography) |
| Image loading | [SDWebImage](https://github.com/SDWebImage/SDWebImage) |

### Testing

| Category | Library |
|---|---|
| BDD framework | [Quick](https://github.com/Quick/Quick) / [Nimble](https://github.com/Quick/Nimble) |
| Rx testing | [RxNimble](https://github.com/RxSwiftCommunity/RxNimble) / [RxTest](https://github.com/ReactiveX/RxSwift) |
| Network stubbing | [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) |
| Snapshot testing | [iOSSnapshotTestCase](https://github.com/uber/ios-snapshot-test-case) |

## Requirements

- Xcode 10+
- Swift 4.2+
- [CocoaPods](https://cocoapods.org/)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/ssouzawallace/star-repos.git
   cd star-repos
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Open the workspace**
   ```bash
   open "Github Star Repos.xcworkspace"
   ```

4. **Build and run** the `Github Star Repos` scheme on a simulator or device.

## Running Tests

Open the workspace in Xcode and run tests with **⌘U**, or from the command line:

```bash
xcodebuild test \
  -workspace "Github Star Repos.xcworkspace" \
  -scheme "Github Star Repos" \
  -destination "platform=iOS Simulator,name=iPhone 12"
```

The test suite includes:

- **Unit tests** — ViewModel state transitions for success and error responses
- **Network tests** — Stubbed HTTP responses to verify API integration
- **Snapshot tests** — Visual regression tests for the repository list

## License

This project is available for personal and educational use.
