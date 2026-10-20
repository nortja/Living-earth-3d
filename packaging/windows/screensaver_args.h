#pragma once
#include <string>
#include <vector>
#include <cwctype>
#include <cstdint>
#include <limits>
namespace earth_saver {
enum class Mode { Configure, Full, Preview, Invalid };
struct Options { Mode mode = Mode::Invalid; uintptr_t parent = 0; };
inline Options parse(const std::vector<std::wstring>& args) {
    if (args.empty()) return {Mode::Configure, 0};
    std::wstring flag = args[0];
    for (auto& c : flag) c = std::towlower(c);
    if (flag == L"/s" && args.size() == 1) return {Mode::Full, 0};
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
    std::vector<std::wstring> result = {L"--wid",std::to_wstring(parent),L"--resolution",std::to_wstring(width)+L"x"+std::to_wstring(height),L"--position",L"0,0",L"--audio-driver",L"Dummy",L"--max-fps",L"30",L"--",L"--saver-hosted"};
    if (preview) result.push_back(L"--saver-preview");
    return result;
}
inline bool animate_monitor(size_t index) { return index < 4; }
}
