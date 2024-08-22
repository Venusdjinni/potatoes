# Potatoes

[![pub package](https://img.shields.io/pub/v/potatoes.svg)](https://pub.dev/packages/potatoes)

Potatoes or french fries?

Potatoes is a lightweight development kit based on [BLoC](https://pub.dev/packages/flutter_bloc),
providing handy classes to help you quickly build your apps.

# Index

- [Potatoes](#potatoes)
- [Index](#index)
  - [Overview](#overview)
- [Potatoes cubits](#potatoes-cubits)
- [Cubit states](#cubit-states)
  - [ObjectCubit](#objectcubit)
  - [CubitManager](#cubitmanager)
  - [ValueCubit](#valuecubit)
- [Services](#services)
  - [ApiService & Dio client](#apiservice-&-dio-client)
  - [PreferencesService](#preferencesservice)
- [Loader widgets](#loader-widgets)
  - [AutoListView](#autolistview)
  - [AutoContentView](#autocontentview)
- [Loader dialogs](#loader-dialogs)
  - [CompletableMixin](#completablemixin)
  - [Dialogs](#dialogs)
- [Phoenix](#phoenix)
- [Library imports](#library-imports)

# Overview
This package is meant to ease the writing of repetitive logics in code by providing
a set of classes and tools based on BLoC pattern. If you are not familiar with BLoC, 
please head first [here](https://pub.dev/packages/flutter_bloc).

Potatoes also provide a simply state logic to help you loop effectively through your
cubits states.


# Potatoes cubits

## Cubit states

In Potatoes logic, cubit states are steps of a cycle alternating from one to another.
A cubit state can be permanent and providing an user interface or punctual just to
notify some listener. You can attribute a role to a state by extending the 
corresponding class:

```dart
// First declare the state base class.
// Cubit states classes extend Equatable
mixin LoginState on Equatable {}

// Use CubitSuccessState for idle or permanent success states. Equatable.props defines
// when the cubit state should be refreshed based on objects equality.
class LoginIdleState extends CubitSuccessState with LoginState {
  final String? email;
  final String? password;

  const LoginIdleState.empty() : email = null, password = null;

  const LoginIdleState(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// Use CubitLoadingState for loading steps. They cast a loading screen and prevent 
// the user from running a request twice.
class LoggingInState extends CubitLoadingState with LoginState {
  const LoggingInState();
}

// CubitInformationState are one-off events that dispatch a specific information
// without breaking the execution of a sequence.
// Use this to show a dialog or fire a one-time action.
class LoginNeedsOTPState extends CubitInformationState with LoginState {
  const LoginNeedsOTPState();
}

// CubitErrorState are used to track errors within an a sequence inside a cubit.
// Providing the error cause and the stack trace allow them to be logged via CubitErrorState.stream
class LoginErrorState extends CubitErrorState with LoginState {
  LoginErrorState(super.error, [super.trace]);
}
```

Each cubit state can be associated to one of these roles and while they do not directly
impact your state classes, they provide you some sort of logic to follow when writing your
cubit methods.

Here is an example with a login cubit:
```dart
class LoginCubit extends Cubit<LoginState> {
  final AuthService authService;
  
  LoginCubit(this.authService) : super(const LoginIdleState.empty());
  
  void login() {
    // fires action only if current state is idle
    if (state is LoginIdleState) {
      final stateBefore = state as LoginIdleState;
      // cast loading behavior
      emit(const LoggingInState());
      authService.login(
        stateBefore.email,
        stateBefore.password
      ).then(
        (response) {
          if (response.shouldValidateOTP) {
            // go to OTP page
            emit(const LoginNeedsOTPState());
            // revert to success state 
            emit(stateBefore);
          } else {
            // direct login
            // information state
            emit(const LoggedInState());
            // revert to empty success state
            emit(const LoginIdleState.empty());
          }
        },
        onError: (error, trace) {
          // log error and go back to last success state
          emit(LoginErrorState(error, trace));
          emit(stateBefore);
        }
      );
    }
  }
}
```

As you can see, by naming each state purpose, performing a cubit action becomes quite
as easy as to state it in natural language.

Depending on the case, you should arrange state roles within a cubit method execution.
For example, a data fetcher cubit should start with a `CubitLoadingState` and may
consider a `CubitErrorState` as a durable state.

## ObjectCubit
An `ObjectCubit` is an implementation of a Cubit designed to handle the lifecycle
of a single object. This is specifically effective to track business objects as 
you might want to update them while still tracking the same Cubit.

`ObjectCubit` ensures that you can get the last version registered version
of the tracked object at anytime, regardless of the current cubit state.

```dart
class PostCubit extends ObjectCubit<Post, APostState> {
  PostCubit(Post post) : super(PostState(post));

  // each time a new state is emitted, this method is called to update [this.object].
  // Relying on [this.object] allows us to access to the latest version of the 
  // tracked object without depending on the current state.
  @override
  Post? getObject(APostState state) {
    if (state is PostState) {
      return state.post;
    } else {
      return null;
    }
  }

  // this method defines the object update logic, based on external events. 
  // [ObjectCubit.update] is called by external source, providing a possibly updated version
  // of the tracked data. Decide here if the cubit should be updated.
  @override
  void update(Post object) {
    if (this.object == null) {
      emit(PostState(object));
    } else if (object.lastUpdate > this.object!.lastUpdate) {
      emit(PostState(object));
    }
  }
}
```

## CubitManager
A `CubitManager` is a factory for a single Cubit type. It handles the
lifecycle of the cubits of a specific type by assigning id to each instance.
This is handy when you want to ensure that only one cubit of each id is
used across your app.
A classic use case could be managing posts cubits inside and app, with posts
objects that can be edited as the app runs. `CubitManager` will ensure that
only one cubit is associated to a specific post (given a unique post ID).
While using `CubitManager`, you may not want the cubits to be automatically
closed by widgets such as `BlocProvider`. Be sure to always use
`BlocProvider.value` instead of the default constructor, as the latest
internally handle the created cubit lifecycle.

```dart
class PostCubitManager extends CubitManager<PostCubit, Post, int> {
  // build the unique identifier of an object, used to track the uniqueness of each cubit
  @override
  int buildId(Post object) {
    return object.id;
  }

  // instantiate a new cubit based on a business object
  @override
  PostCubit create(Post object) {
    return PostCubit(object);
  }

  // update a currently existing cubit with an updated version of the same tracked object
  @override
  void updateCubit(PostCubit cubit, Post object) {
    cubit.update(object);
  }
}
```

## ValueCubit
A miscellaneous cubit used to track simple class values.
```dart
final counterCubit = ValueCubit<int>(0);
counterCubit.set(1);

final counterResetCubit = InitialValueCubit<int>(0);
counterResetCubit.set(1);
counterResetCubit.reset(); // go back to initial value
```

# Services

## ApiService & Dio client
`ApiService` is an abstract class representing an API repository. It comes with these
simplifications:
- dynamic base url based on `Links.server`
- requests execution logging
- simplified authorization headers injection
- responses custom parsing
- unified API error class

### Creating an ApiService

To set up `ApiService`s in your project, you should first define `Links` url values.
```dart
class Links extends potatoes.Links {
  const Links();

  @override
  String get devUrl => 'development url here';

  @override
  String get productionUrl => 'staging/pre-prod url here';

  @override
  String get stagingUrl => 'production url here';

  /// other handy links
}
```
One of these links is selected to initialize the `Dio` instance when using `DioClient.instance`.
You still can provide an unrelated url to `DioClient` by using the `baseUrl` parameter.
```dart
final dio = potatoes.DioClient.instance(
  preferencesService,
  baseUrl: 'custom url to override Links.server',
  connectTimeout: const Duration(seconds: 30),
  sendTimeout: const Duration(seconds: 50),
  receiveTimeout: const Duration(minutes: 5),
  // whether all http status code should lead to a future success  
  disableStatusesErrors: false
);
```

Keep in mind that you still can set `Options` values by calling `dio.options`.

Finally, setting up the base `ApiService` for the project is done by overriding the
`compute` method:
```dart
class CustomApiService extends ApiService {
  const CustomApiService(super._dio);

  @override
  Future<T> compute<T>(
    // basically the dio.fetch call
    Future<Response<dynamic>> request, {
    // a key to look for, where to-parse data are located
    String? mapperKey,
    // an object mapper
    T Function(Map<String, dynamic> p1)? mapper,
    // a string mapper
    T Function(String p1)? messageMapper
  }) async {
    try {
      final response = await request;
      
      // ... compute response
      
      // ... use mapper or messageMapper to return result
    } on DioException catch (error) {
      throw ApiError.fromDio(error);
    } catch (error, trace) {
      throw ApiError.unknown(error.toString(), trace);
    }
  }
}
```

`compute` method is the general way your app will parse data coming from the queried 
remote API. If you have no idea on how to write your compute method, have a look at
`ApiService.defaultExtractResult` as an example.

### Using an ApiService

To get advantage of the capabilities of `ApiService`, you should extends your custom
class and begin creating concrete methods.

```dart
class AuthService extends CustomApiService {
  const AuthService(super._dio);
  
  Future<LoginResponse> login({
    required String email,
    required String password
  }) {
    // compute will run the POST query and parse the result accordingly to the 
    // implementation in CustomApiService.
    // Based on parameters, it will look for 'data' key in the response json and then
    // parse its value using LoginResponse.fromJson constructor
    return compute(
      dio.post(
        '/login',
        data: {
          'email': email,
          'password': password
        }
      ),
      mapperKey: 'data',
      mapper: LoginResponse.fromJson
    );
  }
}
```

## PreferencesService
`PreferencesService` is a wrapper of [SharedPreferences](https://pub.dev/packages/shared_preferences) 
designed to offer a better preferences management and providing new capabilities.

### Creating a PreferencesService
You can create your custom PreferencesService by extending this class.
```dart
class AppPreferencesService extends PreferencesService {
  static const String _tokenKey = 'token';

  AppPreferencesService(super.preferences);

  Future<void> saveToken(String value) => preferences.setString(_tokenKey, value);
  
  @override
  FutureOr<Map<String, String>> getAuthHeaders() {
    /// set headers setup logic here to be used by DioClient
    return {
      'Authorization': preferences.getString(_tokenKey)!
    };
  }
}
```

The preferred logic is to set all your preferences entry keys as const values and use them as above.

`getAuthHeaders` is a method called by `DioClient` each time you set a `withAuth()` while doing a Dio request.

```dart
Future<void> someApiCall() {
  return compute(
    dio.post(
      '/route',
      /// this will inject the result of `getAuthHeaders` before executing this request
      options: Options(headers: withAuth())
    )
  );
}
```

### Secure Preferences management
If you want to store your preferences into a secure storage, you can use the addon
[Potatoes Secured Preferences](https://pub.dev/packages/potatoes_secured_preferences).

# Loader widgets


## AutoListView
`AutoListView` displays a list of paginated items that updates automatically. It handles
an empty builder, loadingBuilder, loadingMoreBuilder and errorBuilder. The item list is 
obtained using `AutoListCubit`.

```dart
AutoListView.get<Post>(
  cubit: AutoListCubit(
    provider: ({int page = 0}) => postService.getPosts(page: page)
  ),
  itemBuilder: (context, post) => PostItem(post: post),
  emptyBuilder: (context) => const Center(
    child: Text("Empty list"),
  ),
  errorBuilder: (context, retry) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text("An error occured"),
      TextButton(
        onPressed: retry,
        child: const Text("Retry"),
      )
    ],
  )
)
```

When using an `AutoListCubit` with custom states, use `defaultBuilder` to
provide appropriate display per state.

## AutoContentView
`AutoContentView` acts as same as `AutoListView` but provides a single item
at the end. It uses `AutoContentCubit` to obtain the data and manage its state.

```dart
AutoContentView.get<User>(
  cubit: AutoContentCubit(
    provider: userService.getUser(id: user.id),
  ),
  builder: (context, user) => UserDisplay(user: user),
  errorBuilder: (context, retry) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text("An error occured"),
      TextButton(
        onPressed: retry,
        child: const Text("Retry"),
      )
    ],
  )
)
```

# Loader Dialogs

## CompletableMixin
`CompletableMixin` is a State extension that allows you to seamlessly add a whole
screen loader to your screen. Use `loadingDialogCompleter` to track the BuilContext
used to display your loader, and call `waitForDialog` to dismiss it. This is 
typically used in conjunction with `showLoadingBarrier` or `showSimpleLoadingBarrier`.

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with CompletableMixin {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
  
  // example listener for a BlocListener
  void onEventReceived(BuildContext context, CustomState state) async {
    // if the loader is currently displayed, removes it
    await waitForDialog();
    
    if (state is LoadingState) {
      // display the loader and pass its completer to loadinDialogCompleter
      loadingDialogCompleter = showLoadingBarrier(context: context);
    }
  }
}
```

## Dialogs
Potatoes provides two built-in loaders:

### Dialog popup loader
```dart
loadingDialogCompleter = showLoadingBarrier(context: context, text: "Please wait...");
```

### Barrier-only loader
```dart
loadingDialogCompleter = showSimpleLoadingBarrier(context: context);
```

# Phoenix
`Phoenix` allows you to entirely rebuild your app from a call using the current context.

```dart
void main() {
  runApp(
    const Phoenix(
      child: MyApp()
    )
  );
}
```
Then:
```dart
// rebuild whole app
Phoenix.rebirth(context);
```

# Library imports

Potatoes depends on the following packages:
- [Dio](https://pub.dev/packages/dio)
- [Equatable](https://pub.dev/packages/equatable)
- [Flutter BLoC](https://pub.dev/packages/flutter_bloc)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)

You may want to access to these package classes without having to extra-importing them.
In such case, use the following import:

```dart
import 'package:potatoes/libs.dart';
```

