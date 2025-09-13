import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/entities.dart';

void main() {
  group('Registration Entity Tests', () {
    late Registration testRegistration;
    late DateTime registrationDate;

    setUp(() {
      registrationDate = DateTime(2024, 1, 15);

      testRegistration = Registration(
        id: "reg123",
        customTourId: "tour123", 
        touristId: "tourist123",
        status: RegistrationStatus.pending,
        confirmationCode: "CONF2024001",
        registrationDate: registrationDate,
        specialRequirements: 'Vegetarian meals, wheelchair accessible',
        emergencyContactName: 'Jane Doe',
        emergencyContactPhone: '+1-555-987-6543',
      );
    });

    test('should create Registration with all fields', () {
      expect(testRegistration.id, 'reg123');
      expect(testRegistration.customTourId, 'tour123');
      expect(testRegistration.touristId, 'tourist123');
      expect(testRegistration.status, RegistrationStatus.pending);
      expect(testRegistration.confirmationCode, 'CONF2024001');
      expect(testRegistration.specialRequirements,
          'Vegetarian meals, wheelchair accessible');
      expect(testRegistration.emergencyContactName, 'Jane Doe');
      expect(testRegistration.emergencyContactPhone, '+1-555-987-6543');
      expect(testRegistration.registrationDate, registrationDate);
    });

    test('should validate registration correctly', () {
      expect(testRegistration.isValid, true);

      // Test empty custom tour ID
      final emptyTourIdReg = testRegistration.copyWith(customTourId: '');
      expect(emptyTourIdReg.isValid, false);

      // Test empty tourist ID
      final emptyTouristIdReg = testRegistration.copyWith(touristId: '');
      expect(emptyTouristIdReg.isValid, false);

      // Test empty confirmation code
      final emptyConfCodeReg = testRegistration.copyWith(confirmationCode: '');
      expect(emptyConfCodeReg.isValid, false);
    });

    test('should validate emergency contact correctly', () {
      expect(testRegistration.isValid, true);

      // Test valid emergency contact with name and phone
      final validContact = testRegistration.copyWith(
        emergencyContactName: 'John Smith',
        emergencyContactPhone: '+1234567890',
      );
      expect(validContact.isValid, true);

      // Test invalid phone number when name is provided
      final invalidPhone = testRegistration.copyWith(
        emergencyContactName: 'John Smith',
        emergencyContactPhone: '123', // Too short
      );
      expect(invalidPhone.isValid, false);

      // Test name without phone (invalid)
      final nameWithoutPhone = Registration(
        id: "reg124",
        customTourId: "tour124", 
        touristId: "tourist124",
        status: RegistrationStatus.pending,
        confirmationCode: "CONF2024002",
        registrationDate: registrationDate,
        emergencyContactName: 'John Smith',
      );
      expect(nameWithoutPhone.isValid, false);

      // Test no emergency contact (valid - optional)
      final noContact = Registration(
        id: "reg125",
        customTourId: "tour125", 
        touristId: "tourist125",
        status: RegistrationStatus.pending,
        confirmationCode: "CONF2024003",
        registrationDate: registrationDate,
      );
      expect(noContact.isValid, true);

      // Test empty name with phone (valid - name can be empty if provided)
      final emptyNameWithPhone = Registration(
        id: "reg126",
        customTourId: "tour126", 
        touristId: "tourist126",
        status: RegistrationStatus.pending,
        confirmationCode: "CONF2024004",
        registrationDate: registrationDate,
        emergencyContactPhone: '+1234567890',
      );
      expect(emptyNameWithPhone.isValid, true);
    });

    test('should test status convenience methods', () {
      expect(testRegistration.isPending, true);
      expect(testRegistration.isApproved, false);
      expect(testRegistration.isRejected, false);
      expect(testRegistration.isCancelled, false);
      expect(testRegistration.isCompleted, false);

      final approvedReg =
          testRegistration.copyWith(status: RegistrationStatus.approved);
      expect(approvedReg.isPending, false);
      expect(approvedReg.isApproved, true);

      final rejectedReg =
          testRegistration.copyWith(status: RegistrationStatus.rejected);
      expect(rejectedReg.isRejected, true);

      final cancelledReg =
          testRegistration.copyWith(status: RegistrationStatus.cancelled);
      expect(cancelledReg.isCancelled, true);

      final completedReg =
          testRegistration.copyWith(status: RegistrationStatus.completed);
      expect(completedReg.isCompleted, true);
    });

    test('should determine if can be cancelled', () {
      expect(testRegistration.canBeCancelled, true); // pending

      final approvedReg =
          testRegistration.copyWith(status: RegistrationStatus.approved);
      expect(approvedReg.canBeCancelled, true); // approved

      final rejectedReg =
          testRegistration.copyWith(status: RegistrationStatus.rejected);
      expect(rejectedReg.canBeCancelled, false); // rejected

      final cancelledReg =
          testRegistration.copyWith(status: RegistrationStatus.cancelled);
      expect(cancelledReg.canBeCancelled, false); // already cancelled

      final completedReg =
          testRegistration.copyWith(status: RegistrationStatus.completed);
      expect(completedReg.canBeCancelled, false); // completed
    });

    test('should determine if requires action', () {
      expect(testRegistration.requiresAction, true); // pending

      final approvedReg =
          testRegistration.copyWith(status: RegistrationStatus.approved);
      expect(approvedReg.requiresAction, false);

      final rejectedReg =
          testRegistration.copyWith(status: RegistrationStatus.rejected);
      expect(rejectedReg.requiresAction, false);
    });

    test('should approve registration correctly', () {
      final approvedReg = testRegistration.approve(notes: 'Welcome aboard!');

      expect(approvedReg.status, RegistrationStatus.approved);
      expect(approvedReg.approvalNotes, 'Welcome aboard!');
      expect(approvedReg.statusUpdatedDate, isNotNull);
      expect(approvedReg.id, testRegistration.id); // unchanged
      expect(approvedReg.touristId, testRegistration.touristId); // unchanged
    });

    test('should reject registration correctly', () {
      final rejectedReg = testRegistration.reject(reason: 'Tour is full');

      expect(rejectedReg.status, RegistrationStatus.rejected);
      expect(rejectedReg.rejectionReason, 'Tour is full');
      expect(rejectedReg.statusUpdatedDate, isNotNull);
      expect(rejectedReg.id, testRegistration.id); // unchanged
    });

    test('should cancel registration correctly', () {
      final cancelledReg = testRegistration.cancel();

      expect(cancelledReg.status, RegistrationStatus.cancelled);
      expect(cancelledReg.statusUpdatedDate, isNotNull);
      expect(cancelledReg.id, testRegistration.id); // unchanged
    });

    test('should complete registration correctly', () {
      final completedReg = testRegistration.complete();

      expect(completedReg.status, RegistrationStatus.completed);
      expect(completedReg.statusUpdatedDate, isNotNull);
      expect(completedReg.id, testRegistration.id); // unchanged
    });

    test('should test all registration statuses', () {
      final statuses = [
        RegistrationStatus.pending,
        RegistrationStatus.approved,
        RegistrationStatus.rejected,
        RegistrationStatus.cancelled,
        RegistrationStatus.completed,
      ];

      for (final status in statuses) {
        final registration = testRegistration.copyWith(status: status);
        expect(registration.status, status);
      }
    });

    test('should create copy with updated fields', () {
      final updatedReg = testRegistration.copyWith(
        status: RegistrationStatus.approved,
        approvalNotes: 'Approved with conditions',
        specialRequirements: 'Updated requirements',
      );

      expect(updatedReg.status, RegistrationStatus.approved);
      expect(updatedReg.approvalNotes, 'Approved with conditions');
      expect(updatedReg.specialRequirements, 'Updated requirements');
      expect(updatedReg.id, 'reg123'); // unchanged
      expect(updatedReg.confirmationCode, 'CONF2024001'); // unchanged
    });

    test('should support equality comparison', () {
      final sameRegistration = Registration(
        id: "reg123",
        customTourId: "tour123", 
        touristId: "tourist123",
        status: RegistrationStatus.pending,
        confirmationCode: "CONF2024001",
        registrationDate: registrationDate,
      );

      expect(testRegistration, equals(sameRegistration));

      final differentReg = testRegistration.copyWith(id: 'reg456');
      expect(testRegistration, isNot(equals(differentReg)));
    });

    test('should handle optional fields', () {
      final minimalReg = Registration(
        id: "reg127",
        customTourId: "tour127", 
        touristId: "tourist127",
        status: RegistrationStatus.pending,
        confirmationCode: "CONF2024005",
        registrationDate: registrationDate,
      );

      expect(minimalReg.specialRequirements, null);
      expect(minimalReg.emergencyContactName, null);
      expect(minimalReg.emergencyContactPhone, null);
      expect(minimalReg.approvalNotes, null);
      expect(minimalReg.rejectionReason, null);
      expect(minimalReg.statusUpdatedDate, null);
      expect(minimalReg.isValid, true);
    });

    test('should validate phone numbers correctly', () {
      final validPhones = [
        '+1-555-123-4567',
        '+44 20 7946 0958',
        '(555) 123-4567',
        '555.123.4567',
        '+1234567890',
      ];

      for (final phone in validPhones) {
        final reg = testRegistration.copyWith(
          emergencyContactName: 'Test Contact',
          emergencyContactPhone: phone,
        );
        expect(reg.isValid, true, reason: 'Phone $phone should be valid');
      }

      final invalidPhones = [
        '123',
        'abc-def-ghij',
        '+1',
      ];

      for (final phone in invalidPhones) {
        final reg = testRegistration.copyWith(
          emergencyContactName: 'Test Contact',
          emergencyContactPhone: phone,
        );
        expect(reg.isValid, false, reason: 'Phone $phone should be invalid');
      }
    });
  });
}
