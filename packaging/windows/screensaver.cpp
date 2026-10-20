// Native Windows screensaver host. No network, shell commands, elevation or installer changes.
#ifndef UNICODE
#define UNICODE
#endif
#define _UNICODE
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shellapi.h>
#include <wtsapi32.h>
#include <vector>
#include <string>
#include <algorithm>
#include <cstring>
#include "screensaver_args.h"

struct View { HWND host = nullptr; HANDLE process = nullptr; DWORD pid = 0; HWND child = nullptr; RECT bounds{}; };
static std::vector<View> views;
static bool stopping = false;
static bool preview = false;
static HWND preview_parent = nullptr;
static HANDLE job = nullptr;
static ULONGLONG started = 0;
static POINT initial_mouse{};
static const wchar_t* host_class = L"LivingEarth3D.SaverHost";

static void stop() { stopping = true; PostQuitMessage(0); }
static LRESULT CALLBACK host_proc(HWND window, UINT message, WPARAM w, LPARAM l) {
    switch (message) {
        case WM_CLOSE: stop(); return 0;
        case WM_DISPLAYCHANGE: stop(); return 0;
        case WM_POWERBROADCAST:
            if (w == PBT_APMSUSPEND) stop();
            return TRUE;
        case WM_WTSSESSION_CHANGE:
            if (w == WTS_SESSION_LOCK || w == WTS_SESSION_LOGOFF || w == WTS_CONSOLE_DISCONNECT || w == WTS_REMOTE_DISCONNECT) stop();
            return 0;
        case WM_SETCURSOR: if (!preview) { SetCursor(nullptr); return TRUE; } break;
        case WM_ERASEBKGND: return 1;
        case WM_PAINT: {
            PAINTSTRUCT paint; HDC dc = BeginPaint(window,&paint);
            FillRect(dc,&paint.rcPaint,(HBRUSH)GetStockObject(BLACK_BRUSH));
            EndPaint(window,&paint); return 0;
        }
    }
    return DefWindowProcW(window,message,w,l);
}
static std::wstring app_path() {
    wchar_t path[32768]; DWORD n = GetModuleFileNameW(nullptr,path,32768);
    if (!n || n >= 32768) return L"";
    std::wstring root(path,n);
    return root.substr(0,root.find_last_of(L"\\/"))+L"\\LivingEarth3D.exe";
}
static bool start_view(View& view, const std::wstring& app) {
    RECT client{};
    if (!GetClientRect(view.host,&client)) return false;
    int width = std::max(1L,client.right), height = std::max(1L,client.bottom);
    std::wstring command = L"\""+app+L"\"";
    for (const auto& argument : earth_saver::renderer_arguments((uintptr_t)view.host,width,height,preview)) command += L" "+argument;
    STARTUPINFOW si{}; si.cb=sizeof(si);
    PROCESS_INFORMATION pi{};
    if (!CreateProcessW(app.c_str(),&command[0],nullptr,nullptr,FALSE,CREATE_SUSPENDED,nullptr,nullptr,&si,&pi)) return false;
    bool assigned = AssignProcessToJobObject(job,pi.hProcess) != FALSE;
    if (assigned) { view.process=pi.hProcess; view.pid=pi.dwProcessId; ResumeThread(pi.hThread); }
    else { TerminateProcess(pi.hProcess,1); CloseHandle(pi.hProcess); }
    CloseHandle(pi.hThread);
    return assigned;
}
static BOOL CALLBACK find_child(HWND window, LPARAM data) {
    View* view = (View*)data; DWORD pid=0;
    GetWindowThreadProcessId(window,&pid);
    wchar_t name[64]{}; GetClassNameW(window,name,64);
    if (pid == view->pid && std::wstring(name) == L"Engine" && IsWindowVisible(window)) { view->child=window; return FALSE; }
    return TRUE;
}
static BOOL CALLBACK add_monitor(HMONITOR, HDC, LPRECT rect, LPARAM) {
    View view; view.bounds=*rect;
    view.host=CreateWindowExW(WS_EX_TOPMOST|WS_EX_TOOLWINDOW,host_class,L"Living Earth Screensaver",
        WS_POPUP|WS_VISIBLE|WS_CLIPCHILDREN,rect->left,rect->top,rect->right-rect->left,rect->bottom-rect->top,
        nullptr,nullptr,GetModuleHandleW(nullptr),nullptr);
    if (!view.host) { stopping=true; return FALSE; }
    views.push_back(view);
    return TRUE;
}
static void tick() {
    ULONGLONG age=GetTickCount64()-started;
    if (preview) {
        if (!IsWindow(preview_parent) || !IsWindowVisible(preview_parent)) { stop(); return; }
    } else if (age > 1200) {
        POINT mouse{}; GetCursorPos(&mouse);
        if (abs(mouse.x-initial_mouse.x)>8 || abs(mouse.y-initial_mouse.y)>8) { stop(); return; }
        for (int key=1; key<255; ++key) {
            // The low bit catches short key/button presses between timer ticks.
            if (GetAsyncKeyState(key) & 0x8001) { stop(); return; }
        }
    } else {
        GetCursorPos(&initial_mouse);
        for (int key=1; key<255; ++key) GetAsyncKeyState(key);
    }
    for (auto& view : views) {
        if (!view.process) continue; // Extra monitors remain black to bound GPU/memory use.
        if (WaitForSingleObject(view.process,0) == WAIT_OBJECT_0) { stop(); return; }
        if (!view.child) {
            EnumChildWindows(view.host,find_child,(LPARAM)&view);
            if (!view.child) EnumWindows(find_child,(LPARAM)&view);
        }
        if (!view.child) { if (age>20000) stop(); continue; }
        RECT client{}; GetClientRect(view.host,&client);
        if (client.right <= 0 || client.bottom <= 0) continue;
        // Godot 4.6 --wid creates an owned WS_POPUP on Windows, not a WS_CHILD.
        // Adopt the initialized offscreen renderer explicitly and reassert after any engine style update.
        LONG_PTR style=GetWindowLongPtrW(view.child,GWL_STYLE);
        if (!(style & WS_CHILD) || GetParent(view.child) != view.host) {
            SetWindowLongPtrW(view.child,GWL_STYLE,(style & ~(WS_POPUP|WS_CAPTION|WS_THICKFRAME|WS_MINIMIZE|WS_MAXIMIZE))|WS_CHILD|WS_CLIPSIBLINGS);
            SetParent(view.child,view.host);
            if (GetParent(view.child) != view.host) { stop(); continue; }
            LONG_PTR ex=GetWindowLongPtrW(view.child,GWL_EXSTYLE);
            SetWindowLongPtrW(view.child,GWL_EXSTYLE,(ex & ~(WS_EX_APPWINDOW|WS_EX_WINDOWEDGE|WS_EX_CLIENTEDGE))|(preview ? WS_EX_NOACTIVATE : 0));
            SetWindowPos(view.child,HWND_TOP,0,0,client.right,client.bottom,SWP_FRAMECHANGED|SWP_NOACTIVATE|SWP_SHOWWINDOW);
            if (preview) EnableWindow(view.child,FALSE);
        }
        RECT child{}; GetWindowRect(view.child,&child);
        MapWindowPoints(HWND_DESKTOP,view.host,(LPPOINT)&child,2);
        if (!EqualRect(&child,&client)) MoveWindow(view.child,0,0,client.right,client.bottom,TRUE);
        view.bounds=client;
    }
}
int WINAPI wWinMain(HINSTANCE instance,HINSTANCE,LPWSTR,int) {
    // Physical pixel coordinates, including mixed-DPI desktops. Avoid a runtime dependency.
    HMODULE user=GetModuleHandleW(L"user32.dll");
    BOOL(WINAPI* dpi)(HANDLE)=nullptr;
    FARPROC dpi_address=GetProcAddress(user,"SetProcessDpiAwarenessContext");
    static_assert(sizeof(dpi)==sizeof(dpi_address),"Windows pointer size");
    std::memcpy(&dpi,&dpi_address,sizeof(dpi));
    if (dpi) dpi((HANDLE)-4); else SetProcessDPIAware();
    int count=0; LPWSTR* raw=CommandLineToArgvW(GetCommandLineW(),&count);
    if (!raw) return 2;
    std::vector<std::wstring> args;
    for (int i=1;i<count;i++) args.push_back(raw[i]);
    LocalFree(raw);
    auto options=earth_saver::parse(args);
    if (options.mode == earth_saver::Mode::Invalid) return 2;
    std::wstring app=app_path();
    if (app.empty() || GetFileAttributesW(app.c_str()) == INVALID_FILE_ATTRIBUTES) return 3;
    if (options.mode == earth_saver::Mode::Configure) {
        std::wstring command=L"\""+app+L"\" -- --screensaver-settings";
        STARTUPINFOW si{};si.cb=sizeof(si);PROCESS_INFORMATION pi{};
        if (!CreateProcessW(app.c_str(),&command[0],nullptr,nullptr,FALSE,0,nullptr,nullptr,&si,&pi)) return 3;
        CloseHandle(pi.hThread);CloseHandle(pi.hProcess);return 0;
    }
    preview=options.mode == earth_saver::Mode::Preview;
    preview_parent=(HWND)options.parent;
    if (preview && (!IsWindow(preview_parent) || !IsWindowVisible(preview_parent))) return 2;
    HANDLE mutex=nullptr;
    if (!preview) {
        mutex=CreateMutexW(nullptr,TRUE,L"Local\\LivingEarth3D.Screensaver");
        if (!mutex || GetLastError()==ERROR_ALREADY_EXISTS) { if(mutex)CloseHandle(mutex);return 0; }
    }
    WNDCLASSW wc{};wc.lpfnWndProc=host_proc;wc.hInstance=instance;wc.lpszClassName=host_class;
    wc.hbrBackground=(HBRUSH)GetStockObject(BLACK_BRUSH);
    if (!RegisterClassW(&wc)) { if(mutex)CloseHandle(mutex);return 3; }
    job=CreateJobObjectW(nullptr,nullptr);
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION limit{};limit.BasicLimitInformation.LimitFlags=JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    if (!job || !SetInformationJobObject(job,JobObjectExtendedLimitInformation,&limit,sizeof(limit))) { if(job)CloseHandle(job);if(mutex)CloseHandle(mutex);return 3; }
    HWND controller=CreateWindowExW(WS_EX_TOOLWINDOW,host_class,L"LivingEarth3D.SaverController",WS_POPUP,0,0,0,0,nullptr,nullptr,instance,nullptr);
    if (!controller) { CloseHandle(job);if(mutex)CloseHandle(mutex);return 3; }
    if (preview) { View view;view.host=preview_parent;views.push_back(view); }
    else {
        EnumDisplayMonitors(nullptr,nullptr,add_monitor,0);
        for (auto& view : views) WTSRegisterSessionNotification(view.host,NOTIFY_FOR_THIS_SESSION);
        if (!views.empty()) SetForegroundWindow(views.front().host);
    }
    int result=0;
    for (size_t i=0;i<views.size() && !stopping;i++) {
        if (earth_saver::animate_monitor(i) && !start_view(views[i],app)) { stopping=true;result=3; }
    }
    started=GetTickCount64();GetCursorPos(&initial_mouse);
    MSG message{};
    while (!stopping && !views.empty()) {
        while (PeekMessageW(&message,nullptr,0,0,PM_REMOVE)) {
            if (message.message==WM_QUIT) { stopping=true;break; }
            TranslateMessage(&message);DispatchMessageW(&message);
        }
        if (!stopping) tick();
        MsgWaitForMultipleObjects(0,nullptr,FALSE,50,QS_ALLINPUT);
    }
    // Own only these renderers. Graceful close first; the job prevents stranded children if a renderer hangs.
    for (auto& view : views) if (view.child) PostMessageW(view.child,WM_CLOSE,0,0);
    ULONGLONG deadline=GetTickCount64()+2500;
    for (auto& view : views) if(view.process) {
        DWORD remaining=GetTickCount64()<deadline ? (DWORD)(deadline-GetTickCount64()) : 0;
        WaitForSingleObject(view.process,remaining);
    }
    CloseHandle(job);
    for (auto& view : views) {
        if(view.process)CloseHandle(view.process);
        if(!preview) { WTSUnRegisterSessionNotification(view.host);DestroyWindow(view.host); }
    }
    DestroyWindow(controller);
    if(mutex)CloseHandle(mutex);
    return result;
}
