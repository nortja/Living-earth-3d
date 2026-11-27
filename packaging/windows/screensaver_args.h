#pragma once
#include <string>
#include <vector>
#include <cwctype>
#include <cstdint>
#include <limits>
namespace earth_saver {
enum class Mode { Configure, Full, Preview, Settings, Select, Timer, Unregister, Invalid };
struct Options { Mode mode = Mode::Invalid; uintptr_t parent = 0; unsigned minutes = 10; bool secure = true; };
inline Options parse(const std::vector<std::wstring>& args) {
    if (args.empty()) return {Mode::Configure, 0};
    std::wstring flag = args[0];
    for (auto& c : flag) c = std::towlower(c);
    if (flag == L"/s" && args.size() == 1) return {Mode::Full, 0};
    if (flag == L"/settings" && args.size() == 1) return {Mode::Settings, 0};
    if (flag == L"/select" && args.size() == 1) return {Mode::Select, 0};
    if (flag == L"/timer" && args.size() == 3) {
        unsigned minutes=0;
        for (const auto& item : std::vector<std::pair<std::wstring,unsigned>>{{L"1",1},{L"5",5},{L"10",10},{L"15",15},{L"30",30},{L"60",60}})
            if (args[1]==item.first) minutes=item.second;
        if (!minutes || (args[2]!=L"0" && args[2]!=L"1")) return {};
        return {Mode::Timer,0,minutes,args[2]==L"1"};
    }
    if (flag == L"/unregister" && args.size() == 1) return {Mode::Unregister, 0};
    if ((flag == L"/c" && args.size() == 1) || (flag.rfind(L"/c:",0) == 0 && args.size() == 1)) return {Mode::Configure, 0};
    std::wstring handle;
    if (flag == L"/p" && args.size() == 2) handle = args[1];
    else if (flag.rfind(L"/p:",0) == 0 && args.size() == 1) handle = flag.substr(3);
    else return {};
    if (handle.empty()) return {};
    uintptr_t value = 0;
    for (auto c : handle) {
        if (c < L'0' || c > L'9') return {};
        unsigned digit = c-L'0';
        if (value > (std::numeric_limits<uintptr_t>::max()-digit)/10) return {};
        value = value*10+digit;
    }
    return value ? Options{Mode::Preview,value} : Options{};
}
inline std::vector<std::wstring> renderer_arguments(uintptr_t parent, int width, int height, bool preview) {
    std::vector<std::wstring> result = {L"--wid",std::to_wstring(parent),L"--resolution",std::to_wstring(width)+L"x"+std::to_wstring(height),L"--position",L"-32000,-32000",L"--audio-driver",L"Dummy",L"--max-fps",L"30",L"--",L"--saver-hosted"};
    if (preview) result.push_back(L"--saver-preview");
    return result;
}
inline constexpr bool session_end_committed(bool ending) noexcept { return ending; }
inline constexpr uint64_t display_change_quiet_ms = 350;
inline constexpr bool display_change_settled(uint64_t now, uint64_t changed_at) noexcept {
    return now >= changed_at && now - changed_at >= display_change_quiet_ms;
}
inline bool monitor_dimensions(long left, long top, long right, long bottom,
                               int& width, int& height) noexcept {
    // Failure is atomic: callers never observe one partially converted extent.
    width = 0;
    height = 0;
    if (right <= left || bottom <= top) return false;

    // Unsigned subtraction preserves the mathematical extent across negative
    // desktop origins without overflowing signed long on either LLP64 or LP64.
    const uint64_t width64 = static_cast<uint64_t>(right) - static_cast<uint64_t>(left);
    const uint64_t height64 = static_cast<uint64_t>(bottom) - static_cast<uint64_t>(top);
    const uint64_t max_extent = static_cast<uint64_t>(std::numeric_limits<int>::max());
    if (width64 == 0 || height64 == 0 || width64 > max_extent || height64 > max_extent)
        return false;

    width = static_cast<int>(width64);
    height = static_cast<int>(height64);
    return true;
}
inline bool valid_monitor_bounds(long left, long top, long right, long bottom) noexcept {
    int width = 0, height = 0;
    return monitor_dimensions(left, top, right, bottom, width, height);
}
enum class MonitorEnumerationDecision { Complete, Retry, Abort };
inline constexpr unsigned monitor_enumeration_max_attempts = 3;
inline constexpr unsigned monitor_enumeration_retry_delay_ms(unsigned completed_attempt) noexcept {
    return completed_attempt * 50u;
}
inline constexpr MonitorEnumerationDecision monitor_enumeration_decision(
        bool api_succeeded, bool callback_failed, size_t monitor_count, unsigned attempt) noexcept {
    // Callback failures indicate invalid geometry or a host-creation failure and
    // must not be retried. API failures and empty inventories may be transient.
    if (callback_failed) return MonitorEnumerationDecision::Abort;
    if (api_succeeded && monitor_count > 0) return MonitorEnumerationDecision::Complete;
    return attempt < monitor_enumeration_max_attempts
        ? MonitorEnumerationDecision::Retry
        : MonitorEnumerationDecision::Abort;
}
inline constexpr bool dpi_update_requires_topology_rebuild(bool monitor_found,
                                                             bool monitor_info_read,
                                                             bool bounds_valid,
                                                             bool host_position_updated) noexcept {
    // A DPI-only host update is complete only when every Win32 lookup and the
    // physical-pixel reposition succeeds. Callers may then retry through the
    // existing debounced, complete-enumeration topology rebuild.
    return !(monitor_found && monitor_info_read && bounds_valid && host_position_updated);
}
inline bool animate_monitor(size_t index) { return index < 4; }
}
