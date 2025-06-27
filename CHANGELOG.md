# 3.1.0

* `AutoListCubit` and `AutoContentCubit` now better catch errors. Some errors were not caught when
the provider threw an exception without returning a future/stream.
* `AutoListView` no longer displays errorBuilder when an error occurs after an initial `AutoListReadyState`.
Errors will now be sent to `onLoadingMoreError` callback.
* Added an optional `Key` parameter to AutoListView and AutoContentView constructors
* Upgraded dio, flutter_bloc and shared_preferences to latest versions

## 3.0.8+1

* Updated `PaginatedList.hasReachedMax` condition from `items.length >= total` to `items.length >= total`

## 3.0.8

* Added a `getById` feature for `CubitManager`

## 3.0.7+1

* `ApiService` now throw an exception when `_getAuth`method fails

## 3.0.7

* Adding a `ScrollController` parameter to AutoListView constructors

## 3.0.6

* Introducing `SliverAutoListView` to support sliver lists

## 3.0.5

* Upgrade `equatable` to version ^2.0.7
* Upgrade `shared_preferences` to version ^2.3.5

## 3.0.4

* `CubitManager` now cleans closed cubits 

## 3.0.3+1

* Fixed doc issue

## 3.0.3

* Added internationalization for default texts

## 3.0.2

* Removed web imports from Dio

## 3.0.1

* Added documentation and examples

## 3.0.0

* Full refactoring
* Added documentation and examples
* Updated license