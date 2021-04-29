import { writable } from 'svelte/store';
import { navigate } from "svelte-routing";

const media = window.matchMedia("(prefers-color-scheme: dark)");

function updateColorScheme(value) {
    switch (value) {
        case "night":
            document.documentElement.classList.add("dark");
            break;
        case "day":
            document.documentElement.classList.remove("dark");
            break;
        default:
            break;
    }
}

export const theme = writable(media.matches ? "night" : "day");

theme.subscribe(updateColorScheme);

media.addEventListener("change", () => {
    theme.set(media.matches ? "night" : "day");
});

updateColorScheme(media.matches ? "night" : "day");

export function toggle() {
    theme.update((oldTheme) => {
        switch (oldTheme) {
            case "night":
                return "day";
            case "day":
                return "night";
            default:
                return media.matches ? "night" : "day";
        }
    });
}
