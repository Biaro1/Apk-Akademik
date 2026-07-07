import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/akademik_model.dart';
import 'package:flutter_app/pages/dashboard_page.dart';

void main() {
  testWidgets('tapping the profile avatar opens profile actions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(760, 40));
    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Ubah Foto Profil'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Lihat Detail Profil'), findsOneWidget);
    expect(find.text('Hapus Foto Profil'), findsOneWidget);
  });

  testWidgets('edit profile opens form and saves new values', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(760, 40));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profil'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi Santoso');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Program Studi'),
      'Sistem Informasi',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Semester'), '6');
    await tester.enterText(find.widgetWithText(TextFormField, 'NIM'), '202410205');

    await tester.tap(find.text('Simpan Profil'));
    await tester.pumpAndSettle();

    expect(AkademikData.profileName, 'Budi Santoso');
    expect(AkademikData.profileProgramStudi, 'Sistem Informasi');
    expect(AkademikData.profileSemester, '6');
    expect(AkademikData.profileNim, '202410205');
  });
}
