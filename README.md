# Core Data Manager

Hey its another manager class to make Core Data easier to use.

I created this project to refresh on Core Data API updates over the past 2-3 years.

Nothing mind blowing at the minute. But a nice example of implimenting Core Data.

# MVVM architecture prototype

Inspired by:
* https://github.com/kaushikgopal/movies-usf
* https://fragmentedpodcast.com/episodes/148/
* https://fragmentedpodcast.com/episodes/151/
* https://developer.android.com/jetpack/docs/guide


## ViewModel example

```swift
struct PostsViewState {
    var posts: [PostData]
}

enum PostsViewEffect {
    case presentDetail(PostDetailViewModelProtocol)
    case presentErrorAlert(Error)
}

enum PostsEvent {
    case createPost(CreatePostData)
    case deletePost(indexPath: IndexPath)
    case postTapped(indexPath: IndexPath)
}

protocol PostsViewModelProtocol {

/// Represents state of UI. UI subsribes to this and appropriately reflows its self to reflect this state.
///
/// Subscribe to state
/// Completion is called when underlying state updates
func subscribeToViewState(_ completion: @escaping (PostsViewState) -> Void)

/// UI acts on effect once, when called
///
func subscribeToViewEffects(_ completion: @escaping (PostsViewEffect) -> Void)

/// All UI actions go through this method
/// Any state update is async and communicated through a subscribe completion
///
/// User or system event input from UI
func eventOccured(_ event: PostsEvent)
}
```

I am a fan of this approach because:

### Refective
* Protocol would be basically identifical for all VM's (maybe additional abstraction to be found here). 
* Each VM has a single ViewState value object which is easy reference
* Each VM has s single ViewEffect enum
* Each VM has  a single Event enum

### Testable
* Tests actions are calls to 'eventOccured'
* Tests asserts are validating if the subscribe methods do or do not emit and what values emitted are.
* Similar VM interface patterns allows for similar VM unit test interface patterns

### Everything is async
* Building from an interface which enforces everything being async ensures future refactoring to make something async will not introduce regression.

### Open to extension
* Common view effect associated value objects could be handled by common UI code e.g. 'error presentation'. Potentially the same can be try for viewState properties. e.g. 'isActivityIndicatorVisible'
* If the cost of reflowing the UI is high there is single point to address this in the view state subscription method. No concerns about state updates clobbering one another as could be the case if view state was exposed by more than single value object.

### Future proof ???
* I think this MVVM approach has potential to easily port to SwiftUI. In particular thinking about viewState of a VM being a Bindable object which SwifthUI binds to. I plan to put up at least a PR demoing this to get an idea of how challening this conversion may or may not be.




