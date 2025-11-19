import { useEffect, useMemo, useState } from "react";

export function useColorScheme() {
    // Load persisted preference from localStorage
    const [isDark, setIsDark] = useState(() => {
        const stored = localStorage.getItem("colorScheme");
        return stored ? JSON.parse(stored) : undefined;
    });

    // Determine active mode (user preference OR default to light mode)
    const value = useMemo(
        () => (isDark === undefined ? false : isDark),
        [isDark]
    );

    // Persist when user changes preference
    useEffect(() => {
        if (isDark !== undefined) {
            localStorage.setItem("colorScheme", JSON.stringify(isDark));
        }
    }, [isDark]);

    // Apply dark/light mode to body
    useEffect(() => {
        document.body.classList.toggle("dark", value);
    }, [value]);

    return { isDark: value, setIsDark };
}
