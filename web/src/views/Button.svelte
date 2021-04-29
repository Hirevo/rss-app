<script>
    export let disabled = false;
</script>

<div class="button centered" class:disabled on:click>
    <slot />
</div>

<style>
    .button {
        appearance: none;
        -moz-appearance: none;
        -webkit-appearance: none;
        cursor: pointer;
        border-top: var(--button-border-top, var(--button-border, solid 2px var(--fg-color)));
        border-bottom: var(--button-border-bottom, var(--button-border, solid 2px var(--fg-color)));
        border-left: var(--button-border-left, var(--button-border, solid 2px var(--fg-color)));
        border-right: var(--button-border-right, var(--button-border, solid 2px var(--fg-color)));
        border-radius: var(--button-border-radius, 5px);
        background: var(--button-background, inherit);
        font-size: var(--button-font-size, initial);
        padding: var(--button-padding, 0 10px);
        margin: var(--button-margin, 0);
        width: var(--button-width, inherit);
        height: var(--button-height, 100%);
        color: var(--button-fg-color, inherit);
        background-color: var(--button-bg-color, inherit);
    }

    .button:hover:not(.disabled) {
        color: var(--button-hover-fg-color, var(--bg-color));
        background-color: var(--button-hover-bg-color, var(--fg-color));
    }

    .button.disabled {
        color: var(--button-disabled-fg-color, #303030);
        background-color: var(--button-disabled-bg-color, #a0a0a0);
        border-color: var(--button-disabled-fg-color, #303030);
    }
</style>
