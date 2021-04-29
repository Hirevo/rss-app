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
        .then(() => state.feeds())
        .then((feeds) => {
            refreshing = false;
            return feeds;
        });

    function refreshFeeds() {
        refreshing = true;
        feeds = state.feeds().then((feeds) => {
            refreshing = false;
            return feeds;
        });
    }

    let url;
    let addingFeed = false;
    function openAddFeedModal() {
        addingFeed = true;
    }
    function closeAddFeedModal() {
        addingFeed = false;
    }
    function addFeed() {
        state.addFeed(url).then(() => {
            addingFeed = false;
            refreshFeeds();
        });
    }

    let contextMenuElement;
    let contextData = undefined;
    let contextTop = 0;
    let contextLeft = 0;
    function openContextMenu(feed: Feed) {
        return function (event: MouseEvent) {
            const { pageX, pageY } = event;

            contextData = {
                feed,
                items: [{
                    label: "Delete Feed",
                    handler: () => {
                        state.deleteFeed(feed.id)
                            .then(() => refreshFeeds());
                    },
                }],
            };

            contextLeft = pageX;
            contextTop = pageY;

            tick().then(() => {
                const rect = contextMenuElement.getBoundingClientRect();
                if (rect.top < 0) {
                    contextTop += rect.top;
                }
                if (rect.bottom > document.body.clientHeight) {
                    contextTop -= rect.bottom - document.body.clientHeight;
                }
                if (rect.left < 0) {
                    contextLeft += rect.left;
                }
                if (rect.right > document.body.clientWidth) {
                    contextLeft -= rect.right - document.body.clientWidth;
                }
            });
        };
    }
    function handleContextMenuItemClick(handler) {
        return function () {
            handler();
            closeContextMenu();
        };
    }
    function closeContextMenu() {
        contextData = undefined;
    }

    function deleteFeed(feed: Feed) {
        return function () {
            state.deleteFeed(feed.id).then(() => refreshFeeds());
        };
    }
</script>

<div class="root">
    <div class="navbar">
        <div class="button-container">
            <Button on:click={goBack}><Icon icon={faArrowLeft} /></Button>
        </div>
        <div class="title-container">
            <div class="title">Feeds</div>
        </div>
        <div class="button-container">
            <Button on:click={openAddFeedModal}>Add Feed</Button>
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
                    <div>
                        <div class="hstack" style="gap: 10px">
                            <div class="feed-button" on:contextmenu|preventDefault={openContextMenu(feed)}>
                                <Button on:click={goTo(`/articles/${encodeURIComponent(feed.id)}`)}>{feed.title}</Button>
                            </div>
                            <div class="delete-button">
                                <Button on:click={deleteFeed(feed)}>
                                    <Icon icon={faTimes} />
                                </Button>
                            </div>
                        </div>
                    </div>
                {:else}
                    <div class="message discrete">No feeds.</div>
                {/each}
            {/await}
        </div>
    </div>
    {#if addingFeed}
        <div class="modal-overlay centered" on:click={closeAddFeedModal}>
            <div class="add-feed-modal vstack" on:click|stopPropagation>
                <div class="add-feed-modal-label centered">
                    Add RSS Feed
                </div>
                <div>
                    <input
                        class="input"
                        type="text"
                        name="url"
                        id="url"
                        bind:value={url}
                        placeholder="Enter URL..."
                    >
                </div>
                <div>
                    <Button on:click={addFeed}>Add Feed</Button>
                </div>
            </div>
        </div>
    {/if}
    {#if contextData}
        <div class="context-overlay" on:click={closeContextMenu} />
        <div class="context-menu vstack" style={`top: ${contextTop}px; left: ${contextLeft}px;`} bind:this={contextMenuElement}>
            <div class="context-menu-size">{contextData.feed.title}</div>
            <div class="context-menu-item-container">
                {#each contextData.items as { label, handler }}
                    <div class="context-menu-item" on:click={handleContextMenuItemClick(handler)}>{label}</div>
                {/each}
            </div>
        </div>
    {/if}
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
        grid-template-columns: 75px 1fr repeat(2, min-content);
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
