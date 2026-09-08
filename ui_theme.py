"""
UI Styling and Theme Engine for Windows Tweaker Suite.
"""

import tkinter as tk
from tkinter import ttk

THEMES = {
    "dark": {
        "name": "Modern Slate Dark",
        "bg": "#0F172A",
        "card_bg": "#1E293B",
        "border": "#334155",
        "accent": "#38BDF8",
        "text": "#F8FAFC",
        "text_dim": "#94A3B8",
        "btn_bg": "#1E293B",
        "btn_hover": "#334155",
        "btn_accent": "#0284C7",
        "tab_bg": "#0F172A",
        "tab_selected": "#1E293B"
    },
    "light": {
        "name": "Clean Light",
        "bg": "#F1F5F9",
        "card_bg": "#FFFFFF",
        "border": "#CBD5E1",
        "accent": "#0284C7",
        "text": "#0F172A",
        "text_dim": "#64748B",
        "btn_bg": "#E2E8F0",
        "btn_hover": "#CBD5E1",
        "btn_accent": "#0284C7",
        "tab_bg": "#E2E8F0",
        "tab_selected": "#FFFFFF"
    },
    "rog": {
        "name": "ROG Gaming Red",
        "bg": "#121214",
        "card_bg": "#1C1C20",
        "border": "#881822",
        "accent": "#FF3344",
        "text": "#ECECEC",
        "text_dim": "#A0A0AA",
        "btn_bg": "#2A181C",
        "btn_hover": "#4A1820",
        "btn_accent": "#CC1122",
        "tab_bg": "#1C1C20",
        "tab_selected": "#2A181C"
    },
    "cyberpunk": {
        "name": "Cyberpunk Neon",
        "bg": "#0A0D14",
        "card_bg": "#101622",
        "border": "#00FFCC",
        "accent": "#00FFCC",
        "text": "#E6EDF3",
        "text_dim": "#7D8590",
        "btn_bg": "#16202A",
        "btn_hover": "#1F3040",
        "btn_accent": "#00CC99",
        "tab_bg": "#101622",
        "tab_selected": "#16202A"
    }
}


class TweakerCard(tk.Frame):
    """Card container for individual tweaks with title, description, and toggle button"""
    def __init__(self, parent, title, desc, on_apply, on_restore, is_active=False, theme_name="dark", **kwargs):
        t = THEMES[theme_name]
        super().__init__(
            parent,
            bg=t["card_bg"],
            bd=1,
            relief="solid",
            highlightthickness=0,
            padx=12,
            pady=8,
            **kwargs
        )
        self.theme_name = theme_name
        self.on_apply = on_apply
        self.on_restore = on_restore
        self.active = is_active

        self.columnconfigure(0, weight=1)

        # Header Title
        self.lbl_title = tk.Label(
            self,
            text=title,
            font=("Segoe UI", 10, "bold"),
            bg=t["card_bg"],
            fg=t["text"],
            anchor="w"
        )
        self.lbl_title.grid(row=0, column=0, sticky="w")

        # Description
        self.lbl_desc = tk.Label(
            self,
            text=desc,
            font=("Segoe UI", 8),
            bg=t["card_bg"],
            fg=t["text_dim"],
            anchor="w",
            wraplength=480,
            justify="left"
        )
        self.lbl_desc.grid(row=1, column=0, sticky="w", pady=(2, 4))

        # Toggle Button
        btn_text = "🟢 Enabled (Restore)" if self.active else "⚡ Apply Tweak"
        btn_fg = t["accent"] if not self.active else "#10B981"
        self.btn_toggle = tk.Button(
            self,
            text=btn_text,
            font=("Segoe UI", 8, "bold"),
            bg=t["btn_bg"],
            fg=btn_fg,
            padx=10,
            pady=2,
            command=self._toggle_tweak
        )
        self.btn_toggle.grid(row=0, column=1, rowspan=2, padx=(8, 0), sticky="e")

    def _toggle_tweak(self):
        t = THEMES[self.theme_name]
        if not self.active:
            self.on_apply()
            self.active = True
            self.btn_toggle.config(text="🟢 Enabled (Restore)", fg="#10B981")
        else:
            self.on_restore()
            self.active = False
            self.btn_toggle.config(text="⚡ Apply Tweak", fg=t["accent"])
