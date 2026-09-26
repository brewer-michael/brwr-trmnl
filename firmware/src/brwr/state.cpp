#ifdef BOARD_BRWR_TRMNL

#include <brwr/state.h>
#include <sys/time.h>
#include <time.h>

namespace brwr {

  static constexpr uint32_t RTC_MAGIC = 0xB5A7'0001;

  RTC_DATA_ATTR RtcState rtc;
  static WakeState s_wake;

  WakeState &wake() { return s_wake; }

  void rtc_init() {
    if (rtc.magic != RTC_MAGIC) {
      // Power-on or reset: RTC memory holds garbage.
      memset(&rtc, 0, sizeof(rtc));
      rtc.magic = RTC_MAGIC;
      strlcpy(rtc.shownName, "Playlist", sizeof(rtc.shownName));
    }
    rtc.wakeCount++;
    // Consume the idle loop's hand-off exactly once.
    s_wake.resumed = rtc.pending;
    rtc.pending = Pending::None;
  }

  uint32_t now_epoch() {
    struct timeval tv;
    gettimeofday(&tv, nullptr);
    // Before NTP the RTC counts from 1970; treat anything before 2024 as unknown.
    return tv.tv_sec > 1704067200 ? (uint32_t)tv.tv_sec : 0;
  }

  bool hold_active() {
    uint32_t now = now_epoch();
    return rtc.holdUntil != 0 && now != 0 && now < rtc.holdUntil;
  }

  void set_shown(const String &name, const String &url) {
    strlcpy(rtc.shownName, name.c_str(), sizeof(rtc.shownName));
    strlcpy(rtc.shownUrl, url.c_str(), sizeof(rtc.shownUrl));
  }

  const char *button_name(Button button) {
    switch (button) {
    case BUTTON_BACK:
      return "back";
    case BUTTON_REFRESH:
      return "refresh";
    case BUTTON_NEXT:
      return "next";
    default:
      return "none";
    }
  }

  const char *press_name(Press press) {
    switch (press) {
    case PRESS_SHORT:
      return "short";
    case PRESS_DOUBLE:
      return "double";
    case PRESS_LONG:
      return "long";
    case PRESS_VERY_LONG:
      return "very_long";
    case PRESS_RESET:
      return "reset";
    default:
      return "none";
    }
  }

} // namespace brwr

#endif // BOARD_BRWR_TRMNL
