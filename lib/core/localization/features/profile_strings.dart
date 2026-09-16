class ProfileStrings {
  static const String profileTitle = 'profile_title';
  static const String emailAddress = 'profile_email';
  static const String mobileNumber = 'profile_phone';
  static const String shopName = 'profile_shop_name';
  static const String dangerZone = 'profile_danger_zone';
  static const String dangerZoneWarning = 'profile_danger_warning';
  static const String deleteAccount = 'profile_delete_account';
  static const String deleteAccountConfirm = 'profile_delete_confirm';
  static const String deleteAccountPrompt = 'profile_delete_prompt';
  static const String loadFailed = 'profile_load_failed';

  static const Map<String, String> bn = {
    profileTitle: 'ইউজার প্রোফাইল',
    emailAddress: 'ইমেইল এড্রেস',
    mobileNumber: 'মোবাইল নম্বর',
    shopName: 'দোকান বা ব্যবসায়ের নাম',
    dangerZone: 'অ্যাকাউন্ট স্থায়ীভাবে মোছা',
    dangerZoneWarning: 'অ্যাকাউন্ট মুছে ফেললে আপনার সকল তথ্য স্থায়ীভাবে মুছে যাবে এবং আর কখনো ফেরত পাওয়া যাবে না।',
    deleteAccount: 'অ্যাকাউন্ট মুছে ফেলুন',
    deleteAccountConfirm: 'অ্যাকাউন্ট ডিলিট নিশ্চিতকরণ',
    deleteAccountPrompt: 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্টটি স্থায়ীভাবে মুছে ফেলতে চান? আপনার সকল ডাটা মুছে যাবে এবং আপনি লগআউট হয়ে যাবেন।',
    loadFailed: 'প্রোফাইলের তথ্য লোড করা সম্ভব হয়নি।',
  };

  static const Map<String, String> en = {
    profileTitle: 'My Profile',
    emailAddress: 'Email Address',
    mobileNumber: 'Mobile Number',
    shopName: 'Shop / Business Name',
    dangerZone: 'Danger Zone / Account Delete',
    dangerZoneWarning: 'If you delete your account, it will be deleted permanently along with all its data.',
    deleteAccount: 'Delete Your Account',
    deleteAccountConfirm: 'Delete Account Confirmation',
    deleteAccountPrompt: 'Are you sure you want to permanently delete your account? All your data will be removed and you will be logged out.',
    loadFailed: 'Failed to load profile details.',
  };
}
