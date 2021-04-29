<script lang="ts">
    import { onMount, tick } from "svelte";

    import Icon from "fa-svelte";
    import { Link } from "svelte-routing";

    import { faArrowLeft } from "@fortawesome/free-solid-svg-icons/faArrowLeft";
    import { faTimes } from "@fortawesome/free-solid-svg-icons/faTimes";
    import { faRedoAlt } from "@fortawesome/free-solid-svg-icons/faRedoAlt";

    import Button from "./Button.svelte";

    import state from "../state";
    import locations from "../locations";
    import type { Feed } from "../types";

    export let category: string;

    function goBack() {
        locations.pop();
    }

    function goTo(location: string) {
        return function () {
            locations.push(location);
        }
    }

    let refreshing = true;
    let feeds: Promise<Feed[]> = state.ready
        .then(() => state.category(category))
        .then((feeds) => {
            refreshing = false;
            return feeds;
        });

    function refreshFeeds() {
        refreshing = true;
        feeds = state.category(category).then((feeds) => {
            refreshing = false;
            return feeds;
        });
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="button-container">
            <Button on:click={goBack}><Icon icon={faArrowLeft} /></Button>
        </div>
        <div class="title-container">
            <div class="title">{category}</div>
        </div>
        <div class="button-container">
            <Button disabled={refreshing} on:click={refreshFeeds}>
                <div class="refresher centered" class:refreshing>
                    <Icon icon={faRedoAlt} />
                </div>
            </Button>
        </div>
    </div>
    <div class="content-container centered">
        <div class="content vstack" style="gap: 10px">
            {#await feeds}
                <div class="message">Loading feeds...</div>
            {:then feeds}
                {#each feeds as feed (feed.id)}
                    <div class="feed-button">
                        <Button on:click={goTo(`/articles/${encodeURIComponent(feed.id)}`)}>{feed.title}</Button>
                    </div>
                {:else}
                    <div class="message discrete">No feeds.</div>
                {/each}
            {/await}
        </div>
    </div>
</div>

<style>
    .root {
        width: 100%;
        height: 100%;
        display: grid;
        grid-template-columns: 100%;
        grid-template-rows: 50px calc(100% - 50px);
    }

    .navbar {
        width: 100%;
        height: 100%;
        border-bottom: 2px solid var(--fg-color);
        /* font-weight: bold; */
        font-size: 20px;
        display: grid;
        grid-template-columns: 75px 1fr repeat(1, min-content);
        grid-template-rows: 1fr;
        grid-gap: 5px;
        padding: 2px;

        --font-wght: 800;
    }

    .title-container {
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        padding: 0 10px;
    }

    .title {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        cursor: pointer;
    }

    .button-container {
        height: 100%;
        white-space: nowrap;
    }

    .refreshing {
        will-change: transform;
        transform-origin: center;
        animation-name: spinning;
        animation-duration: 1s;
        animation-direction: normal;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
    }

    @keyframes spinning {
        from {
            transform: rotate(0deg);
        }

        to {
            transform: rotate(360deg);
        }
    }

    .content-container {
        width: 100%;
        height: 100%;
        overflow: auto;
        padding: 10px;
    }

    .content {
    }

    .feed-button {
        flex-grow: 1;

        --button-padding: 10px 20px;
    }

    .delete-button {
        --button-padding: 10px;
    }

    .message {
        width: 100%;
        height: 100%;
        text-align: center;
        font-size: 22px;
        /* font-weight: 800; */

        --font-wght: 800;
    }

    .discrete {
        color: #777;
    }

    .modal-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        backdrop-filter: brightness(.7);
        -webkit-backdrop-filter: brightness(.7);
    }

    .add-feed-modal {
        gap: 10px;
        background: var(--bg-color);
        padding: 15px 30px 20px 30px;
        border-radius: 10px;
        border: solid 2px var(--fg-color);
        --button-padding: 7px;
    }

    .context-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
    }

    .context-menu {
        position: absolute;
        border: 2px solid var(--fg-color);
        border-radius: 5px;
        background-color: var(--bg-color);
        white-space: nowrap;
    }

    .context-menu-size {
        border-bottom: solid 2px var(--fg-color);
        padding: 10px;
        color: #7f7f7f;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .context-menu-item-container {
        padding: 5px;
    }

    .context-menu-item {
        border-radius: 5px;
        padding: 5px 10px;
        cursor: pointer;
    }

    .context-menu-item:hover {
        color: var(--bg-color);
        background-color: var(--fg-color);
    }

    .input {
        appearance: none;
        -moz-appearance: none;
        -webkit-appearance: none;

        width: 100%;
        padding: 7px;
        margin: 0;

        color: inherit;
        background-color: inherit;

        font-family: inherit;
        font-size: inherit;
        font-weight: inherit;
        text-align: center;

        border: solid 2px var(--fg-color);
        border-radius: 5px;

        outline: none;
    }
</style>
