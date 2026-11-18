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
    const long long candidate_width = static_cast<long long>(right) - static_cast<long long>(left);
    const long long candidate_height = static_cast<long long>(bottom) - static_cast<long long>(top);
    if (candidate_width <= 0 || candidate_height <= 0 ||
        candidate_width > std::numeric_limits<int>::max() ||
        candidate_height > std::numeric_limits<int>::max()) return false;
    width = static_cast<int>(candidate_width);
    height = static_cast<int>(candidate_height);
    return true;
}
inline bool valid_monitor_bounds(long left, long top, long right, long bottom) noexcept {
    int width = 0, height = 0;
    return monitor_dimensions(left, top, right, bottom, width, height);
}
inline bool animate_monitor(size_t index) { return index < 4; }
}
