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
    check(parse({L"/settings"}).mode==Mode::Settings);
    check(parse({L"/SELECT"}).mode==Mode::Select);
    check(parse({L"/unregister"}).mode==Mode::Unregister);
    check(parse({L"/select",L"extra"}).mode==Mode::Invalid);
    check(parse({L"/timer",L"10",L"1"}).mode==Mode::Timer);
    check(parse({L"/timer",L"10",L"1"}).minutes==10);
    check(parse({L"/timer",L"60",L"0"}).secure==false);
    for (auto args : std::vector<std::vector<std::wstring>>{{L"/timer"},{L"/timer",L"10"},{L"/timer",L"0",L"1"},{L"/timer",L"999999",L"1"},{L"/timer",L"10",L"true"},{L"/timer",L"10",L"1",L"extra"},{L"/timer",L"-1",L"0"}}) check(parse(args).mode==Mode::Invalid);
    check(parse({L"/p",L"1234"}).mode==Mode::Preview);
    check(parse({L"/P:1234"}).parent==1234);
    check(parse({L"/p",L"00012"}).parent==12);
    for(auto args:std::vector<std::vector<std::wstring>>{{L"/p"},{L"/p:"},{L"/p",L"0"},{L"/p:-1"},{L"/p:+12"},{L"/p:0x12"},{L"/p:12x"},{L"/p:18446744073709551616"},{L"/s",L"extra"},{L"/p:123",L"extra"},{L"/preview"},{L"--saver-hosted"},{L"/p",L" 12"}})check(parse(args).mode==Mode::Invalid);
    check(!session_end_committed(false));check(session_end_committed(true));
    check(!display_change_settled(1349,1000));
    check(display_change_settled(1350,1000));
    check(!display_change_settled(999,1000));
    check(valid_monitor_bounds(0,0,3840,1080));
    check(valid_monitor_bounds(-3840,-200,0,1960));
    check(!valid_monitor_bounds(0,0,0,1080));
    check(!valid_monitor_bounds(0,0,1920,0));
    check(!valid_monitor_bounds(10,0,0,1080));
    check(!valid_monitor_bounds(0,10,1920,0));
    check(!valid_monitor_bounds(-2147483647L,0,2147483647L,1080));
    int monitor_width=0, monitor_height=0;
    check(monitor_dimensions(0,0,3840,1080,monitor_width,monitor_height) &&
          monitor_width==3840 && monitor_height==1080);
    check(monitor_dimensions(-3840,-200,0,1960,monitor_width,monitor_height) &&
          monitor_width==3840 && monitor_height==2160);
    check(!monitor_dimensions(0,0,0,1080,monitor_width,monitor_height) &&
          monitor_width==0 && monitor_height==0);
    check(!monitor_dimensions(0,0,1920,0,monitor_width,monitor_height) &&
          monitor_width==0 && monitor_height==0);
    check(!monitor_dimensions(10,0,0,1080,monitor_width,monitor_height));
    check(!monitor_dimensions(0,10,1920,0,monitor_width,monitor_height));
    check(!monitor_dimensions(std::numeric_limits<long>::min(),0,
                              std::numeric_limits<long>::max(),1080,monitor_width,monitor_height));
    check(!monitor_dimensions(0,std::numeric_limits<long>::min(),
                              1920,std::numeric_limits<long>::max(),monitor_width,monitor_height));
    const long max_int_extent_origin = -static_cast<long>(std::numeric_limits<int>::max());
    check(monitor_dimensions(max_int_extent_origin,0,0,1080,monitor_width,monitor_height) &&
          monitor_width==std::numeric_limits<int>::max() && monitor_height==1080);
    check(monitor_dimensions(0,max_int_extent_origin,1920,0,monitor_width,monitor_height) &&
          monitor_width==1920 && monitor_height==std::numeric_limits<int>::max());
    const long one_over_int_extent_origin = max_int_extent_origin - 1L;
    monitor_width=123; monitor_height=456;
    check(!monitor_dimensions(one_over_int_extent_origin,0,0,1080,monitor_width,monitor_height) &&
          monitor_width==0 && monitor_height==0);
    monitor_width=123; monitor_height=456;
    check(!monitor_dimensions(0,one_over_int_extent_origin,1920,0,monitor_width,monitor_height) &&
          monitor_width==0 && monitor_height==0);
    check(monitor_enumeration_complete(true,false,1));
    check(monitor_enumeration_complete(true,false,3));
    check(!monitor_enumeration_complete(true,false,0));
    check(!monitor_enumeration_complete(false,false,1)); // API failure after a partial monitor walk.
    check(!monitor_enumeration_complete(false,true,1)); // Callback stopped after invalid monitor bounds.
    check(!monitor_enumeration_complete(true,true,1));
    check(animate_monitor(0));check(animate_monitor(3));check(!animate_monitor(4));check(!animate_monitor(100));
    std::cout<<"Screensaver arguments: "<<checks<<" checks, 0 failures\n";
}
