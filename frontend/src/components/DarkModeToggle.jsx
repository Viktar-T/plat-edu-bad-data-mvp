import React from "react";
import Switch from "react-switch";
import { useColorScheme } from "./useColorScheme";

export const DarkModeToggle = () => {
    const { isDark, setIsDark } = useColorScheme();

    return (
        <Switch
            checked={isDark}
            onChange={setIsDark} // ✅ receives the new boolean directly
            checkedIcon={<span style={{ paddingLeft: 6 }}>🌙</span>}
            uncheckedIcon={<span style={{ paddingLeft: 6 }}>🔆</span>}
            aria-label="Dark mode toggle"
        />
    );
};
