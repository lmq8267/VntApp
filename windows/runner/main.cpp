#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <shellapi.h>
#include <windows.h>

#include <cstdint>
#include <cwchar>
#include <string>

#include "flutter_window.h"
#include "utils.h"

namespace {

bool IsRunAsAdmin() {
  BOOL is_admin = FALSE;
  PSID administrators_group = nullptr;
  SID_IDENTIFIER_AUTHORITY nt_authority = SECURITY_NT_AUTHORITY;

  if (::AllocateAndInitializeSid(&nt_authority, 2, SECURITY_BUILTIN_DOMAIN_RID,
                                 DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0,
                                 &administrators_group)) {
    ::CheckTokenMembership(nullptr, administrators_group, &is_admin);
    ::FreeSid(administrators_group);
  }

  return is_admin == TRUE;
}

bool HasElevationAttemptedFlag() {
  int argc = 0;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return false;
  }

  bool has_flag = false;
  for (int i = 1; i < argc; i++) {
    if (wcscmp(argv[i], L"--elevated-attempted") == 0) {
      has_flag = true;
      break;
    }
  }

  ::LocalFree(argv);
  return has_flag;
}

bool TryRelaunchAsAdmin(int show_command) {
  wchar_t executable_path[MAX_PATH];
  if (::GetModuleFileNameW(nullptr, executable_path, MAX_PATH) == 0) {
    return false;
  }

  std::wstring parameters = ::GetCommandLineW();
  int argc = 0;
  wchar_t** argv = ::CommandLineToArgvW(parameters.c_str(), &argc);
  if (argv != nullptr && argc > 0) {
    parameters = L"";
    for (int i = 1; i < argc; i++) {
      if (!parameters.empty()) {
        parameters += L" ";
      }
      parameters += L"\"";
      parameters += argv[i];
      parameters += L"\"";
    }
    ::LocalFree(argv);
  } else {
    parameters = L"";
  }

  if (!parameters.empty()) {
    parameters += L" ";
  }
  parameters += L"--elevated-attempted";

  HINSTANCE result = ::ShellExecuteW(nullptr, L"runas", executable_path,
                                    parameters.c_str(), nullptr, show_command);
  return reinterpret_cast<intptr_t>(result) > 32;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  if (!IsRunAsAdmin() && !HasElevationAttemptedFlag()) {
    if (TryRelaunchAsAdmin(show_command)) {
      return EXIT_SUCCESS;
    }
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  bool startup_to_tray = false;
  for (const auto& argument : command_line_arguments) {
    if (argument == "--startup-hidden" || argument == "--startup-tray" ||
        argument == "--hidden" || argument == "--minimized") {
      startup_to_tray = true;
      break;
    }
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project, !startup_to_tray);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"vnt_app", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
