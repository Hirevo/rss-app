<script lang="ts">
    import { onMount, tick } from "svelte";

    import Icon from "fa-svelte";
    import { Link } from "svelte-routing";

    import { faArrowLeft } from "@fortawesome/free-solid-svg-icons/faArrowLeft";
    import { faRedoAlt } from "@fortawesome/free-solid-svg-icons/faRedoAlt";

    import Button from "./Button.svelte";

    import state from "../state";
    import locations from "../locations";
    import type { Feed } from "../types";

    let refreshing = true;
    let categories: Promise<{ [key: string]: Feed[] }> = state.ready
        .then(() => state.categories())
        .then((feeds) => {
            refreshing = false;
            return feeds;
        });

    function refreshCategories() {
        refreshing = true;
        categories = state.categories().then((categories) => {
            refreshing = false;
            return categories;
        });
    }

    function goBack() {
        locations.pop();
    }

    function goTo(location: string) {
        return function () {
            locations.push(location);
        }
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="button-container">
            <Button on:click={goBack}><Icon icon={faArrowLeft} /></Button>
        </div>
        <div class="title-container">
            <div class="title">Categories</div>
        </div>
        <div class="button-container">
            <Button disabled={refreshing} on:click={refreshCategories}>
                <div class="refresher centered" class:refreshing>
                    <Icon icon={faRedoAlt} />
                </div>
            </Button>
        </div>
    </div>
    <div class="content-container centered">
        <div class="content vstack" style="gap: 10px">
            {#await categories}
                <div class="message">Loading categories...</div>
            {:then categories}
                {#each Object.entries(categories) as [category, feeds] (category)}
                    <div class="category-button">
                        <Button on:click={goTo(`/category/${encodeURIComponent(category)}`)}>{category}</Button>
                    </div>
                {:else}
                    <div class="message discrete">No categories.</div>
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

    .category-button {
        flex-grow: 1;

        --button-padding: 10px 20px;
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
</style>
