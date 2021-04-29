<script>
    import { theme, toggle } from "../stores/theme.js";

    export let size = 36;

    $: factor = size / 36;
</script>

<div class="root centered" on:click={toggle} style={`--daynight-factor: ${Math.round(factor * 1000) / 1000}`}>
    <div class="day-night" class:day={$theme === "day"} class:night={$theme === "night"} />
</div>

<style>
    .root {
        cursor: pointer;
    }

    .day-night {
        width: calc(36px * var(--daynight-factor, 1));
        height: calc(36px * var(--daynight-factor, 1));
        position: relative;
        border-radius: 50%;
    }

    .day-night::before {
        content: "";
        width: inherit;
        height: inherit;
        border-radius: inherit;
        position: absolute;
        left: 0;
        top: 0;
    }

    .day-night::after {
        content: "";
        width: calc(8px * var(--daynight-factor, 1));
        height: calc(8px * var(--daynight-factor, 1));
        border-radius: 50%;
        margin: calc(-4px * var(--daynight-factor, 1)) 0 0 calc(-4px * var(--daynight-factor, 1));
        position: absolute;
        top: 50%;
        left: 50%;
    }

    .day-night.day {
        box-shadow: inset calc(32px * var(--daynight-factor, 1)) calc(-32px * var(--daynight-factor, 1)) 0 0 var(--fg-color);
        transform: scale(0.5) rotate(0deg);
        transition: transform 0.3s ease 0.1s, box-shadow 0.2s ease 0s;
    }

    .day-night.day::before {
        background: var(--fg-color);
        transition: background 0.3s ease 0.1s;
    }

    .day-night.day::after {
        transform: scale(1.5);
        transition: transform 0.5s ease 0.15s;
        box-shadow:
            0 calc(-23px * var(--daynight-factor, 1)) 0 var(--fg-color),
            0 calc(23px * var(--daynight-factor, 1)) 0 var(--fg-color),
            calc(23px * var(--daynight-factor, 1)) 0 0 var(--fg-color),
            calc(-23px * var(--daynight-factor, 1)) 0 0 var(--fg-color),
            calc(15px * var(--daynight-factor, 1)) calc(15px * var(--daynight-factor, 1)) 0 var(--fg-color),
            calc(-15px * var(--daynight-factor, 1)) calc(15px * var(--daynight-factor, 1)) 0 var(--fg-color),
            calc(15px * var(--daynight-factor, 1)) calc(-15px * var(--daynight-factor, 1)) 0 var(--fg-color),
            calc(-15px * var(--daynight-factor, 1)) calc(-15px * var(--daynight-factor, 1)) 0 var(--fg-color);
    }

    .day-night.night {
        box-shadow: inset calc(8px * var(--daynight-factor, 1)) calc(-8px * var(--daynight-factor, 1)) 0px 0px var(--fg-color);
        transform: scale(1) rotate(-2deg);
        transition: box-shadow 0.5s ease 0s, transform 0.4s ease 0.1s;
    }

    .day-night.night::before {
        transition: background 0.3s ease;
    }

    .day-night.night::after {
        transform: scale(0);
        transition: all 0.3s ease;
    }
</style>
