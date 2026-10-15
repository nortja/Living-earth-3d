# Update the PE icon before signing, using Windows' native resource APIs.
param([Parameter(Mandatory)][string]$Executable, [Parameter(Mandatory)][string]$Icon)
$ErrorActionPreference = 'Stop'
if (-not ('EarthIconResources' -as [type])) {
Add-Type @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class EarthIconResources {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr BeginUpdateResource(string file, bool deleteExisting);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern bool UpdateResource(IntPtr handle, IntPtr type, IntPtr name, ushort language, byte[] data, uint size);
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern bool EndUpdateResource(IntPtr handle, bool discard);
    public static void Apply(string file, byte[] ico) {
        if (ico.Length < 6 || BitConverter.ToUInt16(ico, 0) != 0 || BitConverter.ToUInt16(ico, 2) != 1)
            throw new ArgumentException("Invalid ICO header.");
        int count = BitConverter.ToUInt16(ico, 4);
        if (count < 1 || ico.Length < 6 + count * 16) throw new ArgumentException("Invalid ICO directory.");
        var group = new byte[6 + count * 14];
        Buffer.BlockCopy(ico, 0, group, 0, 6);
        IntPtr handle = BeginUpdateResource(file, false);
        if (handle == IntPtr.Zero) throw new Win32Exception();
        bool committed = false;
        try {
            for (int i=0; i<count; i++) {
                int entry = 6 + i * 16;
                uint size = BitConverter.ToUInt32(ico, entry + 8);
                uint offset = BitConverter.ToUInt32(ico, entry + 12);
                if ((ulong)offset + size > (ulong)ico.Length || size > int.MaxValue) throw new ArgumentException("Invalid ICO image.");
                var image = new byte[(int)size];
                Buffer.BlockCopy(ico, (int)offset, image, 0, image.Length);
                Buffer.BlockCopy(ico, entry, group, 6 + i * 14, 12);
                Buffer.BlockCopy(BitConverter.GetBytes((ushort)(i+1)), 0, group, 6 + i * 14 + 12, 2);
                if (!UpdateResource(handle, new IntPtr(3), new IntPtr(i+1), 1033, image, size)) throw new Win32Exception();
            }
            IntPtr groupName = Marshal.StringToHGlobalUni("GODOT_ICON");
            try {
                if (!UpdateResource(handle, new IntPtr(14), groupName, 1033, group, (uint)group.Length)) throw new Win32Exception();
            } finally { Marshal.FreeHGlobal(groupName); }
            if (!EndUpdateResource(handle, false)) throw new Win32Exception();
            committed = true;
        } finally { if (!committed) EndUpdateResource(handle, true); }
    }
}
'@
}
[EarthIconResources]::Apply([IO.Path]::GetFullPath($Executable), [IO.File]::ReadAllBytes([IO.Path]::GetFullPath($Icon)))
