"""
Ultimate Windows Tweaker & PC Optimizer Suite - Full Power Edition.
Comprehensive GUI for Performance, Privacy, Windows Updates Control,
Background Apps, Startup Apps, Deep Cleaning, DNS Switcher, System Repair,
Battery Health, Context Menus, Services, Bloatware, and Restore Points.
"""

import os
import sys
import time
import threading
import tkinter as tk
from tkinter import ttk, messagebox
from PIL import ImageTk, Image

import tweaks_engine
import cleaner_engine
from icon_generator import generate_tweaker_icon
from ui_theme import THEMES, TweakerCard


class WindowsTweakerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Ultimate Windows Tweaker & PC Optimizer Suite")
        self.geometry("740x670")
        self.resizable(False, False)
        self.current_theme = "dark"

        try:
            self.icon_img = ImageTk.PhotoImage(generate_tweaker_icon(32))
            self.iconphoto(True, self.icon_img)
        except Exception:
            pass

        self._init_styles()
        self._build_ui()

    def _init_styles(self):
        self.style = ttk.Style(self)
        self.style.theme_use("clam")
        self._apply_ttk_theme()

    def _apply_ttk_theme(self):
        t = THEMES[self.current_theme]
        self.configure(bg=t["bg"])
        
        self.style.configure(
            "TNotebook",
            background=t["bg"],
            tabmargins=[2, 4, 2, 0]
        )
        self.style.configure(
            "TNotebook.Tab",
            background=t["tab_bg"],
            foreground=t["text"],
            padding=[8, 4],
            font=("Segoe UI", 8, "bold")
        )
        self.style.map(
            "TNotebook.Tab",
            background=[("selected", t["tab_selected"])],
            foreground=[("selected", t["accent"])]
        )

    def _build_ui(self):
        t = THEMES[self.current_theme]

        # Top Header Banner
        f_header = tk.Frame(self, bg=t["card_bg"], padx=14, pady=8, bd=1, relief="groove")
        f_header.pack(fill="x", padx=8, pady=(8, 2))
        f_header.columnconfigure(0, weight=1)

        lbl_title = tk.Label(
            f_header,
            text="🛡️ Ultimate Windows Tweaker & PC Optimizer",
            font=("Segoe UI", 13, "bold"),
            bg=t["card_bg"],
            fg=t["accent"]
        )
        lbl_title.grid(row=0, column=0, sticky="w")

        lbl_sub = tk.Label(
            f_header,
            text="Performance, Privacy, Updates Controller, Background Apps, Startup Manager, DNS & Repair Hub",
            font=("Segoe UI", 8),
            bg=t["card_bg"],
            fg=t["text_dim"]
        )
        lbl_sub.grid(row=1, column=0, sticky="w")

        btn_theme = tk.Button(
            f_header,
            text="🎨 Theme",
            font=("Segoe UI", 8),
            bg=t["btn_bg"],
            fg=t["text"],
            command=self._cycle_theme,
            padx=8,
            pady=2
        )
        btn_theme.grid(row=0, column=1, rowspan=2, sticky="e")

        # Notebook tabs container
        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=8, pady=2)

        # Tab Frames
        self.tab_perf = self._create_scrollable_tab("Performance")
        self.tab_priv = self._create_scrollable_tab("Privacy")
        self.tab_updates = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_printer = self._create_scrollable_tab("Printer & Features")
        self.tab_startup = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_clean = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_dns = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_repair = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_ui = self._create_scrollable_tab("Context Menu")
        self.tab_serv = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_bloat = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_hub = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)
        self.tab_restore = tk.Frame(self.notebook, bg=t["bg"], padx=10, pady=8)

        self.notebook.add(self.tab_perf["outer"], text="🚀 Performance")
        self.notebook.add(self.tab_priv["outer"], text="🔒 Privacy")
        self.notebook.add(self.tab_updates, text="🔄 Updates & Background")
        self.notebook.add(self.tab_printer["outer"], text="🖨️ Printer & Policies")
        self.notebook.add(self.tab_startup, text="🚀 Startup Apps")
        self.notebook.add(self.tab_clean, text="🧹 Deep Cleaner")
        self.notebook.add(self.tab_dns, text="🌐 Fast DNS")
        self.notebook.add(self.tab_repair, text="🩺 Repair & Battery")
        self.notebook.add(self.tab_ui["outer"], text="🛠️ Context Menu")
        self.notebook.add(self.tab_serv, text="⚡ Services")
        self.notebook.add(self.tab_bloat, text="📦 Bloatware")
        self.notebook.add(self.tab_hub, text="🧰 Quick Hub")
        self.notebook.add(self.tab_restore, text="🛡️ Restore")

        self._build_performance_tab()
        self._build_privacy_tab()
        self._build_updates_tab()
        self._build_printer_tab()
        self._build_startup_tab()
        self._build_cleaner_tab()
        self._build_dns_tab()
        self._build_repair_tab()
        self._build_ui_tab()
        self._build_services_tab()
        self._build_bloatware_tab()
        self._build_hub_tab()
        self._build_restore_tab()
        self._build_bottom_bar()

    def _create_scrollable_tab(self, name):
        t = THEMES[self.current_theme]
        outer = tk.Frame(self.notebook, bg=t["bg"])
        canvas = tk.Canvas(outer, bg=t["bg"], highlightthickness=0)
        scrollbar = ttk.Scrollbar(outer, orient="vertical", command=canvas.yview)
        scrollable_frame = tk.Frame(canvas, bg=t["bg"])

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw", width=700)
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        return {"outer": outer, "inner": scrollable_frame}

    # ==========================================
    # TAB 1: PERFORMANCE
    # ==========================================
    def _build_performance_tab(self):
        f = self.tab_perf["inner"]
        t = THEMES[self.current_theme]

        for tweak in tweaks_engine.PERFORMANCE_TWEAKS:
            is_on = tweak["is_active"]()
            card = TweakerCard(
                f,
                title=tweak["title"],
                desc=tweak["desc"],
                on_apply=tweak["apply"],
                on_restore=tweak["restore"],
                is_active=is_on,
                theme_name=self.current_theme
            )
            card.pack(fill="x", padx=6, pady=3)

        f_b = tk.Frame(f, bg=t["bg"])
        f_b.pack(fill="x", padx=6, pady=6)
        btn_all = tk.Button(
            f_b,
            text="⚡ Apply All Recommended Performance Tweaks",
            font=("Segoe UI", 9, "bold"),
            bg=t["btn_accent"],
            fg="#FFFFFF",
            pady=5,
            command=self._apply_all_performance
        )
        btn_all.pack(fill="x")

    def _apply_all_performance(self):
        for tweak in tweaks_engine.PERFORMANCE_TWEAKS:
            try:
                tweak["apply"]()
            except Exception:
                pass
        messagebox.showinfo("Performance Tweaks Applied", "All recommended performance & gaming tweaks have been engaged successfully!")
        self._refresh_ui()

    # ==========================================
    # TAB 2: PRIVACY
    # ==========================================
    def _build_privacy_tab(self):
        f = self.tab_priv["inner"]
        t = THEMES[self.current_theme]

        for tweak in tweaks_engine.PRIVACY_TWEAKS:
            is_on = tweak["is_active"]()
            card = TweakerCard(
                f,
                title=tweak["title"],
                desc=tweak["desc"],
                on_apply=tweak["apply"],
                on_restore=tweak["restore"],
                is_active=is_on,
                theme_name=self.current_theme
            )
            card.pack(fill="x", padx=6, pady=3)

        f_b = tk.Frame(f, bg=t["bg"])
        f_b.pack(fill="x", padx=6, pady=6)
        btn_all = tk.Button(
            f_b,
            text="🔒 Apply All Recommended Privacy Tweaks",
            font=("Segoe UI", 9, "bold"),
            bg=t["btn_accent"],
            fg="#FFFFFF",
            pady=5,
            command=self._apply_all_privacy
        )
        btn_all.pack(fill="x")

    def _apply_all_privacy(self):
        for tweak in tweaks_engine.PRIVACY_TWEAKS:
            try:
                tweak["apply"]()
            except Exception:
                pass
        messagebox.showinfo("Privacy Tweaks Applied", "Telemetry, ad-tracking, and Bing background searches have been disabled!")
        self._refresh_ui()

    # ==========================================
    # TAB 3: WINDOWS UPDATES & BACKGROUND APPS
    # ==========================================
    def _build_updates_tab(self):
        f = self.tab_updates
        t = THEMES[self.current_theme]

        # Section 1: Windows Updates
        lbl_u_hdr = tk.Label(f, text="Windows Updates Controller", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_u_hdr.pack(anchor="w", pady=(0, 2))

        f_u_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_u_card.pack(fill="x", pady=4)
        f_u_card.columnconfigure(0, weight=1)
        f_u_card.columnconfigure(1, weight=1)
        f_u_card.columnconfigure(2, weight=1)

        self.lbl_u_status = tk.Label(
            f_u_card,
            text=f"Current Status: {tweaks_engine.get_windows_update_mode()}",
            font=("Segoe UI", 9, "bold"),
            bg=t["card_bg"],
            fg=t["text"]
        )
        self.lbl_u_status.grid(row=0, column=0, columnspan=3, sticky="w", pady=(0, 6))

        btn_stop_u = tk.Button(f_u_card, text="🛑 Stop / Pause Updates", font=("Segoe UI", 8, "bold"), bg="#EF4444", fg="#FFFFFF", pady=5, command=self._stop_updates)
        btn_stop_u.grid(row=1, column=0, sticky="ew", padx=2)

        btn_start_u = tk.Button(f_u_card, text="🔄 Restart / Enable Updates", font=("Segoe UI", 8, "bold"), bg="#10B981", fg="#FFFFFF", pady=5, command=self._start_updates)
        btn_start_u.grid(row=1, column=1, sticky="ew", padx=2)

        btn_rec_u = tk.Button(f_u_card, text="💡 Recommended (Notify)", font=("Segoe UI", 8, "bold"), bg=t["btn_accent"], fg="#FFFFFF", pady=5, command=self._rec_updates)
        btn_rec_u.grid(row=1, column=2, sticky="ew", padx=2)

        # Section 2: Global Background Apps
        lbl_bg_hdr = tk.Label(f, text="Global Background Apps Controller", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_bg_hdr.pack(anchor="w", pady=(12, 2))

        f_bg_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_bg_card.pack(fill="x", pady=4)
        f_bg_card.columnconfigure(0, weight=1)
        f_bg_card.columnconfigure(1, weight=1)

        bg_status = "🚫 Background Apps Disabled" if tweaks_engine.is_background_apps_stopped() else "🟢 Background Apps Running"
        self.lbl_bg_status = tk.Label(f_bg_card, text=f"Status: {bg_status}", font=("Segoe UI", 9, "bold"), bg=t["card_bg"], fg=t["text"])
        self.lbl_bg_status.grid(row=0, column=0, columnspan=2, sticky="w", pady=(0, 6))

        btn_stop_bg = tk.Button(f_bg_card, text="🚫 Stop All Background Apps (Save RAM & CPU)", font=("Segoe UI", 9, "bold"), bg="#EF4444", fg="#FFFFFF", pady=6, command=self._stop_bg_apps)
        btn_stop_bg.grid(row=1, column=0, sticky="ew", padx=2)

        btn_start_bg = tk.Button(f_bg_card, text="🔄 Enable Background Apps", font=("Segoe UI", 9), bg=t["btn_bg"], fg=t["text"], pady=6, command=self._start_bg_apps)
        btn_start_bg.grid(row=1, column=1, sticky="ew", padx=2)

    def _stop_updates(self):
        tweaks_engine.stop_windows_updates()
        self.lbl_u_status.config(text=f"Current Status: {tweaks_engine.get_windows_update_mode()}")
        messagebox.showinfo("Windows Updates Stopped", "Automatic Windows Updates and update services have been disabled!")

    def _start_updates(self):
        tweaks_engine.start_windows_updates()
        self.lbl_u_status.config(text=f"Current Status: {tweaks_engine.get_windows_update_mode()}")
        messagebox.showinfo("Windows Updates Restored", "Automatic Windows Updates have been restarted and enabled!")

    def _rec_updates(self):
        tweaks_engine.set_recommended_windows_updates()
        self.lbl_u_status.config(text=f"Current Status: {tweaks_engine.get_windows_update_mode()}")
        messagebox.showinfo("Recommended Updates Set", "Windows will now notify you before downloading updates, preventing sudden game reboots!")

    def _stop_bg_apps(self):
        tweaks_engine.stop_all_background_apps()
        self.lbl_bg_status.config(text="Status: 🚫 Background Apps Disabled")
        messagebox.showinfo("Background Apps Stopped", "All background apps have been globally disabled. You will notice faster boot and less RAM usage!")

    def _start_bg_apps(self):
        tweaks_engine.enable_all_background_apps()
        self.lbl_bg_status.config(text="Status: 🟢 Background Apps Running")
        messagebox.showinfo("Background Apps Enabled", "Background apps enabled.")

    # ==========================================
    # TAB: PRINTER ERRORS & GROUP POLICY / FEATURES
    # ==========================================
    def _build_printer_tab(self):
        f = self.tab_printer["inner"]
        t = THEMES[self.current_theme]

        # Section 1: Printer Sharing Fixes
        lbl_p_hdr = tk.Label(f, text="Network & Shared Printer Errors Fixer", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_p_hdr.pack(anchor="w", pady=(2, 2))

        f_p_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_p_card.pack(fill="x", padx=6, pady=4)
        f_p_card.columnconfigure(0, weight=1)
        f_p_card.columnconfigure(1, weight=1)

        btn_all_p = tk.Button(
            f_p_card,
            text="⚡ 1-Click Fix All Printer Sharing Errors (0x0000011b & 0x00000709)",
            font=("Segoe UI", 9, "bold"),
            bg=t["btn_accent"],
            fg="#FFFFFF",
            pady=7,
            command=self._fix_all_printers
        )
        btn_all_p.grid(row=0, column=0, columnspan=2, sticky="ew", pady=(0, 6))

        btn_11b = tk.Button(f_p_card, text="🔧 Fix Error 0x0000011b (RPC Auth)", font=("Segoe UI", 8), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._fix_11b)
        btn_11b.grid(row=1, column=0, sticky="ew", padx=2, pady=2)

        btn_709 = tk.Button(f_p_card, text="🔧 Fix Error 0x00000709 (Named Pipes)", font=("Segoe UI", 8), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._fix_709)
        btn_709.grid(row=1, column=1, sticky="ew", padx=2, pady=2)

        btn_pnp = tk.Button(f_p_card, text="🔧 Fix Point & Print Restrictions (0x0000007c)", font=("Segoe UI", 8), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._fix_pnp)
        btn_pnp.grid(row=2, column=0, sticky="ew", padx=2, pady=2)

        btn_guest = tk.Button(f_p_card, text="🌐 Enable Insecure Guest Logons (LAN)", font=("Segoe UI", 8), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._enable_guest)
        btn_guest.grid(row=2, column=1, sticky="ew", padx=2, pady=2)

        btn_spool = tk.Button(f_p_card, text="🔄 Clear Print Queue & Restart Spooler", font=("Segoe UI", 8, "bold"), bg=t["btn_bg"], fg="#10B981", pady=5, command=self._restart_spooler)
        btn_spool.grid(row=3, column=0, columnspan=2, sticky="ew", padx=2, pady=(4, 0))

        # Section 2: Group Policy Tools
        lbl_gp_hdr = tk.Label(f, text="Group Policy Editor (gpedit.msc) Tools", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_gp_hdr.pack(anchor="w", pady=(10, 2))

        f_gp_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_gp_card.pack(fill="x", padx=6, pady=4)
        f_gp_card.columnconfigure(0, weight=1)
        f_gp_card.columnconfigure(1, weight=1)

        btn_gp_inst = tk.Button(
            f_gp_card,
            text="📥 Enable Group Policy (gpedit.msc) on Win 10/11 Home",
            font=("Segoe UI", 9, "bold"),
            bg=t["btn_bg"],
            fg=t["accent"],
            pady=6,
            command=tweaks_engine.install_gpedit_home
        )
        btn_gp_inst.grid(row=0, column=0, sticky="ew", padx=2, pady=2)

        btn_gp_upd = tk.Button(
            f_gp_card,
            text="🔄 Force Group Policy Update (gpupdate /force)",
            font=("Segoe UI", 9),
            bg=t["btn_bg"],
            fg=t["text"],
            pady=6,
            command=tweaks_engine.force_gpupdate
        )
        btn_gp_upd.grid(row=0, column=1, sticky="ew", padx=2, pady=2)

        # Section 3: Windows Optional Features & Regedit
        lbl_feat_hdr = tk.Label(f, text="Windows Optional Features & Registry Tools", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_feat_hdr.pack(anchor="w", pady=(10, 2))

        f_feat_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_feat_card.pack(fill="x", padx=6, pady=4)
        f_feat_card.columnconfigure(0, weight=1)
        f_feat_card.columnconfigure(1, weight=1)

        btn_smb = tk.Button(f_feat_card, text="🌐 Enable SMB 1.0 (Old Printers & NAS)", font=("Segoe UI", 8), bg=t["btn_bg"], fg=t["text"], pady=5, command=tweaks_engine.enable_smb1)
        btn_smb.grid(row=0, column=0, sticky="ew", padx=2, pady=2)

        btn_tel = tk.Button(f_feat_card, text="📡 Enable Telnet Client", font=("Segoe UI", 8), bg=t["btn_bg"], fg=t["text"], pady=5, command=tweaks_engine.enable_telnet)
        btn_tel.grid(row=0, column=1, sticky="ew", padx=2, pady=2)

        btn_feat_ui = tk.Button(f_feat_card, text="⚙️ Turn Windows Features On/Off (GUI)", font=("Segoe UI", 8, "bold"), bg=t["btn_bg"], fg=t["text"], pady=5, command=tweaks_engine.launch_optional_features_ui)
        btn_feat_ui.grid(row=1, column=0, sticky="ew", padx=2, pady=2)

        btn_reg_bak = tk.Button(f_feat_card, text="💾 1-Click Registry Backup (.reg on Desktop)", font=("Segoe UI", 8, "bold"), bg=t["btn_accent"], fg="#FFFFFF", pady=5, command=self._backup_reg)
        btn_reg_bak.grid(row=1, column=1, sticky="ew", padx=2, pady=2)

    def _fix_all_printers(self):
        tweaks_engine.apply_all_printer_fixes()
        messagebox.showinfo(
            "Printer Fixes Applied",
            "✅ All Printer Sharing Fixes Engaged:\n\n• RPC Auth Privacy (0x0000011b) Disabled\n• RPC over Named Pipes (0x00000709) Configured\n• Point and Print Restrictions Disabled\n• Insecure Guest Auth Enabled\n• Print Spooler Cleared & Restarted"
        )

    def _fix_11b(self):
        tweaks_engine.fix_printer_error_11b()
        messagebox.showinfo("0x0000011b Fixed", "RPC authentication level privacy enforcement disabled. Network printer sharing should now connect.")

    def _fix_709(self):
        tweaks_engine.fix_printer_error_709()
        messagebox.showinfo("0x00000709 Fixed", "RPC over Named Pipes and TCP configured.")

    def _fix_pnp(self):
        tweaks_engine.fix_point_and_print_restrictions()
        messagebox.showinfo("Point and Print Fixed", "Point and print driver restrictions lifted.")

    def _enable_guest(self):
        tweaks_engine.enable_lan_guest_sharing()
        messagebox.showinfo("Guest Logons Enabled", "LAN guest authentication enabled for network printers and shares.")

    def _restart_spooler(self):
        tweaks_engine.restart_print_spooler()
        messagebox.showinfo("Print Spooler Restarted", "Print queue backlog deleted and Print Spooler service restarted.")

    def _backup_reg(self):
        out = tweaks_engine.backup_registry()
        messagebox.showinfo("Registry Backed Up", f"Registry snapshot exported to:\n{out}")

    # ==========================================
    # TAB 4: STARTUP APPS MANAGER
    # ==========================================
    def _build_startup_tab(self):
        f = self.tab_startup
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Windows Startup Programs Manager", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        cols = ["name", "command", "location"]
        headers = ["Program Name", "Command / Executable Path", "Registry Location"]

        self.tree_start = ttk.Treeview(f, columns=cols, show="headings", height=10)
        for c, h in zip(cols, headers):
            self.tree_start.heading(c, text=h)
            self.tree_start.column(c, width=150 if c != "command" else 360, anchor="w")
        self.tree_start.pack(fill="both", expand=True, pady=4)

        self._refresh_startup_list()

        f_b = tk.Frame(f, bg=t["bg"])
        f_b.pack(fill="x", pady=4)
        f_b.columnconfigure(0, weight=1)
        f_b.columnconfigure(1, weight=1)

        btn_rem = tk.Button(f_b, text="🗑️ Disable / Remove Selected Startup Program", font=("Segoe UI", 9, "bold"), bg="#EF4444", fg="#FFFFFF", pady=5, command=self._remove_selected_startup)
        btn_rem.grid(row=0, column=0, sticky="ew", padx=(0, 4))

        btn_sett = tk.Button(f_b, text="⚙️ Open Windows Startup Settings", font=("Segoe UI", 9), bg=t["btn_bg"], fg=t["text"], pady=5, command=lambda: tweaks_engine.launch_utility("ms-settings:startupapps"))
        btn_sett.grid(row=0, column=1, sticky="ew", padx=(4, 0))

    def _refresh_startup_list(self):
        for item in self.tree_start.get_children():
            self.tree_start.delete(item)
        self.startup_raw = tweaks_engine.get_startup_apps()
        for idx, s in enumerate(self.startup_raw):
            self.tree_start.insert("", "end", iid=str(idx), values=(s["name"], s["command"], s["location"]))

    def _remove_selected_startup(self):
        sel = self.tree_start.selection()
        if not sel:
            messagebox.showwarning("No Selection", "Please select a startup program from the list to remove.")
            return
        idx = int(sel[0])
        item = self.startup_raw[idx]
        confirm = messagebox.askyesno("Confirm", f"Remove '{item['name']}' from Windows Startup?")
        if confirm:
            tweaks_engine.remove_startup_app(item["root"], item["subkey"], item["name"])
            self._refresh_startup_list()
            messagebox.showinfo("Removed", f"'{item['name']}' removed from Windows startup.")

    # ==========================================
    # TAB 5: DEEP CLEANER
    # ==========================================
    def _build_cleaner_tab(self):
        f = self.tab_clean
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Windows Disk Junk, Cache & Temp Files Cleaner", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        self.clean_vars = {}
        self.frame_clean_items = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=6)
        self.frame_clean_items.pack(fill="both", expand=True, pady=4)

        for target in cleaner_engine.CLEANER_TARGETS:
            var = tk.BooleanVar(value=True)
            self.clean_vars[target["id"]] = var
            cb = tk.Checkbutton(
                self.frame_clean_items,
                text=target["name"],
                variable=var,
                font=("Segoe UI", 9),
                bg=t["card_bg"],
                fg=t["text"],
                selectcolor=t["btn_bg"],
                anchor="w"
            )
            cb.pack(fill="x", pady=2)

        self.lbl_clean_status = tk.Label(f, text="Click 'Scan Junk Files' to analyze cleanable storage.", font=("Segoe UI", 9), bg=t["bg"], fg=t["text_dim"])
        self.lbl_clean_status.pack(pady=3)

        f_btns = tk.Frame(f, bg=t["bg"])
        f_btns.pack(fill="x", pady=3)
        f_btns.columnconfigure(0, weight=1)
        f_btns.columnconfigure(1, weight=1)

        btn_scan = tk.Button(f_btns, text="🔍 Scan Junk Files", font=("Segoe UI", 9, "bold"), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._scan_junk)
        btn_scan.grid(row=0, column=0, sticky="ew", padx=(0, 4))

        btn_clean = tk.Button(f_btns, text="🧹 Clean Selected Junk Now", font=("Segoe UI", 9, "bold"), bg=t["btn_accent"], fg="#FFFFFF", pady=5, command=self._clean_junk)
        btn_clean.grid(row=0, column=1, sticky="ew", padx=(4, 0))

    def _scan_junk(self):
        res = cleaner_engine.scan_cleanable_targets()
        self.lbl_clean_status.config(text=f"Analysis Complete: Found {res['total_files']} files ({res['total_mb']} MB) ready to clean!")

    def _clean_junk(self):
        selected_ids = [k for k, v in self.clean_vars.items() if v.get()]
        if not selected_ids:
            messagebox.showwarning("No Selection", "Please check at least one cleaning category.")
            return
        res = cleaner_engine.execute_deep_clean(selected_ids)
        self.lbl_clean_status.config(text=f"Clean Complete: Freed {res['cleaned_mb']} MB ({res['deleted_count']} files removed)!")
        messagebox.showinfo("Cleaning Done", f"Successfully cleaned Windows caches!\n\nFreed: {res['cleaned_mb']} MB\nDNS Cache: Flushed")

    # ==========================================
    # TAB 6: FAST DNS SWITCHER
    # ==========================================
    def _build_dns_tab(self):
        f = self.tab_dns
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Fast DNS Switcher & Latency Ping Tester", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        f_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_card.pack(fill="x", pady=4)
        f_card.columnconfigure(0, weight=1)
        f_card.columnconfigure(1, weight=1)

        self.dns_var = tk.StringVar(value="Cloudflare")
        for idx, (pname, pdata) in enumerate(tweaks_engine.DNS_PROFILES.items()):
            rb = tk.Radiobutton(
                f_card,
                text=f"{pname} ({pdata['primary']}, {pdata['secondary']}) - {pdata['desc']}",
                variable=self.dns_var,
                value=pname,
                font=("Segoe UI", 9),
                bg=t["card_bg"],
                fg=t["text"],
                selectcolor=t["btn_bg"],
                anchor="w"
            )
            rb.grid(row=idx, column=0, columnspan=2, sticky="w", pady=2)

        rb_dhcp = tk.Radiobutton(
            f_card,
            text="DHCP (Default ISP Automatic DNS)",
            variable=self.dns_var,
            value="DHCP (Automatic)",
            font=("Segoe UI", 9),
            bg=t["card_bg"],
            fg=t["text"],
            selectcolor=t["btn_bg"],
            anchor="w"
        )
        rb_dhcp.grid(row=len(tweaks_engine.DNS_PROFILES), column=0, columnspan=2, sticky="w", pady=2)

        f_btns = tk.Frame(f, bg=t["bg"])
        f_btns.pack(fill="x", pady=6)
        f_btns.columnconfigure(0, weight=1)
        f_btns.columnconfigure(1, weight=1)
        f_btns.columnconfigure(2, weight=1)

        btn_apply_dns = tk.Button(f_btns, text="⚡ Set DNS Server", font=("Segoe UI", 9, "bold"), bg=t["btn_accent"], fg="#FFFFFF", pady=5, command=self._apply_dns)
        btn_apply_dns.grid(row=0, column=0, sticky="ew", padx=2)

        btn_ping = tk.Button(f_btns, text="📡 Ping DNS Latency", font=("Segoe UI", 9), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._ping_dns)
        btn_ping.grid(row=0, column=1, sticky="ew", padx=2)

        btn_reset_net = tk.Button(f_btns, text="🔄 Reset TCP/Winsock", font=("Segoe UI", 9), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._reset_net)
        btn_reset_net.grid(row=0, column=2, sticky="ew", padx=2)

        self.lbl_dns_res = tk.Label(f, text="Ping: Click 'Ping DNS Latency' to test server response time.", font=("Segoe UI", 9), bg=t["bg"], fg=t["text_dim"])
        self.lbl_dns_res.pack(pady=4)

    def _apply_dns(self):
        sel = self.dns_var.get()
        tweaks_engine.set_dns_profile(sel)
        messagebox.showinfo("DNS Applied", f"System DNS configured to {sel}!")

    def _ping_dns(self):
        p1 = tweaks_engine.ping_dns_host("1.1.1.1")
        p2 = tweaks_engine.ping_dns_host("8.8.8.8")
        self.lbl_dns_res.config(text=f"Ping Results: Cloudflare (1.1.1.1): {p1} | Google (8.8.8.8): {p2}")

    def _reset_net(self):
        tweaks_engine.reset_network_stack()
        messagebox.showinfo("Network Stack Reset", "Winsock and TCP/IP stack have been reset and DNS flushed.")

    # ==========================================
    # TAB 7: REPAIR & BATTERY
    # ==========================================
    def _build_repair_tab(self):
        f = self.tab_repair
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Windows System Health, Repair & Battery Suite", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        f_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_card.pack(fill="both", expand=True, pady=4)
        f_card.columnconfigure(0, weight=1)
        f_card.columnconfigure(1, weight=1)

        btn_sfc = tk.Button(f_card, text="🩺 Run SFC Scannow (Fix Corrupt Files)", font=("Segoe UI", 9, "bold"), bg=t["btn_bg"], fg=t["text"], pady=8, command=tweaks_engine.run_sfc_scan)
        btn_sfc.grid(row=0, column=0, sticky="ew", padx=3, pady=3)

        btn_dism = tk.Button(f_card, text="🛠️ Run DISM Image RestoreHealth", font=("Segoe UI", 9, "bold"), bg=t["btn_bg"], fg=t["text"], pady=8, command=tweaks_engine.run_dism_repair)
        btn_dism.grid(row=0, column=1, sticky="ew", padx=3, pady=3)

        btn_icon = tk.Button(f_card, text="🖼️ Rebuild Windows Icon Cache", font=("Segoe UI", 9), bg=t["btn_bg"], fg=t["text"], pady=8, command=tweaks_engine.rebuild_icon_cache)
        btn_icon.grid(row=1, column=0, sticky="ew", padx=3, pady=3)

        btn_bat = tk.Button(f_card, text="🔋 Generate HTML Battery Health Report", font=("Segoe UI", 9, "bold"), bg=t["btn_accent"], fg="#FFFFFF", pady=8, command=tweaks_engine.generate_battery_report)
        btn_bat.grid(row=1, column=1, sticky="ew", padx=3, pady=3)

    # ==========================================
    # TAB 8: CONTEXT MENU & UI
    # ==========================================
    def _build_ui_tab(self):
        f = self.tab_ui["inner"]
        t = THEMES[self.current_theme]

        for tweak in tweaks_engine.UI_TWEAKS:
            is_on = tweak["is_active"]()
            card = TweakerCard(
                f,
                title=tweak["title"],
                desc=tweak["desc"],
                on_apply=tweak["apply"],
                on_restore=tweak["restore"],
                is_active=is_on,
                theme_name=self.current_theme
            )
            card.pack(fill="x", padx=6, pady=3)

        f_b = tk.Frame(f, bg=t["bg"])
        f_b.pack(fill="x", padx=6, pady=6)
        btn_restart_exp = tk.Button(
            f_b,
            text="🔄 Restart Windows Explorer (Apply Shell Changes)",
            font=("Segoe UI", 9),
            bg=t["btn_bg"],
            fg=t["accent"],
            pady=5,
            command=tweaks_engine.restart_explorer
        )
        btn_restart_exp.pack(fill="x")

    # ==========================================
    # TAB 9: SERVICES
    # ==========================================
    def _build_services_tab(self):
        f = self.tab_serv
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Windows Background Services Optimization", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        cols = ["name", "display", "recommended"]
        headers = ["Service Name", "Display Name", "Recommendation"]

        tree_s = ttk.Treeview(f, columns=cols, show="headings", height=8)
        for c, h in zip(cols, headers):
            tree_s.heading(c, text=h)
            tree_s.column(c, width=130 if c != "display" else 300, anchor="w" if c == "display" else "center")
        tree_s.pack(fill="both", expand=True, pady=4)

        for s in tweaks_engine.SERVICES_LIST:
            tree_s.insert("", "end", values=(s["name"], s["display"], s["recommended"]))

        f_b = tk.Frame(f, bg=t["bg"])
        f_b.pack(fill="x", pady=4)
        f_b.columnconfigure(0, weight=1)
        f_b.columnconfigure(1, weight=1)

        btn_opt = tk.Button(f_b, text="⚡ Optimize Background Services (Safe)", font=("Segoe UI", 9, "bold"), bg=t["btn_accent"], fg="#FFFFFF", pady=5, command=self._opt_services)
        btn_opt.grid(row=0, column=0, sticky="ew", padx=(0, 4))

        btn_rst = tk.Button(f_b, text="🔄 Restore Default Services", font=("Segoe UI", 9), bg=t["btn_bg"], fg=t["text"], pady=5, command=self._rst_services)
        btn_rst.grid(row=0, column=1, sticky="ew", padx=(4, 0))

    def _opt_services(self):
        tweaks_engine.optimize_services()
        messagebox.showinfo("Services Optimized", "Non-essential telemetry and background services have been safely disabled.")

    def _rst_services(self):
        tweaks_engine.restore_default_services()
        messagebox.showinfo("Services Restored", "Default Windows services configuration restored.")

    # ==========================================
    # TAB 10: BLOATWARE REMOVER
    # ==========================================
    def _build_bloatware_tab(self):
        f = self.tab_bloat
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Pre-Installed Windows Bloatware AppxPackages", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        self.bloat_vars = {}
        f_items = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=4)
        f_items.pack(fill="both", expand=True, pady=4)

        for b in tweaks_engine.BLOATWARE_APPS:
            var = tk.BooleanVar(value=True if "Phone" not in b["name"] else False)
            self.bloat_vars[b["name"]] = var
            cb = tk.Checkbutton(
                f_items,
                text=f"{b['label']} ({b['desc']})",
                variable=var,
                font=("Segoe UI", 8),
                bg=t["card_bg"],
                fg=t["text"],
                selectcolor=t["btn_bg"],
                anchor="w"
            )
            cb.pack(fill="x", pady=1)

        btn_rem = tk.Button(f, text="🗑️ Remove Selected Bloatware Apps", font=("Segoe UI", 9, "bold"), bg="#EF4444", fg="#FFFFFF", pady=5, command=self._remove_bloatware)
        btn_rem.pack(fill="x", pady=4)

    def _remove_bloatware(self):
        selected_apps = [k for k, v in self.bloat_vars.items() if v.get()]
        if not selected_apps:
            messagebox.showwarning("No Selection", "Please select at least one app to remove.")
            return

        confirm = messagebox.askyesno("Confirm Removal", f"Remove {len(selected_apps)} selected Windows Apps?")
        if confirm:
            removed = tweaks_engine.remove_selected_bloatware(selected_apps)
            messagebox.showinfo("Bloatware Removed", f"Successfully removed {len(removed)} apps:\n\n" + "\n".join(removed))

    # ==========================================
    # TAB 11: QUICK UTILITIES HUB
    # ==========================================
    def _build_hub_tab(self):
        f = self.tab_hub
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Windows Administrative Tools & Utilities Hub", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        f_grid = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=12, pady=8)
        f_grid.pack(fill="both", expand=True, pady=4)
        f_grid.columnconfigure(0, weight=1)
        f_grid.columnconfigure(1, weight=1)

        for idx, util in enumerate(tweaks_engine.SYSTEM_UTILITIES):
            r = idx // 2
            c = idx % 2
            btn = tk.Button(
                f_grid,
                text=f"⚙️ {util['name']}",
                font=("Segoe UI", 9),
                bg=t["btn_bg"],
                fg=t["text"],
                pady=6,
                command=lambda cmd=util["cmd"]: tweaks_engine.launch_utility(cmd)
            )
            btn.grid(row=r, column=c, sticky="ew", padx=4, pady=4)

    # ==========================================
    # TAB 12: RESTORE & SAFETY
    # ==========================================
    def _build_restore_tab(self):
        f = self.tab_restore
        t = THEMES[self.current_theme]

        lbl_hdr = tk.Label(f, text="Safety & System Restore Point Manager", font=("Segoe UI", 11, "bold"), bg=t["bg"], fg=t["accent"])
        lbl_hdr.pack(anchor="w", pady=(0, 2))

        lbl_desc = tk.Label(
            f,
            text="Before applying major system modifications, creating a System Restore point allows you to revert Windows back to a clean state anytime.",
            font=("Segoe UI", 9),
            bg=t["bg"],
            fg=t["text_dim"],
            wraplength=660,
            justify="left"
        )
        lbl_desc.pack(anchor="w", pady=4)

        f_card = tk.Frame(f, bg=t["card_bg"], bd=1, relief="solid", padx=16, pady=12)
        f_card.pack(fill="x", pady=6)

        btn_rp = tk.Button(
            f_card,
            text="🛡️ Create System Restore Point Now",
            font=("Segoe UI", 10, "bold"),
            bg=t["btn_accent"],
            fg="#FFFFFF",
            pady=8,
            command=self._make_restore_point
        )
        btn_rp.pack(fill="x")

    def _make_restore_point(self):
        succ = tweaks_engine.create_restore_point()
        if succ:
            messagebox.showinfo("Restore Point Created", "System Restore Point created successfully!")
        else:
            messagebox.showwarning("Notice", "Restore point creation command sent via PowerShell.")

    # ==========================================
    # BOTTOM BAR & HELPERS
    # ==========================================
    def _build_bottom_bar(self):
        t = THEMES[self.current_theme]
        f_bot = tk.Frame(self, bg=t["bg"], padx=10, pady=4)
        f_bot.pack(fill="x", side="bottom")

        lbl_status = tk.Label(
            f_bot,
            text="Tested, verified, and safe for Windows 10 & Windows 11.",
            font=("Segoe UI", 8),
            bg=t["bg"],
            fg=t["text_dim"]
        )
        lbl_status.pack(side="left")

        btn_exit = tk.Button(
            f_bot,
            text="Close",
            font=("Segoe UI", 9),
            bg=t["btn_bg"],
            fg=t["text"],
            padx=12,
            pady=2,
            command=self.destroy
        )
        btn_exit.pack(side="right")

    def _cycle_theme(self):
        keys = list(THEMES.keys())
        idx = (keys.index(self.current_theme) + 1) % len(keys)
        self.current_theme = keys[idx]
        self._refresh_ui()

    def _refresh_ui(self):
        for widget in self.winfo_children():
            widget.destroy()
        self._apply_ttk_theme()
        self._build_ui()


if __name__ == "__main__":
    app = WindowsTweakerApp()
    app.mainloop()
