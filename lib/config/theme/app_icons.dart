import 'package:flutter/widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Semantic icon map for the app.
///
/// Outline = idle / list / secondary. Bold (`*_copy`) = selected / emphasis.
abstract final class AppIcons {
  // ——— Navigation (citizen) ———
  static const IconData navHome = Iconsax.home_2;
  static const IconData navHomeActive = Iconsax.home_2_copy;
  static const IconData navProfile = Iconsax.profile_circle;
  static const IconData navProfileActive = Iconsax.profile_circle_copy;
  static const IconData navDonations = Iconsax.heart;
  static const IconData navDonationsActive = Iconsax.heart_copy;
  static const IconData navComplaints = Iconsax.message_question;
  static const IconData navComplaintsActive = Iconsax.message_question_copy;
  static const IconData navTransactions = Iconsax.clipboard_text;
  static const IconData navTransactionsActive = Iconsax.clipboard_text_copy;

  // ——— Navigation (delegate) ———
  static const IconData navMap = Iconsax.map_1;
  static const IconData navMapActive = Iconsax.map_1_copy;
  static const IconData navTasks = Iconsax.task_square;
  static const IconData navTasksActive = Iconsax.task_square_copy;
  static const IconData navBuildings = Iconsax.buildings;
  static const IconData navBuildingsActive = Iconsax.buildings_copy;

  // ——— App bar ———
  static const IconData settings = Iconsax.setting_2;
  static const IconData notification = Iconsax.notification;
  static const IconData notificationActive = Iconsax.notification_bing;
  static const IconData back = Iconsax.arrow_right_3;

  // ——— Home / services ———
  static const IconData transactions = Iconsax.clipboard_tick;
  static const IconData digitalDocs = Iconsax.scan_barcode;
  static const IconData wallet = Iconsax.empty_wallet;
  static const IconData complaint = Iconsax.message_question;
  static const IconData announcements = Iconsax.volume_high;
  static const IconData statsTotal = Iconsax.clipboard_text;
  static const IconData statsPending = Iconsax.timer;
  static const IconData statsDone = Iconsax.tick_circle;

  // ——— Delegate home ———
  static const IconData map = Iconsax.map_1;
  static const IconData tasks = Iconsax.task_square;
  static const IconData scanDocument = Iconsax.scanner;
  static const IconData cemetery = Iconsax.candle;
  static const IconData building = Iconsax.building_4;
  static const IconData buildings = Iconsax.buildings;

  // ——— Map controls ———
  static const IconData myLocation = Iconsax.gps;
  static const IconData layers = Iconsax.layer;
  static const IconData addLocation = Iconsax.location_add;
  static const IconData location = Iconsax.location;
  static const IconData locationOff = Iconsax.location_slash;

  // ——— Notifications by type ———
  static const IconData notifComplaint = Iconsax.receipt;
  static const IconData notifTask = Iconsax.task_square;
  static const IconData notifGeneral = Iconsax.notification;
  static const IconData notifIdentity = Iconsax.shield_tick;
  static const IconData notifTransaction = Iconsax.document_text;
  static const IconData notifBulk = Iconsax.volume_high;
  static const IconData notifInfo = Iconsax.info_circle;
  static const IconData markAllRead = Iconsax.tick_circle;
  static const IconData emptyNotifications = Iconsax.notification_bing;

  // ——— Profile / settings ———
  static const IconData language = Iconsax.global;
  static const IconData lock = Iconsax.lock;
  static const IconData privacy = Iconsax.shield_tick;
  static const IconData terms = Iconsax.document_text;
  static const IconData logout = Iconsax.logout;
  static const IconData phone = Iconsax.call;
  static const IconData verified = Iconsax.verify;
  static const IconData personalCard = Iconsax.personalcard;
  static const IconData email = Iconsax.sms;
  static const IconData user = Iconsax.user;

  // ——— Donations ———
  static const IconData donate = Iconsax.heart;
  static const IconData donateActive = Iconsax.heart_tick;
  static const IconData people = Iconsax.people;
  static const IconData support = Iconsax.headphone;
  static const IconData city = Iconsax.buildings;
  static const IconData health = Iconsax.hospital;
  static const IconData food = Iconsax.reserve;
  static const IconData education = Iconsax.teacher;
  static const IconData housing = Iconsax.house;
  static const IconData water = Iconsax.drop;

  // ——— Cemetery plot status ———
  static const IconData plotAvailable = Iconsax.tick_circle;
  static const IconData plotOccupied = Iconsax.user;
  static const IconData plotBooked = Iconsax.bookmark;
  static const IconData plotInfo = Iconsax.info_circle;

  // ——— Common actions ———
  static const IconData search = Iconsax.search_normal;
  static const IconData close = Iconsax.close_circle;
  static const IconData refresh = Iconsax.refresh;
  static const IconData delete = Iconsax.trash;
  static const IconData edit = Iconsax.edit_2;
  static const IconData add = Iconsax.add;
  static const IconData addCircle = Iconsax.add_circle;
  static const IconData wifiOff = Iconsax.cloud_cross;
  static const IconData error = Iconsax.danger;
  static const IconData warning = Iconsax.warning_2;
  static const IconData empty = Iconsax.box_1;
  static const IconData calendar = Iconsax.calendar;
  static const IconData camera = Iconsax.camera;
  static const IconData gallery = Iconsax.gallery;
  static const IconData send = Iconsax.send_2;
  static const IconData filter = Iconsax.filter;
  static const IconData chevron = Iconsax.arrow_left_2;
  static const IconData flag = Iconsax.flag;
}
