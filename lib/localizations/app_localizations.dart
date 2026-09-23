import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quick;

  /// No description provided for @hub.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get hub;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @myanmar.
  ///
  /// In en, this message translates to:
  /// **'Myanmar'**
  String get myanmar;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYou;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @yourInterests.
  ///
  /// In en, this message translates to:
  /// **'Your Interests'**
  String get yourInterests;

  /// No description provided for @trendingNiches.
  ///
  /// In en, this message translates to:
  /// **'Trending Niches'**
  String get trendingNiches;

  /// No description provided for @suggestedForYou.
  ///
  /// In en, this message translates to:
  /// **'Suggested for You'**
  String get suggestedForYou;

  /// No description provided for @peopleYouMightKnow.
  ///
  /// In en, this message translates to:
  /// **'People you might know'**
  String get peopleYouMightKnow;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @repost.
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get repost;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @commentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments. Please try again.'**
  String get commentsLoadError;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @newReply.
  ///
  /// In en, this message translates to:
  /// **'New reply'**
  String get newReply;

  /// No description provided for @commentPostError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your comment. Please try again.'**
  String get commentPostError;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyComment.
  ///
  /// In en, this message translates to:
  /// **'Reply Comment'**
  String get replyComment;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @commentCopied.
  ///
  /// In en, this message translates to:
  /// **'Comment copied'**
  String get commentCopied;

  /// Shown in the comment input while replying to an account
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}'**
  String replyTo(String name);

  /// No description provided for @localGuide.
  ///
  /// In en, this message translates to:
  /// **'Local Guide'**
  String get localGuide;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @copyContentLink.
  ///
  /// In en, this message translates to:
  /// **'Copy content link'**
  String get copyContentLink;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @pinPost.
  ///
  /// In en, this message translates to:
  /// **'Pin Post'**
  String get pinPost;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deletePostConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post?'**
  String get deletePostConfirmTitle;

  /// No description provided for @deletePostConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This post will be permanently deleted. This action can\'t be undone.'**
  String get deletePostConfirmMessage;

  /// No description provided for @deletePostFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the post. Please try again.'**
  String get deletePostFailed;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get postDeleted;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @birthdays.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get birthdays;

  /// No description provided for @savedPosts.
  ///
  /// In en, this message translates to:
  /// **'Saved Posts'**
  String get savedPosts;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsAndPrivacy;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ...'**
  String get searchHint;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @suggestedCommunities.
  ///
  /// In en, this message translates to:
  /// **'Suggested Communities'**
  String get suggestedCommunities;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @answers.
  ///
  /// In en, this message translates to:
  /// **'answers'**
  String get answers;

  /// No description provided for @askCircle.
  ///
  /// In en, this message translates to:
  /// **'ASK CIRCLE'**
  String get askCircle;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @groupsYouMightLike.
  ///
  /// In en, this message translates to:
  /// **'Groups you might like'**
  String get groupsYouMightLike;

  /// No description provided for @popularInMandalay.
  ///
  /// In en, this message translates to:
  /// **'Popular in Mandalay'**
  String get popularInMandalay;

  /// No description provided for @hideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideReplies;

  /// No description provided for @viewReplies.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewReplies;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'replies'**
  String get replies;

  /// Number of replies to show/hide
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String viewRepliesCount(int count);

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @shareTo.
  ///
  /// In en, this message translates to:
  /// **'Share to...'**
  String get shareTo;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @followingCount.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingCount;

  /// No description provided for @createStory.
  ///
  /// In en, this message translates to:
  /// **'Create Story'**
  String get createStory;

  /// No description provided for @newStory.
  ///
  /// In en, this message translates to:
  /// **'New Story'**
  String get newStory;

  /// No description provided for @textTab.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textTab;

  /// No description provided for @photoTab.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoTab;

  /// No description provided for @videoTab.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoTab;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @postStory.
  ///
  /// In en, this message translates to:
  /// **'Post Story'**
  String get postStory;

  /// No description provided for @writeSomething.
  ///
  /// In en, this message translates to:
  /// **'Write something'**
  String get writeSomething;

  /// No description provided for @twentyFourHour.
  ///
  /// In en, this message translates to:
  /// **'24 hr'**
  String get twentyFourHour;

  /// No description provided for @inter.
  ///
  /// In en, this message translates to:
  /// **'Inter'**
  String get inter;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to take photos and record videos.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable on this device.'**
  String get cameraUnavailable;

  /// No description provided for @cameraOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening camera...'**
  String get cameraOpening;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @photoTabHint.
  ///
  /// In en, this message translates to:
  /// **'Select a photo from your gallery'**
  String get photoTabHint;

  /// No description provided for @videoTabHint.
  ///
  /// In en, this message translates to:
  /// **'Record a video from your camera'**
  String get videoTabHint;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @recordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record Video'**
  String get recordVideo;

  /// No description provided for @whoCanSeeYourStory.
  ///
  /// In en, this message translates to:
  /// **'Who can see your story?'**
  String get whoCanSeeYourStory;

  /// No description provided for @whoCanSeeYourPost.
  ///
  /// In en, this message translates to:
  /// **'Who can see your post?'**
  String get whoCanSeeYourPost;

  /// No description provided for @storyVisible24Hours.
  ///
  /// In en, this message translates to:
  /// **'Your story will be visible for 24 hours.'**
  String get storyVisible24Hours;

  /// No description provided for @publicAudience.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicAudience;

  /// No description provided for @publicAudienceDesc.
  ///
  /// In en, this message translates to:
  /// **'Anyone on OLLIO'**
  String get publicAudienceDesc;

  /// No description provided for @friendsAudience.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsAudience;

  /// No description provided for @friendsAudienceDesc.
  ///
  /// In en, this message translates to:
  /// **'Only your connections'**
  String get friendsAudienceDesc;

  /// No description provided for @closeFriendsAudience.
  ///
  /// In en, this message translates to:
  /// **'Close Friends'**
  String get closeFriendsAudience;

  /// No description provided for @closeFriendsAudienceDesc.
  ///
  /// In en, this message translates to:
  /// **'A selected list of people'**
  String get closeFriendsAudienceDesc;

  /// No description provided for @editCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'Edit Close Friends'**
  String get editCloseFriends;

  /// No description provided for @searchFriends.
  ///
  /// In en, this message translates to:
  /// **'Search friends...'**
  String get searchFriends;

  /// No description provided for @noFriendsFound.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get noFriendsFound;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveToPhone.
  ///
  /// In en, this message translates to:
  /// **'Save to Phone'**
  String get saveToPhone;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a account'**
  String get createAccount;

  /// No description provided for @createPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createPostTitle;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @createPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, moments, or start a\ndiscussion.'**
  String get createPostSubtitle;

  /// No description provided for @createPostOption.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPostOption;

  /// No description provided for @createPostOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Share photos, text, and updates with your\nnetwork.'**
  String get createPostOptionDesc;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @postTextareaHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening in Neighbourhood?'**
  String get postTextareaHint;

  /// No description provided for @createPostImageLimit.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to 5 images.'**
  String get createPostImageLimit;

  /// No description provided for @createPostAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get createPostAddMore;

  /// No description provided for @createPostUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload your post. Please try again.'**
  String get createPostUploadFailed;

  /// No description provided for @createPostUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post uploaded successfully.'**
  String get createPostUploadSuccess;

  /// No description provided for @uploadingYourPost.
  ///
  /// In en, this message translates to:
  /// **'Uploading your post...'**
  String get uploadingYourPost;

  /// No description provided for @shareQuick.
  ///
  /// In en, this message translates to:
  /// **'Share Quick'**
  String get shareQuick;

  /// No description provided for @shareQuickDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload or record a short-form video.'**
  String get shareQuickDesc;

  /// No description provided for @addStory.
  ///
  /// In en, this message translates to:
  /// **'Add Story'**
  String get addStory;

  /// No description provided for @addStoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Show your feeling to share with your friends.'**
  String get addStoryDesc;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a Question'**
  String get askQuestion;

  /// No description provided for @askQuestionDesc.
  ///
  /// In en, this message translates to:
  /// **'Start a circle poll or Q&A session.'**
  String get askQuestionDesc;

  /// No description provided for @connectWithRareSoul.
  ///
  /// In en, this message translates to:
  /// **'Connect with your rare soul!'**
  String get connectWithRareSoul;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in!'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join to reconnect with your rare soul.'**
  String get signInSubtitle;

  /// No description provided for @emailOrPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get emailOrPhoneNumber;

  /// No description provided for @emailOrPhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone number'**
  String get emailOrPhoneNumberHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account!'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create new an account to get started and enjoy seamless access to our features.'**
  String get signUpSubtitle;

  /// No description provided for @byContinuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get byContinuing;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andWord;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @agreementEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get agreementEnd;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerFailed;

  /// No description provided for @registerValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields and accept the terms.'**
  String get registerValidationError;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive OTP code to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email or phone number.'**
  String get forgotEmailError;

  /// No description provided for @otpSendFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the OTP. Please try again.'**
  String get otpSendFailedError;

  /// No description provided for @otpVerifyFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify the OTP. Please try again.'**
  String get otpVerifyFailedError;

  /// No description provided for @passwordResetFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset the password. Please try again.'**
  String get passwordResetFailedError;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email Address'**
  String get verifyEmailTitle;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone'**
  String get verifyPhoneTitle;

  /// No description provided for @verifyPhoneNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone Number'**
  String get verifyPhoneNumberTitle;

  /// No description provided for @otpSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your OTP will be sent to '**
  String get otpSentPrefix;

  /// No description provided for @otpSentSuffix.
  ///
  /// In en, this message translates to:
  /// **'.\nPlease check and enter the OTP below to verify your account.'**
  String get otpSentSuffix;

  /// No description provided for @otpExpiredPrefix.
  ///
  /// In en, this message translates to:
  /// **'OTP Expired '**
  String get otpExpiredPrefix;

  /// Remaining OTP expiry seconds shown next to the countdown label
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String otpSeconds(int seconds);

  /// No description provided for @otpInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP code.'**
  String get otpInvalidError;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @dontReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t receive OTP?'**
  String get dontReceiveOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @createNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPasswordTitle;

  /// No description provided for @createNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password you always may remember. Your password must have 8 characters at least.'**
  String get createNewPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @changePasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordAction;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Your password must have at least 8 characters.'**
  String get passwordTooShortError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatchError;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @noNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noNetworkTitle;

  /// No description provided for @noNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Please turn on your mobile data or WiFi and try again.'**
  String get noNetworkMessage;

  /// No description provided for @loginValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email or phone number and password.'**
  String get loginValidationError;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @signUpWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Facebook'**
  String get signUpWithFacebook;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get signInWithFacebook;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @birthdayQuestion.
  ///
  /// In en, this message translates to:
  /// **'When\'s Your Birthdays'**
  String get birthdayQuestion;

  /// No description provided for @birthdayHint.
  ///
  /// In en, this message translates to:
  /// **'You can choose who can see this form your profile.'**
  String get birthdayHint;

  /// No description provided for @birthOfDate.
  ///
  /// In en, this message translates to:
  /// **'Birth of Date'**
  String get birthOfDate;

  /// No description provided for @birthDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get birthDatePlaceholder;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @genderQuestion.
  ///
  /// In en, this message translates to:
  /// **'What gender are you?'**
  String get genderQuestion;

  /// No description provided for @genderHint.
  ///
  /// In en, this message translates to:
  /// **'You can change who sees your gender on your profile later.'**
  String get genderHint;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Select other to choose another gender or if you\'d rather not say.'**
  String get genderOtherHint;

  /// No description provided for @chooseYourInterests.
  ///
  /// In en, this message translates to:
  /// **'Choose your Interests'**
  String get chooseYourInterests;

  /// No description provided for @chooseYourInterestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get better circles recommendations'**
  String get chooseYourInterestsSubtitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @profilePictureTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePictureTitle;

  /// No description provided for @profilePictureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add profile picture to get better circles connections'**
  String get profilePictureSubtitle;

  /// No description provided for @importFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Import From Gallery'**
  String get importFromGallery;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @cropPhoto.
  ///
  /// In en, this message translates to:
  /// **'Crop Photo'**
  String get cropPhoto;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your photo. Please try again.'**
  String get profilePhotoUpdateFailed;

  /// No description provided for @bioUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your bio. Please try again.'**
  String get bioUpdateFailed;

  /// No description provided for @interestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load interests. Please try again.'**
  String get interestsLoadError;

  /// No description provided for @chooseBirthday.
  ///
  /// In en, this message translates to:
  /// **'Choose your birthday'**
  String get chooseBirthday;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @introduceYourBio.
  ///
  /// In en, this message translates to:
  /// **'Introduce your bio'**
  String get introduceYourBio;

  /// No description provided for @editBio.
  ///
  /// In en, this message translates to:
  /// **'Edit Bio'**
  String get editBio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your bio'**
  String get bioHint;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @pinnedCommunities.
  ///
  /// In en, this message translates to:
  /// **'Pinned Communities'**
  String get pinnedCommunities;

  /// No description provided for @pinnedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Pinned'**
  String pinnedCount(int count);

  /// No description provided for @yourCommunities.
  ///
  /// In en, this message translates to:
  /// **'Your Communities'**
  String get yourCommunities;

  /// No description provided for @recentlyActive.
  ///
  /// In en, this message translates to:
  /// **'Recently Active • Yangon Time'**
  String get recentlyActive;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @moderator.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get moderator;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @publicLabel.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicLabel;

  /// No description provided for @privateLabel.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLabel;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'3 pending member\napprovals'**
  String get pendingApprovals;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @discovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get discovery;

  /// No description provided for @lookingForNewTribes.
  ///
  /// In en, this message translates to:
  /// **'Looking for new tribes?'**
  String get lookingForNewTribes;

  /// No description provided for @discoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore 50+ vibrant local communities in\nKamayut, Bahan & Downtown Yangon.'**
  String get discoverySubtitle;

  /// No description provided for @exploreCommunities.
  ///
  /// In en, this message translates to:
  /// **'Explore Communities'**
  String get exploreCommunities;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @noPostsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you share a post, it will appear here.'**
  String get noPostsYetSubtitle;

  /// No description provided for @postsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load posts. Please try again.'**
  String get postsLoadError;

  /// No description provided for @reactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your reaction. Please try again.'**
  String get reactionFailed;

  /// No description provided for @reactions.
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get reactions;

  /// No description provided for @noReactions.
  ///
  /// In en, this message translates to:
  /// **'No reactions yet'**
  String get noReactions;

  /// No description provided for @reactionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load reactions. Please try again.'**
  String get reactionsLoadError;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String weeksAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
