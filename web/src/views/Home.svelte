<script lang="ts">
    import { Link } from "svelte-routing";

    import Button from "./Button.svelte";
    import DayNight from "./DayNight.svelte";

    import state from "../state";
    import locations from "../locations";

    function goTo(location: string) {
        return function () {
            locations.push(location);
        }
    }
</script>

<div class="root">
    <div class="navbar centered">
        <div class="title-container centered">
            <div class="title">
                RSS App
            </div>
        </div>
        <div class="day-night centered hstack">
            <DayNight size={30} />
        </div>
    </div>
    <div class="content-container centered">
        <div class="vstack buttons">
            <Button on:click={goTo("/feeds")}>Feeds</Button>
            <Button on:click={goTo("/categories")}>Categories</Button>
            <Button on:click={goTo("/settings")}>Settings</Button>
        </div>
    </div>
</div>

<style>
    .root {
        width: 100%;
        height: 100%;
        display: grid;
        grid-template-columns: 100%;
        grid-template-rows: 50px 1fr min-content;
    }

    .navbar {
        width: 100%;
        height: 100%;
        border-bottom: 2px solid var(--fg-color);
        /* font-weight: bold; */
        font-size: 20px;
        text-align: center;

        display: grid;
        grid-gap: 5px;
        grid-template-rows: 1fr;
        grid-template-columns: 1fr min-content;

        --font-wght: 800;
    }

    .title-container {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .title {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        cursor: pointer;
    }

    .day-night {
        margin-right: 10px;
    }

    .content-container {
        width: 100%;
        height: 100%;

        --button-margin: 5px;
        --button-padding: 20px 30px;
        --button-font-size: 22px;
        --button-border-width: 3px;
    }

    .buttons {
        width: 300px;
    }
</style>
