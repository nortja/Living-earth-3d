#include "../packaging/windows/screensaver_args.h"
#include <iostream>
#include <stdexcept>
using namespace earth_saver;
int main(int argc, char** argv) {
    if (argc == 5 && std::string(argv[1]) == "--engine-args") {
        for (const auto& arg : renderer_arguments(1,std::stoi(argv[2]),std::stoi(argv[3]),std::string(argv[4])=="preview")) std::wcout<<arg<<L"\n";
        return 0;
    }
    int checks=0;
    auto check=[&](bool valid){++checks;if(!valid)throw std::runtime_error("Screensaver argument contract failed");};
    check(parse({}).mode==Mode::Configure);
    check(parse({L"/c"}).mode==Mode::Configure);
    check(parse({L"/C:123"}).mode==Mode::Configure);
    check(parse({L"/s"}).mode==Mode::Full);
    check(parse({L"/S"}).mode==Mode::Full);
    check(parse({L"/p",L"1234"}).mode==Mode::Preview);
    check(parse({L"/P:1234"}).parent==1234);
    check(parse({L"/p",L"00012"}).parent==12);
    for(auto args:std::vector<std::vector<std::wstring>>{{L"/p"},{L"/p:"},{L"/p",L"0"},{L"/p:-1"},{L"/p:+12"},{L"/p:0x12"},{L"/p:12x"},{L"/p:18446744073709551616"},{L"/s",L"extra"},{L"/p:123",L"extra"},{L"/preview"},{L"--saver-hosted"},{L"/p",L" 12"}})check(parse(args).mode==Mode::Invalid);
    check(animate_monitor(0));check(animate_monitor(3));check(!animate_monitor(4));check(!animate_monitor(100));
    std::cout<<"Screensaver arguments: "<<checks<<" checks, 0 failures\n";
}
