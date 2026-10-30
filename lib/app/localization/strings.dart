import 'package:flutter/material.dart';

String tr(BuildContext context, String text) {
  if (Localizations.localeOf(context).languageCode != 'km') return text;
  return const {
        'Khmer Bank': 'ធនាគារខ្មែរ',
        'Rooted in Cambodia. Made for you.': 'សម្រាប់អ្នក និងអនាគតកម្ពុជា',
        'Sign in to Khmer Bank': 'ចូលទៅកាន់ធនាគារខ្មែរ',
        'Username or phone number': 'ឈ្មោះអ្នកប្រើ ឬលេខទូរស័ព្ទ',
        'Password': 'ពាក្យសម្ងាត់',
        'Remember me': 'ចងចាំខ្ញុំ',
        'Forgot password?': 'ភ្លេចពាក្យសម្ងាត់?',
        'Biometric login': 'ចូលដោយជីវមាត្រ',
        'Create account': 'បង្កើតគណនី',
        'Signing in…': 'កំពុងចូល…',
        'Skip': 'រំលង',
        'Next': 'បន្ទាប់',
        'Get started': 'ចាប់ផ្ដើម',
        'Page': 'ទំព័រ',
        'A fresh perspective on your money.':
            'ទស្សនៈថ្មីចំពោះហិរញ្ញវត្ថុរបស់អ្នក',
        'All your accounts. One beautifully simple place.':
            'គណនីទាំងអស់របស់អ្នកនៅកន្លែងតែមួយ',
        'Life moves fast. So can your money.':
            'ផ្ទេរប្រាក់បានរហ័សតាមតម្រូវការរបស់អ្នក',
        'Transfers and QR payments, without the friction.':
            'ផ្ទេរប្រាក់ និងទូទាត់តាម QR យ៉ាងងាយស្រួល',
        'Your peace of mind, built right in.': 'ភាពស្ងប់ចិត្តរបស់អ្នកជាអាទិភាព',
        'Explore banking safely with fictional demo data.':
            'សាកល្បងសេវាធនាគារដោយសុវត្ថិភាពជាមួយទិន្នន័យសាកល្បង',
        'Home': 'ទំព័រដើម',
        'Accounts': 'គណនី',
        'Scan QR': 'ស្កេន QR',
        'Cards': 'កាត',
        'Profile': 'ប្រវត្តិរូប',
        'Settings': 'ការកំណត់',
        'Transfer': 'ផ្ទេរប្រាក់',
        'Recent activity': 'ប្រតិបត្តិការថ្មីៗ',
        'See all': 'មើលទាំងអស់',
        'Available balance': 'សមតុល្យដែលអាចប្រើបាន',
        'Good afternoon,': 'សួស្តី,',
        'My accounts': 'គណនីរបស់ខ្ញុំ',
        'Language': 'ភាសា',
        'Notifications': 'ការជូនដំណឹង',
        'Spending insights': 'ការវិភាគចំណាយ',
        'Receive': 'ទទួលប្រាក់',
        'Top up': 'បញ្ចូលប្រាក់',
        'Bills': 'វិក្កយបត្រ',
        'More': 'ផ្សេងទៀត',
        'Continue': 'បន្ត',
        'Login': 'ចូលគណនី',
        'Welcome back': 'សូមស្វាគមន៍មកវិញ',
        'Transactions': 'ប្រតិបត្តិការ',
        'Security': 'សុវត្ថិភាព',
        'Logout': 'ចាកចេញ',
      }[text] ??
      text;
}
