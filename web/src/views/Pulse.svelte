<script>
    export let color = "#fc3636";
</script>

<div class="pulse" style={`--pulse-color: ${color}`} />

<style>
    .pulse {
        width: 0.8rem;
        height: 0.8rem;
        border-radius: 50%;
        background: var(--pulse-color);
        display: inline-block;
        position: relative;
    }

    .pulse::after {
        content: "";
        width: 0.8rem;
        height: 0.8rem;
        background: var(--pulse-color);
        position: absolute;
        border-radius: 50%;
        top: 0;
        left: 0;
        opacity: 0.75;
        animation-name: pulse;
        animation-duration: 1.5s;
        animation-iteration-count: infinite;
        animation-timing-function: ease-out;
        will-change: transform;
    }

    @keyframes pulse {
        0% {
            transform: scale(1);
            opacity: 0.75;
        }

        75% {
            transform: scale(4);
            opacity: 0;
        }

        100% {
            transform: scale(4);
            opacity: 0;
        }
    }
</style>
