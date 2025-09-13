import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mock entities and blocs for testing
enum UserRole { tourist, provider, admin }

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final UserRole userType;
  final bool profileCompleted;
  final DateTime createdDate;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.userType,
    required this.profileCompleted,
    required this.createdDate,
  });
}

// Mock UserBloc states
abstract class UserState {}

class UserLoading extends UserState {}

class UserAuthenticated extends UserState {
  final User user;
  UserAuthenticated({required this.user});
}

class UserError extends UserState {
  final String message;
  UserError({required this.message});
}

// Mock UserBloc
class MockUserBloc extends Mock implements Bloc<dynamic, UserState> {
  @override
  UserState get state => super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: UserLoading(),
      );

  @override
  Stream<UserState> get stream => super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: Stream.value(UserLoading()),
      );
}

// Mock ProfileCompletionWrapper widget
class ProfileCompletionWrapper extends StatelessWidget {
  final Widget child;

  const ProfileCompletionWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockUserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is UserError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }

        if (state is UserAuthenticated) {
          if (!state.user.profileCompleted) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Complete Your Profile'),
                    Text('Please complete your profile to continue'),
                  ],
                ),
              ),
            );
          }
          return child;
        }

        return const Scaffold(
          body: Center(child: Text('Unknown state')),
        );
      },
    );
  }
}

@GenerateMocks([])
void main() {
  group('ProfileCompletionWrapper Widget Tests', () {
    late MockUserBloc mockUserBloc;

    setUp(() {
      mockUserBloc = MockUserBloc();
    });

    testWidgets('should show child when profile is complete',
        (WidgetTester tester) async {
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        phone: '+1234567890',
        userType: UserRole.tourist,
        profileCompleted: true,
        createdDate: DateTime.now(),
      );

      when(mockUserBloc.state).thenReturn(UserAuthenticated(user: user));
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(UserAuthenticated(user: user)));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MockUserBloc>(
            create: (_) => mockUserBloc,
            child: const ProfileCompletionWrapper(
              child: Text('Main Content'),
            ),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Complete Your Profile'), findsNothing);
    });

    testWidgets('should show profile completion when profile is incomplete',
        (WidgetTester tester) async {
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: null,
        phone: null,
        userType: UserRole.tourist,
        profileCompleted: false,
        createdDate: DateTime.now(),
      );

      when(mockUserBloc.state).thenReturn(UserAuthenticated(user: user));
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(UserAuthenticated(user: user)));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MockUserBloc>(
            create: (_) => mockUserBloc,
            child: const ProfileCompletionWrapper(
              child: Text('Main Content'),
            ),
          ),
        ),
      );

      expect(find.text('Main Content'), findsNothing);
      expect(find.text('Complete Your Profile'), findsOneWidget);
    });

    testWidgets('should show loading when user state is loading',
        (WidgetTester tester) async {
      when(mockUserBloc.state).thenReturn(UserLoading());
      when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserLoading()));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MockUserBloc>(
            create: (_) => mockUserBloc,
            child: const ProfileCompletionWrapper(
              child: Text('Main Content'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Main Content'), findsNothing);
    });

    testWidgets('should show error when user state has error',
        (WidgetTester tester) async {
      when(mockUserBloc.state)
          .thenReturn(UserError(message: 'Failed to load user'));
      when(mockUserBloc.stream).thenAnswer(
          (_) => Stream.value(UserError(message: 'Failed to load user')));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MockUserBloc>(
            create: (_) => mockUserBloc,
            child: const ProfileCompletionWrapper(
              child: Text('Main Content'),
            ),
          ),
        ),
      );

      expect(find.text('Failed to load user'), findsOneWidget);
      expect(find.text('Main Content'), findsNothing);
    });
  });
}
